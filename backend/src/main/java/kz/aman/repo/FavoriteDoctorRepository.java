package kz.aman.repo;

import java.util.List;
import kz.aman.domain.FavoriteDoctor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface FavoriteDoctorRepository extends JpaRepository<FavoriteDoctor, Long> {

    @Query("select f.doctor.id from FavoriteDoctor f where f.patient.id = :patientId order by f.id")
    List<Long> doctorIds(@Param("patientId") Long patientId);

    boolean existsByPatientIdAndDoctorId(Long patientId, Long doctorId);

    void deleteByPatientIdAndDoctorId(Long patientId, Long doctorId);
}
