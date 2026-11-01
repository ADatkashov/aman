package kz.aman.repo;

import java.util.List;
import java.util.Optional;
import kz.aman.domain.Clinic;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClinicRepository extends JpaRepository<Clinic, Long> {

    @EntityGraph(attributePaths = "services")
    List<Clinic> findAllByOrderByIdAsc();

    @EntityGraph(attributePaths = "services")
    Optional<Clinic> findWithServicesById(Long id);
}
