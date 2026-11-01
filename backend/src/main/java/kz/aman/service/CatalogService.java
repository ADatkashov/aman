package kz.aman.service;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import kz.aman.common.ApiException;
import kz.aman.config.AppProperties;
import kz.aman.domain.DoctorReview;
import kz.aman.domain.DoctorSchedule;
import kz.aman.dto.CatalogDtos.ClinicDto;
import kz.aman.dto.CatalogDtos.DoctorDto;
import kz.aman.dto.CatalogDtos.ReviewDto;
import kz.aman.dto.CatalogDtos.SlotDto;
import kz.aman.repo.AppointmentRepository;
import kz.aman.repo.ClinicRepository;
import kz.aman.repo.DoctorRepository;
import kz.aman.repo.DoctorScheduleRepository;
import kz.aman.repo.ReviewRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Read-only catalog: doctors, clinics, reviews and free slots. */
@Service
@Transactional(readOnly = true)
public class CatalogService {

    private final DoctorRepository doctors;
    private final ClinicRepository clinics;
    private final DoctorScheduleRepository schedules;
    private final AppointmentRepository appointments;
    private final ReviewRepository reviews;
    private final AppProperties props;

    public CatalogService(DoctorRepository doctors, ClinicRepository clinics, DoctorScheduleRepository schedules,
            AppointmentRepository appointments, ReviewRepository reviews, AppProperties props) {
        this.doctors = doctors;
        this.clinics = clinics;
        this.schedules = schedules;
        this.appointments = appointments;
        this.reviews = reviews;
        this.props = props;
    }

    public List<DoctorDto> doctors(String specialty, Long clinicId, String q) {
        String query = q == null || q.isBlank() ? null : q.trim();
        String sp = specialty == null || specialty.isBlank() ? null : specialty.trim().toLowerCase();
        return doctors.search(sp, clinicId, query).stream().map(DoctorDto::from).toList();
    }

    public DoctorDto doctor(Long id) {
        return DoctorDto.from(doctors.findWithDetailsById(id).orElseThrow(() -> ApiException.notFound("Doctor")));
    }

    public List<ClinicDto> clinics() {
        return clinics.findAllByOrderByIdAsc().stream().map(ClinicDto::from).toList();
    }

    public ClinicDto clinic(Long id) {
        return ClinicDto.from(clinics.findWithServicesById(id).orElseThrow(() -> ApiException.notFound("Clinic")));
    }

    public List<ReviewDto> reviews(Long doctorId) {
        if (!doctors.existsById(doctorId)) {
            throw ApiException.notFound("Doctor");
        }
        return reviews.findTop20ByDoctorIdOrderByCreatedAtDesc(doctorId).stream().map(this::toDto).toList();
    }

    /** All slots of [date] in the clinic time zone with availability. */
    public List<SlotDto> slots(Long doctorId, LocalDate date) {
        if (!doctors.existsById(doctorId)) {
            throw ApiException.notFound("Doctor");
        }
        ZoneId zone = props.booking().zone();
        LocalDate today = LocalDate.now(zone);
        if (date.isBefore(today) || date.isAfter(today.plusDays(props.booking().horizonDays()))) {
            return List.of();
        }
        List<DoctorSchedule> weekly = schedules.findByDoctorId(doctorId);
        Instant dayStart = date.atStartOfDay(zone).toInstant();
        Set<Instant> booked = new HashSet<>(appointments.activeStarts(doctorId, dayStart, date.plusDays(1).atStartOfDay(zone).toInstant()));
        Instant earliest = Instant.now().plus(props.booking().leadTime());
        return ScheduleCalculator.templateStarts(weekly, date, zone).stream()
                .sorted()
                .map(s -> new SlotDto(s, s.isAfter(earliest) && !booked.contains(s)))
                .toList();
    }

    public Optional<Instant> nextSlot(Long doctorId) {
        if (!doctors.existsById(doctorId)) {
            throw ApiException.notFound("Doctor");
        }
        ZoneId zone = props.booking().zone();
        LocalDate day = LocalDate.now(zone);
        for (int i = 0; i <= 21; i++) {
            Optional<SlotDto> free = slots(doctorId, day.plusDays(i)).stream().filter(SlotDto::available).findFirst();
            if (free.isPresent()) {
                return Optional.of(free.get().start());
            }
        }
        return Optional.empty();
    }

    private ReviewDto toDto(DoctorReview r) {
        String[] parts = r.getPatient().getFullName().trim().split("\\s+");
        String author = parts.length > 1 ? parts[1] + " " + parts[0].charAt(0) + "." : parts[0];
        return new ReviewDto(r.getId(), r.getDoctor().getId(), author, r.getRating(), r.getText(),
                r.getCreatedAt().atZone(props.booking().zone()).toLocalDate());
    }
}
