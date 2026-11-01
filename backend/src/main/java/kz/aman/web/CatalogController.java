package kz.aman.web;

import java.time.LocalDate;
import java.util.List;
import kz.aman.dto.CatalogDtos.ClinicDto;
import kz.aman.dto.CatalogDtos.DoctorDto;
import kz.aman.dto.CatalogDtos.NextSlotDto;
import kz.aman.dto.CatalogDtos.ReviewDto;
import kz.aman.dto.CatalogDtos.SlotDto;
import kz.aman.service.CatalogService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class CatalogController {

    private final CatalogService catalog;

    public CatalogController(CatalogService catalog) {
        this.catalog = catalog;
    }

    @GetMapping("/doctors")
    public List<DoctorDto> doctors(
            @RequestParam(required = false) String specialty,
            @RequestParam(required = false) Long clinicId,
            @RequestParam(required = false, name = "q") String query) {
        return catalog.doctors(specialty, clinicId, query);
    }

    @GetMapping("/doctors/{id}")
    public DoctorDto doctor(@PathVariable Long id) {
        return catalog.doctor(id);
    }

    /** Free/busy slots of a day: {@code GET /doctors/{id}/schedule?date=2026-11-04}. */
    @GetMapping("/doctors/{id}/schedule")
    public List<SlotDto> schedule(
            @PathVariable Long id, @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return catalog.slots(id, date);
    }

    @GetMapping("/doctors/{id}/next-slot")
    public NextSlotDto nextSlot(@PathVariable Long id) {
        return new NextSlotDto(catalog.nextSlot(id).orElse(null));
    }

    @GetMapping("/doctors/{id}/reviews")
    public List<ReviewDto> reviews(@PathVariable Long id) {
        return catalog.reviews(id);
    }

    @GetMapping("/clinics")
    public List<ClinicDto> clinics() {
        return catalog.clinics();
    }

    @GetMapping("/clinics/{id}")
    public ClinicDto clinic(@PathVariable Long id) {
        return catalog.clinic(id);
    }
}
