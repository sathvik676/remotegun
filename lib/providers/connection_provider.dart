import 'dart:async';

import 'package:cloud_car/models/app_settings.dart';
import 'package:cloud_car/models/backend_health.dart';
import 'package:cloud_car/models/connection_state.dart';
import 'package:cloud_car/providers/settings_provider.dart';
import 'package:cloud_car/services/backend_repository.dart';
import 'package:cloud_car/utils/constants.dart';
import 'package:flutter/foundation.dart';

class ConnectionProvider extends ChangeNotifier {
  ConnectionProvider(this._repository, this._settingsProvider);

  final BackendRepository _repository;
  final SettingsProvider _settingsProvider;

  ConnectionStatus _status = ConnectionStatus.connecting;
  BackendHealth? _lastHealth;
  String? _lastError;
  DateTime? _lastCheckedAt;
  bool _isChecking = false;
  int _consecutiveFailures = 0;
  Timer? _timer;
  bool _disposed = false;

  ConnectionStatus get status => _status;
  BackendHealth? get lastHealth => _lastHealth;
  String? get lastError => _lastError;
  DateTime? get lastCheckedAt => _lastCheckedAt;
  bool get isChecking => _isChecking;
  bool get isOnline => _status == ConnectionStatus.online;
  int get consecutiveFailures => _consecutiveFailures;

  ServerSettings get _settings => _settingsProvider.settings;

  void initialize() {
    _settingsProvider.addListener(_onSettingsChanged);
    startMonitoring();
  }

  void startMonitoring() {
    if (_disposed) return;
    _timer?.cancel();
    _schedule(const Duration(seconds: 0));
  }

  void stopMonitoring() {
    _timer?.cancel();
  }

  Future<void> retryNow() async {
    _timer?.cancel();
    await _check();
  }

  void _onSettingsChanged() {
    startMonitoring();
  }

  Future<void> _check() async {
    if (_isChecking || _disposed) return;
    _isChecking = true;
    _notify();

    final result = await _repository.ping(_settings);
    if (_disposed) return;

    _lastCheckedAt = DateTime.now();
    _lastHealth = BackendHealth.fromApiResult(result);

    if (result.isSuccess) {
      _status = ConnectionStatus.online;
      _consecutiveFailures = 0;
      _lastError = null;
      _schedule(
        const Duration(seconds: AppDefaults.healthIntervalSeconds),
      );
    } else {
      _status = ConnectionStatus.offline;
      _consecutiveFailures += 1;
      _lastError = result.displayMessage;
      _schedule(_backoffDelay());
    }

    _isChecking = false;
    _notify();
  }

  Duration _backoffDelay() {
    final exponent = _consecutiveFailures - 1;
    final safeExponent = exponent < 0 ? 0 : (exponent > 5 ? 5 : exponent);
    final seconds = 1 << safeExponent;
    final capped = seconds > AppDefaults.maxRetrySeconds
        ? AppDefaults.maxRetrySeconds
        : seconds;
    return Duration(seconds: capped);
  }

  void _schedule(Duration delay) {
    if (_disposed) return;
    _timer?.cancel();
    _timer = Timer(delay, () {
      unawaited(_check());
    });
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _settingsProvider.removeListener(_onSettingsChanged);
    super.dispose();
  }
}
