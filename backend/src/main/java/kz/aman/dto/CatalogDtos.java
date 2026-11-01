package kz.aman.dto;

import java.time.Instant;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import kz.aman.domain.Clinic;
import kz.aman.domain.ClinicService;
import kz.aman.domain.Doctor;
import kz.aman.domain.DoctorService;
import kz.aman.domain.Loc;

public final class CatalogDtos {

    private CatalogDtos() {}

    public record ServiceDto(Loc name, int priceKzt) {}

    public record DoctorDto(
            Long id,
            String fullName,
            String specialty,
            Long clinicId,
            int experienceYears,
            double rating,
            int reviewsCount,
            int priceKzt,
            Loc education,
            Loc qualification,
            Loc about,
            List<String> languages,
            List<ServiceDto> services,
            int avatarSeed,
            boolean female,
            String photoUrl) {

        public static DoctorDto from(Doctor d) {
            return new DoctorDto(d.getId(), d.getFullName(), d.getSpecialty().getCode(), d.getClinic().getId(),
                    d.getExperienceYears(), d.getRating(), d.getReviewsCount(), d.getPriceKzt(), d.getEducation(),
                    d.getQualification(), d.getAbout(), Arrays.asList(d.getLanguages().split(",")),
                    d.getServices().stream().map((DoctorService s) -> new ServiceDto(s.getName(), s.getPriceKzt())).toList(),
                    d.getAvatarSeed(), d.isFemale(), d.getPhotoUrl());
        }
    }

    public record ClinicDto(
            Long id,
            String name,
            String city,
            String address,
            double latitude,
            double longitude,
            String phone,
            double rating,
            int reviewsCount,
            Loc workingHours,
            List<ServiceDto> services,
            int imageSeed,
            int changeDeadlineHours,
            boolean demo) {

        public static ClinicDto from(Clinic c) {
            return new ClinicDto(c.getId(), c.getName(), c.getCity(), c.getAddress(), c.getLatitude(), c.getLongitude(),
                    c.getPhone(), c.getRating(), c.getReviewsCount(), c.getWorkingHours(),
                    c.getServices().stream().map((ClinicService s) -> new ServiceDto(s.getName(), s.getPriceKzt())).toList(),
                    c.getImageSeed(), c.getChangeDeadlineHours(), c.isDemo());
        }
    }

    public record ReviewDto(Long id, Long doctorId, String author, int rating, String text, LocalDate date) {}

    public record SlotDto(Instant start, boolean available) {}

    public record NextSlotDto(Instant start) {}
}
