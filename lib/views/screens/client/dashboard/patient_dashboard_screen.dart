// ============================================================
// FILE: lib/views/screens/client/dashboard/patient_dashboard_screen.dart
// Patient dashboard screen — hosts the bottom nav and the home tab.
// ============================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rambaa/controllers/auth_controllers/auth_controller.dart';
import 'package:rambaa/views/screens/client/appointments/appointment_screen.dart';
import 'package:rambaa/views/screens/client/health/health_monitor_screen.dart';
import 'package:rambaa/views/screens/client/messages/message_list_screen.dart';
import 'package:rambaa/views/screens/client/dashboard/widgets/dashboard_models.dart';
import 'package:rambaa/views/screens/client/dashboard/widgets/home_tab.dart';
import 'package:rambaa/views/screens/client/patients_profile/profile_screen.dart';
import 'package:rambaa/constants/app_colors.dart';
import 'package:rambaa/controllers/appointment_controller.dart';
import 'package:rambaa/controllers/caregiver_controllers/caregiver_controller.dart';
import 'package:rambaa/controllers/provider_controller/provider_controller.dart';
import 'package:rambaa/models/notification_model.dart';
import 'package:rambaa/routes/app_routes.dart';
import 'package:rambaa/services/firebase_service.dart';
import 'package:rambaa/views/widgets/app_bottom_nav.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  int _navIndex = 0;
  final AuthController _authCtrl = Get.find<AuthController>();
  late final ProviderController _providerCtrl;
  late final CaregiverController _caregiverCtrl;
  late final AppointmentController _apptCtrl;
  StreamSubscription<List<NotificationModel>>? _notifSub;

  int _notifCount = 0;

  String _heartRate = '--';
  String _oxygen = '--';
  String _bloodPressure = '--';

  final List<ServiceCategory> _categories = const [
    ServiceCategory(emoji: '🩺', labelKey: 'category_doctors', bg: AppColors.primaryLighter),
    ServiceCategory(emoji: '💉', labelKey: 'category_nurses', bg: AppColors.healthGreenLighter),
    ServiceCategory(emoji: '🏃', labelKey: 'category_physiotherapists', bg: AppColors.accentLighter),
    ServiceCategory(emoji: '🥗', labelKey: 'category_nutritionists', bg: AppColors.secondaryLighter),
    ServiceCategory(emoji: '🧠', labelKey: 'category_psychologists', bg: AppColors.primaryLighter),
  ];

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ProviderController>()) {
      Get.put<ProviderController>(ProviderController(), permanent: true);
    }
    _providerCtrl = Get.find<ProviderController>();
    if (!Get.isRegistered<CaregiverController>()) {
      Get.put<CaregiverController>(CaregiverController(), permanent: true);
    }
    _caregiverCtrl = Get.find<CaregiverController>();
    if (!Get.isRegistered<AppointmentController>()) {
      Get.lazyPut<AppointmentController>(() => AppointmentController());
    }
    _apptCtrl = Get.find<AppointmentController>();
    _loadVitals();
    _listenNotifications();
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    super.dispose();
  }

  void _listenNotifications() {
    final uid = _authCtrl.user.value?.id;
    if (uid == null || uid.isEmpty) return;
    _notifSub = FirebaseService.notificationsStream(uid).listen(
      (items) {
        final count = items
            .where((n) => !n.isRead)
            .where((n) =>
                n.type != NotificationType.message &&
                n.type != NotificationType.call)
            .length;
        if (mounted) {
          setState(() => _notifCount = count);
        }
      },
      onError: (_) {},
    );
  }

  Future<void> _loadVitals() async {
    final id = _authCtrl.user.value?.id;
    if (id == null || id.isEmpty) return;
    final patient = await FirebaseService.getPatientById(id);
    if (!mounted || patient == null) return;
    setState(() {
      _heartRate = patient.heartRate?.isNotEmpty == true
          ? patient.heartRate!
          : '--';
      _oxygen =
          patient.oxygen?.isNotEmpty == true ? '${patient.oxygen}%' : '--';
      _bloodPressure = patient.bloodPressure?.isNotEmpty == true
          ? patient.bloodPressure!
          : '--';
    });
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning'.tr;
    if (hour < 17) return 'good_afternoon'.tr;
    return 'good_evening'.tr;
  }

  void _onNavTap(int i) => setState(() => _navIndex = i);

  void _onCategoryTap(int index) {
    final specialtyMap = {
      'category_doctors': 'General Physician',
      'category_nurses': 'Community Nurse',
      'category_physiotherapists': 'Physiotherapist',
      'category_nutritionists': 'Nutritionist',
      'category_psychologists': 'Psychologist',
    };
    final labelKey = _categories[index].labelKey;
    final specialty = specialtyMap[labelKey];
    if (specialty != null) {
      _providerCtrl.setSpecialty(specialty);
    }
    Get.toNamed(AppRoutes.providerList);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _navIndex,
        children: [
          PatientHomeTab(
            patientName: _authCtrl.user.value?.name ?? '',
            greeting: _greeting,
            notifCount: _notifCount,
            heartRate: _heartRate,
            oxygen: _oxygen,
            bloodPressure: _bloodPressure,
            categories: _categories,
            providerCtrl: _providerCtrl,
            caregiverCtrl: _caregiverCtrl,
            appointmentCtrl: _apptCtrl,
            onBookProvider: (provider) =>
                Get.toNamed(AppRoutes.booking, arguments: provider),
            onBookCaregiver: (caregiver) =>
                Get.toNamed(AppRoutes.booking, arguments: {
                  'provider': {
                    'id': caregiver.id,
                    'name': caregiver.name,
                    'avatarEmoji': '👩‍⚕️',
                    'serviceType': caregiver.serviceType,
                    'role': 'caregiver',
                  },
                }),
            onCategoryTap: _onCategoryTap,
          ),
          AppointmentScreen(onBack: () => setState(() => _navIndex = 0)),
          const HealthMonitorScreen(),
          const MessagesListScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        role: NavRole.patient,
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
