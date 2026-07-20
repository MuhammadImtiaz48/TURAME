import 'package:get/get.dart';

import '../models/appointment_model.dart';
import '../services/firebase_service.dart';
import 'auth_controllers/auth_controller.dart';

class AppointmentController extends GetxController {
  final AuthController _authCtrl = Get.find<AuthController>();
  final selectedTab = 0.obs;

  final RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final patientId = _authCtrl.user.value?.id ?? '';
    if (patientId.isEmpty) return;
    try {
      final maps = await FirebaseService.getAppointmentsByPatient(patientId);
      if (maps.isNotEmpty) {
        appointments.assignAll(maps.map((m) => AppointmentModel.fromMap(m, m['id'] ?? '')));
      }
    } catch (e) {
      // Keep existing data on error
    }
  }

  Future<void> _persistStatus(String id, AppointmentStatus status) async {
    try {
      await FirebaseService.updateAppointmentStatus(id, status.name);
    } catch (e) {
      // Local list already updated optimistically
    }
  }

  Future<void> _persistCallCompleted(String id, bool value) async {
    try {
      await FirebaseService.updateAppointmentStatus(id, value ? 'completed' : 'pending');
    } catch (e) {
      // Best-effort
    }
  }

  AppointmentModel? getActiveAppointmentForProvider(String providerId) {
    return appointments.firstWhereOrNull(
      (a) =>
          a.providerId == providerId &&
          (a.status == AppointmentStatus.confirmed || a.status == AppointmentStatus.pending) &&
          !a.callCompleted &&
          a.isWithinCallWindow,
    );
  }

  bool canCallProvider(String providerId) {
    return getActiveAppointmentForProvider(providerId) != null;
  }

  AppointmentType? callTypeForProvider(String providerId) {
    final appt = getActiveAppointmentForProvider(providerId);
    return appt?.type;
  }

  void markCallCompleted(String id) {
    final index = appointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      appointments[index] = appointments[index].copyWith(
        callCompleted: true,
        status: AppointmentStatus.completed,
      );
      _persistCallCompleted(id, true);
    }
  }

  // ─── Getters ─────────────────────────────────────────────────

  List<AppointmentModel> get upcoming {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return appointments
        .where((a) =>
            (a.status == AppointmentStatus.confirmed ||
                a.status == AppointmentStatus.pending) &&
            !DateTime(a.dateTime.year, a.dateTime.month, a.dateTime.day)
                .isBefore(today))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<AppointmentModel> get completed => appointments
      .where((a) => a.status == AppointmentStatus.completed)
      .toList();

  List<AppointmentModel> get cancelled => appointments
      .where((a) => a.status == AppointmentStatus.cancelled)
      .toList();

  List<AppointmentModel> get currentList {
    switch (selectedTab.value) {
      case 0:  return upcoming;
      case 1:  return completed;
      case 2:  return cancelled;
      default: return upcoming;
    }
  }

  AppointmentModel? get nextAppointment {
    if (upcoming.isEmpty) return null;
    final sorted = [...upcoming]
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return sorted.first;
  }

  // ─── Actions ─────────────────────────────────────────────────

  void changeTab(int index) => selectedTab.value = index;

  Future<void> reload() async => _loadAppointments();

  void cancelAppointment(String id) {
    final index = appointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      appointments[index] = appointments[index].copyWith(
        status: AppointmentStatus.cancelled,
      );
      _persistStatus(id, AppointmentStatus.cancelled);
    }
  }

  void confirmAppointment(String id) {
    final index = appointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      appointments[index] = appointments[index].copyWith(
        status: AppointmentStatus.confirmed,
      );
      _persistStatus(id, AppointmentStatus.confirmed);
    }
  }
}