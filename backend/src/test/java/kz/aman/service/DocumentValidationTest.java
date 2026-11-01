package kz.aman.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import kz.aman.common.ApiException;
import kz.aman.common.ErrorCode;
import org.junit.jupiter.api.Test;

class DocumentValidationTest {

    private static final byte[] PDF = "%PDF-1.4 content".getBytes();
    private static final byte[] PNG = {(byte) 0x89, 'P', 'N', 'G', 0x0D, 0x0A};
    private static final byte[] JPG = {(byte) 0xFF, (byte) 0xD8, (byte) 0xFF, (byte) 0xE0};

    @Test
    void acceptsAllowedTypesWithMatchingSignature() {
        assertThat(DocumentService.detectMime("a.pdf", PDF)).isEqualTo("application/pdf");
        assertThat(DocumentService.detectMime("a.PNG", PNG)).isEqualTo("image/png");
        assertThat(DocumentService.detectMime("a.jpeg", JPG)).isEqualTo("image/jpeg");
        assertThat(DocumentService.detectMime("a.jpg", JPG)).isEqualTo("image/jpeg");
    }

    @Test
    void rejectsDisallowedExtensions() {
        assertThatThrownBy(() -> DocumentService.detectMime("run.exe", PDF))
                .isInstanceOfSatisfying(ApiException.class, e -> assertThat(e.code()).isEqualTo(ErrorCode.FILE_TYPE_NOT_ALLOWED));
        assertThatThrownBy(() -> DocumentService.detectMime("noext", PDF)).isInstanceOf(ApiException.class);
    }

    @Test
    void rejectsContentThatDoesNotMatchTheExtension() {
        assertThatThrownBy(() -> DocumentService.detectMime("fake.pdf", "MZ-binary".getBytes()))
                .isInstanceOf(ApiException.class);
        assertThatThrownBy(() -> DocumentService.detectMime("fake.png", PDF)).isInstanceOf(ApiException.class);
        assertThatThrownBy(() -> DocumentService.detectMime("tiny.pdf", new byte[] {'%'})).isInstanceOf(ApiException.class);
    }

    @Test
    void sanitizesFileNames() {
        assertThat(DocumentService.sanitizeName("../../etc/passwd")).isEqualTo("passwd");
        assertThat(DocumentService.sanitizeName("C:\\Users\\x\\scan.pdf")).isEqualTo("scan.pdf");
        assertThat(DocumentService.sanitizeName(null)).isEqualTo("document");
        assertThat(DocumentService.sanitizeName("  ")).isEqualTo("document");
        assertThat(DocumentService.sanitizeName("a\u0000b.pdf")).isEqualTo("ab.pdf");
    }

    @Test
    void normalizesDocumentKinds() {
        assertThat(DocumentService.normalizeKind("labReport")).isEqualTo("LAB_REPORT");
        assertThat(DocumentService.normalizeKind("LAB_REPORT")).isEqualTo("LAB_REPORT");
        assertThat(DocumentService.normalizeKind("referral")).isEqualTo("REFERRAL");
        assertThat(DocumentService.normalizeKind("whatever")).isEqualTo("OTHER");
        assertThat(DocumentService.normalizeKind(null)).isEqualTo("OTHER");
    }
}
