package kz.aman.web;

import jakarta.validation.Valid;
import kz.aman.dto.AuthDtos.AuthResponse;
import kz.aman.dto.AuthDtos.LoginRequest;
import kz.aman.dto.AuthDtos.LogoutRequest;
import kz.aman.dto.AuthDtos.OtpResponse;
import kz.aman.dto.AuthDtos.PhoneRequest;
import kz.aman.dto.AuthDtos.RefreshRequest;
import kz.aman.dto.AuthDtos.RegisterRequest;
import kz.aman.dto.AuthDtos.ResetPasswordRequest;
import kz.aman.dto.AuthDtos.VerifyOtpRequest;
import kz.aman.service.AuthService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    private final AuthService auth;

    public AuthController(AuthService auth) {
        this.auth = auth;
    }

    /** Creates an unverified account and sends an OTP to the phone. */
    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public OtpResponse register(@Valid @RequestBody RegisterRequest request) {
        return auth.register(request);
    }

    @PostMapping("/otp/request")
    public OtpResponse requestOtp(@Valid @RequestBody PhoneRequest request) {
        return auth.requestOtp(request.phone());
    }

    /** Confirms the phone and signs the user in. */
    @PostMapping("/otp/verify")
    public AuthResponse verifyOtp(@Valid @RequestBody VerifyOtpRequest request) {
        return auth.verifyOtp(request.phone(), request.code());
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request) {
        return auth.login(request.phone(), request.password());
    }

    @PostMapping("/refresh")
    public AuthResponse refresh(@Valid @RequestBody RefreshRequest request) {
        return auth.refresh(request.refreshToken());
    }

    @PostMapping("/logout")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void logout(@RequestBody(required = false) LogoutRequest request) {
        auth.logout(request == null ? null : request.refreshToken());
    }

    @PostMapping("/password/forgot")
    public OtpResponse forgot(@Valid @RequestBody PhoneRequest request) {
        return auth.forgotPassword(request.phone());
    }

    @PostMapping("/password/reset")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void reset(@Valid @RequestBody ResetPasswordRequest request) {
        auth.resetPassword(request.phone(), request.code(), request.newPassword());
    }
}
