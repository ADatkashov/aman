package kz.aman.web;

import java.util.List;
import kz.aman.dto.HealthDtos.DocumentDto;
import kz.aman.security.AmanPrincipal;
import kz.aman.service.CurrentPatient;
import kz.aman.service.DocumentService;
import kz.aman.service.DocumentService.StoredFile;
import org.springframework.core.io.Resource;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/documents")
public class DocumentController {

    private final DocumentService service;
    private final CurrentPatient current;

    public DocumentController(DocumentService service, CurrentPatient current) {
        this.service = service;
        this.current = current;
    }

    @GetMapping
    public List<DocumentDto> list(@AuthenticationPrincipal AmanPrincipal p) {
        return service.list(p.userId(), current.of(p).getId());
    }

    @GetMapping("/{id}")
    public DocumentDto get(@AuthenticationPrincipal AmanPrincipal p, @PathVariable Long id) {
        return service.get(p.userId(), current.of(p).getId(), id);
    }

    @GetMapping("/{id}/content")
    public ResponseEntity<Resource> content(@AuthenticationPrincipal AmanPrincipal p, @PathVariable Long id) {
        StoredFile file = service.content(p.userId(), current.of(p).getId(), id);
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(file.mimeType()))
                .header(HttpHeaders.CONTENT_DISPOSITION, ContentDisposition.attachment().filename(file.fileName()).build().toString())
                .header("X-Content-Type-Options", "nosniff")
                .header(HttpHeaders.CACHE_CONTROL, "no-store")
                .body(file.resource());
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseStatus(HttpStatus.CREATED)
    public DocumentDto upload(
            @AuthenticationPrincipal AmanPrincipal p,
            @RequestParam("file") MultipartFile file,
            @RequestParam(required = false) String title,
            @RequestParam(required = false) String kind) {
        return service.upload(p.userId(), current.of(p).getId(), file, title, kind);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@AuthenticationPrincipal AmanPrincipal p, @PathVariable Long id) {
        service.delete(p.userId(), current.of(p).getId(), id);
    }
}
