package kz.aman.config;

import java.time.Duration;
import java.time.ZoneId;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Application settings ({@code aman.*}). Secrets come from the environment
 * and are never committed.
 */
@ConfigurationProperties(prefix = "aman")
public record AppProperties(Jwt jwt, Otp otp, Storage storage, Booking booking, Cors cors) {

    public record Jwt(String secret, Duration accessTtl, Duration refreshTtl, String issuer) {}

    /** {@code exposeDemoCode} returns the OTP in API responses: demo/dev ONLY. */
    public record Otp(boolean exposeDemoCode, Duration ttl, int maxAttempts) {}

    public record Storage(String dir) {}

    public record Booking(ZoneId zone, Duration leadTime, int horizonDays) {}

    public record Cors(java.util.List<String> allowedOrigins) {}
}
