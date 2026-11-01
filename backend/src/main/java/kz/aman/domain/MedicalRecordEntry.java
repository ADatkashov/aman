package kz.aman.domain;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "medical_record_entries",
    indexes = @Index(name = "idx_record_patient_date", columnList = "patient_id, entry_date"))
public class MedicalRecordEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;

    @Column(name = "type", nullable = false, length = 30)
    private String type;

    @Column(name = "entry_date", nullable = false)
    private LocalDate entryDate;

    @Convert(converter = LocConverter.class)
    @Column(columnDefinition = "text")
    private Loc title;

    @Convert(converter = LocConverter.class)
    @Column(columnDefinition = "text")
    private Loc details;

    @Column(name = "doctor_name", length = 200)
    private String doctorName;

    @Column(name = "source_ref", nullable = false, length = 64)
    private String sourceRef;

    protected MedicalRecordEntry() {}

    public Long getId() { return id; }
    public Patient getPatient() { return patient; }
    public void setPatient(Patient patient) { this.patient = patient; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public LocalDate getEntryDate() { return entryDate; }
    public void setEntryDate(LocalDate entryDate) { this.entryDate = entryDate; }
    public Loc getTitle() { return title; }
    public void setTitle(Loc title) { this.title = title; }
    public Loc getDetails() { return details; }
    public void setDetails(Loc details) { this.details = details; }
    public String getDoctorName() { return doctorName; }
    public void setDoctorName(String doctorName) { this.doctorName = doctorName; }
    public String getSourceRef() { return sourceRef; }
    public void setSourceRef(String sourceRef) { this.sourceRef = sourceRef; }
}
