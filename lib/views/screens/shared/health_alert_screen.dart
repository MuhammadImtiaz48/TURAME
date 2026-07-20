import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_theme.dart';
import '../../../controllers/health_alert_controller.dart';

class HealthAlertScreen extends StatelessWidget {
  const HealthAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HealthAlertController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(ctrl: ctrl),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AlertMetricCard(ctrl: ctrl),
                  SizedBox(height: 16.h),
                  _AiRecommendationCard(ctrl: ctrl),
                  SizedBox(height: 24.h),
                  _NotifyCareTeam(ctrl: ctrl),
                  SizedBox(height: 12.h),
                  _EmergencySosButton(ctrl: ctrl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final HealthAlertController ctrl;
  const _Header({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.emergencyGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Icon(Icons.arrow_back, color: Colors.white, size: 22.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('⚠️', style: TextStyle(fontSize: 18.sp)),
                        SizedBox(width: 8.w),
                        Text(
                          'health_alert_detected'.tr,
                          style: AppTextStyles.onDarkTitle,
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${'abnormal_reading'.tr} · ${ctrl.formattedTime}',
                      style: AppTextStyles.onDarkBody,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Alert Metric Card ───────────────────────────────────────────────────────

class _AlertMetricCard extends StatelessWidget {
  final HealthAlertController ctrl;
  const _AlertMetricCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final alert = ctrl.alert;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: alert.cardBgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: alert.severityColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Text(alert.metricEmoji, style: TextStyle(fontSize: 20.sp)),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.metricName,
                    style: AppTextStyles.h3.copyWith(color: alert.severityColor),
                  ),
                  Text(alert.description, style: AppTextStyles.bodySmall),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: alert.severityColor.withValues(alpha: 0.15), height: 1),
          SizedBox(height: 12.h),
          // Detected value row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('detected_value'.tr, style: AppTextStyles.bodySmall),
                  SizedBox(height: 2.h),
                  Text(
                    '${'normal_range'.tr}: ${alert.normalRange}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: alert.detectedValue.toStringAsFixed(0),
                      style: AppTextStyles.metric.copyWith(
                        color: alert.severityColor,
                        fontSize: 36.sp,
                      ),
                    ),
                    TextSpan(
                      text: ' ${alert.unit}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: alert.severityColor.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── AI Recommendation Card ──────────────────────────────────────────────────

class _AiRecommendationCard extends StatelessWidget {
  final HealthAlertController ctrl;
  const _AiRecommendationCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🤖', style: TextStyle(fontSize: 18.sp)),
              SizedBox(width: 8.w),
              Text('ai_recommendation'.tr, style: AppTextStyles.h3),
            ],
          ),
          SizedBox(height: 10.h),
          _HighlightedText(text: ctrl.alert.aiRecommendation),
        ],
      ),
    );
  }
}

// Highlights urgent phrases in red
class _HighlightedText extends StatelessWidget {
  final String text;
  const _HighlightedText({required this.text});

  @override
  Widget build(BuildContext context) {
    // Split on sentences to highlight urgent ones
    final sentences = text.split('. ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sentences.map((s) {
        final isUrgent = s.toLowerCase().contains('10 minutes') ||
            s.toLowerCase().contains('emergency') ||
            s.toLowerCase().contains('chest pain');
        return Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Text(
            s.endsWith('.') ? s : '$s.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isUrgent ? AppColors.danger : AppColors.textSecondary,
              fontWeight: isUrgent ? FontWeight.w600 : FontWeight.w400,
              height: 1.6,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Notify Care Team ────────────────────────────────────────────────────────

class _NotifyCareTeam extends StatelessWidget {
  final HealthAlertController ctrl;
  const _NotifyCareTeam({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('notify_care_team'.tr, style: AppTextStyles.h2),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _CareTeamButton(
                emoji: '👨‍⚕️',
                label: 'notify_doctor'.tr,
                onTap: ctrl.notifyDoctor,
                borderColor: AppColors.primary,
                textColor: AppColors.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _CareTeamButton(
                emoji: '👨‍👩‍👧',
                label: 'family'.tr,
                onTap: ctrl.notifyFamily,
                borderColor: AppColors.border,
                textColor: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CareTeamButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  final Color borderColor;
  final Color textColor;

  const _CareTeamButton({
    required this.emoji,
    required this.label,
    required this.onTap,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 22.sp)),
            SizedBox(height: 6.h),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Emergency SOS Button ────────────────────────────────────────────────────

class _EmergencySosButton extends StatelessWidget {
  final HealthAlertController ctrl;
  const _EmergencySosButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ctrl.callEmergency,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          gradient: AppColors.emergencyGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.danger.withValues(alpha: 0.35),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🚨', style: TextStyle(fontSize: 20.sp)),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'emergency_sos'.tr,
                  style: AppTextStyles.buttonLarge,
                ),
                Text(
                  'call_emergency_services'.tr,
                  style: AppTextStyles.onDarkBody.copyWith(fontSize: 12.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}