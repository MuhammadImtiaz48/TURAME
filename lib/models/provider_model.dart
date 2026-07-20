// ============================================================
// FILE: lib/models/provider_model.dart
// ============================================================

class ProviderModel {
  final String id;
  final String name;
  final String specialty;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final double consultationFee;
  final bool isAvailable;
  final bool isVerified;
  final int experienceYears;
  final double distanceKm;
  final List<String> languages;
  final List<String> services;
  final String hospital;
  final String providerLocation;
  final String licenseNumber;
  final String bio;
  final List<Map<String, dynamic>> availability;
  final List<String> education;

  const ProviderModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.consultationFee,
    required this.isAvailable,
    required this.isVerified,
    required this.experienceYears,
    required this.distanceKm,
    required this.languages,
    required this.services,
    required this.hospital,
    required this.providerLocation,
    this.licenseNumber = '',
    this.bio = '',
    this.availability = const [],
    this.education = const [],
  });

  // ── Firestore mapping ───────────────────────────────────────
  factory ProviderModel.fromMap(Map<String, dynamic> map) {
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

    return ProviderModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      specialty: map['specialty'] ?? 'General Physician',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 0.0,
      reviewCount:
          (map['reviewCount'] is num) ? (map['reviewCount'] as num).toInt() : 0,
      consultationFee: (map['consultationFee'] is num)
          ? (map['consultationFee'] as num).toDouble()
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
      services: parseList(map['services']),
      hospital: map['hospital'] ?? '',
      providerLocation: map['providerLocation'] ?? 'Clinic',
      licenseNumber: map['licenseNumber'] ?? '',
      bio: map['bio'] ?? '',
      availability: parseAvailability(map['availability']),
      education: parseList(map['education']),
    );
  }

  ProviderModel copyWith({
    String? id,
    String? name,
    String? specialty,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    double? consultationFee,
    bool? isAvailable,
    bool? isVerified,
    int? experienceYears,
    double? distanceKm,
    List<String>? languages,
    List<String>? services,
    String? hospital,
    String? providerLocation,
    String? licenseNumber,
    String? bio,
    List<Map<String, dynamic>>? availability,
    List<String>? education,
  }) {
    return ProviderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      consultationFee: consultationFee ?? this.consultationFee,
      isAvailable: isAvailable ?? this.isAvailable,
      isVerified: isVerified ?? this.isVerified,
      experienceYears: experienceYears ?? this.experienceYears,
      distanceKm: distanceKm ?? this.distanceKm,
      languages: languages ?? this.languages,
      services: services ?? this.services,
      hospital: hospital ?? this.hospital,
      providerLocation: providerLocation ?? this.providerLocation,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      bio: bio ?? this.bio,
      availability: availability ?? this.availability,
      education: education ?? this.education,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'specialty': specialty,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'consultationFee': consultationFee,
      'isAvailable': isAvailable,
      'isVerified': isVerified,
      'experienceYears': experienceYears,
      'distanceKm': distanceKm,
      'languages': languages,
      'services': services,
      'hospital': hospital,
      'providerLocation': providerLocation,
      'licenseNumber': licenseNumber,
      'bio': bio,
      'availability': availability,
      'education': education,
    };
  }
}
