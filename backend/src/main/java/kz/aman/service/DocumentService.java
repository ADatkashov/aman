package kz.aman.service;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Instant;
import java.util.HexFormat;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import kz.aman.common.ApiException;
import kz.aman.common.ErrorCode;
import kz.aman.config.AppProperties;
import kz.aman.domain.MedicalDocument;
import kz.aman.dto.HealthDtos.DocumentDto;
import kz.aman.repo.MedicalDocumentRepository;
import kz.aman.repo.PatientRepository;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

/**
 * Secure document storage.
 *
 * <ul>
 *   <li>size limit 10 MB, non-empty, extension whitelist (pdf, jpg, jpeg, png);
 *   <li>the declared type is NOT trusted: the file signature (magic bytes) must match;
 *   <li>files are stored under a random key, never under the user-supplied name;
 *   <li>every access is ownership-checked and audited.
 * </ul>
 */
@Service
public class DocumentService {

    public static final long MAX_BYTES = 10L * 1024 * 1024;
    private static final Map<String, String> KINDS = Map.of(
            "LABREPORT", "LAB_REPORT", "PRESCRIPTION", "PRESCRIPTION", "CONCLUSION", "CONCLUSION",
            "REFERRAL", "REFERRAL", "OTHER", "OTHER");

    private final MedicalDocumentRepository documents;
    private final PatientRepository patients;
    private final AuditService audit;
    private final Path root;

    public DocumentService(MedicalDocumentRepository documents, PatientRepository patients, AuditService audit,
            AppProperties props) {
        this.documents = documents;
        this.patients = patients;
        this.audit = audit;
        this.root = Path.of(props.storage().dir()).toAbsolutePath().normalize();
    }

    @Transactional(readOnly = true)
    public List<DocumentDto> list(Long userId, Long patientId) {
        audit.record(userId, "READ_LIST", "DOCUMENT", null);
        return documents.findByPatientIdOrderByUploadedAtDescIdDesc(patientId).stream().map(DocumentService::toDto).toList();
    }

    @Transactional(readOnly = true)
    public DocumentDto get(Long userId, Long patientId, Long id) {
        MedicalDocument d = owned(patientId, id);
        audit.record(userId, "READ", "DOCUMENT", id);
        return toDto(d);
    }

    /** File content for download; ownership-checked and audited. */
    @Transactional(readOnly = true)
    public StoredFile content(Long userId, Long patientId, Long id) {
        MedicalDocument d = owned(patientId, id);
        audit.record(userId, "DOWNLOAD", "DOCUMENT", id);
        Path file = root.resolve(d.getStorageKey()).normalize();
        if (!file.startsWith(root) || !Files.isRegularFile(file)) {
            throw ApiException.notFound("Document content");
        }
        return new StoredFile(new FileSystemResource(file), d.getMimeType(), d.getFileName());
    }

    @Transactional
    public DocumentDto upload(Long userId, Long patientId, MultipartFile file, String title, String kind) {
        if (file == null || file.isEmpty()) {
            throw new ApiException(ErrorCode.FILE_EMPTY, "The file is empty");
        }
        if (file.getSize() > MAX_BYTES) {
            throw new ApiException(ErrorCode.FILE_TOO_LARGE, "File is larger than 10 MB");
        }
        byte[] bytes;
        try {
            bytes = file.getBytes();
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
        String originalName = sanitizeName(file.getOriginalFilename());
        String mime = detectMime(originalName, bytes);
        String normalizedKind = normalizeKind(kind);

        String key = UUID.randomUUID().toString().replace("-", "");
        try {
            Files.createDirectories(root);
            Path target = root.resolve(key).normalize();
            if (!target.startsWith(root)) {
                throw new IllegalStateException("Path escape");
            }
            Files.copy(new java.io.ByteArrayInputStream(bytes), target, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }

        MedicalDocument d = new MedicalDocument();
        d.setPatient(patients.getReferenceById(patientId));
        d.setTitle(title == null || title.isBlank() ? originalName : title.trim().substring(0, Math.min(title.trim().length(), 200)));
        d.setKind(normalizedKind);
        d.setFileName(originalName);
        d.setMimeType(mime);
        d.setSizeBytes(bytes.length);
        d.setStorageKey(key);
        d.setSha256(sha256(bytes));
        d.setUploadedAt(Instant.now());
        d.setUploadedByPatient(true);
        documents.save(d);
        audit.record(userId, "UPLOAD", "DOCUMENT", d.getId());
        return toDto(d);
    }

    @Transactional
    public void delete(Long userId, Long patientId, Long id) {
        MedicalDocument d = owned(patientId, id);
        if (!d.isUploadedByPatient()) {
            throw new ApiException(ErrorCode.FORBIDDEN, "Clinic documents cannot be deleted by the patient");
        }
        documents.delete(d);
        try {
            Files.deleteIfExists(root.resolve(d.getStorageKey()).normalize());
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
        audit.record(userId, "DELETE", "DOCUMENT", id);
    }

    // --- validation helpers (package-private for unit tests) -------------

    static String detectMime(String fileName, byte[] bytes) {
        String lower = fileName.toLowerCase(Locale.ROOT);
        int dot = lower.lastIndexOf('.');
        String ext = dot < 0 ? "" : lower.substring(dot + 1);
        String mime = switch (ext) {
            case "pdf" -> startsWith(bytes, '%', 'P', 'D', 'F', '-') ? "application/pdf" : null;
            case "png" -> startsWith(bytes, 0x89, 'P', 'N', 'G') ? "image/png" : null;
            case "jpg", "jpeg" -> startsWith(bytes, 0xFF, 0xD8, 0xFF) ? "image/jpeg" : null;
            default -> null;
        };
        if (mime == null) {
            throw new ApiException(ErrorCode.FILE_TYPE_NOT_ALLOWED, "Only PDF, JPG and PNG files are allowed");
        }
        return mime;
    }

    /** Accepts {@code labReport}, {@code LAB_REPORT}, {@code lab-report}; unknown values become OTHER. */
    static String normalizeKind(String kind) {
        if (kind == null) {
            return "OTHER";
        }
        String key = kind.trim().toUpperCase(Locale.ROOT).replace("_", "").replace("-", "");
        return KINDS.getOrDefault(key, "OTHER");
    }

    static String sanitizeName(String name) {
        String base = name == null ? "document" : name.replace('\\', '/');
        base = base.substring(base.lastIndexOf('/') + 1).replaceAll("[\\p{Cntrl}]", "").trim();
        if (base.isEmpty()) {
            base = "document";
        }
        return base.length() > 120 ? base.substring(base.length() - 120) : base;
    }

    private static boolean startsWith(byte[] bytes, int... prefix) {
        if (bytes.length < prefix.length) {
            return false;
        }
        for (int i = 0; i < prefix.length; i++) {
            if ((bytes[i] & 0xFF) != prefix[i]) {
                return false;
            }
        }
        return true;
    }

    private static String sha256(byte[] bytes) {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(bytes));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }

    private MedicalDocument owned(Long patientId, Long id) {
        return documents.findByIdAndPatientId(id, patientId).orElseThrow(() -> ApiException.notFound("Document"));
    }

    private static DocumentDto toDto(MedicalDocument d) {
        return new DocumentDto(d.getId(), d.getTitle(), d.getKind(), d.getFileName(), d.getMimeType(), d.getSizeBytes(),
                d.getUploadedAt(), d.isUploadedByPatient());
    }

    public record StoredFile(Resource resource, String mimeType, String fileName) {}
}
