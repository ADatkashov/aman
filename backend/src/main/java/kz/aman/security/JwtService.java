package kz.aman.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;
import java.util.Date;
import java.util.HexFormat;
import java.util.Optional;
import javax.crypto.SecretKey;
import kz.aman.config.AppProperties;
import kz.aman.domain.Role;
import org.springframework.stereotype.Service;

/** Issues and verifies short-lived access tokens (HS256) and opaque refresh tokens. */
@Service
public class JwtService {

    private static final SecureRandom RANDOM = new SecureRandom();

    private final AppProperties.Jwt props;
    private final SecretKey key;

    public JwtService(AppProperties props) {
        this.props = props.jwt();
        String secret = this.props.secret();
        if (secret == null || secret.getBytes(StandardCharsets.UTF_8).length < 32) {
            throw new IllegalStateException(
                    "aman.jwt.secret (AMAN_JWT_SECRET) must be set to at least 32 bytes");
        }
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    public String createAccessToken(long userId, Role role) {
        Instant now = Instant.now();
        return Jwts.builder()
                .issuer(props.issuer())
                .subject(Long.toString(userId))
                .claim("role", role.name())
                .claim("typ", "access")
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plus(props.accessTtl())))
                .signWith(key)
                .compact();
    }

    public Optional<AmanPrincipal> parseAccessToken(String token) {
        try {
            Claims c = Jwts.parser().verifyWith(key).requireIssuer(props.issuer()).build()
                    .parseSignedClaims(token).getPayload();
            if (!"access".equals(c.get("typ", String.class))) {
                return Optional.empty();
            }
            return Optional.of(new AmanPrincipal(Long.parseLong(c.getSubject()), Role.valueOf(c.get("role", String.class))));
        } catch (JwtException | IllegalArgumentException e) {
            return Optional.empty();
        }
    }

    /** 256-bit random opaque token (URL-safe). Only its hash is stored. */
    public String newRefreshToken() {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    public static String sha256(String value) {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }
}
