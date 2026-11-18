import 'package:cloud_car/models/api_result.dart';

class BackendHealth {
  const BackendHealth({
    required this.reachable,
    required this.checkedAt,
    this.status,
    this.esp32Online,
    this.mqttConnected,
    this.batteryPercentage,
    this.motorSpeed,
    this.direction,
    this.rawMessage,
  });

  final bool reachable;
  final DateTime checkedAt;
  final String? status;
  final bool? esp32Online;
  final bool? mqttConnected;
  final int? batteryPercentage;
  final int? motorSpeed;
  final String? direction;
  final String? rawMessage;

  bool get hasTelemetry =>
      esp32Online != null ||
      mqttConnected != null ||
      batteryPercentage != null ||
      motorSpeed != null ||
      direction != null;

  static BackendHealth fromApiResult(ApiResult result) {
    final json = result.json;
    final telemetry = _asMap(json?['telemetry']);

    return BackendHealth(
      reachable: result.isSuccess,
      checkedAt: DateTime.now(),
      status: _firstString(json, const ['status', 'state', 'message']),
      esp32Online: _firstBool(
        json,
        const ['esp32Online', 'esp32_online', 'carOnline', 'deviceOnline'],
      ) ??
          _firstBool(
            telemetry,
            const ['esp32Online', 'esp32_online', 'online'],
          ),
      mqttConnected: _firstBool(
        json,
        const [
          'mqttConnected',
          'mqtt_connected',
          'mqttOnline',
          'brokerConnected',
        ],
      ) ??
          _firstBool(
            telemetry,
            const ['mqttConnected', 'mqtt_connected', 'connected'],
          ),
      batteryPercentage: _firstInt(
        json,
        const ['batteryPercentage', 'battery_percent', 'battery'],
      ) ??
          _firstInt(
            telemetry,
            const ['batteryPercentage', 'battery_percent', 'battery'],
          ),
      motorSpeed: _firstInt(
        json,
        const ['motorSpeed', 'motor_speed', 'currentSpeed'],
      ) ??
          _firstInt(
            telemetry,
            const ['motorSpeed', 'motor_speed', 'speed'],
          ),
      direction: _firstString(
        json,
        const ['direction', 'currentDirection', 'current_direction'],
      ) ??
          _firstString(telemetry, const ['direction', 'command']),
      rawMessage: result.errorMessage ??
          _firstString(json, const ['detail', 'error']),
    );
  }

  static Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry<String, dynamic>(key.toString(), item),
      );
    }
    return null;
  }

  static String? _firstString(Map<String, dynamic>? json, List<String> keys) {
    for (final key in keys) {
      final value = json?[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  static int? _firstInt(Map<String, dynamic>? json, List<String> keys) {
    for (final key in keys) {
      final value = json?[key];
      if (value is int) return value;
      if (value is num) return value.round();
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static bool? _firstBool(Map<String, dynamic>? json, List<String> keys) {
    for (final key in keys) {
      final value = json?[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final text = value.toLowerCase().trim();
        if (const {'true', '1', 'yes', 'on', 'ok', 'online', 'connected'}
            .contains(text)) {
          return true;
        }
        if (const {'false', '0', 'no', 'off', 'error', 'offline', 'disconnected'}
            .contains(text)) {
          return false;
        }
      }
    }
    return null;
  }
}
