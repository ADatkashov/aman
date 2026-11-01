package kz.aman.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import kz.aman.domain.Appointment;

public final class AppointmentDtos {

    private AppointmentDtos() {}

    public record CreateRequest(
            @NotNull Long doctorId,
            @NotNull Instant start,
            @NotBlank @Size(min = 3, max = 300) String reason) {}

    public record CancelRequest(@Size(max = 300) String reason) {}

    public record RescheduleRequest(@NotNull Instant start) {}

    public record ReviewRequest(@Min(1) @Max(5) int rating, @Size(max = 1000) String text) {}

    public record AppointmentDto(
            Long id,
            String number,
            Long doctorId,
            Long clinicId,
            Instant start,
            int durationMinutes,
            String status,
            String reason,
            int priceKzt,
            Instant createdAt,
            int rescheduledCount,
            String cancelReason,
            Integer reviewRating) {

        public static AppointmentDto from(Appointment a) {
            return new AppointmentDto(a.getId(), a.getNumber(), a.getDoctor().getId(), a.getClinic().getId(), a.getStartAt(),
                    a.getDurationMinutes(), a.getStatus().name(), a.getReason(), a.getPriceKzt(), a.getCreatedAt(),
                    a.getRescheduledCount(), a.getCancelReason(), a.getReviewRating());
        }
    }
}
