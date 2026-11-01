package kz.aman.domain;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "notifications",
    indexes = @Index(name = "idx_notifications_patient", columnList = "patient_id, created_at"))
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;

    @Column(name = "type", nullable = false, length = 40)
    private String type;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "is_read", nullable = false)
    private boolean read;

    /** Template parameters only (doctor, start, number); never medical content. */
    @Column(name = "params_json", columnDefinition = "text")
    private String paramsJson;

    @Column(name = "route", length = 200)
    private String route;

    public Notification() {}

    public Long getId() { return id; }
    public Patient getPatient() { return patient; }
    public void setPatient(Patient patient) { this.patient = patient; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
    public boolean isRead() { return read; }
    public void setRead(boolean read) { this.read = read; }
    public String getParamsJson() { return paramsJson; }
    public void setParamsJson(String paramsJson) { this.paramsJson = paramsJson; }
    public String getRoute() { return route; }
    public void setRoute(String route) { this.route = route; }
}
