// ============================================================
// FILE: lib/models/caregiver_model.dart
// ============================================================

class CaregiverModel {
  final String id;
  final String name;
  final String serviceType;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final double dailyRate;
  final int experienceYears;
  final double distanceKm;
  final List<String> skills;
  final bool isAvailable;
  final bool isVerified;
  final List<String> languages;
  final String location;

  const CaregiverModel({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.dailyRate,
    required this.experienceYears,
    required this.distanceKm,
    required this.skills,
    required this.isAvailable,
    required this.isVerified,
    required this.languages,
    required this.location,
  });

  factory CaregiverModel.fromMap(Map<String, dynamic> map) {
    List<String> parseList(dynamic value) {
      if (value is List) return value.map((e) => e.toString()).toList();
      return const [];
    }

    return CaregiverModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      serviceType: map['serviceType'] ?? 'Caregiver',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 0.0,
      reviewCount: (map['reviewCount'] is num) ? (map['reviewCount'] as num).toInt() : 0,
      dailyRate: (map['dailyRate'] is num) ? (map['dailyRate'] as num).toDouble() : 0.0,
      experienceYears: (map['experienceYears'] is num) ? (map['experienceYears'] as num).toInt() : 0,
      distanceKm: (map['distanceKm'] is num) ? (map['distanceKm'] as num).toDouble() : 0.0,
      skills: parseList(map['skills']),
      isAvailable: map['isAvailable'] ?? false,
      isVerified: map['isVerified'] ?? false,
      languages: parseList(map['languages']),
      location: map['location'] ?? 'Kigali, Rwanda',
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
      'experienceYears': experienceYears,
      'distanceKm': distanceKm,
      'skills': skills,
      'isAvailable': isAvailable,
      'isVerified': isVerified,
      'languages': languages,
      'location': location,
    };
  }
}
