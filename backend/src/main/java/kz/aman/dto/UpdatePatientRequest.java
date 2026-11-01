package kz.aman.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;

public record UpdatePatientRequest(
        @NotBlank @Size(min = 3, max = 200) String fullName,
        @Email @Size(max = 200) String email,
        @Past LocalDate birthDate,
        @Pattern(regexp = "^(MALE|FEMALE)$", flags = Pattern.Flag.CASE_INSENSITIVE) String gender,
        @Size(max = 20) String bloodType,
        @Size(max = 100) String city) {}
