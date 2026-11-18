import 'package:cloud_car/models/api_result.dart';
import 'package:cloud_car/models/diagnostics_result.dart';
import 'package:cloud_car/models/movement_command.dart';
import 'package:cloud_car/providers/settings_provider.dart';
import 'package:cloud_car/services/backend_repository.dart';
import 'package:cloud_car/utils/constants.dart';
import 'package:flutter/foundation.dart';

class DiagnosticsProvider extends ChangeNotifier {
  DiagnosticsProvider(this._repository, this._settingsProvider);

  final BackendRepository _repository;
  final SettingsProvider _settingsProvider;

  final List<DiagnosticResult> _results = <DiagnosticResult>[];
  bool _isRunning = false;
  bool _disposed = false;

  List<DiagnosticResult> get results => List.unmodifiable(_results);
  bool get isRunning => _isRunning;
  bool get hasResults => _results.isNotEmpty;

  Future<void> runSafeSuite() async {
    if (_isRunning) return;
    _isRunning = true;
    _notify();

    final settings = _settingsProvider.settings;
    await _run(
      name: 'Root endpoint',
      endpoint: ApiPaths.root,
      call: () => _repository.root(settings),
    );
    await _run(
      name: 'Health endpoint',
      endpoint: ApiPaths.health,
      call: () => _repository.ping(settings),
    );
    await _run(
      name: 'STOP command',
      endpoint: ApiPaths.command,
      call: () => _repository.sendCommand(settings, MovementCommand.stop),
    );

    _isRunning = false;
    _notify();
  }

  Future<void> testLed({required bool on}) async {
    final settings = _settingsProvider.settings;
    final state = on ? 'ON' : 'OFF';
    await _run(
      name: 'LED $state',
      endpoint: ApiPaths.led(state),
      call: () => _repository.setLed(settings, on: on),
    );
  }

  void clear() {
    _results.clear();
    _notify();
  }

  Future<void> _run({
    required String name,
    required String endpoint,
    required Future<ApiResult> Function() call,
  }) async {
    final started = DateTime.now();
    late final bool success;
    late final String message;
    int? statusCode;

    try {
      final result = await call();
      success = result.isSuccess;
      statusCode = result.statusCode;
      message = result.displayMessage;
    } catch (error) {
      success = false;
      message = error.toString();
    }

    final entry = DiagnosticResult(
      name: name,
      endpoint: endpoint,
      success: success,
      statusCode: statusCode,
      message: message,
      duration: DateTime.now().difference(started),
      timestamp: started,
    );

    _results.insert(0, entry);
    if (_results.length > 50) _results.removeLast();
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
