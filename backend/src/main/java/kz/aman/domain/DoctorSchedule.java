package kz.aman.domain;

import jakarta.persistence.*;

@Entity
@Table(name = "doctor_schedules",
    uniqueConstraints = @UniqueConstraint(name = "uq_schedule_doctor_weekday", columnNames = {"doctor_id", "weekday"}))
public class DoctorSchedule {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "doctor_id", nullable = false)
    private Doctor doctor;

    @Column(name = "weekday", nullable = false)
    private int weekday;

    @Column(name = "start_minute", nullable = false)
    private int startMinute;

    @Column(name = "end_minute", nullable = false)
    private int endMinute;

    @Column(name = "slot_minutes", nullable = false)
    private int slotMinutes;

    @Column(name = "break_start_minute")
    private Integer breakStartMinute;

    @Column(name = "break_end_minute")
    private Integer breakEndMinute;

    public DoctorSchedule() {}

    public Long getId() { return id; }
    public Doctor getDoctor() { return doctor; }
    public void setDoctor(Doctor doctor) { this.doctor = doctor; }
    public int getWeekday() { return weekday; }
    public void setWeekday(int weekday) { this.weekday = weekday; }
    public int getStartMinute() { return startMinute; }
    public void setStartMinute(int startMinute) { this.startMinute = startMinute; }
    public int getEndMinute() { return endMinute; }
    public void setEndMinute(int endMinute) { this.endMinute = endMinute; }
    public int getSlotMinutes() { return slotMinutes; }
    public void setSlotMinutes(int slotMinutes) { this.slotMinutes = slotMinutes; }
    public Integer getBreakStartMinute() { return breakStartMinute; }
    public void setBreakStartMinute(Integer breakStartMinute) { this.breakStartMinute = breakStartMinute; }
    public Integer getBreakEndMinute() { return breakEndMinute; }
    public void setBreakEndMinute(Integer breakEndMinute) { this.breakEndMinute = breakEndMinute; }
}
