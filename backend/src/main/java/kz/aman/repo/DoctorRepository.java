package kz.aman.repo;

import java.util.List;
import java.util.Optional;
import kz.aman.domain.Doctor;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface DoctorRepository extends JpaRepository<Doctor, Long> {

    @EntityGraph(attributePaths = {"specialty", "clinic", "services"})
    @Query("""
            select distinct d from Doctor d
            where (:specialty is null or d.specialty.code = :specialty)
              and (:clinicId is null or d.clinic.id = :clinicId)
              and (:q is null or lower(d.fullName) like lower(concat('%', :q, '%')))
            order by d.reviewsCount desc, d.id asc
            """)
    List<Doctor> search(@Param("specialty") String specialty, @Param("clinicId") Long clinicId, @Param("q") String q);

    @EntityGraph(attributePaths = {"specialty", "clinic", "services"})
    Optional<Doctor> findWithDetailsById(Long id);
}
