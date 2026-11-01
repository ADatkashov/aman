package kz.aman.repo;

import java.util.List;
import java.util.Optional;
import kz.aman.domain.MedicalDocument;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MedicalDocumentRepository extends JpaRepository<MedicalDocument, Long> {
    List<MedicalDocument> findByPatientIdOrderByUploadedAtDescIdDesc(Long patientId);

    Optional<MedicalDocument> findByIdAndPatientId(Long id, Long patientId);
}
