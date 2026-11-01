package kz.aman.domain;

import jakarta.persistence.*;
import java.util.List;
import java.util.ArrayList;

@Entity
@Table(name = "clinics",
    indexes = @Index(name = "idx_clinics_city", columnList = "city"))
public class Clinic {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false, length = 200)
    private String name;

    @Column(name = "city", nullable = false, length = 100)
    private String city;

    @Column(name = "address", nullable = false, length = 300)
    private String address;

    @Column(name = "latitude", nullable = false)
    private double latitude;

    @Column(name = "longitude", nullable = false)
    private double longitude;

    @Column(name = "phone", nullable = false, length = 32)
    private String phone;

    @Column(name = "rating", nullable = false)
    private double rating;

    @Column(name = "reviews_count", nullable = false)
    private int reviewsCount;

    @Convert(converter = LocConverter.class)
    @Column(columnDefinition = "text")
    private Loc workingHours;

    @Column(name = "image_seed", nullable = false)
    private int imageSeed;

    @Column(name = "change_deadline_hours", nullable = false)
    private int changeDeadlineHours;

    @Column(name = "demo", nullable = false)
    private boolean demo;

    @OneToMany(mappedBy = "clinic", fetch = FetchType.LAZY)
    @OrderBy("id")
    private List<ClinicService> services = new ArrayList<>();

    protected Clinic() {}

    public Long getId() { return id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public double getLatitude() { return latitude; }
    public void setLatitude(double latitude) { this.latitude = latitude; }
    public double getLongitude() { return longitude; }
    public void setLongitude(double longitude) { this.longitude = longitude; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public double getRating() { return rating; }
    public void setRating(double rating) { this.rating = rating; }
    public int getReviewsCount() { return reviewsCount; }
    public void setReviewsCount(int reviewsCount) { this.reviewsCount = reviewsCount; }
    public Loc getWorkingHours() { return workingHours; }
    public void setWorkingHours(Loc workingHours) { this.workingHours = workingHours; }
    public int getImageSeed() { return imageSeed; }
    public void setImageSeed(int imageSeed) { this.imageSeed = imageSeed; }
    public int getChangeDeadlineHours() { return changeDeadlineHours; }
    public void setChangeDeadlineHours(int changeDeadlineHours) { this.changeDeadlineHours = changeDeadlineHours; }
    public boolean isDemo() { return demo; }
    public void setDemo(boolean demo) { this.demo = demo; }
    public List<ClinicService> getServices() { return services; }
    public void setServices(List<ClinicService> services) { this.services = services; }
}
