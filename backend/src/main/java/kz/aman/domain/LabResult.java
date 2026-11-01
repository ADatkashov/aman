package kz.aman.domain;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.List;
import java.util.ArrayList;

@Entity
@Table(name = "lab_results",
    indexes = @Index(name = "idx_lab_patient_date", columnList = "patient_id, result_date"))
public class LabResult {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;

    @Column(name = "test_code", nullable = false, length = 60)
    private String testCode;

    @Column(name = "category", nullable = false, length = 30)
    private String category;

    @Convert(converter = LocConverter.class)
    @Column(columnDefinition = "text")
    private Loc name;

    @Column(name = "result_date", nullable = false)
    private LocalDate resultDate;

    @Column(name = "laboratory", nullable = false, length = 200)
    private String laboratory;

    @Column(name = "status", nullable = false, length = 20)
    private String status;

    @Column(name = "document_id")
    private Long documentId;

    @OneToMany(mappedBy = "result", fetch = FetchType.LAZY, cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("id")
    private List<LabIndicator> indicators = new ArrayList<>();

    public LabResult() {}

    public Long getId() { return id; }
    public Patient getPatient() { return patient; }
    public void setPatient(Patient patient) { this.patient = patient; }
    public String getTestCode() { return testCode; }
    public void setTestCode(String testCode) { this.testCode = testCode; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public Loc getName() { return name; }
    public void setName(Loc name) { this.name = name; }
    public LocalDate getResultDate() { return resultDate; }
    public void setResultDate(LocalDate resultDate) { this.resultDate = resultDate; }
    public String getLaboratory() { return laboratory; }
    public void setLaboratory(String laboratory) { this.laboratory = laboratory; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Long getDocumentId() { return documentId; }
    public void setDocumentId(Long documentId) { this.documentId = documentId; }
    public List<LabIndicator> getIndicators() { return indicators; }
    public void setIndicators(List<LabIndicator> indicators) { this.indicators = indicators; }
}
