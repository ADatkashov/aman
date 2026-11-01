package kz.aman.repo;

import java.util.List;
import java.util.Optional;
import kz.aman.domain.LabResult;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LabResultRepository extends JpaRepository<LabResult, Long> {

    @EntityGraph(attributePaths = "indicators")
    List<LabResult> findDistinctByPatientIdOrderByResultDateDescIdDesc(Long patientId);

    @EntityGraph(attributePaths = "indicators")
    Optional<LabResult> findByIdAndPatientId(Long id, Long patientId);
}
