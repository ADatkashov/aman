package kz.aman.domain;

import jakarta.persistence.*;
import java.util.List;
import java.util.ArrayList;

@Entity
@Table(name = "doctors",
    indexes = {@Index(name = "idx_doctors_specialty", columnList = "specialty_id"), @Index(name = "idx_doctors_clinic", columnList = "clinic_id")})
public class Doctor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "full_name", nullable = false, length = 200)
    private String fullName;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "specialty_id", nullable = false)
    private Specialty specialty;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "clinic_id", nullable = false)
    private Clinic clinic;

    @Column(name = "experience_years", nullable = false)
    private int experienceYears;

    @Column(name = "rating", nullable = false)
    private double rating;

    @Column(name = "reviews_count", nullable = false)
    private int reviewsCount;

    @Column(name = "price_kzt", nullable = false)
    private int priceKzt;

    @Convert(converter = LocConverter.class)
    @Column(columnDefinition = "text")
    private Loc education;

    @Convert(converter = LocConverter.class)
    @Column(columnDefinition = "text")
    private Loc qualification;

    @Convert(converter = LocConverter.class)
    @Column(columnDefinition = "text")
    private Loc about;

    @Column(name = "languages", nullable = false, length = 20)
    private String languages;

    @Column(name = "avatar_seed", nullable = false)
    private int avatarSeed;

    @Column(name = "female", nullable = false)
    private boolean female;

    @Column(name = "photo_url", length = 500)
    private String photoUrl;

    @OneToMany(mappedBy = "doctor", fetch = FetchType.LAZY)
    @OrderBy("id")
    private List<DoctorService> services = new ArrayList<>();

    public Doctor() {}

    public Long getId() { return id; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public Specialty getSpecialty() { return specialty; }
    public void setSpecialty(Specialty specialty) { this.specialty = specialty; }
    public Clinic getClinic() { return clinic; }
    public void setClinic(Clinic clinic) { this.clinic = clinic; }
    public int getExperienceYears() { return experienceYears; }
    public void setExperienceYears(int experienceYears) { this.experienceYears = experienceYears; }
    public double getRating() { return rating; }
    public void setRating(double rating) { this.rating = rating; }
    public int getReviewsCount() { return reviewsCount; }
    public void setReviewsCount(int reviewsCount) { this.reviewsCount = reviewsCount; }
    public int getPriceKzt() { return priceKzt; }
    public void setPriceKzt(int priceKzt) { this.priceKzt = priceKzt; }
    public Loc getEducation() { return education; }
    public void setEducation(Loc education) { this.education = education; }
    public Loc getQualification() { return qualification; }
    public void setQualification(Loc qualification) { this.qualification = qualification; }
    public Loc getAbout() { return about; }
    public void setAbout(Loc about) { this.about = about; }
    public String getLanguages() { return languages; }
    public void setLanguages(String languages) { this.languages = languages; }
    public int getAvatarSeed() { return avatarSeed; }
    public void setAvatarSeed(int avatarSeed) { this.avatarSeed = avatarSeed; }
    public boolean isFemale() { return female; }
    public void setFemale(boolean female) { this.female = female; }
    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
    public List<DoctorService> getServices() { return services; }
    public void setServices(List<DoctorService> services) { this.services = services; }
}
