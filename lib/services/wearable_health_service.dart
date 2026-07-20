import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:open_wearables_health_sdk/health_data_type.dart';
import 'package:open_wearables_health_sdk/open_wearables_health_sdk.dart';

import '../constants/wearable_health_config.dart';

/// Wraps [OpenWearablesHealthSdk] for Samsung Health (Android) sync.
///
/// Follows the same GetX service pattern as [StripeService] / [ZegoService].
class WearableHealthService extends GetxService {
  static WearableHealthService get to => Get.find<WearableHealthService>();

  static const _providerKey = 'wearable_health_provider';
  static const _samsungConnectedKey = 'samsung_health_connected';

  final _box = GetStorage();
  bool _initialized = false;

  /// Data types aligned with TURAME vitals + common wearable metrics.
  static const List<HealthDataType> _syncTypes = [
    HealthDataType.steps,
    HealthDataType.heartRate,
    HealthDataType.restingHeartRate,
    HealthDataType.oxygenSaturation,
    HealthDataType.bloodPressure,
    HealthDataType.bloodPressureSystolic,
    HealthDataType.bloodPressureDiastolic,
    HealthDataType.bloodGlucose,
    HealthDataType.sleep,
    HealthDataType.activeEnergy,
    HealthDataType.workout,
  ];

  bool get isSamsungConnected =>
      _box.read<bool>(_samsungConnectedKey) == true &&
      OpenWearablesHealthSdk.isSignedIn;

  bool get isSyncActive => OpenWearablesHealthSdk.isSyncActive;

  bool get isSignedIn => OpenWearablesHealthSdk.isSignedIn;

  Future<WearableHealthService> init() async {
    if (_initialized) return this;
    if (!WearableHealthConfig.isHostConfigured) {
      debugPrint('WearableHealthConfig.host is empty — SDK not configured');
      return this;
    }

    try {
      await OpenWearablesHealthSdk.configure(host: WearableHealthConfig.host);
      await OpenWearablesHealthSdk.setLogLevel(
        kDebugMode ? OWLogLevel.debug : OWLogLevel.none,
      );

      if (Platform.isAndroid) {
        await OpenWearablesHealthSdk.setSyncNotification(
          title: 'TURAME',
          text: 'Syncing your health data...',
        );
      }

      if (OpenWearablesHealthSdk.isSignedIn) {
        await _resumeInterruptedSync();
      } else {
        await _box.write(_samsungConnectedKey, false);
      }

      _initialized = true;
    } catch (e, st) {
      debugPrint('WearableHealthService.init failed: $e\n$st');
    }
    return this;
  }

  /// Connects Samsung Health on Android and starts background sync.
  ///
  /// [owUserId] should be the Open Wearables user id when using tokens.
  /// With API-key auth, the Firebase uid is acceptable for staging.
  ///
  /// Pass [accessToken] + [refreshToken] for production token auth;
  /// otherwise [WearableHealthConfig.apiKey] is used when set.
  Future<void> connectSamsungHealth({
    required String owUserId,
    String? accessToken,
    String? refreshToken,
  }) async {
    if (!Platform.isAndroid) {
      throw const WearableHealthException(
        'Samsung Health is only available on Android devices.',
      );
    }
    if (!_initialized) await init();
    if (!WearableHealthConfig.isHostConfigured) {
      throw const WearableHealthException(
        'Open Wearables host is not configured.',
      );
    }
    if (owUserId.trim().isEmpty) {
      throw const WearableHealthException('User id is required to sync health.');
    }

    await _ensureSignedIn(
      owUserId: owUserId.trim(),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    final available = await OpenWearablesHealthSdk.getAvailableProviders();
    final samsung = available.cast<AvailableProvider?>().firstWhere(
          (p) => p?.id == AndroidHealthProvider.samsungHealth.id,
          orElse: () => null,
        );

    if (samsung == null) {
      throw const WearableHealthException(
        'Samsung Health is not available on this device. '
        'Install Samsung Health (v6.30.2+) and enable Developer Mode for testing.',
      );
    }

    await OpenWearablesHealthSdk.setProvider(AndroidHealthProvider.samsungHealth);
    await _box.write(_providerKey, AndroidHealthProvider.samsungHealth.name);

    final authorized = await OpenWearablesHealthSdk.requestAuthorization(
      types: _syncTypes,
    );
    if (!authorized) {
      throw const WearableHealthException(
        'Health permissions were not granted.',
      );
    }

    await OpenWearablesHealthSdk.setSyncNotification(
      title: 'TURAME',
      text: 'Syncing Samsung Health data...',
    );

    final started = await OpenWearablesHealthSdk.startBackgroundSync(
      syncDaysBack: WearableHealthConfig.syncDaysBack,
    );
    if (!started) {
      throw const WearableHealthException('Failed to start health sync.');
    }

    await _box.write(_samsungConnectedKey, true);
  }

  /// Disconnects Samsung Health sync and signs out of the SDK session.
  Future<void> disconnectSamsungHealth() async {
    try {
      await OpenWearablesHealthSdk.stopBackgroundSync();
      await OpenWearablesHealthSdk.signOut();
    } finally {
      await _box.write(_samsungConnectedKey, false);
      await _box.remove(_providerKey);
    }
  }

  /// Triggers an immediate incremental sync if Samsung Health is connected.
  Future<void> syncNow() async {
    if (!isSamsungConnected) return;
    await OpenWearablesHealthSdk.syncNow();
  }

  Future<List<AvailableProvider>> getAvailableProviders() async {
    if (!Platform.isAndroid) return const [];
    if (!_initialized) await init();
    return OpenWearablesHealthSdk.getAvailableProviders();
  }

  Future<void> _ensureSignedIn({
    required String owUserId,
    String? accessToken,
    String? refreshToken,
  }) async {
    if (OpenWearablesHealthSdk.isSignedIn) return;

    final hasTokens =
        accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty;

    if (hasTokens) {
      await OpenWearablesHealthSdk.signIn(
        userId: owUserId,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      return;
    }

    if (!WearableHealthConfig.hasApiKey) {
      throw const WearableHealthException(
        'Open Wearables credentials missing. Set WearableHealthConfig.apiKey '
        'or provide accessToken + refreshToken from your backend.',
      );
    }

    await OpenWearablesHealthSdk.signIn(
      userId: owUserId,
      apiKey: WearableHealthConfig.apiKey,
    );
  }

  Future<void> _resumeInterruptedSync() async {
    try {
      final status = await OpenWearablesHealthSdk.getSyncStatus();
      if (status['hasResumableSession'] == true) {
        await OpenWearablesHealthSdk.resumeSync();
      }
    } catch (e) {
      debugPrint('WearableHealthService resume sync: $e');
    }
  }
}

class WearableHealthException implements Exception {
  final String message;
  const WearableHealthException(this.message);

  @override
  String toString() => message;
}
