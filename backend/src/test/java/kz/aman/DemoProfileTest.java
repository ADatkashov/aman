package kz.aman;

import static org.assertj.core.api.Assertions.assertThat;

import kz.aman.demo.DemoDataSeeder;
import kz.aman.domain.AppointmentStatus;
import kz.aman.repo.AppointmentRepository;
import kz.aman.repo.LabResultRepository;
import kz.aman.repo.MedicalDocumentRepository;
import kz.aman.repo.MedicalRecordRepository;
import kz.aman.repo.NotificationRepository;
import kz.aman.repo.PatientRepository;
import kz.aman.service.AuthService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

/** The `demo` profile seeds a complete, synthetic patient that can sign in. */
@SpringBootTest(properties = {
    "spring.datasource.url=jdbc:h2:mem:demoprofile;MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1",
    "aman.storage.dir=${java.io.tmpdir}/aman-test-documents-demo"
})
@ActiveProfiles({"migration", "demo"})
class DemoProfileTest {

    @Autowired PatientRepository patients;
    @Autowired AppointmentRepository appointments;
    @Autowired LabResultRepository labs;
    @Autowired MedicalRecordRepository records;
    @Autowired MedicalDocumentRepository documents;
    @Autowired NotificationRepository notifications;
    @Autowired AuthService auth;

    @Test
    @Transactional
    void seedsASyntheticPatientWithHistory() {
        var patient = patients.findAll().stream()
                .filter(p -> p.getUser().getPhone().equals(DemoDataSeeder.PHONE)).findFirst().orElseThrow();
        var appts = appointments.findByPatientIdOrderByStartAtDesc(patient.getId());
        assertThat(appts).hasSize(6);
        assertThat(appts).extracting(a -> a.getStatus()).contains(AppointmentStatus.CONFIRMED, AppointmentStatus.COMPLETED, AppointmentStatus.CANCELLED);
        assertThat(appts).allSatisfy(a -> assertThat(a.getNumber()).startsWith("AM-"));
        assertThat(labs.findDistinctByPatientIdOrderByResultDateDescIdDesc(patient.getId())).hasSizeGreaterThanOrEqualTo(10);
        assertThat(records.findByPatientIdOrderByEntryDateDescIdDesc(patient.getId())).isNotEmpty()
                .allSatisfy(e -> assertThat(e.getSourceRef()).isNotBlank());
        assertThat(documents.findByPatientIdOrderByUploadedAtDescIdDesc(patient.getId())).hasSize(4);
        assertThat(notifications.findByPatientIdOrderByCreatedAtDescIdDesc(patient.getId())).hasSize(4);
    }

    @Test
    void demoCredentialsWork() {
        var response = auth.login(DemoDataSeeder.PHONE, DemoDataSeeder.PASSWORD);
        assertThat(response.accessToken()).isNotBlank();
        assertThat(response.patient().fullName()).contains("Алексей");
    }
}
