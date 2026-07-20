// ============================================================
// FILE: lib/views/screens/client/dashboard/widgets/dashboard_models.dart
// Data models used by the patient dashboard widgets.
// ============================================================

import 'package:flutter/material.dart';
import 'package:rambaa/constants/app_colors.dart';
import 'package:rambaa/models/provider_model.dart';

class ServiceCategory {
  final String emoji;
  final String labelKey;
  final Color bg;

  const ServiceCategory({
    required this.emoji,
    required this.labelKey,
    required this.bg,
  });
}

class DashboardProviderData {
  final String emoji;
  final Color bg;
  final String name;
  final String spec;
  final String rating;
  final String reviews;
  final String distance;
  final String fee;
  final bool available;
  final String? imageUrl;

  const DashboardProviderData({
    required this.emoji,
    required this.bg,
    required this.name,
    required this.spec,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.fee,
    required this.available,
    this.imageUrl,
  });

  factory DashboardProviderData.fromModel(ProviderModel p) {
    final fee = p.consultationFee
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );

    String emoji;
    Color bg;
    switch (p.specialty.toLowerCase()) {
      case 'pediatrician':
        emoji = '👶';
        bg = AppColors.healthGreenLighter;
        break;
      case 'cardiologist':
        emoji = '❤️';
        bg = AppColors.accentLighter;
        break;
      case 'dermatologist':
        emoji = '🧴';
        bg = AppColors.secondaryLighter;
        break;
      case 'gynecologist':
        emoji = '🤰';
        bg = AppColors.primaryLighter;
        break;
      case 'dentist':
        emoji = '🦷';
        bg = AppColors.healthGreenLighter;
        break;
      case 'orthopedist':
        emoji = '🦴';
        bg = AppColors.accentLighter;
        break;
      case 'community nurse':
        emoji = '🤱';
        bg = AppColors.healthGreenLighter;
        break;
      default:
        emoji = '🩺';
        bg = AppColors.primaryLighter;
    }

    return DashboardProviderData(
      emoji: emoji,
      bg: bg,
      name: p.name,
      spec: '${p.specialty} · ${p.experienceYears} yrs exp',
      rating: p.rating.toStringAsFixed(1),
      reviews: p.reviewCount.toString(),
      distance: '${p.distanceKm} km',
      fee: 'RWF $fee',
      available: p.isAvailable,
      imageUrl: p.imageUrl.isNotEmpty ? p.imageUrl : null,
    );
  }
}
