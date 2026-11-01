package kz.aman.service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import kz.aman.common.ApiException;
import kz.aman.common.ErrorCode;
import kz.aman.config.AppProperties;
import kz.aman.domain.OtpCode;
import kz.aman.domain.Patient;
import kz.aman.domain.RefreshToken;
import kz.aman.domain.Role;
import kz.aman.domain.UserAccount;
import kz.aman.dto.AuthDtos.AuthResponse;
import kz.aman.dto.AuthDtos.OtpResponse;
import kz.aman.dto.AuthDtos.RegisterRequest;
import kz.aman.dto.PatientDto;
import kz.aman.repo.OtpCodeRepository;
import kz.aman.repo.PatientRepository;
import kz.aman.repo.RefreshTokenRepository;
import kz.aman.repo.UserRepository;
import kz.aman.security.JwtService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Registration, phone verification (OTP), login, token refresh and password reset. */
@Service
public class AuthService {

    private static final SecureRandom RANDOM = new SecureRandom();
    /** Pre-computed hash so that unknown phones cost the same time as wrong passwords. */
    private final String dummyHash;

    private final UserRepository users;
    private final PatientRepository patients;
    private final OtpCodeRepository otps;
    private final RefreshTokenRepository refreshTokens;
    private final PasswordEncoder encoder;
    private final JwtService jwt;
    private final AppProperties props;
    private final RateLimiter limiter;
    private final SmsSender sms;

    public AuthService(UserRepository users, PatientRepository patients, OtpCodeRepository otps,
            RefreshTokenRepository refreshTokens, PasswordEncoder encoder, JwtService jwt, AppProperties props,
            RateLimiter limiter, SmsSender sms) {
        this.users = users;
        this.patients = patients;
        this.otps = otps;
        this.refreshTokens = refreshTokens;
        this.encoder = encoder;
        this.jwt = jwt;
        this.props = props;
        this.limiter = limiter;
        this.sms = sms;
        this.dummyHash = encoder.encode("not-a-real-password-0");
    }

    @Transactional
    public OtpResponse register(RegisterRequest req) {
        if (!req.consentAccepted()) {
            throw new ApiException(ErrorCode.CONSENT_REQUIRED, "Consent to data processing is required");
        }
        limiter.check("register:" + req.phone(), 5, Duration.ofHours(1));
        UserAccount user = users.findByPhone(req.phone()).orElse(null);
        if (user != null && user.isPhoneVerified()) {
            throw new ApiException(ErrorCode.PHONE_TAKEN, "Phone number is already registered");
        }
        if (user == null) {
            user = new UserAccount(req.phone(), encoder.encode(req.password()), Role.PATIENT);
            user.setConsentAcceptedAt(Instant.now());
            users.save(user);
            Patient patient = new Patient(user, req.fullName().trim());
            patient.setAvatarSeed(Math.abs(req.phone().hashCode()) % 200);
            patients.save(patient);
        } else {
            // Unverified account: allow re-registration with fresh credentials.
            user.setPasswordHash(encoder.encode(req.password()));
            user.setConsentAcceptedAt(Instant.now());
            patients.findByUserId(user.getId()).ifPresent(p -> p.setFullName(req.fullName().trim()));
        }
        return issueOtp(req.phone());
    }

    @Transactional
    public OtpResponse requestOtp(String phone) {
        limiter.check("otp:" + phone, 5, Duration.ofMinutes(15));
        if (users.findByPhone(phone).isEmpty()) {
            throw new ApiException(ErrorCode.ACCOUNT_NOT_FOUND, "Account not found");
        }
        return issueOtp(phone);
    }

    @Transactional(noRollbackFor = ApiException.class)
    public AuthResponse verifyOtp(String phone, String code) {
        consumeOtp(phone, code);
        UserAccount user = users.findByPhone(phone)
                .orElseThrow(() -> new ApiException(ErrorCode.ACCOUNT_NOT_FOUND, "Account not found"));
        user.setPhoneVerified(true);
        return issueTokens(user);
    }

    @Transactional
    public AuthResponse login(String phone, String password) {
        limiter.check("login:" + phone, 10, Duration.ofMinutes(15));
        UserAccount user = users.findByPhone(phone).orElse(null);
        boolean ok = encoder.matches(password, user == null ? dummyHash : user.getPasswordHash());
        if (user == null || !ok || !user.isPhoneVerified() || !user.isEnabled()) {
            throw new ApiException(ErrorCode.INVALID_CREDENTIALS, "Wrong phone number or password");
        }
        limiter.reset("login:" + phone);
        return issueTokens(user);
    }

    @Transactional(noRollbackFor = ApiException.class)
    public AuthResponse refresh(String refreshToken) {
        RefreshToken stored = refreshTokens.findByTokenHash(JwtService.sha256(refreshToken))
                .orElseThrow(() -> new ApiException(ErrorCode.UNAUTHORIZED, "Invalid refresh token"));
        if (stored.isRevoked() || stored.getExpiresAt().isBefore(Instant.now()) || !stored.getUser().isEnabled()) {
            // Re-use of a rotated token signals theft: revoke the whole family.
            if (stored.isRevoked()) {
                refreshTokens.findByUserIdAndRevokedFalse(stored.getUser().getId()).forEach(t -> t.setRevoked(true));
            }
            throw new ApiException(ErrorCode.UNAUTHORIZED, "Invalid refresh token");
        }
        stored.setRevoked(true);
        return issueTokens(stored.getUser());
    }

    @Transactional
    public void logout(String refreshToken) {
        if (refreshToken == null || refreshToken.isBlank()) {
            return;
        }
        refreshTokens.findByTokenHash(JwtService.sha256(refreshToken)).ifPresent(t -> t.setRevoked(true));
    }

    @Transactional
    public OtpResponse forgotPassword(String phone) {
        limiter.check("forgot:" + phone, 5, Duration.ofMinutes(15));
        UserAccount user = users.findByPhone(phone)
                .filter(UserAccount::isPhoneVerified)
                .orElseThrow(() -> new ApiException(ErrorCode.ACCOUNT_NOT_FOUND, "Account not found"));
        return issueOtp(user.getPhone());
    }

    @Transactional(noRollbackFor = ApiException.class)
    public void resetPassword(String phone, String code, String newPassword) {
        consumeOtp(phone, code);
        UserAccount user = users.findByPhone(phone)
                .orElseThrow(() -> new ApiException(ErrorCode.ACCOUNT_NOT_FOUND, "Account not found"));
        user.setPasswordHash(encoder.encode(newPassword));
        refreshTokens.findByUserIdAndRevokedFalse(user.getId()).forEach(t -> t.setRevoked(true));
    }

    // --- internals -------------------------------------------------------

    private OtpResponse issueOtp(String phone) {
        String code = String.format("%04d", RANDOM.nextInt(10_000));
        OtpCode otp = new OtpCode();
        otp.setPhone(phone);
        otp.setCodeHash(hmac(phone + ":" + code));
        otp.setExpiresAt(Instant.now().plus(props.otp().ttl()));
        otps.save(otp);
        sms.send(phone, "AMAN: " + code);
        return new OtpResponse(true, props.otp().exposeDemoCode() ? code : null);
    }

    private void consumeOtp(String phone, String code) {
        OtpCode otp = otps.findFirstByPhoneAndConsumedFalseOrderByIdDesc(phone)
                .orElseThrow(() -> new ApiException(ErrorCode.INVALID_OTP, "Invalid or expired code"));
        if (otp.getExpiresAt().isBefore(Instant.now()) || otp.getAttempts() >= props.otp().maxAttempts()) {
            otp.setConsumed(true);
            throw new ApiException(ErrorCode.INVALID_OTP, "Invalid or expired code");
        }
        boolean match = MessageDigest.isEqual(
                otp.getCodeHash().getBytes(StandardCharsets.UTF_8), hmac(phone + ":" + code).getBytes(StandardCharsets.UTF_8));
        if (!match) {
            otp.setAttempts(otp.getAttempts() + 1);
            otps.save(otp);
            throw new ApiException(ErrorCode.INVALID_OTP, "Invalid or expired code");
        }
        otp.setConsumed(true);
    }

    private AuthResponse issueTokens(UserAccount user) {
        String refresh = jwt.newRefreshToken();
        RefreshToken token = new RefreshToken();
        token.setUser(user);
        token.setTokenHash(JwtService.sha256(refresh));
        token.setExpiresAt(Instant.now().plus(props.jwt().refreshTtl()));
        refreshTokens.save(token);
        Patient patient = patients.findByUserId(user.getId()).orElse(null);
        return new AuthResponse(jwt.createAccessToken(user.getId(), user.getRole()), refresh,
                props.jwt().accessTtl().toSeconds(), patient == null ? null : PatientDto.from(patient));
    }

    private String hmac(String value) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(props.jwt().secret().getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            return java.util.HexFormat.of().formatHex(mac.doFinal(value.getBytes(StandardCharsets.UTF_8)));
        } catch (java.security.GeneralSecurityException e) {
            throw new IllegalStateException(e);
        }
    }
}
