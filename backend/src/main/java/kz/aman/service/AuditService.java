package kz.aman.service;

import java.time.Instant;
import kz.aman.domain.AuditLog;
import kz.aman.repo.AuditLogRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Records who accessed which medical resource (never its content). */
@Service
public class AuditService {

    private final AuditLogRepository repo;

    public AuditService(AuditLogRepository repo) {
        this.repo = repo;
    }

    @Transactional
    public void record(Long userId, String action, String resourceType, Object resourceId) {
        AuditLog entry = new AuditLog();
        entry.setUserId(userId);
        entry.setAction(action);
        entry.setResourceType(resourceType);
        entry.setResourceId(resourceId == null ? null : resourceId.toString());
        entry.setAt(Instant.now());
        repo.save(entry);
    }
}
