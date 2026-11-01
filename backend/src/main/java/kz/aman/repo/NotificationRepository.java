package kz.aman.repo;

import java.util.List;
import java.util.Optional;
import kz.aman.domain.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByPatientIdOrderByCreatedAtDescIdDesc(Long patientId);

    Optional<Notification> findByIdAndPatientId(Long id, Long patientId);

    boolean existsByPatientIdAndTypeAndRoute(Long patientId, String type, String route);

    @Modifying
    @Query("update Notification n set n.read = true where n.patient.id = :patientId and n.read = false")
    int markAllRead(@Param("patientId") Long patientId);
}
