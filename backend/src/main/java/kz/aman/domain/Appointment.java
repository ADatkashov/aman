package kz.aman.domain;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "appointments",
    indexes = {@Index(name = "idx_appt_patient_start", columnList = "patient_id, start_at"), @Index(name = "idx_appt_doctor_start", columnList = "doctor_id, start_at")})
public class Appointment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "number", nullable = false, unique = true, length = 32)
    private String number;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "doctor_id", nullable = false)
    private Doctor doctor;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "clinic_id", nullable = false)
    private Clinic clinic;

    @Column(name = "start_at", nullable = false)
    private Instant startAt;

    @Column(name = "duration_minutes", nullable = false)
    private int durationMinutes;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private AppointmentStatus status;

    @Column(name = "reason", length = 300)
    private String reason;

    @Column(name = "price_kzt", nullable = false)
    private int priceKzt;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "rescheduled_count", nullable = false)
    private int rescheduledCount;

    @Column(name = "cancel_reason", length = 300)
    private String cancelReason;

    @Column(name = "review_rating")
    private Integer reviewRating;

    /** `doctorId:epochSecond` while the visit is active, `null` otherwise: a unique key forbids double booking. */
    @Column(name = "active_slot_key", unique = true, length = 64)
    private String activeSlotKey;

    protected Appointment() {}

    public Long getId() { return id; }
    public String getNumber() { return number; }
    public void setNumber(String number) { this.number = number; }
    public Patient getPatient() { return patient; }
    public void setPatient(Patient patient) { this.patient = patient; }
    public Doctor getDoctor() { return doctor; }
    public void setDoctor(Doctor doctor) { this.doctor = doctor; }
    public Clinic getClinic() { return clinic; }
    public void setClinic(Clinic clinic) { this.clinic = clinic; }
    public Instant getStartAt() { return startAt; }
    public void setStartAt(Instant startAt) { this.startAt = startAt; }
    public int getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(int durationMinutes) { this.durationMinutes = durationMinutes; }
    public AppointmentStatus getStatus() { return status; }
    public void setStatus(AppointmentStatus status) { this.status = status; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public int getPriceKzt() { return priceKzt; }
    public void setPriceKzt(int priceKzt) { this.priceKzt = priceKzt; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
    public int getRescheduledCount() { return rescheduledCount; }
    public void setRescheduledCount(int rescheduledCount) { this.rescheduledCount = rescheduledCount; }
    public String getCancelReason() { return cancelReason; }
    public void setCancelReason(String cancelReason) { this.cancelReason = cancelReason; }
    public Integer getReviewRating() { return reviewRating; }
    public void setReviewRating(Integer reviewRating) { this.reviewRating = reviewRating; }
    public String getActiveSlotKey() { return activeSlotKey; }
    public void setActiveSlotKey(String activeSlotKey) { this.activeSlotKey = activeSlotKey; }
}
