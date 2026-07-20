import 'dart:async';

import 'package:get/get.dart';

import '../../models/appointment_model.dart';
import '../../models/caregiver_client_model.dart';
import '../../models/caregiver_earning_model.dart';
import '../../models/caregiver_schedule_model.dart';
import '../../models/notification_model.dart';
import '../../models/payment_model.dart';
import '../../models/user_model.dart';
import '../../models/withdrawal_model.dart';
import '../../services/firebase_service.dart';
import '../../controllers/caregiver_profile_controller.dart';
import '../auth_controllers/auth_controller.dart';

class CaregiverDashboardController extends GetxController {
  final AuthController _authCtrl = Get.find<AuthController>();
  StreamSubscription? _earningsSub;
  StreamSubscription? _withdrawalsSub;
  StreamSubscription? _notificationsSub;
  StreamSubscription? _appointmentsSub;

  // Clients the caregiver has locally accepted or declined, so live stream
  // updates don't overwrite those decisions.
  final Set<String> _acceptedClientIds = <String>{};
  final Set<String> _declinedClientIds = <String>{};

  @override
  void onInit() {
    super.onInit();
    selectedDayIndex.value = 0;
    _listenAppointments();
    _listenEarnings();
    _listenWithdrawals();
    _listenNotifications();
  }

  @override
  void onClose() {
    _earningsSub?.cancel();
    _withdrawalsSub?.cancel();
    _notificationsSub?.cancel();
    _appointmentsSub?.cancel();
    super.onClose();
  }

  void _listenNotifications() {
    final caregiverId = _authCtrl.user.value?.id ?? '';
    if (caregiverId.isEmpty) return;

    _notificationsSub?.cancel();
    _notificationsSub = FirebaseService.notificationsStream(caregiverId).listen(
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
    final caregiverId = _authCtrl.user.value?.id ?? '';
    if (caregiverId.isEmpty) return;

    _earningsSub?.cancel();
    _earningsSub = FirebaseService.paymentsByCaregiverStream(caregiverId).listen(
      (payments) {
        final success =
            payments.where((p) => p.status == TransactionStatus.success).toList();
        earnings.assignAll(
          success.map(CaregiverEarningModel.fromPayment).toList(),
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
    final caregiverId = _authCtrl.user.value?.id ?? '';
    if (caregiverId.isEmpty) return;

    _withdrawalsSub?.cancel();
    _withdrawalsSub = FirebaseService.withdrawalsByCaregiverStream(caregiverId).listen(
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

  // Listens to the caregiver's appointments in real time and hydrates both
  // the schedule and the client list from them (mirrors the provider flow,
  // but live so newly booked clients appear without a manual refresh).
  void _listenAppointments() {
    final caregiverId = _authCtrl.user.value?.id ?? '';
    if (caregiverId.isEmpty) return;

    _appointmentsSub?.cancel();
    _appointmentsSub =
        FirebaseService.appointmentsByCaregiverStream(caregiverId).listen(
      (maps) {
        final scheduleModels = <CaregiverScheduleModel>[];
        final clientMap = <String, CaregiverClientModel>{};

        for (final map in maps) {
          final model = CaregiverScheduleModel.fromMap(map);
          scheduleModels.add(model);

          final clientId = model.clientId;
          if (clientId.isNotEmpty && !clientMap.containsKey(clientId)) {
            if (_declinedClientIds.contains(clientId)) continue;

            final isAccepted = _acceptedClientIds.contains(clientId);
            final status = isAccepted
                ? CaregiverClientStatus.active
                : (model.status == AppointmentStatus.pending
                    ? CaregiverClientStatus.pending
                    : CaregiverClientStatus.active);

            clientMap[clientId] = CaregiverClientModel(
              id: clientId,
              name: model.clientName,
              careType: model.careType,
              location: location,
              since: _formatSince(model.dateTime),
              status: status,
              avatarEmoji: model.avatarEmoji,
              imageUrl: model.imageUrl,
              age: 0,
              phone: '',
              emergencyContact: '',
            );
          }
        }

        scheduleModels.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        schedule.assignAll(scheduleModels);
        clients.assignAll(clientMap.values.toList());
        _updateHireRequestCount();
      },
      onError: (_) {},
    );
  }

  String _formatSince(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  // ── Profile ───────────────────────────────────────────────────
  String get caregiverId => _authCtrl.user.value?.id ?? '';
  String get caregiverName => _authCtrl.user.value?.name ?? '';
  String get fullName => caregiverName;
  String get serviceType => 'Caregiver';
  String get location => 'Kigali, Rwanda';

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning_caregiver'.tr;
    if (hour < 17) return 'good_afternoon_caregiver'.tr;
    return 'good_evening_caregiver'.tr;
  }
  double get rating {
    if (Get.isRegistered<CaregiverProfileController>()) {
      final profileCtrl = Get.find<CaregiverProfileController>();
      final current = profileCtrl.profile.value;
      if (current != null) return current.rating;
    }
    return 4.8;
  }
  int get experienceYears => 0;
  int get totalClients => activeClientsCount;
  String get memberSince {
    final createdAt = _authCtrl.user.value?.createdAt;
    if (createdAt == null) return '—';
    return '${createdAt.month}/${createdAt.year}';
  }

  // ── Stats ─────────────────────────────────────────────────────
  final RxInt monthlyEarnings = 0.obs;
  final RxString earningsGrowth = '0%'.obs;
  final RxList<double> barData = <double>[].obs;
  final RxDouble availableBalance = 0.0.obs;
  final RxDouble totalWithdrawn = 0.0.obs;
  final RxDouble totalEarned = 0.0.obs;
  final RxInt hireRequestCount = 0.obs;
  final RxInt notifCount = 0.obs;

  // ── Data lists ────────────────────────────────────────────────
  final RxList<CaregiverClientModel> clients = <CaregiverClientModel>[].obs;
  final RxList<CaregiverScheduleModel> schedule = <CaregiverScheduleModel>[].obs;
  final RxList<CaregiverEarningModel> earnings = <CaregiverEarningModel>[].obs;

  // ── Tab / filter state ────────────────────────────────────────
  final RxInt clientsTab = 0.obs;
  final RxInt scheduleTab = 0.obs;
  final RxInt selectedDayIndex = 0.obs;
  final RxString clientSearchQuery = ''.obs;
  final RxString earningsFilter = 'This Month'.obs;

  String get caregiverRole {
    final role = _authCtrl.user.value?.role;
    if (role == UserRole.caregiver) return 'Caregiver';
    if (role == UserRole.provider) return 'Provider';
    return 'Patient';
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

  int get activeClientsCount =>
      clients.where((c) => c.status == CaregiverClientStatus.active).length;

  List<CaregiverClientModel> get allClients => clients;

  List<CaregiverClientModel> get activeClients =>
      clients.where((c) => c.status == CaregiverClientStatus.active).toList();

  List<CaregiverClientModel> get pendingClients =>
      clients.where((c) => c.status == CaregiverClientStatus.pending).toList();

  List<CaregiverClientModel> get hireRequests => pendingClients;

  List<CaregiverClientModel> get filteredClients {
    List<CaregiverClientModel> list;
    switch (clientsTab.value) {
      case 1:
        list = pendingClients;
        break;
      case 2:
        list = activeClients;
        break;
      default:
        list = allClients;
    }

    final q = clientSearchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.careType.toLowerCase().contains(q))
        .toList();
  }

  List<CaregiverScheduleModel> get todaySchedule {
    final now = DateTime.now();
    return schedule.where((s) {
      return s.dateTime.year == now.year &&
          s.dateTime.month == now.month &&
          s.dateTime.day == now.day;
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<CaregiverScheduleModel> get upcomingSchedule {
    final now = DateTime.now();
    return schedule
        .where((s) =>
            (s.status == AppointmentStatus.confirmed ||
                s.status == AppointmentStatus.pending) &&
            s.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<CaregiverScheduleModel> get completedSchedule => schedule
      .where((s) => s.status == AppointmentStatus.completed)
      .toList()
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  List<CaregiverScheduleModel> get cancelledSchedule => schedule
      .where((s) => s.status == AppointmentStatus.cancelled)
      .toList()
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  List<CaregiverScheduleModel> get currentScheduleList {
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
        'appointmentCount': schedule.where((s) {
          return s.dateTime.year == day.year &&
              s.dateTime.month == day.month &&
              s.dateTime.day == day.day &&
              s.status != AppointmentStatus.cancelled;
        }).length,
      };
    });
  }

  List<CaregiverScheduleModel> get selectedDayAppointments {
    final day = weekDays[selectedDayIndex.value]['fullDate'] as DateTime;
    return schedule
        .where((s) {
          return s.dateTime.year == day.year &&
              s.dateTime.month == day.month &&
              s.dateTime.day == day.day;
        })
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<CaregiverEarningModel> get filteredEarnings {
    if (earningsFilter.value == 'All Time') return earnings;
    final label = FirebaseService.monthLabel(DateTime.now());
    return earnings.where((e) => e.month == label).toList();
  }

  Map<String, List<CaregiverEarningModel>> get groupedEarnings {
    final map = <String, List<CaregiverEarningModel>>{};
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

  CaregiverClientModel? clientById(String id) {
    return clients.firstWhereOrNull((c) => c.id == id);
  }

  void changeClientsTab(int index) => clientsTab.value = index;
  void changeScheduleTab(int index) => scheduleTab.value = index;
  void selectDay(int index) => selectedDayIndex.value = index;
  void setClientSearch(String query) => clientSearchQuery.value = query;
  void toggleEarningsFilter() {
    earningsFilter.value =
        earningsFilter.value == 'This Month' ? 'All Time' : 'This Month';
  }

  void acceptClient(String id) {
    _acceptedClientIds.add(id);
    _declinedClientIds.remove(id);
    final index = clients.indexWhere((c) => c.id == id);
    if (index != -1) {
      clients[index] =
          clients[index].copyWith(status: CaregiverClientStatus.active);
      _updateHireRequestCount();
    }
  }

  void declineClient(String id) {
    _declinedClientIds.add(id);
    _acceptedClientIds.remove(id);
    clients.removeWhere((c) => c.id == id);
    _updateHireRequestCount();
  }

  void confirmShift(String id) {
    final index = schedule.indexWhere((s) => s.id == id);
    if (index != -1) {
      schedule[index] = schedule[index]
          .copyWith(status: AppointmentStatus.confirmed);
    }
  }

  void cancelShift(String id) {
    final index = schedule.indexWhere((s) => s.id == id);
    if (index != -1) {
      schedule[index] = schedule[index]
          .copyWith(status: AppointmentStatus.cancelled);
    }
  }

  void completeShift(String id) {
    final index = schedule.indexWhere((s) => s.id == id);
    if (index != -1) {
      schedule[index] = schedule[index]
          .copyWith(status: AppointmentStatus.completed);
      _addRatingPoint();
    }
  }

  void _addRatingPoint() {
    if (!Get.isRegistered<CaregiverProfileController>()) return;
    final profileCtrl = Get.find<CaregiverProfileController>();
    final current = profileCtrl.profile.value;
    if (current == null) return;
    final newRating = (current.rating + 0.5).clamp(0.0, 5.0);
    if (newRating == current.rating) return;
    final updated = current.copyWith(
      rating: newRating,
      reviewCount: current.reviewCount + 1,
    );
    profileCtrl.profile.value = updated;
    FirebaseService.updateCaregiver(updated);
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
        userRole: 'caregiver',
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

  void _updateHireRequestCount() {
    hireRequestCount.value = pendingClients.length;
  }
}
