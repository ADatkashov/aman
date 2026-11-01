package kz.aman.dto;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import kz.aman.domain.Loc;

public final class HealthDtos {

    private HealthDtos() {}

    public record LabIndicatorDto(Loc name, double value, String unit, Double refMin, Double refMax) {}

    public record LabResultDto(
            Long id,
            String testCode,
            String category,
            Loc name,
            LocalDate date,
            String laboratory,
            String status,
            List<LabIndicatorDto> indicators,
            Long documentId) {}

    public record LabOrderDto(Long id, Loc name, String category, String doctorName, LocalDate date, String status) {}

    public record MedicalEntryDto(
            Long id, String type, LocalDate date, Loc title, Loc details, String doctorName, String sourceRef) {}

    public record DocumentDto(
            Long id,
            String title,
            String kind,
            String fileName,
            String mimeType,
            long sizeBytes,
            Instant uploadedAt,
            boolean uploadedByPatient) {}

    public record NotificationDto(
            Long id, String type, Instant createdAt, boolean read, Map<String, String> params, String route) {}
}
