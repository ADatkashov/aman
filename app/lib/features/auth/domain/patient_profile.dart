enum Gender {
  male,
  female;

  static Gender fromId(String? id) => Gender.values.firstWhere(
    (g) => g.name == id?.toLowerCase(),
    orElse: () => Gender.male,
  );
}

class PatientProfile {
  const PatientProfile({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.birthDate,
    this.gender = Gender.male,
    this.bloodType,
    this.city,
    this.avatarSeed = 0,
  });

  final String id;
  final String fullName;

  /// E.164-like normalized phone, e.g. `+77001234567`.
  final String phone;
  final String? email;
  final DateTime? birthDate;
  final Gender gender;
  final String? bloodType;
  final String? city;
  final int avatarSeed;

  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return parts[1];
    return parts.first;
  }

  int? ageAt(DateTime now) {
    final b = birthDate;
    if (b == null) return null;
    var age = now.year - b.year;
    if (now.month < b.month || (now.month == b.month && now.day < b.day)) age--;
    return age;
  }

  PatientProfile copyWith({
    String? fullName,
    String? email,
    DateTime? birthDate,
    Gender? gender,
    String? bloodType,
    String? city,
  }) => PatientProfile(
    id: id,
    fullName: fullName ?? this.fullName,
    phone: phone,
    email: email ?? this.email,
    birthDate: birthDate ?? this.birthDate,
    gender: gender ?? this.gender,
    bloodType: bloodType ?? this.bloodType,
    city: city ?? this.city,
    avatarSeed: avatarSeed,
  );

  factory PatientProfile.fromJson(Map<String, dynamic> json) => PatientProfile(
    id: json['id'].toString(),
    fullName: json['fullName'] as String,
    phone: json['phone'] as String,
    email: json['email'] as String?,
    birthDate: json['birthDate'] == null
        ? null
        : DateTime.parse(json['birthDate'] as String),
    gender: Gender.fromId(json['gender'] as String?),
    bloodType: json['bloodType'] as String?,
    city: json['city'] as String?,
    avatarSeed: (json['avatarSeed'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'birthDate': birthDate?.toIso8601String().substring(0, 10),
    'gender': gender.name.toUpperCase(),
    'bloodType': bloodType,
    'city': city,
  };
}
