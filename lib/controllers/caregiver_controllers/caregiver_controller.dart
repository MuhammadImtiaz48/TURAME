// ============================================================
// FILE: lib/controllers/caregiver_controller.dart
// ============================================================

import 'package:get/get.dart';
import '../../models/caregiver_model.dart';
import '../../services/firebase_service.dart';

enum CaregiverSortOption { rating, distance, fee, experience }

class CaregiverController extends GetxController {
  // ── State ─────────────────────────────────────────────────
  final RxList<CaregiverModel> _allCaregivers = <CaregiverModel>[].obs;
  final RxList<CaregiverModel> filteredCaregivers = <CaregiverModel>[].obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString selectedLocation = 'All'.obs;
  final RxBool availableOnly = false.obs;
  final RxBool verifiedOnly = false.obs;
  final Rx<CaregiverSortOption> sortOption = CaregiverSortOption.rating.obs;
  final RxBool isLoading = false.obs;

  // ── Category list ─────────────────────────────────────────
  final List<String> categories = const [
    'All',
    'Elderly Care',
    'Child Care',
    'Home Support',
    'Disability',
    'Post-Surgery',
    'Palliative',
  ];

  final List<String> locations = const [
    'All',
    'Home',
    'Hospital',
    'Both',
  ];

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadCaregivers();
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedCategory, (_) => _applyFilters());
    ever(selectedLocation, (_) => _applyFilters());
    ever(availableOnly, (_) => _applyFilters());
    ever(verifiedOnly, (_) => _applyFilters());
    ever(sortOption, (_) => _applyFilters());
  }

  Future<void> _loadCaregivers() async {
    isLoading.value = true;
    try {
      final caregivers = await FirebaseService.getCaregivers();
      _allCaregivers.assignAll(caregivers);
    } catch (e) {
      _allCaregivers.assignAll([]);
    }
    _applyFilters();
    isLoading.value = false;
  }

  @override
  Future<void> refresh() async => _loadCaregivers();

  void _applyFilters() {
    List<CaregiverModel> result = List.from(_allCaregivers);

    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((c) =>
      c.name.toLowerCase().contains(q) ||
          c.serviceType.toLowerCase().contains(q) ||
          c.skills.any((s) => s.toLowerCase().contains(q))).toList();
    }

    if (selectedCategory.value != 'All') {
      result = result
          .where((c) => c.serviceType == selectedCategory.value)
          .toList();
    }

    if (selectedLocation.value != 'All') {
      result = result.where((c) => c.location == selectedLocation.value).toList();
    }

    if (availableOnly.value) {
      result = result.where((c) => c.isAvailable).toList();
    }

    if (verifiedOnly.value) {
      result = result.where((c) => c.isVerified).toList();
    }

    switch (sortOption.value) {
      case CaregiverSortOption.rating:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case CaregiverSortOption.distance:
        result.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      case CaregiverSortOption.fee:
        result.sort((a, b) => a.dailyRate.compareTo(b.dailyRate));
        break;
      case CaregiverSortOption.experience:
        result.sort((a, b) => b.experienceYears.compareTo(a.experienceYears));
        break;
    }

    filteredCaregivers.assignAll(result);
  }

  void setSearch(String val) => searchQuery.value = val;
  void setCategory(String val) => selectedCategory.value = val;
  void setLocation(String val) => selectedLocation.value = val;
  void toggleAvailable() => availableOnly.toggle();
  void toggleVerified() => verifiedOnly.toggle();
  void setSortOption(CaregiverSortOption opt) => sortOption.value = opt;

  void clearFilters() {
    searchQuery.value = '';
    selectedCategory.value = 'All';
    selectedLocation.value = 'All';
    availableOnly.value = false;
    verifiedOnly.value = false;
    sortOption.value = CaregiverSortOption.rating;
  }

  bool get hasActiveFilters =>
      selectedCategory.value != 'All' ||
      selectedLocation.value != 'All' ||
          availableOnly.value ||
          verifiedOnly.value ||
          sortOption.value != CaregiverSortOption.rating;
}