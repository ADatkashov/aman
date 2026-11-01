package kz.aman.web;

import java.util.List;
import kz.aman.dto.HealthDtos.NotificationDto;
import kz.aman.security.AmanPrincipal;
import kz.aman.service.CurrentPatient;
import kz.aman.service.NotificationService;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/notifications")
public class NotificationController {

    private final NotificationService service;
    private final CurrentPatient current;

    public NotificationController(NotificationService service, CurrentPatient current) {
        this.service = service;
        this.current = current;
    }

    @GetMapping
    public List<NotificationDto> list(@AuthenticationPrincipal AmanPrincipal p) {
        return service.list(current.of(p).getId());
    }

    @PatchMapping("/{id}/read")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void read(@AuthenticationPrincipal AmanPrincipal p, @PathVariable Long id) {
        service.markRead(current.of(p).getId(), id);
    }

    @PatchMapping("/read-all")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void readAll(@AuthenticationPrincipal AmanPrincipal p) {
        service.markAllRead(current.of(p).getId());
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@AuthenticationPrincipal AmanPrincipal p, @PathVariable Long id) {
        service.delete(current.of(p).getId(), id);
    }
}
