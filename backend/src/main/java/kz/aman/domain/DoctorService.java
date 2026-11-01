package kz.aman.domain;

import jakarta.persistence.*;

@Entity
@Table(name = "doctor_services",
    indexes = @Index(name = "idx_doctor_services_doctor", columnList = "doctor_id"))
public class DoctorService {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "doctor_id", nullable = false)
    private Doctor doctor;

    @Convert(converter = LocConverter.class)
    @Column(columnDefinition = "text")
    private Loc name;

    @Column(name = "price_kzt", nullable = false)
    private int priceKzt;

    public DoctorService() {}

    public Long getId() { return id; }
    public Doctor getDoctor() { return doctor; }
    public void setDoctor(Doctor doctor) { this.doctor = doctor; }
    public Loc getName() { return name; }
    public void setName(Loc name) { this.name = name; }
    public int getPriceKzt() { return priceKzt; }
    public void setPriceKzt(int priceKzt) { this.priceKzt = priceKzt; }
}
