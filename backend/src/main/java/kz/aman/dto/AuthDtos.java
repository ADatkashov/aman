package kz.aman.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public final class AuthDtos {

    private AuthDtos() {}

    public static final String PHONE = "^\\+7\\d{10}$";
    public static final String PASSWORD = "^(?=.*\\p{L})(?=.*\\d).{8,72}$";

    public record RegisterRequest(
            @NotBlank @Size(min = 3, max = 200) String fullName,
            @NotBlank @Pattern(regexp = PHONE, message = "must be +7XXXXXXXXXX") String phone,
            @NotBlank @Pattern(regexp = PASSWORD, message = "8-72 chars with a letter and a digit") String password,
            boolean consentAccepted) {}

    public record PhoneRequest(@NotBlank @Pattern(regexp = PHONE, message = "must be +7XXXXXXXXXX") String phone) {}

    public record VerifyOtpRequest(
            @NotBlank @Pattern(regexp = PHONE) String phone,
            @NotBlank @Pattern(regexp = "^\\d{4}$", message = "must be 4 digits") String code) {}

    public record LoginRequest(
            @NotBlank @Pattern(regexp = PHONE) String phone, @NotBlank @Size(max = 72) String password) {}

    public record RefreshRequest(@NotBlank String refreshToken) {}

    public record LogoutRequest(String refreshToken) {}

    public record ResetPasswordRequest(
            @NotBlank @Pattern(regexp = PHONE) String phone,
            @NotBlank @Pattern(regexp = "^\\d{4}$") String code,
            @NotBlank @Pattern(regexp = PASSWORD, message = "8-72 chars with a letter and a digit") String newPassword) {}

    /** {@code demoOtp} is present only when {@code aman.otp.expose-demo-code=true}. */
    public record OtpResponse(boolean otpSent, String demoOtp) {}

    public record AuthResponse(String accessToken, String refreshToken, long expiresInSeconds, PatientDto patient) {}
}
