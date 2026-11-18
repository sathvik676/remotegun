import 'package:cloud_car/models/app_settings.dart';
import 'package:cloud_car/services/settings_repository.dart';
import 'package:flutter/foundation.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._repository);

  final SettingsRepository _repository;

  ServerSettings _settings = ServerSettings.defaults;
  bool _isLoading = true;
  String? _lastError;
  bool _disposed = false;

  ServerSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  Future<void> initialize() async {
    try {
      _settings = await _repository.load();
      _lastError = null;
    } catch (error) {
      _settings = ServerSettings.defaults;
      _lastError = 'Could not load saved settings: $error';
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<bool> save(ServerSettings next) async {
    try {
      await _repository.save(next);
      _settings = next;
      _lastError = null;
      _notify();
      return true;
    } catch (error) {
      _lastError = 'Could not save settings: $error';
      _notify();
      return false;
    }
  }

  Future<bool> resetToDefaults() => save(ServerSettings.defaults);

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
