package kz.aman.service;

import java.util.List;
import java.util.Locale;
import kz.aman.common.ApiException;
import kz.aman.domain.LabIndicator;
import kz.aman.domain.LabOrder;
import kz.aman.domain.LabResult;
import kz.aman.domain.MedicalRecordEntry;
import kz.aman.dto.HealthDtos.LabIndicatorDto;
import kz.aman.dto.HealthDtos.LabOrderDto;
import kz.aman.dto.HealthDtos.LabResultDto;
import kz.aman.dto.HealthDtos.MedicalEntryDto;
import kz.aman.repo.LabOrderRepository;
import kz.aman.repo.LabResultRepository;
import kz.aman.repo.MedicalRecordRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Laboratory results and the electronic medical record. Every read is
 * scoped to the owning patient and audited. The service never interprets
 * values: a result is flagged only against the laboratory's own reference range.
 */
@Service
@Transactional(readOnly = true)
public class HealthDataService {

    private final LabResultRepository results;
    private final LabOrderRepository orders;
    private final MedicalRecordRepository records;
    private final AuditService audit;

    public HealthDataService(LabResultRepository results, LabOrderRepository orders, MedicalRecordRepository records,
            AuditService audit) {
        this.results = results;
        this.orders = orders;
        this.records = records;
        this.audit = audit;
    }

    public List<LabResultDto> labResults(Long userId, Long patientId) {
        audit.record(userId, "READ_LIST", "LAB_RESULT", null);
        return results.findDistinctByPatientIdOrderByResultDateDescIdDesc(patientId).stream().map(HealthDataService::toDto).toList();
    }

    public LabResultDto labResult(Long userId, Long patientId, Long id) {
        LabResult r = results.findByIdAndPatientId(id, patientId).orElseThrow(() -> ApiException.notFound("Lab result"));
        audit.record(userId, "READ", "LAB_RESULT", id);
        return toDto(r);
    }

    public List<LabOrderDto> labOrders(Long userId, Long patientId) {
        audit.record(userId, "READ_LIST", "LAB_ORDER", null);
        return orders.findByPatientIdOrderByOrderDateDescIdDesc(patientId).stream().map(HealthDataService::toDto).toList();
    }

    public List<MedicalEntryDto> medicalRecords(Long userId, Long patientId) {
        audit.record(userId, "READ_LIST", "MEDICAL_RECORD", null);
        return records.findByPatientIdOrderByEntryDateDescIdDesc(patientId).stream().map(HealthDataService::toDto).toList();
    }

    public MedicalEntryDto medicalRecord(Long userId, Long patientId, Long id) {
        MedicalRecordEntry e = records.findByIdAndPatientId(id, patientId).orElseThrow(() -> ApiException.notFound("Record"));
        audit.record(userId, "READ", "MEDICAL_RECORD", id);
        return toDto(e);
    }

    /** Status is "ATTENTION" when any value lies outside the laboratory's reference interval. */
    static LabResultDto toDto(LabResult r) {
        List<LabIndicatorDto> indicators = r.getIndicators().stream()
                .map(i -> new LabIndicatorDto(i.getName(), i.getValue(), i.getUnit(), i.getRefMin(), i.getRefMax())).toList();
        String status = r.getStatus();
        if ("READY".equals(status) && r.getIndicators().stream().anyMatch(HealthDataService::outOfRange)) {
            status = "ATTENTION";
        }
        return new LabResultDto(r.getId(), r.getTestCode(), r.getCategory().toLowerCase(Locale.ROOT), r.getName(),
                r.getResultDate(), r.getLaboratory(), status, indicators, r.getDocumentId());
    }

    static boolean outOfRange(LabIndicator i) {
        return (i.getRefMin() != null && i.getValue() < i.getRefMin()) || (i.getRefMax() != null && i.getValue() > i.getRefMax());
    }

    private static LabOrderDto toDto(LabOrder o) {
        return new LabOrderDto(o.getId(), o.getName(), o.getCategory().toLowerCase(Locale.ROOT), o.getDoctorName(),
                o.getOrderDate(), o.getStatus());
    }

    private static MedicalEntryDto toDto(MedicalRecordEntry e) {
        return new MedicalEntryDto(e.getId(), e.getType(), e.getEntryDate(), e.getTitle(), e.getDetails(), e.getDoctorName(),
                e.getSourceRef());
    }
}
