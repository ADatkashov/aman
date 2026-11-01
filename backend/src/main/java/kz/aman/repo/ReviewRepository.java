package kz.aman.repo;

import java.util.List;
import kz.aman.domain.DoctorReview;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReviewRepository extends JpaRepository<DoctorReview, Long> {

    @EntityGraph(attributePaths = "patient")
    List<DoctorReview> findTop20ByDoctorIdOrderByCreatedAtDesc(Long doctorId);
}
