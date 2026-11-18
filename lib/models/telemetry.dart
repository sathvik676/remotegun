import 'package:cloud_car/models/movement_command.dart';

class TelemetrySnapshot {
  const TelemetrySnapshot({
    required this.motorSpeed,
    required this.direction,
    required this.backendTelemetryAvailable,
    required this.lastUpdated,
    this.batteryPercentage,
    this.esp32Online,
    this.mqttConnected,
    this.reportedMotorSpeed,
    this.reportedDirection,
  });

  final int? batteryPercentage;
  final bool? esp32Online;
  final bool? mqttConnected;
  final int motorSpeed;
  final MovementDirection direction;
  final bool backendTelemetryAvailable;
  final int? reportedMotorSpeed;
  final String? reportedDirection;
  final DateTime? lastUpdated;

  String get speedSource =>
      backendTelemetryAvailable && reportedMotorSpeed != null
          ? 'Backend telemetry'
          : 'Last command sent by this app';

  String get directionSource =>
      backendTelemetryAvailable && reportedDirection != null
          ? 'Backend telemetry'
          : 'Last command sent by this app';
}
