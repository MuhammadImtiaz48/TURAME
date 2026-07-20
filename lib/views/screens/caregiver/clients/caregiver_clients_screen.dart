import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/caregiver_controllers/caregiver_dashboard_controller.dart';
import '../../../../models/caregiver_client_model.dart';
import '../../../../routes/app_routes.dart';
import '../../../../services/firebase_service.dart';

class CaregiverClientsScreen extends StatelessWidget {
  const CaregiverClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CaregiverDashboardController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(ctrl: ctrl),
          _TabBar(ctrl: ctrl),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: CupertinoSearchTextField(
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textPrimary),
              placeholder: 'Search clients...',
              onChanged: ctrl.setClientSearch,
            ),
          ),
          Expanded(
            child: Obx(() {
              final list = ctrl.filteredClients;
              if (list.isEmpty) return const _EmptyState();
              return ListView.builder(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                itemCount: list.length,
                itemBuilder: (_, i) => _ClientCard(
                  client: list[i],
                  ctrl: ctrl,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final CaregiverDashboardController ctrl;
  const _Header({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.caregiverGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('nav_clients'.tr, style: AppTextStyles.onDarkTitle),
                    SizedBox(height: 4.h),
                    Obx(() => Text(
                          '${ctrl.allClients.length} total · ${ctrl.pendingClients.length} requests',
                          style: AppTextStyles.onDarkBody,
                        )),
                  ],
                ),
              ),
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.people_rounded,
                    color: Colors.white, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final CaregiverDashboardController ctrl;
  const _TabBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final tabs = ['All', 'Requests', 'Active'];
    return Container(
      color: AppColors.surface,
      child: Obx(() => Row(
            children: List.generate(tabs.length, (i) {
              final count = switch (i) {
                1 => ctrl.pendingClients.length,
                2 => ctrl.activeClients.length,
                _ => ctrl.allClients.length,
              };
              return _TabItem(
                label: tabs[i],
                count: count,
                selected: ctrl.clientsTab.value == i,
                onTap: () => ctrl.changeClientsTab(i),
              );
            }),
          )),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.caregiverColor : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: selected
                      ? AppColors.caregiverColor
                      : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (count > 0) ...[
                SizedBox(width: 4.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.caregiverColor
                        : AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '$count',
                    style: AppTextStyles.badge.copyWith(fontSize: 10.sp),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final CaregiverClientModel client;
  final CaregiverDashboardController ctrl;

  const _ClientCard({required this.client, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isPending = client.status == CaregiverClientStatus.pending;

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.caregiverClientDetail,
        arguments: client,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ClientAvatar(
                  imageUrl: client.imageUrl,
                  clientId: client.id,
                  fallbackEmoji: client.avatarEmoji,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.name, style: AppTextStyles.h3),
                      SizedBox(height: 2.h),
                      Text(client.careType, style: AppTextStyles.bodySmall),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 12, color: AppColors.textTertiary),
                          SizedBox(width: 3.w),
                          Text(client.location, style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: client.statusBg,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    client.statusLabel,
                    style: AppTextStyles.badge.copyWith(
                      color: client.statusColor,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ),
            if (client.nextShift != null) ...[
              SizedBox(height: 10.h),
              Row(
                children: [
                  const Icon(Icons.event_rounded,
                      size: 13, color: AppColors.caregiverColor),
                  SizedBox(width: 6.w),
                  Text(
                    'Next: ${client.nextShift}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.caregiverColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            if (isPending) ...[
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => ctrl.acceptClient(client.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.caregiverColor,
                        minimumSize: Size(double.infinity, 40.h),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm),
                        ),
                      ),
                      child:
                          Text('accept'.tr, style: AppTextStyles.buttonMedium),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ctrl.declineClient(client.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        minimumSize: Size(double.infinity, 40.h),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm),
                        ),
                      ),
                      child: Text('decline'.tr,
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: AppColors.textSecondary,
                          )),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded,
              size: 56.sp, color: AppColors.textTertiary),
          SizedBox(height: 16.h),
          Text('No clients found', style: AppTextStyles.h3),
          SizedBox(height: 6.h),
          Text(
            'Clients will appear here once they send hire requests.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Client Avatar (resolves real uploaded image) ─────────────────────────────
class _ClientAvatar extends StatefulWidget {
  final String? imageUrl;
  final String clientId;
  final String fallbackEmoji;

  const _ClientAvatar({
    required this.imageUrl,
    required this.clientId,
    required this.fallbackEmoji,
  });

  @override
  State<_ClientAvatar> createState() => _ClientAvatarState();
}

class _ClientAvatarState extends State<_ClientAvatar> {
  String? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant _ClientAvatar oldWidget) {
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
      width: 48.w,
      height: 48.w,
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
                style: TextStyle(fontSize: 22.sp),
              ),
            ),
    );
  }
}
