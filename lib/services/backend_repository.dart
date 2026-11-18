import 'dart:convert';

import 'package:cloud_car/models/api_result.dart';
import 'package:cloud_car/models/app_settings.dart';
import 'package:cloud_car/models/movement_command.dart';
import 'package:cloud_car/services/api_client.dart';
import 'package:cloud_car/utils/constants.dart';

class BackendRepository {
  const BackendRepository(this._api);

  final ApiClient _api;

  Future<ApiResult> ping(ServerSettings settings) {
    return _api.get(settings, ApiPaths.health);
  }

  Future<ApiResult> root(ServerSettings settings) {
    return _api.get(settings, ApiPaths.root);
  }

  Future<ApiResult> sendCommand(
    ServerSettings settings,
    MovementCommand command,
  ) {
    return _api.post(
      settings,
      ApiPaths.command,
      body: jsonEncode(command.toJson()),
    );
  }

  Future<ApiResult> setLed(ServerSettings settings, {required bool on}) {
    return _api.post(settings, ApiPaths.led(on ? 'ON' : 'OFF'));
  }
}
