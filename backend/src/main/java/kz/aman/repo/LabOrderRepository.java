package kz.aman.repo;

import java.util.List;
import kz.aman.domain.LabOrder;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LabOrderRepository extends JpaRepository<LabOrder, Long> {
    List<LabOrder> findByPatientIdOrderByOrderDateDescIdDesc(Long patientId);
}
