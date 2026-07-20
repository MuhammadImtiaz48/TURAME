import 'dart:async';

import 'package:get/get.dart';

import '../../models/appointment_model.dart';
import '../../models/notification_model.dart';
import '../../models/patient_model.dart';
import '../../models/provider_appointment_model.dart';
import '../../models/provider_earning_model.dart';
import '../../models/payment_model.dart';
import '../../models/user_model.dart';
import '../../models/withdrawal_model.dart';
import '../../services/firebase_service.dart';
import '../auth_controllers/auth_controller.dart';
import 'provider_profile_controller.dart';

class ProviderDashboardController extends GetxController {
  final AuthController _authCtrl = Get.find<AuthController>();
  StreamSubscription? _earningsSub;
  StreamSubscription? _withdrawalsSub;
  StreamSubscription? _notificationsSub;

  @override
  void onInit() {
    super.onInit();
    _loadDashboardData();
    _listenEarnings();
    _listenWithdrawals();
    _listenNotifications();
  }

  @override
  void onClose() {
    _earningsSub?.cancel();
    _withdrawalsSub?.cancel();
    _notificationsSub?.cancel();
    super.onClose();
  }

  void _listenNotifications() {
    final providerId = _authCtrl.user.value?.id ?? '';
    if (providerId.isEmpty) return;

    _notificationsSub?.cancel();
    _notificationsSub = FirebaseService.notificationsStream(providerId).listen(
      (items) {
        final count = items
            .where((n) => !n.isRead)
            .where((n) =>
                n.type != NotificationType.message &&
                n.type != NotificationType.call)
            .length;
        notifCount.value = count;
      },
      onError: (_) {},
    );
  }

  void _listenEarnings() {
    final providerId = _authCtrl.user.value?.id ?? '';
    if (providerId.isEmpty) return;

    _earningsSub?.cancel();
    _earningsSub = FirebaseService.paymentsByProviderStream(providerId).listen(
      (payments) {
        final success =
            payments.where((p) => p.status == TransactionStatus.success).toList();
        earnings.assignAll(
          success.map(ProviderEarningModel.fromPayment).toList(),
        );

        final now = DateTime.now();
        final thisMonthLabel = FirebaseService.monthLabel(now);
        final monthTotal = success
            .where((p) => p.month == thisMonthLabel)
            .fold<double>(0, (sum, p) => sum + p.amount);
        monthlyEarnings.value = monthTotal.round();

        final totalEarned =
            success.fold<double>(0, (sum, p) => sum + p.amount);
        this.totalEarned.value = totalEarned;
        availableBalance.value = totalEarned - totalWithdrawn.value;

        // Compare to previous month to show growth.
        final prevMonth = DateTime(now.year, now.month - 1);
        final prevLabel = FirebaseService.monthLabel(prevMonth);
        final prevTotal = success
            .where((p) => p.month == prevLabel)
            .fold<double>(0, (sum, p) => sum + p.amount);
        if (prevTotal > 0) {
          final growth = ((monthTotal - prevTotal) / prevTotal) * 100;
          earningsGrowth.value =
              '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(0)}%';
        } else {
          earningsGrowth.value = monthTotal > 0 ? '+100%' : '0%';
        }

        // Simple 7-day bar data from successful payments.
        final bars = List<double>.filled(7, 0);
        for (final p in success) {
          final daysAgo = now.difference(p.createdAt).inDays;
          if (daysAgo >= 0 && daysAgo < 7) {
            bars[6 - daysAgo] += p.amount;
          }
        }
        barData.assignAll(bars);
      },
      onError: (_) {},
    );
  }

  void _listenWithdrawals() {
    final providerId = _authCtrl.user.value?.id ?? '';
    if (providerId.isEmpty) return;

    _withdrawalsSub?.cancel();
    _withdrawalsSub = FirebaseService.withdrawalsByProviderStream(providerId).listen(
      (withdrawals) {
        final total = withdrawals
            .where((w) => w.status == 'completed')
            .fold<double>(0, (sum, w) => sum + w.amount);
        totalWithdrawn.value = total;
        availableBalance.value = totalEarned.value - totalWithdrawn.value;
      },
      onError: (_) {},
    );
  }

  Future<void> _loadDashboardData() async {
    final providerId = _authCtrl.user.value?.id ?? '';
    if (providerId.isEmpty) return;

    try {
      final maps = await FirebaseService.getAppointmentsByProvider(providerId);
      final patientIds = <String>{};
      final appointmentModels = <ProviderAppointmentModel>[];

      for (final map in maps) {
        final pid = map['patientId']?.toString();
        if (pid != null && pid.isNotEmpty) {
          patientIds.add(pid);
        }
        appointmentModels.add(ProviderAppointmentModel.fromMap(map));
      }

      schedule.assignAll(appointmentModels);

      if (patientIds.isEmpty) {
        patients.assignAll([]);
        return;
      }

      final fetched = await FirebaseService.getPatients();
      final bookedPatients =
          fetched.where((p) => patientIds.contains(p.id)).toList();

      if (bookedPatients.isNotEmpty) {
        patients.assignAll(bookedPatients);
      }
    } catch (e) {
      // Keep existing data on error
    }
  }

  Future<void> _persistAppointmentStatus(
      String id, AppointmentStatus status) async {
    try {
      await FirebaseService.updateAppointmentStatus(id, status.name);
    } catch (e) {
      // Local list already updated optimistically
    }
  }

  // ── Profile ───────────────────────────────────────────────────
  String get doctorName => _authCtrl.user.value?.name ?? '';
  String get specialty => _getSpecialtyFromRole(_authCtrl.user.value?.role);

  String _getSpecialtyFromRole(UserRole? role) {
    switch (role) {
      case UserRole.provider:
        return 'Healthcare Provider';
      case UserRole.caregiver:
        return 'Caregiver';
      case UserRole.home:
        return 'Home Healthcare Provider';
      default:
        return 'Patient';
    }
  }

  // ── Stats ─────────────────────────────────────────────────────
  int get todayCount => todaysRegisteredPatients.length;
  int get thisWeekCount => weekRegisteredPatients.length;
  int get pendingCount => pendingPatients.length;

  // ── Notifications ─────────────────────────────────────────────
  final RxInt notifCount = 0.obs;

  // ── Earnings summary ──────────────────────────────────────────
  final RxInt monthlyEarnings = 0.obs;
  final RxString earningsGrowth = '0%'.obs;
  final RxList<double> barData = <double>[].obs;
  final RxDouble availableBalance = 0.0.obs;
  final RxDouble totalWithdrawn = 0.0.obs;
  final RxDouble totalEarned = 0.0.obs;

  // ── Data lists ────────────────────────────────────────────────
  final RxList<PatientModel> patients = <PatientModel>[].obs;
  final RxList<ProviderAppointmentModel> schedule = <ProviderAppointmentModel>[].obs;
  final RxList<ProviderEarningModel> earnings = <ProviderEarningModel>[].obs;

  // ── Tab / filter state ────────────────────────────────────────
  final RxInt currentTab = 0.obs;
  final RxInt patientsTab = 0.obs;
  final RxInt scheduleTab = 0.obs;
  final RxInt selectedDayIndex = 0.obs;
  final RxString patientSearchQuery = ''.obs;
  final RxString earningsFilter = 'This Month'.obs;

  // ── Greeting ──────────────────────────────────────────────────
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning_doctor'.tr;
    if (hour < 17) return 'good_afternoon_doctor'.tr;
    return 'good_evening_doctor'.tr;
  }

  String get formattedMonthlyEarnings {
    final formatted = monthlyEarnings.value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return 'RWF $formatted';
  }

  String get formattedBalance {
    final formatted = availableBalance.value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return 'RWF $formatted';
  }

  String get formattedRemainingBalance => formattedBalance;

  String get formattedWithdrawn {
    final formatted = totalWithdrawn.value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return 'RWF $formatted';
  }

  // ── Patients ──────────────────────────────────────────────────
  List<PatientModel> get allPatients => patients;

  List<PatientModel> get activePatients =>
      patients.where((p) => p.status == PatientStatus.active).toList();

  List<PatientModel> get pendingPatients =>
      patients.where((p) => p.status == PatientStatus.pending).toList();

  List<PatientModel> get filteredPatients {
    List<PatientModel> list;
    switch (patientsTab.value) {
      case 1:
        list = pendingPatients;
        break;
      case 2:
        list = activePatients;
        break;
      default:
        list = allPatients;
    }

    final q = patientSearchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.condition.toLowerCase().contains(q))
        .toList();
  }

  List<PatientModel> get todaysRegisteredPatients {
    final now = DateTime.now();
    return patients.where((p) {
      if (p.registeredAt == null) return false;
      return p.registeredAt!.year == now.year &&
          p.registeredAt!.month == now.month &&
          p.registeredAt!.day == now.day;
    }).toList();
  }

  List<PatientModel> get weekRegisteredPatients {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return patients.where((p) {
      if (p.registeredAt == null) return false;
      return !p.registeredAt!.isBefore(weekStart);
    }).toList();
  }

  // Today's registered patients first; if fewer than 4, fill with the
  // top recent patients so the dashboard always shows up to 4 patients.
  List<PatientModel> get todaysOrTopPatients {
    final now = DateTime.now();
    final today = patients.where((p) {
      if (p.registeredAt == null) return false;
      return p.registeredAt!.year == now.year &&
          p.registeredAt!.month == now.month &&
          p.registeredAt!.day == now.day;
    }).toList();

    final result = <PatientModel>[...today];
    for (final p in patients) {
      if (result.length >= 4) break;
      if (!result.contains(p)) result.add(p);
    }
    return result;
  }

  String patientTimeLabel(PatientModel p) {
    final appt = todaySchedule
        .where((a) => a.patientId == p.id)
        .fold<ProviderAppointmentModel?>(null, (prev, a) {
      if (prev == null) return a;
      return a.dateTime.isBefore(prev.dateTime) ? a : prev;
    });
    if (appt != null) {
      final dt = appt.dateTime;
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return 'Today · $hour:$minute $ampm';
    }
    return p.lastVisit;
  }

  List<ProviderAppointmentModel> get todaySchedule {
    final now = DateTime.now();
    return schedule.where((a) {
      return a.dateTime.year == now.year &&
          a.dateTime.month == now.month &&
          a.dateTime.day == now.day;
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  // Patients whose appointment is scheduled for today only (no fallback
  // to all patients).
  List<PatientModel> get todaysPatients {
    final ids = todaySchedule.map((a) => a.patientId).toSet();
    return patients.where((p) => ids.contains(p.id)).toList();
  }

  List<ProviderAppointmentModel> get pendingAppointments => schedule
      .where((a) => a.status == AppointmentStatus.pending)
      .toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  List<ProviderAppointmentModel> get upcomingSchedule => schedule
      .where((a) =>
          a.status == AppointmentStatus.confirmed ||
          a.status == AppointmentStatus.pending)
      .toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  List<ProviderAppointmentModel> get completedSchedule => schedule
      .where((a) => a.status == AppointmentStatus.completed)
      .toList()
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  List<ProviderAppointmentModel> get cancelledSchedule => schedule
      .where((a) => a.status == AppointmentStatus.cancelled)
      .toList()
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  List<ProviderAppointmentModel> get currentScheduleList {
    switch (scheduleTab.value) {
      case 1:
        return upcomingSchedule;
      case 2:
        return completedSchedule;
      case 3:
        return cancelledSchedule;
      default:
        return selectedDayAppointments;
    }
  }

  List<Map<String, dynamic>> get weekDays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return List.generate(7, (i) {
      final day = today.add(Duration(days: i));
      return {
        'label': days[day.weekday % 7],
        'date': day.day,
        'fullDate': day,
        'isToday': day.day == now.day &&
            day.month == now.month &&
            day.year == now.year,
        'appointmentCount': schedule.where((a) {
          return a.dateTime.year == day.year &&
              a.dateTime.month == day.month &&
              a.dateTime.day == day.day &&
              a.status != AppointmentStatus.cancelled;
        }).length,
      };
    });
  }

  List<ProviderAppointmentModel> get selectedDayAppointments {
    final day = weekDays[selectedDayIndex.value]['fullDate'] as DateTime;
    return schedule
        .where((a) =>
            a.dateTime.year == day.year &&
            a.dateTime.month == day.month &&
            a.dateTime.day == day.day)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<ProviderEarningModel> get filteredEarnings {
    if (earningsFilter.value == 'All Time') return earnings;
    final label = FirebaseService.monthLabel(DateTime.now());
    return earnings.where((e) => e.month == label).toList();
  }

  Map<String, List<ProviderEarningModel>> get groupedEarnings {
    final map = <String, List<ProviderEarningModel>>{};
    for (final e in filteredEarnings) {
      map.putIfAbsent(e.month, () => []).add(e);
    }
    return map;
  }

  int get totalEarningTransactions => filteredEarnings.length;

  String get totalEarningsAmount {
    final total = filteredEarnings
        .where((e) => e.status == TransactionStatus.success)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final formatted = total.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return 'RWF $formatted';
  }

  PatientModel? patientById(String id) {
    return patients.firstWhereOrNull((p) => p.id == id);
  }

  // ── Actions ───────────────────────────────────────────────────
  void changePatientsTab(int index) => patientsTab.value = index;
  void changeScheduleTab(int index) => scheduleTab.value = index;
  void selectDay(int index) => selectedDayIndex.value = index;
  void setPatientSearch(String query) => patientSearchQuery.value = query;
  void toggleEarningsFilter() {
    earningsFilter.value =
        earningsFilter.value == 'This Month' ? 'All Time' : 'This Month';
  }

  void acceptPatient(String id) {
    final index = patients.indexWhere((p) => p.id == id);
    if (index != -1) {
      patients[index] =
          patients[index].copyWith(status: PatientStatus.active);
    }
  }

  void declinePatient(String id) {
    patients.removeWhere((p) => p.id == id);
  }

  Future<bool> updatePatient(PatientModel updated) async {
    final index = patients.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      patients[index] = updated;
    }
    try {
      await FirebaseService.updatePatient(updated);
      return true;
    } catch (e) {
      return false;
    }
  }

  void confirmAppointment(String id) {
    final index = schedule.indexWhere((a) => a.id == id);
    if (index != -1) {
      schedule[index] = schedule[index]
          .copyWith(status: AppointmentStatus.confirmed);
      _persistAppointmentStatus(id, AppointmentStatus.confirmed);
    }
  }

  void cancelAppointment(String id) {
    final index = schedule.indexWhere((a) => a.id == id);
    if (index != -1) {
      schedule[index] = schedule[index]
          .copyWith(status: AppointmentStatus.cancelled);
      _persistAppointmentStatus(id, AppointmentStatus.cancelled);
    }
  }

  void completeAppointment(String id) {
    final index = schedule.indexWhere((a) => a.id == id);
    if (index != -1) {
      final appointment = schedule[index];
      schedule[index] = appointment
          .copyWith(status: AppointmentStatus.completed);
      _persistAppointmentStatus(id, AppointmentStatus.completed);

      final pIndex = patients.indexWhere((p) => p.id == appointment.patientId);
      if (pIndex != -1 && patients[pIndex].status != PatientStatus.inactive) {
        final updated = patients[pIndex]
            .copyWith(status: PatientStatus.inactive);
        patients[pIndex] = updated;
        FirebaseService.updatePatient(updated);
      }

      _addRatingPoint();
    }
  }

  void _addRatingPoint() {
    if (!Get.isRegistered<ProviderProfileController>()) return;
    final profileCtrl = Get.find<ProviderProfileController>();
    final current = profileCtrl.profile.value;
    if (current == null) return;
    final newRating = (current.rating + 0.5).clamp(0.0, 5.0);
    if (newRating == current.rating) return;
    final updated = current.copyWith(
      rating: newRating,
      reviewCount: current.reviewCount + 1,
    );
    profileCtrl.profile.value = updated;
    FirebaseService.updateProvider(updated);
  }

  Future<bool> withdrawEarnings(double amount, String methodId) async {
    if (amount <= 0 || amount > availableBalance.value) return false;

    final userId = _authCtrl.user.value?.id ?? '';
    if (userId.isEmpty) return false;

    final method = methodId == 'airtel'
        ? WithdrawalMethod.airtelMoney
        : WithdrawalMethod.mtnMobile;

    try {
      await FirebaseService.createWithdrawal(WithdrawalRecord(
        id: '',
        userId: userId,
        userRole: 'provider',
        amount: amount,
        method: method,
        createdAt: DateTime.now(),
        status: 'completed',
      ));
      await _notifyWithdrawalSuccess(userId, amount);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _notifyWithdrawalSuccess(String userId, double amount) async {
    try {
      final enabled = await FirebaseService.isNotificationsEnabled(userId);
      if (!enabled) return;
      await FirebaseService.createNotification(
        userId: userId,
        title: 'Withdrawal Successful',
        message: 'RWF ${amount.toStringAsFixed(0)} has been sent to your account.',
        type: NotificationType.payment,
        category: 'Earnings',
        data: {'amount': amount.toStringAsFixed(0)},
      );
    } catch (_) {}
  }
}
