package kz.aman;

import static org.assertj.core.api.Assertions.assertThat;

import kz.aman.repo.ClinicRepository;
import kz.aman.repo.DoctorRepository;
import kz.aman.repo.DoctorScheduleRepository;
import kz.aman.repo.SpecialtyRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

/**
 * The SQL migrations must match the JPA mapping exactly (Hibernate runs in
 * {@code validate} mode) and the demo catalog must load.
 */
@SpringBootTest
@ActiveProfiles("migration")
class MigrationTest {

    @Autowired SpecialtyRepository specialties;
    @Autowired ClinicRepository clinics;
    @Autowired DoctorRepository doctors;
    @Autowired DoctorScheduleRepository schedules;

    @Test
    void migrationsMatchTheEntityModelAndLoadTheDemoCatalog() {
        assertThat(specialties.count()).isEqualTo(8);
        assertThat(clinics.count()).isEqualTo(6);
        assertThat(doctors.count()).isEqualTo(14);
        assertThat(schedules.count()).isGreaterThan(50);
        var first = doctors.findWithDetailsById(1L).orElseThrow();
        assertThat(first.getFullName()).startsWith("Смирнов");
        assertThat(first.getEducation().kk()).isNotBlank();
        assertThat(first.getServices()).isNotEmpty();
        assertThat(clinics.findWithServicesById(1L).orElseThrow().isDemo()).isTrue();
    }
}
