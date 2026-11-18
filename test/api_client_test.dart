import 'dart:async';
import 'dart:convert';

import 'package:cloud_car/models/app_settings.dart';
import 'package:cloud_car/models/movement_command.dart';
import 'package:cloud_car/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const settings = ServerSettings(
    host: '10.0.2.2',
    port: 8000,
    scheme: 'http',
    basePath: '',
    timeoutSeconds: 2,
  );

  test('POST /command sends the documented payload', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/command');
      expect(request.url.host, '10.0.2.2');
      expect(request.url.port, 8000);
      expect(
        jsonDecode(request.body),
        <String, dynamic>{'command': 'FORWARD', 'speed': 150},
      );
      return http.Response('{"ok":true,"message":"sent"}', 200);
    });

    final api = ApiClient(client: client);
    final result = await api.post(
      settings,
      '/command',
      body: jsonEncode(
        const MovementCommand(
          direction: MovementDirection.forward,
          speed: 150,
        ).toJson(),
      ),
    );

    expect(result.isSuccess, isTrue);
    expect(result.statusCode, 200);
    expect(result.stringField('message'), 'sent');
  });

  test('GET /health parses a minimal FastAPI response', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/health');
      return http.Response('{"status":"ok"}', 200);
    });

    final result = await ApiClient(client: client).get(settings, '/health');
    expect(result.isSuccess, isTrue);
    expect(result.stringField('status'), 'ok');
  });

  test('non-2xx responses expose the FastAPI detail message', () async {
    final client = MockClient(
      (_) async => http.Response('{"detail":"Invalid command"}', 422),
    );

    final result = await ApiClient(client: client).get(settings, '/health');
    expect(result.isSuccess, isFalse);
    expect(result.statusCode, 422);
    expect(result.displayMessage, 'Invalid command');
  });

  test('timeouts produce a clear user-facing message', () async {
    final client = MockClient(
      (_) async => throw TimeoutException('test timeout'),
    );

    final result = await ApiClient(client: client).get(settings, '/health');
    expect(result.isSuccess, isFalse);
    expect(result.errorMessage, contains('timed out'));
  });

  test('POST /led/ON uses the documented LED endpoint', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/led/ON');
      return http.Response('{"ok":true}', 200);
    });

    final result = await ApiClient(client: client).post(settings, '/led/ON');
    expect(result.isSuccess, isTrue);
  });
}
