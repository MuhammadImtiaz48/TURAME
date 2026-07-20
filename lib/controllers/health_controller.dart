import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../models/health_model.dart';
import '../services/apple_health_service.dart';
import '../services/firebase_service.dart';
import '../services/wearable_health_service.dart';
import 'auth_controllers/auth_controller.dart';

class HealthController extends GetxController {
  final lastSync = 'Last sync —'.obs;
  final isLive = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isConnectingDevice = false.obs;

  final AuthController _authCtrl = Get.find<AuthController>();

  WearableHealthService get _wearable => WearableHealthService.to;
  AppleHealthService get _appleHealth => AppleHealthService.to;

  final RxList<HealthMetricModel> metrics = <HealthMetricModel>[].obs;

  final RxList<ConnectedDeviceModel> devices = <ConnectedDeviceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Defer seeding/loading so no observable is mutated synchronously while
    // the (eagerly built) health screen's Obx widgets are mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _seedDevices();
      _seedMetrics();
      _restoreDeviceState();
      loadVitals();
    });
  }

  void _seedDevices() {
    final appleOnIos = Platform.isIOS;
    devices.assignAll([
      ConnectedDeviceModel(
        name: 'Apple Watch',
        subtitle: appleOnIos
            ? 'Connect via Apple Health'
            : 'Only available on iOS',
        type: DeviceType.appleWatch,
        isConnected: false,
        isAvailable: appleOnIos,
      ),
      ConnectedDeviceModel(
        name: 'Samsung Health',
        subtitle: Platform.isAndroid
            ? 'Connect Samsung Galaxy Watch'
            : 'Only available on Android',
        type: DeviceType.samsungHealth,
        isConnected: false,
        isAvailable: Platform.isAndroid,
      ),
    ]);
  }

  void _restoreDeviceState() {
    if (Get.isRegistered<AppleHealthService>() &&
        Platform.isIOS &&
        _appleHealth.isConnected) {
      _setDeviceConnected(
        DeviceType.appleWatch,
        connected: true,
        subtitle: 'Apple Health syncing',
      );
    }

    if (!Get.isRegistered<WearableHealthService>()) return;
    final connected = _wearable.isSamsungConnected;
    _setDeviceConnected(
      DeviceType.samsungHealth,
      connected: connected,
      subtitle: connected
          ? 'Samsung Health syncing'
          : (Platform.isAndroid
              ? 'Connect Samsung Galaxy Watch'
              : 'Only available on Android'),
    );
  }

  // Build the metric cards with empty/placeholder values; real values are
  // filled in by loadVitals() from HealthKit or provider-entered vitals.
  void _seedMetrics() {
    metrics.assignAll([
      HealthMetricModel(
        id: 'heart_rate',
        emoji: '❤️',
        value: '--',
        unit: 'bpm',
        label: 'Heart Rate',
        status: HealthStatus.normal,
        cardColor: const Color(0xFFFFF0F0),
        metricColor: AppColors.heartRate,
        sparkline: [68, 72, 70, 75, 71, 72, 74, 72],
      ),
      HealthMetricModel(
        id: 'oxygen',
        emoji: '🫁',
        value: '--',
        unit: '%',
        label: 'Oxygen SpO₂',
        status: HealthStatus.normal,
        cardColor: const Color(0xFFEFF6FF),
        metricColor: AppColors.oxygen,
        sparkline: [97, 98, 98, 99, 97, 98, 98, 98],
      ),
      HealthMetricModel(
        id: 'blood_pressure',
        emoji: '🩸',
        value: '--',
        unit: 'mmHg',
        label: 'Blood Pressure',
        status: HealthStatus.normal,
        cardColor: const Color(0xFFF0FDF4),
        metricColor: AppColors.bloodPressure,
        sparkline: [118, 122, 119, 121, 120, 118, 120, 120],
      ),
      HealthMetricModel(
        id: 'blood_sugar',
        emoji: '💉',
        value: '--',
        unit: 'mg/dL',
        label: 'Blood Sugar',
        status: HealthStatus.normal,
        cardColor: const Color(0xFFFFFBEB),
        metricColor: AppColors.bloodSugar,
        sparkline: [92, 96, 94, 97, 95, 93, 95, 95],
      ),
    ]);
  }

  // Fetch vitals: prefer Apple Health when connected, else Firestore vitals.
  Future<void> loadVitals() async {
    try {
      isLoading.value = true;

      if (Get.isRegistered<AppleHealthService>() &&
          Platform.isIOS &&
          _appleHealth.isConnected) {
        final loaded = await _loadAppleHealthVitals();
        if (loaded) return;
      }

      await _loadFirebaseVitals();
    } catch (e) {
      // Keep existing/placeholder values when fetch fails.
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _loadAppleHealthVitals() async {
    try {
      final vitals = await _appleHealth.fetchVitals();
      if (!vitals.hasAnyData) return false;

      _applyMetric(
        'heart_rate',
        vitals.heartRate,
        unit: 'bpm',
        status: _heartRateStatus(vitals.heartRate),
        sparkline: vitals.heartRateSparkline,
      );
      _applyMetric(
        'oxygen',
        vitals.oxygen,
        unit: '%',
        status: _oxygenStatus(vitals.oxygen),
        sparkline: vitals.oxygenSparkline,
      );
      _applyMetric(
        'blood_pressure',
        vitals.bloodPressure,
        unit: 'mmHg',
        status: HealthStatus.normal,
        sparkline: vitals.bloodPressureSparkline,
      );
      _applyMetric(
        'blood_sugar',
        vitals.bloodSugar,
        unit: 'mg/dL',
        status: _bloodSugarStatus(vitals.bloodSugar),
        sparkline: vitals.bloodSugarSparkline,
      );

      final syncTime = vitals.lastUpdated ?? DateTime.now();
      lastSync.value = 'Last sync ${_timeAgo(syncTime)}';
      return true;
    } catch (e) {
      debugPrint('Apple Health vitals load failed: $e');
      return false;
    }
  }

  Future<void> _loadFirebaseVitals() async {
    final id = _authCtrl.user.value?.id;
    if (id == null || id.isEmpty) return;

    final patient = await FirebaseService.getPatientById(id);
    if (patient == null) return;

    _applyMetric(
      'heart_rate',
      patient.heartRate,
      unit: 'bpm',
      status: _heartRateStatus(patient.heartRate),
    );
    _applyMetric(
      'oxygen',
      patient.oxygen,
      unit: '%',
      status: _oxygenStatus(patient.oxygen),
    );
    _applyMetric(
      'blood_pressure',
      patient.bloodPressure,
      unit: 'mmHg',
      status: HealthStatus.normal,
    );
    _applyMetric(
      'blood_sugar',
      patient.bloodSugar,
      unit: 'mg/dL',
      status: _bloodSugarStatus(patient.bloodSugar),
    );

    lastSync.value = 'Last sync ${_timeAgo(DateTime.now())}';
  }

  // Update a metric's value/unit/status by id, preserving its other props.
  void _applyMetric(
    String id,
    String? rawValue, {
    required String unit,
    required HealthStatus status,
    List<double>? sparkline,
  }) {
    final index = metrics.indexWhere((m) => m.id == id);
    if (index == -1) return;
    final current = metrics[index];
    final hasValue = rawValue != null && rawValue.trim().isNotEmpty;

    metrics[index] = HealthMetricModel(
      id: current.id,
      emoji: current.emoji,
      value: hasValue ? rawValue.trim() : '--',
      unit: hasValue ? unit : '',
      label: current.label,
      status: hasValue ? status : HealthStatus.normal,
      cardColor: current.cardColor,
      metricColor: current.metricColor,
      sparkline: (sparkline != null && sparkline.isNotEmpty)
          ? sparkline
          : current.sparkline,
    );
  }

  HealthStatus _heartRateStatus(String? raw) {
    final v = double.tryParse(raw ?? '');
    if (v == null) return HealthStatus.normal;
    if (v < 60 || v > 100) return HealthStatus.warning;
    return HealthStatus.normal;
  }

  HealthStatus _oxygenStatus(String? raw) {
    final v = double.tryParse(raw ?? '');
    if (v == null) return HealthStatus.normal;
    if (v < 90) return HealthStatus.critical;
    if (v < 95) return HealthStatus.warning;
    return HealthStatus.normal;
  }

  HealthStatus _bloodSugarStatus(String? raw) {
    final v = double.tryParse(raw ?? '');
    if (v == null) return HealthStatus.normal;
    if (v < 70 || v > 140) return HealthStatus.warning;
    return HealthStatus.normal;
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} d ago';
  }

  Future<void> syncNow() async {
    lastSync.value = 'Syncing...';
    try {
      if (Get.isRegistered<WearableHealthService>() &&
          _wearable.isSamsungConnected) {
        await _wearable.syncNow();
      }
      await loadVitals();
      if (lastSync.value == 'Syncing...') {
        lastSync.value = 'Last sync just now';
      }
    } catch (e) {
      lastSync.value = 'Last sync failed';
      Get.snackbar(
        'Sync failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> connectDevice(ConnectedDeviceModel device) async {
    if (!device.isAvailable) {
      final msg = device.type == DeviceType.appleWatch
          ? 'Apple Watch is only available on iOS.'
          : device.type == DeviceType.samsungHealth
              ? 'Samsung Health is only available on Android.'
              : 'This device is not available on this platform.';
      Get.snackbar(
        device.name,
        msg,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    switch (device.type) {
      case DeviceType.samsungHealth:
        await connectSamsungHealth();
      case DeviceType.appleWatch:
        await connectAppleWatch();
      case DeviceType.fitbit:
      case DeviceType.other:
        Get.snackbar(
          'Unavailable',
          'This device type is not supported yet.',
          snackPosition: SnackPosition.BOTTOM,
        );
    }
  }

  Future<void> disconnectDevice(ConnectedDeviceModel device) async {
    switch (device.type) {
      case DeviceType.samsungHealth:
        await disconnectSamsungHealth();
      case DeviceType.appleWatch:
        await disconnectAppleWatch();
      case DeviceType.fitbit:
      case DeviceType.other:
        return;
    }
  }

  Future<void> connectAppleWatch() async {
    if (!Platform.isIOS) {
      Get.snackbar(
        'apple_health'.tr,
        'Apple Watch is only available on iOS.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (!Get.isRegistered<AppleHealthService>()) {
      Get.snackbar(
        'Error',
        'Apple Health service is not available.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isConnectingDevice.value = true;
      await _appleHealth.connect();
      _setDeviceConnected(
        DeviceType.appleWatch,
        connected: true,
        subtitle: 'Apple Health syncing',
      );
      await loadVitals();
      lastSync.value = 'Last sync just now';
      Get.snackbar(
        'apple_health'.tr,
        'wearable_connected'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on AppleHealthException catch (e) {
      Get.snackbar(
        'apple_health'.tr,
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'apple_health'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isConnectingDevice.value = false;
    }
  }

  Future<void> disconnectAppleWatch() async {
    if (!Get.isRegistered<AppleHealthService>()) return;

    try {
      isConnectingDevice.value = true;
      await _appleHealth.disconnect();
      _setDeviceConnected(
        DeviceType.appleWatch,
        connected: false,
        subtitle: Platform.isIOS
            ? 'Connect via Apple Health'
            : 'Only available on iOS',
      );
      await _loadFirebaseVitals();
      Get.snackbar(
        'apple_health'.tr,
        'wearable_disconnected'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'apple_health'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isConnectingDevice.value = false;
    }
  }

  Future<void> connectSamsungHealth({
    String? accessToken,
    String? refreshToken,
  }) async {
    if (!Get.isRegistered<WearableHealthService>()) {
      Get.snackbar(
        'Error',
        'Wearable health service is not available.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final userId = _authCtrl.user.value?.id;
    if (userId == null || userId.isEmpty) {
      Get.snackbar(
        'Sign in required',
        'Please sign in before connecting Samsung Health.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isConnectingDevice.value = true;
      await _wearable.connectSamsungHealth(
        owUserId: userId,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      _setDeviceConnected(
        DeviceType.samsungHealth,
        connected: true,
        subtitle: 'Samsung Health syncing',
      );
      lastSync.value = 'Last sync just now';
      Get.snackbar(
        'samsung_health'.tr,
        'wearable_connected'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on WearableHealthException catch (e) {
      Get.snackbar(
        'samsung_health'.tr,
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'samsung_health'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isConnectingDevice.value = false;
    }
  }

  Future<void> disconnectSamsungHealth() async {
    if (!Get.isRegistered<WearableHealthService>()) return;

    try {
      isConnectingDevice.value = true;
      await _wearable.disconnectSamsungHealth();
      _setDeviceConnected(
        DeviceType.samsungHealth,
        connected: false,
        subtitle: Platform.isAndroid
            ? 'Connect Samsung Galaxy Watch'
            : 'Only available on Android',
      );
      Get.snackbar(
        'samsung_health'.tr,
        'wearable_disconnected'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'samsung_health'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isConnectingDevice.value = false;
    }
  }

  void _setDeviceConnected(
    DeviceType type, {
    required bool connected,
    required String subtitle,
  }) {
    final index = devices.indexWhere((d) => d.type == type);
    if (index == -1) return;
    devices[index] = devices[index].copyWith(
      isConnected: connected,
      subtitle: subtitle,
      clearBattery: !connected,
    );
  }
}
