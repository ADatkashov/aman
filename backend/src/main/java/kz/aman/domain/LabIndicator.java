package kz.aman.domain;

import jakarta.persistence.*;

@Entity
@Table(name = "lab_indicators",
    indexes = @Index(name = "idx_lab_indicators_result", columnList = "result_id"))
public class LabIndicator {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "result_id", nullable = false)
    private LabResult result;

    @Convert(converter = LocConverter.class)
    @Column(columnDefinition = "text")
    private Loc name;

    @Column(name = "value", nullable = false)
    private double value;

    @Column(name = "unit", nullable = false, length = 30)
    private String unit;

    @Column(name = "ref_min")
    private Double refMin;

    @Column(name = "ref_max")
    private Double refMax;

    protected LabIndicator() {}

    public Long getId() { return id; }
    public LabResult getResult() { return result; }
    public void setResult(LabResult result) { this.result = result; }
    public Loc getName() { return name; }
    public void setName(Loc name) { this.name = name; }
    public double getValue() { return value; }
    public void setValue(double value) { this.value = value; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    public Double getRefMin() { return refMin; }
    public void setRefMin(Double refMin) { this.refMin = refMin; }
    public Double getRefMax() { return refMax; }
    public void setRefMax(Double refMax) { this.refMax = refMax; }
}
