package kz.aman.service;

import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import kz.aman.common.ApiException;
import kz.aman.common.ErrorCode;
import kz.aman.config.AppProperties;
import kz.aman.domain.Appointment;
import kz.aman.domain.AppointmentStatus;
import kz.aman.domain.Doctor;
import kz.aman.domain.DoctorReview;
import kz.aman.domain.DoctorSchedule;
import kz.aman.domain.Patient;
import kz.aman.dto.AppointmentDtos.AppointmentDto;
import kz.aman.repo.AppointmentRepository;
import kz.aman.repo.DoctorRepository;
import kz.aman.repo.DoctorScheduleRepository;
import kz.aman.repo.PatientRepository;
import kz.aman.repo.ReviewRepository;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Booking use cases. All invariants live here and in the database:
 * a slot must be offered by the doctor's schedule, lie in the future and be
 * free; the unique {@code active_slot_key} makes double booking impossible
 * even for concurrent requests.
 */
@Service
public class AppointmentService {

    private static final DateTimeFormatter DAY = DateTimeFormatter.ofPattern("yyMMdd");

    private final AppointmentRepository appointments;
    private final DoctorRepository doctors;
    private final DoctorScheduleRepository schedules;
    private final PatientRepository patients;
    private final ReviewRepository reviews;
    private final NotificationService notifications;
    private final AppProperties props;

    public AppointmentService(AppointmentRepository appointments, DoctorRepository doctors,
            DoctorScheduleRepository schedules, PatientRepository patients, ReviewRepository reviews,
            NotificationService notifications, AppProperties props) {
        this.appointments = appointments;
        this.doctors = doctors;
        this.schedules = schedules;
        this.patients = patients;
        this.reviews = reviews;
        this.notifications = notifications;
        this.props = props;
    }

    @Transactional(readOnly = true)
    public List<AppointmentDto> list(Long patientId) {
        return appointments.findByPatientIdOrderByStartAtDesc(patientId).stream().map(AppointmentDto::from).toList();
    }

    @Transactional(readOnly = true)
    public AppointmentDto get(Long patientId, Long id) {
        return AppointmentDto.from(owned(patientId, id));
    }

    @Transactional
    public AppointmentDto create(Long patientId, Long doctorId, Instant start, String reason) {
        Patient patient = patients.findById(patientId).orElseThrow(() -> ApiException.notFound("Patient"));
        Doctor doctor = doctors.findWithDetailsById(doctorId).orElseThrow(() -> ApiException.notFound("Doctor"));
        List<DoctorSchedule> weekly = schedules.findByDoctorId(doctorId);
        validateSlot(weekly, start);
        String key = ScheduleCalculator.slotKey(doctorId, start);
        if (appointments.existsByActiveSlotKey(key)) {
            throw slotTaken();
        }
        DoctorSchedule day = weekly.stream()
                .filter(s -> s.getWeekday() == start.atZone(zone()).getDayOfWeek().getValue()).findFirst().orElseThrow();

        Appointment a = new Appointment();
        a.setNumber("TMP-" + java.util.UUID.randomUUID().toString().replace("-", "").substring(0, 20));
        a.setPatient(patient);
        a.setDoctor(doctor);
        a.setClinic(doctor.getClinic());
        a.setStartAt(start);
        a.setDurationMinutes(day.getSlotMinutes());
        a.setStatus(AppointmentStatus.CONFIRMED);
        a.setReason(reason.trim());
        a.setPriceKzt(doctor.getPriceKzt());
        a.setCreatedAt(Instant.now());
        a.setActiveSlotKey(key);
        try {
            appointments.saveAndFlush(a);
        } catch (DataIntegrityViolationException e) {
            throw translate(e);
        }
        a.setNumber("AM-" + LocalDate.now(zone()).format(DAY) + "-" + (1000 + a.getId()));
        notifications.publish(patient, "APPOINTMENT_CREATED",
                Map.of("doctor", shortName(doctor), "start", start.toString(), "number", a.getNumber()),
                "/appointments/" + a.getId());
        return AppointmentDto.from(a);
    }

    @Transactional
    public AppointmentDto cancel(Long patientId, Long id, String reason) {
        Appointment a = owned(patientId, id);
        requireChangeable(a);
        a.setStatus(AppointmentStatus.CANCELLED);
        a.setActiveSlotKey(null);
        a.setCancelReason(reason == null || reason.isBlank() ? null : reason.trim());
        notifications.publish(a.getPatient(), "APPOINTMENT_CANCELLED",
                Map.of("doctor", shortName(a.getDoctor()), "start", a.getStartAt().toString(), "number", a.getNumber()),
                "/appointments/" + a.getId());
        return AppointmentDto.from(a);
    }

    @Transactional
    public AppointmentDto reschedule(Long patientId, Long id, Instant newStart) {
        Appointment a = owned(patientId, id);
        requireChangeable(a);
        Long doctorId = a.getDoctor().getId();
        validateSlot(schedules.findByDoctorId(doctorId), newStart);
        String key = ScheduleCalculator.slotKey(doctorId, newStart);
        if (!key.equals(a.getActiveSlotKey()) && appointments.existsByActiveSlotKey(key)) {
            throw slotTaken();
        }
        a.setStartAt(newStart);
        a.setActiveSlotKey(key);
        a.setRescheduledCount(a.getRescheduledCount() + 1);
        try {
            appointments.saveAndFlush(a);
        } catch (DataIntegrityViolationException e) {
            throw translate(e);
        }
        notifications.publish(a.getPatient(), "APPOINTMENT_RESCHEDULED",
                Map.of("doctor", shortName(a.getDoctor()), "start", newStart.toString(), "number", a.getNumber()),
                "/appointments/" + a.getId());
        return AppointmentDto.from(a);
    }

    @Transactional
    public AppointmentDto review(Long patientId, Long id, int rating, String text) {
        Appointment a = owned(patientId, id);
        Instant end = a.getStartAt().plus(Duration.ofMinutes(a.getDurationMinutes()));
        boolean finished = a.getStatus() == AppointmentStatus.COMPLETED
                || (a.getStatus() == AppointmentStatus.CONFIRMED && end.isBefore(Instant.now()));
        if (!finished) {
            throw new ApiException(ErrorCode.NOT_COMPLETED, "A review is possible after the visit");
        }
        if (a.getReviewRating() != null) {
            throw new ApiException(ErrorCode.ALREADY_REVIEWED, "The visit has already been reviewed");
        }
        DoctorReview r = new DoctorReview();
        r.setAppointment(a);
        r.setDoctor(a.getDoctor());
        r.setPatient(a.getPatient());
        r.setRating(rating);
        r.setText(text == null || text.isBlank() ? null : text.trim());
        r.setCreatedAt(Instant.now());
        reviews.save(r);
        a.setReviewRating(rating);
        Doctor d = a.getDoctor();
        double total = d.getRating() * d.getReviewsCount() + rating;
        d.setReviewsCount(d.getReviewsCount() + 1);
        d.setRating(Math.round(total / d.getReviewsCount() * 10.0) / 10.0);
        return AppointmentDto.from(a);
    }

    // --- rules -----------------------------------------------------------

    private void validateSlot(List<DoctorSchedule> weekly, Instant start) {
        Instant now = Instant.now();
        if (!start.isAfter(now.plus(props.booking().leadTime()))) {
            throw new ApiException(ErrorCode.SLOT_IN_PAST, "This time is no longer available");
        }
        LocalDate day = start.atZone(zone()).toLocalDate();
        LocalDate today = LocalDate.now(zone());
        if (day.isAfter(today.plusDays(props.booking().horizonDays()))
                || !ScheduleCalculator.isOffered(weekly, start, zone())) {
            throw new ApiException(ErrorCode.OUTSIDE_SCHEDULE, "The time is outside the doctor's schedule");
        }
    }

    private void requireChangeable(Appointment a) {
        boolean confirmed = a.getStatus() == AppointmentStatus.CONFIRMED;
        Duration left = Duration.between(Instant.now(), a.getStartAt());
        if (!confirmed || left.compareTo(Duration.ofHours(a.getClinic().getChangeDeadlineHours())) < 0) {
            throw new ApiException(ErrorCode.TOO_LATE_TO_CHANGE,
                    "Changes are possible at least " + a.getClinic().getChangeDeadlineHours() + " h before the visit");
        }
    }

    /** Ownership is part of the query: another patient's id yields 404, never data. */
    private Appointment owned(Long patientId, Long id) {
        return appointments.findByIdAndPatientId(id, patientId).orElseThrow(() -> ApiException.notFound("Appointment"));
    }

    /** SQLSTATE 23505 = unique violation: somebody else holds the slot. Other violations are bugs. */
    private RuntimeException translate(DataIntegrityViolationException e) {
        Throwable cause = e;
        while (cause != null) {
            if (cause instanceof java.sql.SQLException sql && "23505".equals(sql.getSQLState())) {
                return slotTaken();
            }
            cause = cause.getCause();
        }
        return e;
    }

    private ApiException slotTaken() {
        return new ApiException(ErrorCode.SLOT_TAKEN, "This time has just been booked");
    }

    private ZoneId zone() {
        return props.booking().zone();
    }

    private static String shortName(Doctor d) {
        String[] p = d.getFullName().split(" ");
        return p.length < 2 ? d.getFullName() : p[0] + " " + p[1].charAt(0) + ".";
    }
}
