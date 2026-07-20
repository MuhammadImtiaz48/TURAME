import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppBottomNav — Role-aware bottom navigation bar
//
// Usage:
//   AppBottomNav(role: NavRole.patient,  currentIndex: 0, onTap: (i) => ...)
//   AppBottomNav(role: NavRole.provider, currentIndex: 0, onTap: (i) => ...)
//   AppBottomNav(role: NavRole.caregiver,currentIndex: 0, onTap: (i) => ...)
// ─────────────────────────────────────────────────────────────────────────────

enum NavRole { patient, provider, caregiver }

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String labelKey; // translation key
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
  });
}

class AppBottomNav extends StatelessWidget {
  final NavRole role;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.role,
    required this.currentIndex,
    required this.onTap,
  });

  // ── Nav items per role ───────────────────────────────────────────
  static const _patientItems = [
    _NavItem(icon: Icons.home_outlined,         activeIcon: Icons.home_rounded,              labelKey: 'nav_home'),
    _NavItem(icon: Icons.calendar_today_outlined,activeIcon: Icons.calendar_today_rounded,   labelKey: 'nav_appointments'),
    _NavItem(icon: Icons.favorite_outline,       activeIcon: Icons.favorite_rounded,          labelKey: 'nav_health'),
    _NavItem(icon: Icons.chat_bubble_outline,    activeIcon: Icons.chat_bubble_rounded,       labelKey: 'nav_chat'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,            labelKey: 'nav_profile'),
  ];

  static const _providerItems = [
    _NavItem(icon: Icons.home_outlined,          activeIcon: Icons.home_rounded,              labelKey: 'nav_home'),
    _NavItem(icon: Icons.people_outline,         activeIcon: Icons.people_rounded,            labelKey: 'nav_patients'),
    _NavItem(icon: Icons.chat_bubble_outline,    activeIcon: Icons.chat_bubble_rounded,       labelKey: 'nav_messages'),
    _NavItem(icon: Icons.calendar_today_outlined,activeIcon: Icons.calendar_today_rounded,   labelKey: 'nav_schedule'),
    _NavItem(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet_rounded, labelKey: 'nav_revenue'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,            labelKey: 'nav_profile'),
  ];

  static const _caregiverItems = [
    _NavItem(icon: Icons.home_outlined,          activeIcon: Icons.home_rounded,              labelKey: 'nav_home'),
    _NavItem(icon: Icons.people_outline,         activeIcon: Icons.people_rounded,            labelKey: 'nav_clients'),
    _NavItem(icon: Icons.chat_bubble_outline,    activeIcon: Icons.chat_bubble_rounded,       labelKey: 'nav_messages'),
    _NavItem(icon: Icons.calendar_today_outlined,activeIcon: Icons.calendar_today_rounded,   labelKey: 'nav_schedule'),
    _NavItem(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet_rounded, labelKey: 'nav_revenue'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,            labelKey: 'nav_profile'),
  ];

  List<_NavItem> get _items => switch (role) {
    NavRole.patient   => _patientItems,
    NavRole.provider  => _providerItems,
    NavRole.caregiver => _caregiverItems,
  };

  Color get _activeColor => switch (role) {
    NavRole.patient   => AppColors.patientColor,
    NavRole.provider  => AppColors.providerColor,
    NavRole.caregiver => AppColors.accent,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0F1565C0),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60.h,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isActive = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Icon ──────────────────────────────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          key: ValueKey(isActive),
                          size: 24.sp,
                          color: isActive
                              ? _activeColor
                              : AppColors.textTertiary,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      // ── Label ─────────────────────────────────
                      Text(
                        _label(item.labelKey),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isActive
                              ? _activeColor
                              : AppColors.textTertiary,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 10.sp,
                        ),
                      ),
                      // ── Active dot ────────────────────────────
                      SizedBox(height: 3.h),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: isActive ? 5 : 0,
                        height: isActive ? 5 : 0,
                        decoration: BoxDecoration(
                          color: _activeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // Inline translation fallback (works with GetX .tr too)
  String _label(String key) {
    const labels = {
      'nav_home':         'Home',
      'nav_appointments': 'Appointments',
      'nav_health':       'Health',
      'nav_chat':         'Messages',
      'nav_profile':      'Profile',
      'nav_patients':     'Patients',
      'nav_messages':     'Messages',
      'nav_schedule':     'Schedule',
      'nav_revenue':      'Earnings',
      'nav_clients':      'Clients',
    };
    // GetX translation will override at runtime via .tr
    return labels[key] ?? key;
  }
}