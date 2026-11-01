package kz.aman.web;

import jakarta.validation.Valid;
import java.util.List;
import kz.aman.dto.AppointmentDtos.AppointmentDto;
import kz.aman.dto.AppointmentDtos.CancelRequest;
import kz.aman.dto.AppointmentDtos.CreateRequest;
import kz.aman.dto.AppointmentDtos.RescheduleRequest;
import kz.aman.dto.AppointmentDtos.ReviewRequest;
import kz.aman.security.AmanPrincipal;
import kz.aman.service.AppointmentService;
import kz.aman.service.CurrentPatient;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/appointments")
public class AppointmentController {

    private final AppointmentService service;
    private final CurrentPatient current;

    public AppointmentController(AppointmentService service, CurrentPatient current) {
        this.service = service;
        this.current = current;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public AppointmentDto create(@AuthenticationPrincipal AmanPrincipal p, @Valid @RequestBody CreateRequest request) {
        return service.create(current.of(p).getId(), request.doctorId(), request.start(), request.reason());
    }

    @GetMapping
    public List<AppointmentDto> list(@AuthenticationPrincipal AmanPrincipal p) {
        return service.list(current.of(p).getId());
    }

    @GetMapping("/{id}")
    public AppointmentDto get(@AuthenticationPrincipal AmanPrincipal p, @PathVariable Long id) {
        return service.get(current.of(p).getId(), id);
    }

    @PatchMapping("/{id}/cancel")
    public AppointmentDto cancel(
            @AuthenticationPrincipal AmanPrincipal p,
            @PathVariable Long id,
            @Valid @RequestBody(required = false) CancelRequest request) {
        return service.cancel(current.of(p).getId(), id, request == null ? null : request.reason());
    }

    @PatchMapping("/{id}/reschedule")
    public AppointmentDto reschedule(
            @AuthenticationPrincipal AmanPrincipal p, @PathVariable Long id, @Valid @RequestBody RescheduleRequest request) {
        return service.reschedule(current.of(p).getId(), id, request.start());
    }

    @PostMapping("/{id}/review")
    public AppointmentDto review(
            @AuthenticationPrincipal AmanPrincipal p, @PathVariable Long id, @Valid @RequestBody ReviewRequest request) {
        return service.review(current.of(p).getId(), id, request.rating(), request.text());
    }
}
