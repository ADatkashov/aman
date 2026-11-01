package kz.aman.dto;

import java.time.LocalDate;
import kz.aman.domain.Patient;

public record PatientDto(
        Long id,
        String fullName,
        String phone,
        String email,
        LocalDate birthDate,
        String gender,
        String bloodType,
        String city,
        int avatarSeed) {

    public static PatientDto from(Patient p) {
        return new PatientDto(p.getId(), p.getFullName(), p.getUser().getPhone(), p.getEmail(), p.getBirthDate(),
                p.getGender(), p.getBloodType(), p.getCity(), p.getAvatarSeed());
    }
}
