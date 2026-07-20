import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:health/health.dart';

/// Snapshot of vitals read from Apple Health / HealthKit.
class AppleHealthVitals {
  final String? heartRate;
  final String? oxygen;
  final String? bloodPressure;
  final String? bloodSugar;
  final List<double> heartRateSparkline;
  final List<double> oxygenSparkline;
  final List<double> bloodPressureSparkline;
  final List<double> bloodSugarSparkline;
  final DateTime? lastUpdated;

  const AppleHealthVitals({
    this.heartRate,
    this.oxygen,
    this.bloodPressure,
    this.bloodSugar,
    this.heartRateSparkline = const [],
    this.oxygenSparkline = const [],
    this.bloodPressureSparkline = const [],
    this.bloodSugarSparkline = const [],
    this.lastUpdated,
  });

  bool get hasAnyData =>
      heartRate != null ||
      oxygen != null ||
      bloodPressure != null ||
      bloodSugar != null;
}

/// Reads Apple Watch / HealthKit vitals via the [health] package (iOS only).
class AppleHealthService extends GetxService {
  static AppleHealthService get to => Get.find<AppleHealthService>();

  static const _connectedKey = 'apple_health_connected';

  final _box = GetStorage();
  final Health _health = Health();
  bool _configured = false;

  static const List<HealthDataType> _types = [
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_GLUCOSE,
  ];

  bool get isConnected =>
      Platform.isIOS && _box.read<bool>(_connectedKey) == true;

  Future<AppleHealthService> init() async {
    if (!Platform.isIOS) return this;
    try {
      await _health.configure();
      _configured = true;
    } catch (e, st) {
      debugPrint('AppleHealthService.init failed: $e\n$st');
    }
    return this;
  }

  Future<void> connect() async {
    if (!Platform.isIOS) {
      throw const AppleHealthException(
        'Apple Watch is only available on iOS devices.',
      );
    }
    if (!_configured) await init();

    final permissions =
        List<HealthDataAccess>.filled(_types.length, HealthDataAccess.READ);

    final authorized = await _health.requestAuthorization(
      _types,
      permissions: permissions,
    );
    if (!authorized) {
      throw const AppleHealthException(
        'Apple Health permissions were not granted.',
      );
    }

    await _box.write(_connectedKey, true);
  }

  Future<void> disconnect() async {
    await _box.write(_connectedKey, false);
  }

  /// Fetches the latest vitals used by Health Monitoring.
  Future<AppleHealthVitals> fetchVitals({Duration lookback = const Duration(days: 7)}) async {
    if (!Platform.isIOS) {
      throw const AppleHealthException(
        'Apple Watch is only available on iOS devices.',
      );
    }
    if (!_configured) await init();
    if (!isConnected) {
      throw const AppleHealthException('Apple Health is not connected.');
    }

    final end = DateTime.now();
    final start = end.subtract(lookback);

    final points = await _health.getHealthDataFromTypes(
      types: _types,
      startTime: start,
      endTime: end,
    );
    final unique = _health.removeDuplicates(points);
    unique.sort((a, b) => b.dateTo.compareTo(a.dateTo));

    final hr = _latestNumeric(unique, HealthDataType.HEART_RATE);
    final spo2Raw = _latestNumeric(unique, HealthDataType.BLOOD_OXYGEN);
    final systolic = _latestNumeric(unique, HealthDataType.BLOOD_PRESSURE_SYSTOLIC);
    final diastolic =
        _latestNumeric(unique, HealthDataType.BLOOD_PRESSURE_DIASTOLIC);
    final glucose = _latestNumeric(unique, HealthDataType.BLOOD_GLUCOSE);

    final spo2 = spo2Raw == null
        ? null
        : (spo2Raw <= 1 ? spo2Raw * 100 : spo2Raw);

    DateTime? lastUpdated;
    for (final p in unique) {
      if (lastUpdated == null || p.dateTo.isAfter(lastUpdated)) {
        lastUpdated = p.dateTo;
      }
    }

    return AppleHealthVitals(
      heartRate: hr?.round().toString(),
      oxygen: spo2?.round().toString(),
      bloodPressure: (systolic != null && diastolic != null)
          ? '${systolic.round()}/${diastolic.round()}'
          : null,
      bloodSugar: glucose?.round().toString(),
      heartRateSparkline: _sparkline(unique, HealthDataType.HEART_RATE),
      oxygenSparkline: _sparkline(
        unique,
        HealthDataType.BLOOD_OXYGEN,
        scaleIfFraction: true,
      ),
      bloodPressureSparkline:
          _sparkline(unique, HealthDataType.BLOOD_PRESSURE_SYSTOLIC),
      bloodSugarSparkline: _sparkline(unique, HealthDataType.BLOOD_GLUCOSE),
      lastUpdated: lastUpdated,
    );
  }

  double? _latestNumeric(List<HealthDataPoint> points, HealthDataType type) {
    for (final p in points) {
      if (p.type != type) continue;
      final v = p.value;
      if (v is NumericHealthValue) return v.numericValue.toDouble();
    }
    return null;
  }

  List<double> _sparkline(
    List<HealthDataPoint> points,
    HealthDataType type, {
    bool scaleIfFraction = false,
    int maxPoints = 8,
  }) {
    final values = <double>[];
    for (final p in points.reversed) {
      if (p.type != type) continue;
      final v = p.value;
      if (v is! NumericHealthValue) continue;
      var n = v.numericValue.toDouble();
      if (scaleIfFraction && n <= 1) n *= 100;
      values.add(n);
      if (values.length >= maxPoints) break;
    }
    return values;
  }
}

class AppleHealthException implements Exception {
  final String message;
  const AppleHealthException(this.message);

  @override
  String toString() => message;
}
