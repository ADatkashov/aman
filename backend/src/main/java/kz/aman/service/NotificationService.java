package kz.aman.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import kz.aman.common.ApiException;
import kz.aman.domain.Notification;
import kz.aman.domain.Patient;
import kz.aman.dto.HealthDtos.NotificationDto;
import kz.aman.repo.NotificationRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class NotificationService {

    private static final TypeReference<Map<String, String>> PARAMS = new TypeReference<>() {};

    private final NotificationRepository repo;
    private final ObjectMapper mapper;

    public NotificationService(NotificationRepository repo, ObjectMapper mapper) {
        this.repo = repo;
        this.mapper = mapper;
    }

    /** Stores an event (type + template parameters). Text is rendered by clients. */
    @Transactional
    public void publish(Patient patient, String type, Map<String, String> params, String route) {
        Notification n = new Notification();
        n.setPatient(patient);
        n.setType(type);
        n.setCreatedAt(Instant.now());
        n.setRead(false);
        n.setRoute(route);
        try {
            n.setParamsJson(mapper.writeValueAsString(params));
        } catch (JsonProcessingException e) {
            throw new IllegalStateException(e);
        }
        repo.save(n);
    }

    @Transactional(readOnly = true)
    public List<NotificationDto> list(Long patientId) {
        return repo.findByPatientIdOrderByCreatedAtDescIdDesc(patientId).stream().map(this::toDto).toList();
    }

    @Transactional
    public void markRead(Long patientId, Long id) {
        repo.findByIdAndPatientId(id, patientId).orElseThrow(() -> ApiException.notFound("Notification")).setRead(true);
    }

    @Transactional
    public void markAllRead(Long patientId) {
        repo.markAllRead(patientId);
    }

    @Transactional
    public void delete(Long patientId, Long id) {
        repo.delete(repo.findByIdAndPatientId(id, patientId).orElseThrow(() -> ApiException.notFound("Notification")));
    }

    private NotificationDto toDto(Notification n) {
        Map<String, String> params;
        try {
            params = n.getParamsJson() == null ? Map.of() : mapper.readValue(n.getParamsJson(), PARAMS);
        } catch (JsonProcessingException e) {
            params = Map.of();
        }
        return new NotificationDto(n.getId(), n.getType(), n.getCreatedAt(), n.isRead(), params, n.getRoute());
    }
}
