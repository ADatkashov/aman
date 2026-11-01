package kz.aman.repo;

import java.util.List;
import java.util.Optional;
import kz.aman.domain.MedicalRecordEntry;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MedicalRecordRepository extends JpaRepository<MedicalRecordEntry, Long> {
    List<MedicalRecordEntry> findByPatientIdOrderByEntryDateDescIdDesc(Long patientId);

    Optional<MedicalRecordEntry> findByIdAndPatientId(Long id, Long patientId);
}
