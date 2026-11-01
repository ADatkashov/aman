package kz.aman.repo;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import kz.aman.domain.Appointment;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface AppointmentRepository extends JpaRepository<Appointment, Long> {

    boolean existsByActiveSlotKey(String activeSlotKey);

    @EntityGraph(attributePaths = {"doctor", "clinic"})
    List<Appointment> findByPatientIdOrderByStartAtDesc(Long patientId);

    @EntityGraph(attributePaths = {"doctor", "clinic"})
    Optional<Appointment> findByIdAndPatientId(Long id, Long patientId);

    @Query("select a.startAt from Appointment a where a.doctor.id = :doctorId and a.activeSlotKey is not null"
            + " and a.startAt >= :from and a.startAt < :to")
    List<Instant> activeStarts(@Param("doctorId") Long doctorId, @Param("from") Instant from, @Param("to") Instant to);

    @Query("select a from Appointment a join fetch a.doctor join fetch a.clinic join fetch a.patient"
            + " where a.status = kz.aman.domain.AppointmentStatus.CONFIRMED and a.startAt < :before")
    List<Appointment> findConfirmedStartingBefore(@Param("before") Instant before);
}
