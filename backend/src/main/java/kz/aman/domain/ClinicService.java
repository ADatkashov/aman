package kz.aman.domain;

import jakarta.persistence.*;

@Entity
@Table(name = "clinic_services",
    indexes = @Index(name = "idx_clinic_services_clinic", columnList = "clinic_id"))
public class ClinicService {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "clinic_id", nullable = false)
    private Clinic clinic;

    @Convert(converter = LocConverter.class)
    @Column(columnDefinition = "text")
    private Loc name;

    @Column(name = "price_kzt", nullable = false)
    private int priceKzt;

    public ClinicService() {}

    public Long getId() { return id; }
    public Clinic getClinic() { return clinic; }
    public void setClinic(Clinic clinic) { this.clinic = clinic; }
    public Loc getName() { return name; }
    public void setName(Loc name) { this.name = name; }
    public int getPriceKzt() { return priceKzt; }
    public void setPriceKzt(int priceKzt) { this.priceKzt = priceKzt; }
}
