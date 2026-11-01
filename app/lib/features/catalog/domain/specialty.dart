import 'package:flutter/material.dart';

/// Medical specialties offered in the catalog. The wire id is [name].
enum Specialty {
  therapist(Icons.medical_services_rounded),
  cardiologist(Icons.favorite_rounded),
  neurologist(Icons.psychology_rounded),
  pediatrician(Icons.child_care_rounded),
  dentist(Icons.mood_rounded),
  dermatologist(Icons.spa_rounded),
  ophthalmologist(Icons.visibility_rounded),
  endocrinologist(Icons.bloodtype_rounded);

  const Specialty(this.icon);
  final IconData icon;

  static Specialty fromId(String id) => Specialty.values.firstWhere(
        (s) => s.name == id,
        orElse: () => Specialty.therapist,
      );
}
