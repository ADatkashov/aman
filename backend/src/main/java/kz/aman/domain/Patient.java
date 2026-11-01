package kz.aman.domain;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "patients")
public class Patient {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private UserAccount user;

    @Column(name = "full_name", nullable = false, length = 200)
    private String fullName;

    @Column(name = "email", length = 200)
    private String email;

    @Column(name = "birth_date")
    private LocalDate birthDate;

    @Column(name = "gender", length = 10)
    private String gender;

    @Column(name = "blood_type", length = 20)
    private String bloodType;

    @Column(name = "city", length = 100)
    private String city;

    @Column(name = "avatar_seed", nullable = false)
    private int avatarSeed;

    protected Patient() {}

    public Long getId() { return id; }
    public UserAccount getUser() { return user; }
    public void setUser(UserAccount user) { this.user = user; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public LocalDate getBirthDate() { return birthDate; }
    public void setBirthDate(LocalDate birthDate) { this.birthDate = birthDate; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public String getBloodType() { return bloodType; }
    public void setBloodType(String bloodType) { this.bloodType = bloodType; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public int getAvatarSeed() { return avatarSeed; }
    public void setAvatarSeed(int avatarSeed) { this.avatarSeed = avatarSeed; }

    public Patient(UserAccount user, String fullName) {
        this.user = user;
        this.fullName = fullName;
        this.gender = "MALE";
    }
}
