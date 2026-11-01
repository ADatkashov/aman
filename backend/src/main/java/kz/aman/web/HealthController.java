package kz.aman.web;

import java.util.List;
import kz.aman.dto.HealthDtos.LabOrderDto;
import kz.aman.dto.HealthDtos.LabResultDto;
import kz.aman.dto.HealthDtos.MedicalEntryDto;
import kz.aman.security.AmanPrincipal;
import kz.aman.service.CurrentPatient;
import kz.aman.service.HealthDataService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class HealthController {

    private final HealthDataService service;
    private final CurrentPatient current;

    public HealthController(HealthDataService service, CurrentPatient current) {
        this.service = service;
        this.current = current;
    }

    @GetMapping("/laboratory/results")
    public List<LabResultDto> results(@AuthenticationPrincipal AmanPrincipal p) {
        return service.labResults(p.userId(), current.of(p).getId());
    }

    @GetMapping("/laboratory/results/{id}")
    public LabResultDto result(@AuthenticationPrincipal AmanPrincipal p, @PathVariable Long id) {
        return service.labResult(p.userId(), current.of(p).getId(), id);
    }

    @GetMapping("/laboratory/orders")
    public List<LabOrderDto> orders(@AuthenticationPrincipal AmanPrincipal p) {
        return service.labOrders(p.userId(), current.of(p).getId());
    }

    @GetMapping("/medical-records")
    public List<MedicalEntryDto> records(@AuthenticationPrincipal AmanPrincipal p) {
        return service.medicalRecords(p.userId(), current.of(p).getId());
    }

    @GetMapping("/medical-records/{id}")
    public MedicalEntryDto record(@AuthenticationPrincipal AmanPrincipal p, @PathVariable Long id) {
        return service.medicalRecord(p.userId(), current.of(p).getId(), id);
    }
}
