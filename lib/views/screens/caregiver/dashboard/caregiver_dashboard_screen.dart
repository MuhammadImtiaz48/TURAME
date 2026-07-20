import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/caregiver_controllers/caregiver_dashboard_controller.dart';
import '../../../../models/caregiver_client_model.dart';
import '../../../../routes/app_routes.dart';
import '../../../../services/firebase_service.dart';
import '../../../widgets/app_bottom_nav.dart';
import '../caregiver_messages_screen.dart';
import '../clients/caregiver_clients_screen.dart';
import '../earnings/caregiver_earnings_screen.dart';
import '../profile/caregiver_profile_screen.dart';
import '../schedule/caregiver_schedule_screen.dart';

class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() =>
      _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  int _navIndex = 0;
  late final CaregiverDashboardController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.isRegistered<CaregiverDashboardController>()
        ? Get.find<CaregiverDashboardController>()
        : Get.put(CaregiverDashboardController());
  }

  void _onNavTap(int i) => setState(() => _navIndex = i);

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
          _HomeTab(
            ctrl: _ctrl,
            onSeeAllClients: () => setState(() => _navIndex = 1),
            onSeeAllRequests: () {
              _ctrl.changeClientsTab(1);
              setState(() => _navIndex = 1);
            },
          ),
          const CaregiverClientsScreen(),
          const CaregiverMessagesScreen(),
          const CaregiverScheduleScreen(),
          const CaregiverEarningsScreen(),
          const CaregiverProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        role: NavRole.caregiver,
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

// ─── Home Tab ─────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final CaregiverDashboardController ctrl;
  final VoidCallback onSeeAllClients;
  final VoidCallback onSeeAllRequests;

  const _HomeTab({
    required this.ctrl,
    required this.onSeeAllClients,
    required this.onSeeAllRequests,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
            child: Obx(() => _CaregiverHeader(
                greeting: ctrl.greeting,
                name: ctrl.caregiverName,
                role: ctrl.caregiverRole,
                caregiverId: ctrl.caregiverId,
                monthlyEarnings: ctrl.formattedMonthlyEarnings,
                activeClients: ctrl.activeClientsCount,
                notifCount: ctrl.notifCount.value,
              )),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMD,
            vertical: AppTheme.spacingMD,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
               Obx(() {
                 final requests = ctrl.hireRequests;
                 return Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     _SectionHeader(
                       title: 'new_hire_requests'.tr,
                       badge: ctrl.hireRequestCount.value > 0
                           ? ctrl.hireRequestCount.value
                           : null,
                       showSeeAll: requests.length > 1,
                       onSeeAll: onSeeAllRequests,
                     ),
                     SizedBox(height: 12.h),
                     if (requests.isEmpty)
                       Text(
                         'No new hire requests.',
                         style: AppTextStyles.bodyMedium
                             .copyWith(color: AppColors.textSecondary),
                       )
                     else
                       ...requests.map(
                         (r) => _HireRequestCard(data: r, ctrl: ctrl),
                       ),
                   ],
                 );
               }),
               SizedBox(height: 20.h),
               Obx(() {
                 final clients = ctrl.activeClients;
                 return Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     _SectionHeader(
                       title: 'active_clients'.tr,
                       showSeeAll: true,
                       onSeeAll: onSeeAllClients,
                     ),
                     SizedBox(height: 12.h),
                     if (clients.isEmpty)
                       Text(
                         'No active clients yet.',
                         style: AppTextStyles.bodyMedium
                             .copyWith(color: AppColors.textSecondary),
                       )
                     else
                       ...clients.map((c) => _ActiveClientCard(data: c)),
                   ],
                 );
               }),
               SizedBox(height: 24.h),
            ]),
          ),
        ),
      ],
    );
  }
}

// ─── Caregiver Header ─────────────────────────────────────────────────────────
class _CaregiverHeader extends StatelessWidget {
  final String greeting;
  final String name;
  final String role;
  final String caregiverId;
  final String monthlyEarnings;
  final int activeClients;
  final int notifCount;

  const _CaregiverHeader({
    required this.greeting,
    required this.name,
    required this.role,
    required this.caregiverId,
    required this.monthlyEarnings,
    required this.activeClients,
    this.notifCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.caregiverGradient,
      ),
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacingMD,
        MediaQuery.of(context).padding.top + 16.h,
        AppTheme.spacingMD,
        AppTheme.spacingXXL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting, style: AppTextStyles.onDarkBody),
                  SizedBox(height: 2.h),
                  Text(name, style: AppTextStyles.onDarkTitle),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      role,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textOnDark,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.notification),
                        child: Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.textOnDark,
                            size: 22,
                          ),
                        ),
                      ),
                      if (notifCount > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 18.w,
                            height: 18.w,
                            decoration: BoxDecoration(
                              color: AppColors.dangerLight,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.textOnDark,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$notifCount',
                                style: AppTextStyles.badge.copyWith(fontSize: 9.sp),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 10.w),
                  _CaregiverAvatar(caregiverId: caregiverId),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMD,
              vertical: 14.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(monthlyEarnings, style: AppTextStyles.onDarkTitle),
                      SizedBox(height: 2.h),
                      Text(
                        'this_month_label'.tr,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textOnDark.withValues(alpha: 0.75),
                          letterSpacing: 0.5,
                          fontSize: 9.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 36.h,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                SizedBox(width: AppTheme.spacingMD),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$activeClients', style: AppTextStyles.onDarkTitle),
                    SizedBox(height: 2.h),
                    Text(
                      'active_clients_label'.tr,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textOnDark.withValues(alpha: 0.75),
                        letterSpacing: 0.5,
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Caregiver Avatar (resolves real uploaded image) ──────────────────────────
class _CaregiverAvatar extends StatefulWidget {
  final String caregiverId;
  const _CaregiverAvatar({required this.caregiverId});

  @override
  State<_CaregiverAvatar> createState() => _CaregiverAvatarState();
}

class _CaregiverAvatarState extends State<_CaregiverAvatar> {
  String? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant _CaregiverAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.caregiverId != widget.caregiverId) {
      _resolve();
    }
  }

  Future<void> _resolve() async {
    if (widget.caregiverId.isEmpty) return;
    final fetched = await FirebaseService.getUserImageUrl(widget.caregiverId);
    if (mounted) setState(() => _resolvedUrl = fetched);
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolvedUrl;
    final showImage = url != null && url.isNotEmpty;
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        shape: BoxShape.circle,
        image: showImage
            ? DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: showImage
          ? null
          : Center(
              child: Text('😊', style: TextStyle(fontSize: 22.sp)),
            ),
    );
  }
}

// ─── Client image avatar (resolves real uploaded image) ───────────────────────
class _ClientImageAvatar extends StatefulWidget {
  final String? imageUrl;
  final String clientId;
  final String fallbackEmoji;
  final double size;
  final double emojiSize;

  const _ClientImageAvatar({
    required this.imageUrl,
    required this.clientId,
    required this.fallbackEmoji,
    required this.size,
    required this.emojiSize,
  });

  @override
  State<_ClientImageAvatar> createState() => _ClientImageAvatarState();
}

class _ClientImageAvatarState extends State<_ClientImageAvatar> {
  String? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant _ClientImageAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.clientId != widget.clientId) {
      _resolve();
    }
  }

  Future<void> _resolve() async {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      if (mounted) setState(() => _resolvedUrl = widget.imageUrl);
      return;
    }
    if (widget.clientId.isEmpty) return;
    final fetched = await FirebaseService.getUserImageUrl(widget.clientId);
    if (mounted) setState(() => _resolvedUrl = fetched);
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolvedUrl;
    final showImage = url != null && url.isNotEmpty;
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: AppColors.accentLighter,
        shape: BoxShape.circle,
        image: showImage
            ? DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: showImage
          ? null
          : Center(
              child: Text(
                widget.fallbackEmoji,
                style: TextStyle(fontSize: widget.emojiSize),
              ),
            ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final bool showSeeAll;
  final VoidCallback? onSeeAll;
  final int? badge;

  const _SectionHeader({
    required this.title,
    this.showSeeAll = false,
    this.onSeeAll,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(title, style: AppTextStyles.h3),
            if (badge != null) ...[
              SizedBox(width: 8.w),
              Container(
                width: 20.w,
                height: 20.w,
                decoration: const BoxDecoration(
                  color: AppColors.caregiverColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$badge',
                    style: AppTextStyles.badge.copyWith(fontSize: 10.sp),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (showSeeAll)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'see_all'.tr,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.caregiverColor,
                fontSize: 13.sp,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Hire Request Card ────────────────────────────────────────────────────────
class _HireRequestCard extends StatelessWidget {
  final CaregiverClientModel data;
  final CaregiverDashboardController ctrl;

  const _HireRequestCard({required this.data, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ClientImageAvatar(
                imageUrl: data.imageUrl,
                clientId: data.id,
                fallbackEmoji: data.avatarEmoji,
                size: 36.w,
                emojiSize: 18.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.name, style: AppTextStyles.h3),
                    SizedBox(height: 2.h),
                    Text(data.careType, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 13, color: AppColors.caregiverColor),
              SizedBox(width: 4.w),
              Text(data.location, style: AppTextStyles.caption),
              if (data.dailyRate.isNotEmpty) ...[
                SizedBox(width: 12.w),
                const Text('🤑', style: TextStyle(fontSize: 12)),
                SizedBox(width: 4.w),
                Text(data.dailyRate, style: AppTextStyles.caption),
              ],
            ],
          ),
          if (data.hours.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 13, color: AppColors.textTertiary),
                SizedBox(width: 4.w),
                Text(data.hours, style: AppTextStyles.caption),
              ],
            ),
          ],
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => ctrl.acceptClient(data.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.caregiverColor,
                    minimumSize: Size(double.infinity, 40.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                  ),
                  child: Text('accept'.tr, style: AppTextStyles.buttonMedium),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => ctrl.declineClient(data.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    minimumSize: Size(double.infinity, 40.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                  ),
                  child: Text(
                    'decline'.tr,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Active Client Card ───────────────────────────────────────────────────────
class _ActiveClientCard extends StatelessWidget {
  final CaregiverClientModel data;

  const _ActiveClientCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.caregiverClientDetail,
        arguments: data,
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(AppTheme.spacingMD),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            _ClientImageAvatar(
              imageUrl: data.imageUrl,
              clientId: data.id,
              fallbackEmoji: data.avatarEmoji,
              size: 52.w,
              emojiSize: 22.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.name, style: AppTextStyles.h3),
                  SizedBox(height: 2.h),
                  Text(data.careType, style: AppTextStyles.bodySmall),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 12, color: AppColors.textTertiary),
                      SizedBox(width: 3.w),
                      Text(
                        '${data.location} · ${data.since}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.healthGreenLighter,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'active'.tr,
                style: AppTextStyles.badge.copyWith(
                  color: AppColors.healthGreen,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
