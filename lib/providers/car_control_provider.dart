import 'dart:async';

import 'package:cloud_car/models/led_state.dart';
import 'package:cloud_car/models/movement_command.dart';
import 'package:cloud_car/providers/connection_provider.dart';
import 'package:cloud_car/providers/settings_provider.dart';
import 'package:cloud_car/services/backend_repository.dart';
import 'package:cloud_car/utils/command_mapper.dart';
import 'package:cloud_car/utils/constants.dart';
import 'package:flutter/foundation.dart';

class CarControlProvider extends ChangeNotifier {
  CarControlProvider(
    this._repository,
    this._settingsProvider,
    this._connectionProvider,
  );

  final BackendRepository _repository;
  final SettingsProvider _settingsProvider;
  final ConnectionProvider _connectionProvider;

  static const _minCommandInterval = Duration(milliseconds: 120);
  static const _keepAliveInterval = Duration(milliseconds: 300);
  static const _commandExpiry = Duration(milliseconds: 900);

  MovementDirection _direction = MovementDirection.stop;
  int _speed = AppDefaults.speed;
  int _effectiveSpeed = 0;
  bool _emergencyStopped = false;
  LedState _ledState = LedState.unknown;
  String? _lastError;
  String? _statusMessage;
  DateTime? _lastSentAt;
  DateTime? _lastSuccessfulCommandAt;

  JoystickVector _joystickVector = JoystickVector.neutral;
  MovementCommand? _desiredCommand;
  Timer? _repeatTimer;
  Timer? _watchdogTimer;
  bool _isSending = false;
  bool _disposed = false;

  MovementDirection get direction => _direction;
  int get speed => _speed;
  int get effectiveSpeed => _effectiveSpeed;
  bool get emergencyStopped => _emergencyStopped;
  LedState get ledState => _ledState;
  String? get lastError => _lastError;
  String? get statusMessage => _statusMessage;
  bool get isMoving => _direction.isMoving && !_emergencyStopped;
  bool get movementEnabled =>
      !_emergencyStopped && _connectionProvider.isOnline;

  Future<void> initialize() async {
    _connectionProvider.addListener(_onConnectionChanged);
  }

  void _onConnectionChanged() {
    if (!_connectionProvider.isOnline) handleConnectionLost();
  }

  void updateJoystick(JoystickVector vector) {
    _joystickVector = vector;

    if (_emergencyStopped) {
      _statusMessage = 'Emergency stop is active. Reset it before moving.';
      _notify();
      return;
    }

    if (!_connectionProvider.isOnline) {
      _setLocalStop();
      _lastError = 'Backend is offline. Movement commands are disabled.';
      _statusMessage = 'Waiting for backend connection.';
      _notify();
      return;
    }

    final command = CommandMapper.map(vector, maxSpeed: _speed);
    if (command.direction == MovementDirection.stop) {
      releaseJoystick();
      return;
    }

    _desiredCommand = command;
    _direction = command.direction;
    _effectiveSpeed = command.speed;
    _lastError = null;
    _statusMessage = 'Commanding ${command.direction.label} at ${command.speed}.';

    _sendNowIfAllowed(command);
    _startRepeatTimer();
    _armWatchdog();
    _notify();
  }

  void releaseJoystick() {
    final hadMovement = _desiredCommand != null || _joystickVector.isActive;
    _joystickVector = JoystickVector.neutral;
    _setLocalStop();
    if (hadMovement && !_emergencyStopped) {
      unawaited(sendStop());
    } else {
      _notify();
    }
  }

  Future<bool> sendStop() async {
    if (!_connectionProvider.isOnline) {
      _setLocalStop();
      _lastError = 'Backend offline. Local stop applied; STOP was not sent.';
      _statusMessage = 'Safety stop applied locally.';
      _notify();
      return false;
    }
    return _sendCommand(MovementCommand.stop, stopRequested: true);
  }

  void activateEmergencyStop() {
    _emergencyStopped = true;
    _joystickVector = JoystickVector.neutral;
    _setLocalStop();
    _statusMessage = 'EMERGENCY STOP ACTIVE — motors commanded to stop.';
    _lastError = null;
    unawaited(sendStop());
    _notify();
  }

  Future<void> resetEmergencyStop() async {
    final wasOnline = _connectionProvider.isOnline;
    if (wasOnline) {
      await sendStop();
    } else {
      _lastError = 'Backend offline. STOP could not be transmitted.';
    }

    _emergencyStopped = false;
    _joystickVector = JoystickVector.neutral;
    _setLocalStop();
    _statusMessage = wasOnline
        ? 'Emergency stop reset. Joystick is released.'
        : 'Emergency stop reset locally. Backend is still offline.';
    _notify();
  }

  void setSpeed(int value) {
    _speed = value.clamp(AppDefaults.minSpeed, AppDefaults.maxSpeed).toInt();

    if (_desiredCommand != null && _joystickVector.isActive) {
      final updated = CommandMapper.map(_joystickVector, maxSpeed: _speed);
      if (updated.direction != MovementDirection.stop) {
        _desiredCommand = updated;
        _direction = updated.direction;
        _effectiveSpeed = updated.speed;
        unawaited(_sendCommand(updated));
      }
    }
    _notify();
  }

  Future<bool> setLed({required bool on}) async {
    if (!_connectionProvider.isOnline) {
      _lastError = 'Backend is offline. LED state was not changed.';
      _notify();
      return false;
    }

    final result = await _repository.setLed(
      _settingsProvider.settings,
      on: on,
    );

    if (result.isSuccess) {
      _ledState = on ? LedState.on : LedState.off;
      _statusMessage = 'LED turned ${on ? 'ON' : 'OFF'}.';
      _lastError = null;
    } else {
      _lastError = result.displayMessage;
    }
    _notify();
    return result.isSuccess;
  }

  void handleConnectionLost() {
    if (_desiredCommand != null) {
      _setLocalStop();
      if (!_emergencyStopped) {
        _lastError = 'Connection lost. Movement stopped locally.';
        _statusMessage = 'No movement until the backend reconnects.';
      }
      _notify();
    }
  }

  void handleAppBackgrounded() {
    if (_desiredCommand != null || _joystickVector.isActive) {
      releaseJoystick();
    }
  }

  void clearMessages() {
    _lastError = null;
    _statusMessage = null;
    _notify();
  }

  void _sendNowIfAllowed(MovementCommand command) {
    final now = DateTime.now();
    if (_lastSentAt == null ||
        now.difference(_lastSentAt!) >= _minCommandInterval) {
      unawaited(_sendCommand(command));
    }
  }

  Future<bool> _sendCommand(
    MovementCommand command, {
    bool stopRequested = false,
  }) async {
    if (_disposed) return false;

    final isStop = command.direction == MovementDirection.stop;
    if (_isSending && !stopRequested && !isStop) return false;
    if (_emergencyStopped && !isStop) return false;
    if (!_connectionProvider.isOnline && !isStop) {
      handleConnectionLost();
      return false;
    }

    if (!stopRequested && !isStop) _isSending = true;

    try {
      final result = await _repository.sendCommand(
        _settingsProvider.settings,
        command,
      );

      if (!result.isSuccess) {
        _lastError = result.displayMessage;
        return false;
      }

      final sentAt = DateTime.now();
      _lastSentAt = sentAt;
      _lastSuccessfulCommandAt = sentAt;
      _lastError = null;

      if (isStop) {
        if (_desiredCommand == null) {
          _direction = MovementDirection.stop;
          _effectiveSpeed = 0;
        }
      } else {
        _direction = command.direction;
        _effectiveSpeed = command.speed;
        _armWatchdog();
      }
      return true;
    } catch (error) {
      _lastError = 'Command failed: $error';
      return false;
    } finally {
      if (!stopRequested && !isStop) _isSending = false;
      _notify();
    }
  }

  void _startRepeatTimer() {
    _repeatTimer?.cancel();
    _repeatTimer = Timer.periodic(_keepAliveInterval, (_) {
      final desired = _desiredCommand;
      if (desired == null || _emergencyStopped || !_connectionProvider.isOnline) {
        _repeatTimer?.cancel();
        handleConnectionLost();
        return;
      }
      unawaited(_sendCommand(desired));
    });
  }

  void _armWatchdog() {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer(_commandExpiry, _checkCommandWatchdog);
  }

  void _checkCommandWatchdog() {
    if (_desiredCommand == null) return;
    final lastSuccess = _lastSuccessfulCommandAt;
    final expired = lastSuccess == null ||
        DateTime.now().difference(lastSuccess) >= _commandExpiry;

    if (!expired) {
      _armWatchdog();
      return;
    }

    _lastError = 'Movement command timed out. Local stop applied.';
    _statusMessage = 'Safety watchdog stopped movement.';
    _setLocalStop();
    unawaited(sendStop());
  }

  void _setLocalStop() {
    _repeatTimer?.cancel();
    _watchdogTimer?.cancel();
    _desiredCommand = null;
    _joystickVector = JoystickVector.neutral;
    _direction = MovementDirection.stop;
    _effectiveSpeed = 0;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _repeatTimer?.cancel();
    _watchdogTimer?.cancel();
    _connectionProvider.removeListener(_onConnectionChanged);
    super.dispose();
  }
}
