package kz.aman.service;

import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import kz.aman.domain.Appointment;
import kz.aman.domain.AppointmentStatus;
import kz.aman.repo.AppointmentRepository;
import kz.aman.repo.NotificationRepository;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/** Closes finished visits and creates one reminder per visit within 24 hours. */
@Component
public class AppointmentLifecycleJob {

    private static final String REMINDER = "APPOINTMENT_REMINDER";

    private final AppointmentRepository appointments;
    private final NotificationRepository notificationRepo;
    private final NotificationService notifications;

    public AppointmentLifecycleJob(AppointmentRepository appointments, NotificationRepository notificationRepo,
            NotificationService notifications) {
        this.appointments = appointments;
        this.notificationRepo = notificationRepo;
        this.notifications = notifications;
    }

    @Scheduled(fixedDelayString = "PT10M", initialDelayString = "PT1M")
    @Transactional
    public void run() {
        runAt(Instant.now());
    }

    @Transactional
    public void runAt(Instant now) {
        for (Appointment a : appointments.findConfirmedStartingBefore(now.plus(Duration.ofHours(24)))) {
            Instant end = a.getStartAt().plus(Duration.ofMinutes(a.getDurationMinutes()));
            if (end.isBefore(now)) {
                a.setStatus(AppointmentStatus.COMPLETED);
                continue;
            }
            String route = "/appointments/" + a.getId();
            if (!notificationRepo.existsByPatientIdAndTypeAndRoute(a.getPatient().getId(), REMINDER, route)) {
                String[] n = a.getDoctor().getFullName().split(" ");
                String shortName = n.length < 2 ? n[0] : n[0] + " " + n[1].charAt(0) + ".";
                notifications.publish(a.getPatient(), REMINDER,
                        Map.of("doctor", shortName, "start", a.getStartAt().toString(), "number", a.getNumber()), route);
            }
        }
    }
}
