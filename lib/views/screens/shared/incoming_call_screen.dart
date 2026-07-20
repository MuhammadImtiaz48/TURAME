import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../services/call_service.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callId;
  final String roomId;
  final String userId;
  final String userName;
  final String remoteUserId;
  final String remoteUserName;
  final String callType;

  const IncomingCallScreen({
    super.key,
    required this.callId,
    required this.roomId,
    required this.userId,
    required this.userName,
    required this.remoteUserId,
    required this.remoteUserName,
    this.callType = 'video',
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isAccepting = false;
  bool _isRejecting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _startVibration();
  }

  void _startVibration() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        Vibration.vibrate(pattern: [500, 200, 500, 200, 500], repeat: 0);
      }
    } catch (e) {
      debugPrint('Vibration error: $e');
    }
  }

  Future<void> _stopVibration() async {
    try {
      Vibration.cancel();
    } catch (e) {
      debugPrint('Stop vibration error: $e');
    }
  }

  Future<void> _acceptCall() async {
    if (_isAccepting || _isRejecting) return;
    setState(() => _isAccepting = true);
    await _stopVibration();

    if (!Get.isRegistered<CallService>()) {
      Get.put(CallService(), permanent: true);
    }
    if (widget.callId.isNotEmpty) {
      await CallService.to
          .updateCallStatus(widget.callId, CallService.statusAccepted);
    }

    if (mounted) Get.back();

    await CallService.to.joinCall(
      roomId: widget.roomId,
      userId: widget.userId,
      userName: widget.userName,
      remoteUserId: widget.remoteUserId,
      calleeName: widget.remoteUserName,
      callType: widget.callType,
      isIncoming: true,
    );
  }

  Future<void> _rejectCall() async {
    if (_isRejecting || _isAccepting) return;
    setState(() => _isRejecting = true);
    await _stopVibration();

    if (!Get.isRegistered<CallService>()) {
      Get.put(CallService(), permanent: true);
    }
    if (widget.callId.isNotEmpty) {
      await CallService.to
          .updateCallStatus(widget.callId, CallService.statusRejected);
    }

    if (mounted) Get.back();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stopVibration();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.callType.toLowerCase() == 'video';
    final callerInitial = widget.remoteUserName.isNotEmpty
        ? widget.remoteUserName[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 60.h),
                    Text(
                      isVideo ? 'Video Call' : 'Audio Call',
                      style: AppTextStyles.onDarkBody.copyWith(
                        fontSize: 14.sp,
                        color: Colors.white70,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 140.w,
                        height: 140.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.secondary,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            callerInitial,
                            style: TextStyle(
                              fontSize: 56.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textOnDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    Text(
                      widget.remoteUserName,
                      style: AppTextStyles.onDarkTitle.copyWith(fontSize: 28.sp),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Incoming ${isVideo ? 'video' : 'audio'} call...',
                      style: AppTextStyles.onDarkBody.copyWith(
                        fontSize: 16.sp,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 80.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          icon: Icons.call_end_rounded,
                          label: 'Reject',
                          color: AppColors.danger,
                          onTap: _rejectCall,
                          isLoading: _isRejecting,
                        ),
                        SizedBox(width: 60.w),
                        _buildActionButton(
                          icon: isVideo
                              ? Icons.videocam_rounded
                              : Icons.call_rounded,
                          label: 'Accept',
                          color: AppColors.success,
                          onTap: _acceptCall,
                          isLoading: _isAccepting,
                        ),
                      ],
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedOpacity(
        opacity: isLoading ? 0.6 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          children: [
            Container(
              width: 72.w,
              height: 72.h,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.textOnDark,
                      ),
                    )
                  : Icon(icon, size: 32.r, color: AppColors.textOnDark),
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: AppTextStyles.onDarkBody.copyWith(
                fontSize: 13.sp,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
