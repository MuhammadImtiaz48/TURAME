// ============================================================
// FILE: lib/controllers/provider_controller.dart
// ============================================================

import 'dart:async';
import 'package:get/get.dart';
import '../../models/provider_model.dart';
import '../../services/firebase_service.dart';

enum ProviderSortOption { rating, distance, fee, experience }

class ProviderController extends GetxController {
  // ── State ─────────────────────────────────────────────────
  final RxList<ProviderModel> _allProviders = <ProviderModel>[].obs;
  final RxList<ProviderModel> filteredProviders = <ProviderModel>[].obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedSpecialty = 'All'.obs;
  final RxString selectedLocation = 'All'.obs;
  final RxBool availableOnly = false.obs;
  final RxBool verifiedOnly = false.obs;
  final Rx<ProviderSortOption> sortOption = ProviderSortOption.rating.obs;
  final RxBool isLoading = false.obs;

  StreamSubscription<List<ProviderModel>>? _providersSubscription;

  // ── Specialty list ────────────────────────────────────────
  final List<String> specialties = const [
    'All',
    'General Physician',
    'Pediatrician',
    'Cardiologist',
    'Community Nurse',
    'Dermatologist',
    'Gynecologist',
    'Dentist',
    'Orthopedist',
    'Physiotherapist',
    'Nutritionist',
    'Psychologist',
  ];

  // ── Location list ─────────────────────────────────────────
  final List<String> locations = const [
    'All',
    'Clinic',
    'Home',
    'Both',
  ];

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _listenToProviders();

    // React to filter changes automatically
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedSpecialty, (_) => _applyFilters());
    ever(selectedLocation, (_) => _applyFilters());
    ever(availableOnly, (_) => _applyFilters());
    ever(verifiedOnly, (_) => _applyFilters());
    ever(sortOption, (_) => _applyFilters());
  }

  void _listenToProviders() {
    isLoading.value = true;
    _providersSubscription = FirebaseService.getProvidersStream().listen(
      (fetched) {
        _allProviders.assignAll(fetched);
        _applyFilters();
        isLoading.value = false;
      },
      onError: (e) {
        _allProviders.assignAll([]);
        _applyFilters();
        isLoading.value = false;
      },
    );
  }

  @override
  void onClose() {
    _providersSubscription?.cancel();
    super.onClose();
  }

  @override
  Future<void> refresh() async {
    _providersSubscription?.cancel();
    _listenToProviders();
  }

  // ── Filter & Sort logic ───────────────────────────────────
  void _applyFilters() {
    List<ProviderModel> result = List.from(_allProviders);

    // Search
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((p) =>
      p.name.toLowerCase().contains(q) ||
          p.specialty.toLowerCase().contains(q) ||
          p.hospital.toLowerCase().contains(q)).toList();
    }

    // Specialty filter
    if (selectedSpecialty.value != 'All') {
      result = result.where((p) => p.specialty.toLowerCase() == selectedSpecialty.value.toLowerCase()).toList();
    }

    // Location filter
    if (selectedLocation.value != 'All') {
      result = result.where((p) => p.providerLocation == selectedLocation.value).toList();
    }

    // Available only
    if (availableOnly.value) {
      result = result.where((p) => p.isAvailable).toList();
    }

    // Verified only
    if (verifiedOnly.value) {
      result = result.where((p) => p.isVerified).toList();
    }

    // Sort
    switch (sortOption.value) {
      case ProviderSortOption.rating:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ProviderSortOption.distance:
        result.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      case ProviderSortOption.fee:
        result.sort((a, b) => a.consultationFee.compareTo(b.consultationFee));
        break;
      case ProviderSortOption.experience:
        result.sort((a, b) => b.experienceYears.compareTo(a.experienceYears));
        break;
    }

    filteredProviders.assignAll(result);
  }

  // ── Public helpers ────────────────────────────────────────
  void setSearch(String val) => searchQuery.value = val;
  void setSpecialty(String val) => selectedSpecialty.value = val;
  void setLocation(String val) => selectedLocation.value = val;
  void toggleAvailable() => availableOnly.toggle();
  void toggleVerified() => verifiedOnly.toggle();
  void setSortOption(ProviderSortOption opt) => sortOption.value = opt;

  void clearFilters() {
    searchQuery.value = '';
    selectedSpecialty.value = 'All';
    selectedLocation.value = 'All';
    availableOnly.value = false;
    verifiedOnly.value = false;
    sortOption.value = ProviderSortOption.rating;
    filteredProviders.value = List.from(_allProviders);
  }

  bool get hasActiveFilters =>
      selectedSpecialty.value != 'All' ||
      selectedLocation.value != 'All' ||
          availableOnly.value ||
          verifiedOnly.value ||
          sortOption.value != ProviderSortOption.rating;
}