import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
import 'package:get/get.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/health_controller.dart';
import '../../../../models/health_model.dart';

class HealthMonitorScreen extends StatelessWidget {
  const HealthMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HealthController>()) {
      Get.lazyPut<HealthController>(() => HealthController());
    }
    final ctrl = Get.find<HealthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(ctrl: ctrl),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metrics Grid
                  Obx(() => GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ctrl.metrics.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 1.05,
                    ),
                    itemBuilder: (_, i) =>
                        _HealthMetricCard(metric: ctrl.metrics[i]),
                  )),
                  SizedBox(height: 24.h),
                  // Connected Devices
                  Text('Connected Devices', style: AppTextStyles.h2),
                  SizedBox(height: 12.h),
                  Obx(() => Column(
                    children: ctrl.devices
                        .map(
                          (d) => _DeviceCard(
                            device: d,
                            isBusy: ctrl.isConnectingDevice.value,
                            onConnect: () => ctrl.connectDevice(d),
                            onDisconnect: () => ctrl.disconnectDevice(d),
                          ),
                        )
                        .toList(),
                  )),
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
  final HealthController ctrl;
  const _Header({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
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
                    Text('Health Monitoring',
                        style: AppTextStyles.onDarkTitle),
                    SizedBox(height: 4.h),
                    Obx(() => Row(
                      children: [
                        Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4ADE80),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Live Data  ·  ${ctrl.lastSync.value}',
                          style: AppTextStyles.onDarkBody,
                        ),
                      ],
                    )),
                  ],
                ),
              ),
              GestureDetector(
                onTap: ctrl.syncNow,
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(Icons.sync, color: Colors.white, size: 20.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Health Metric Card (widget) ─────────────────────────────────────────────

class _HealthMetricCard extends StatelessWidget {
  final HealthMetricModel metric;
  const _HealthMetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: metric.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: metric.metricColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji + sparkline row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(metric.emoji, style: TextStyle(fontSize: 20.sp)),
              const Spacer(),
              _Sparkline(
                data: metric.sparkline,
                color: metric.metricColor,
              ),
            ],
          ),
          const Spacer(),
          // Value
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: metric.value,
                  style: AppTextStyles.metric.copyWith(
                    color: metric.metricColor,
                  ),
                ),
                TextSpan(
                  text: ' ${metric.unit}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: metric.metricColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Text(metric.label, style: AppTextStyles.bodySmall),
          SizedBox(height: 6.h),
          // Status
          Row(
            children: [
              Container(
                width: 6.r,
                height: 6.r,
                decoration: BoxDecoration(
                  color: metric.statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                metric.statusLabel,
                style: AppTextStyles.labelSmall.copyWith(
                  color: metric.statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Sparkline ───────────────────────────────────────────────────────────────

class _Sparkline extends StatelessWidget {
  final List<double> data;
  final Color color;
  const _Sparkline({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 20.h,
      child: CustomPaint(
        painter: _SparklinePainter(data: data, color: color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  const _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final minVal = data.reduce((a, b) => a < b ? a : b);
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final points = List.generate(data.length, (i) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height - ((data[i] - minVal) / range) * size.height;
      return Offset(x, y);
    });

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.data != data || old.color != color;
}

// ─── Device Card ─────────────────────────────────────────────────────────────

class _DeviceCard extends StatelessWidget {
  final ConnectedDeviceModel device;
  final bool isBusy;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const _DeviceCard({
    required this.device,
    required this.isBusy,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: device.isConnected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: device.isConnected ? AppColors.primary : AppColors.border,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: device.isConnected
                  ? Colors.white.withValues(alpha: 0.2)
                  : AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Center(
              child: Text(device.deviceIcon, style: TextStyle(fontSize: 18.sp)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: AppTextStyles.h3.copyWith(
                    color: device.isConnected
                        ? AppColors.textOnDark
                        : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  device.subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: device.isConnected
                        ? Colors.white.withValues(alpha: 0.75)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isBusy)
            SizedBox(
              width: 22.r,
              height: 22.r,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: device.isConnected ? Colors.white : AppColors.primary,
              ),
            )
          else if (!device.isAvailable)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.border.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                device.type == DeviceType.appleWatch ? 'iOS only' : 'Android only',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else if (device.isConnected)
            GestureDetector(
              onTap: onDisconnect,
              child: Row(
                children: [
                  if (device.batteryPercent != null) ...[
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${device.batteryPercent}%',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'disconnect'.tr,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: onConnect,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${'connect'.tr} +',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
