import 'package:cloud_car/models/movement_command.dart';
import 'package:cloud_car/models/telemetry.dart';
import 'package:cloud_car/providers/car_control_provider.dart';
import 'package:cloud_car/providers/connection_provider.dart';
import 'package:flutter/foundation.dart';

class TelemetryProvider extends ChangeNotifier {
  TelemetryProvider(this._connectionProvider, this._carProvider);

  final ConnectionProvider _connectionProvider;
  final CarControlProvider _carProvider;
  bool _disposed = false;

  TelemetrySnapshot get snapshot {
    final health = _connectionProvider.lastHealth;
    final hasBackendTelemetry = health?.hasTelemetry ?? false;
    final reportedDirection = _parseDirection(health?.direction);

    return TelemetrySnapshot(
      batteryPercentage: health?.batteryPercentage,
      esp32Online: health?.esp32Online,
      mqttConnected: health?.mqttConnected,
      motorSpeed: health?.motorSpeed ?? _carProvider.effectiveSpeed,
      direction: reportedDirection ?? _carProvider.direction,
      backendTelemetryAvailable: hasBackendTelemetry,
      reportedMotorSpeed: health?.motorSpeed,
      reportedDirection: health?.direction,
      lastUpdated: health?.checkedAt,
    );
  }

  MovementDirection? _parseDirection(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase().trim()) {
      case 'FORWARD':
        return MovementDirection.forward;
      case 'BACKWARD':
        return MovementDirection.backward;
      case 'LEFT':
        return MovementDirection.left;
      case 'RIGHT':
        return MovementDirection.right;
      case 'STOP':
        return MovementDirection.stop;
      default:
        return null;
    }
  }

  void initialize() {
    _connectionProvider.addListener(_notify);
    _carProvider.addListener(_notify);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _connectionProvider.removeListener(_notify);
    _carProvider.removeListener(_notify);
    super.dispose();
  }
}
