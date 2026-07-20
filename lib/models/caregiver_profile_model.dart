// ============================================================
// FILE: lib/models/caregiver_profile_model.dart
// ============================================================

class CaregiverProfileModel {
  final String id;
  final String name;
  final String serviceType;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final double dailyRate;
  final bool isAvailable;
  final bool isVerified;
  final int experienceYears;
  final double distanceKm;
  final List<String> languages;
  final List<String> skills;
  final String location;
  final String bio;
  final List<Map<String, dynamic>> availability;

  const CaregiverProfileModel({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.dailyRate,
    required this.isAvailable,
    required this.isVerified,
    required this.experienceYears,
    required this.distanceKm,
    required this.languages,
    required this.skills,
    required this.location,
    this.bio = '',
    this.availability = const [],
  });

  // ── Firestore mapping ───────────────────────────────────────
  factory CaregiverProfileModel.fromMap(Map<String, dynamic> map) {
    List<String> parseList(dynamic value) {
      if (value is List) return value.map((e) => e.toString()).toList();
      return const [];
    }

    List<Map<String, dynamic>> parseAvailability(dynamic value) {
      if (value is List) {
        return value.map((e) {
          if (e is Map) return Map<String, dynamic>.from(e);
          return <String, dynamic>{};
        }).toList();
      }
      return const [];
    }

    return CaregiverProfileModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      serviceType: map['serviceType'] ?? 'Caregiver',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 0.0,
      reviewCount:
          (map['reviewCount'] is num) ? (map['reviewCount'] as num).toInt() : 0,
      dailyRate: (map['dailyRate'] is num)
          ? (map['dailyRate'] as num).toDouble()
          : 0.0,
      isAvailable: map['isAvailable'] ?? false,
      isVerified: map['isVerified'] ?? false,
      experienceYears: (map['experienceYears'] is num)
          ? (map['experienceYears'] as num).toInt()
          : 0,
      distanceKm: (map['distanceKm'] is num)
          ? (map['distanceKm'] as num).toDouble()
          : 0.0,
      languages: parseList(map['languages']),
      skills: parseList(map['skills']),
      location: map['location'] ?? 'Kigali, Rwanda',
      bio: map['bio'] ?? '',
      availability: parseAvailability(map['availability']),
    );
  }

  CaregiverProfileModel copyWith({
    String? id,
    String? name,
    String? serviceType,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    double? dailyRate,
    bool? isAvailable,
    bool? isVerified,
    int? experienceYears,
    double? distanceKm,
    List<String>? languages,
    List<String>? skills,
    String? location,
    String? bio,
    List<Map<String, dynamic>>? availability,
  }) {
    return CaregiverProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      serviceType: serviceType ?? this.serviceType,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      dailyRate: dailyRate ?? this.dailyRate,
      isAvailable: isAvailable ?? this.isAvailable,
      isVerified: isVerified ?? this.isVerified,
      experienceYears: experienceYears ?? this.experienceYears,
      distanceKm: distanceKm ?? this.distanceKm,
      languages: languages ?? this.languages,
      skills: skills ?? this.skills,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      availability: availability ?? this.availability,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'serviceType': serviceType,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'dailyRate': dailyRate,
      'isAvailable': isAvailable,
      'isVerified': isVerified,
      'experienceYears': experienceYears,
      'distanceKm': distanceKm,
      'languages': languages,
      'skills': skills,
      'location': location,
      'bio': bio,
      'availability': availability,
    };
  }
}
