import 'dart:convert';

import 'package:cloud_car/models/app_settings.dart';
import 'package:cloud_car/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsRepository {
  Future<ServerSettings> load();
  Future<void> save(ServerSettings settings);
}

class SharedPreferencesSettingsRepository implements SettingsRepository {
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<ServerSettings> load() async {
    final prefs = await _store();
    final raw = prefs.getString(StorageKeys.serverSettings);
    if (raw == null || raw.isEmpty) return ServerSettings.defaults;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return ServerSettings.fromJson(
          decoded.map(
            (key, value) => MapEntry<String, dynamic>(key.toString(), value),
          ),
        );
      }
    } catch (_) {
      // Corrupt stored settings should never prevent the app from starting.
    }
    return ServerSettings.defaults;
  }

  @override
  Future<void> save(ServerSettings settings) async {
    final prefs = await _store();
    await prefs.setString(StorageKeys.serverSettings, jsonEncode(settings.toJson()));
  }

  Future<SharedPreferences> _store() async {
    if (_prefs != null) return _prefs!;
    await initialize();
    return _prefs!;
  }
}
