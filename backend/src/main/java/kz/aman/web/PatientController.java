package kz.aman.web;

import jakarta.validation.Valid;
import java.util.List;
import kz.aman.dto.PatientDto;
import kz.aman.dto.UpdatePatientRequest;
import kz.aman.security.AmanPrincipal;
import kz.aman.service.CurrentPatient;
import kz.aman.service.PatientService;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/patients/me")
public class PatientController {

    private final PatientService service;
    private final CurrentPatient current;

    public PatientController(PatientService service, CurrentPatient current) {
        this.service = service;
        this.current = current;
    }

    @GetMapping
    public PatientDto me(@AuthenticationPrincipal AmanPrincipal p) {
        return service.me(current.of(p).getId());
    }

    @PutMapping
    public PatientDto update(@AuthenticationPrincipal AmanPrincipal p, @Valid @RequestBody UpdatePatientRequest request) {
        return service.update(current.of(p).getId(), request);
    }

    @GetMapping("/favorites")
    public List<Long> favorites(@AuthenticationPrincipal AmanPrincipal p) {
        return service.favoriteDoctorIds(current.of(p).getId());
    }

    @PutMapping("/favorites/{doctorId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void addFavorite(@AuthenticationPrincipal AmanPrincipal p, @PathVariable Long doctorId) {
        service.addFavorite(current.of(p).getId(), doctorId);
    }

    @DeleteMapping("/favorites/{doctorId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void removeFavorite(@AuthenticationPrincipal AmanPrincipal p, @PathVariable Long doctorId) {
        service.removeFavorite(current.of(p).getId(), doctorId);
    }
}
