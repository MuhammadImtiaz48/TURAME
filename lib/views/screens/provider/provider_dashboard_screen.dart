// ============================================================
// FILE: lib/views/screens/provider/provider_dashboard_screen.dart
// Provider dashboard screen — hosts the bottom nav and the home tab.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rambaa/constants/app_colors.dart';
import 'package:rambaa/controllers/provider_controller/provider_dashboard_controller.dart';
import 'package:rambaa/routes/app_routes.dart';
import 'package:rambaa/views/screens/provider/widgets/home_tab.dart';
import 'package:rambaa/views/widgets/app_bottom_nav.dart';
import 'package:rambaa/views/screens/provider/provider_payments_screens/provider_earnings_screen.dart';
import 'package:rambaa/views/screens/provider/provider_patient_screens/provider_patients_screen.dart';
import 'package:rambaa/views/screens/provider/provider_messages_screen.dart';
import 'package:rambaa/views/screens/provider/provider_profile/provider_profile_screen.dart';
import 'package:rambaa/views/screens/provider/provider_schedule_screen.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  int _navIndex = 0;
  late final ProviderDashboardController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(ProviderDashboardController());
  }

  void _onNavTap(int i) {
    setState(() => _navIndex = i);
    _ctrl.currentTab.value = i;
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
          ProviderHomeTab(
            ctrl: _ctrl,
            onSeeAllPatients: () => setState(() => _navIndex = 1),
            onWithdraw: () => Get.toNamed(AppRoutes.providerWithdraw),
          ),
          const ProviderPatientsScreen(),
          const ProviderMessagesScreen(),
          const ProviderScheduleScreen(),
          const ProviderEarningsScreen(),
          const ProviderProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        role: NavRole.provider,
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
