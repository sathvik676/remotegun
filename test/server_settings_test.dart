import 'package:cloud_car/models/app_settings.dart';
import 'package:cloud_car/utils/constants.dart';
import 'package:cloud_car/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildUri includes host, port, and optional base path', () {
    const settings = ServerSettings(
      host: '192.168.1.5',
      port: 8000,
      scheme: 'http',
      basePath: '/api/v1',
      timeoutSeconds: 4,
    );

    expect(settings.baseUrl, 'http://192.168.1.5:8000');
    expect(
      settings.buildUri(ApiPaths.health).toString(),
      'http://192.168.1.5:8000/api/v1/health',
    );
  });

  test('settings round-trip through JSON', () {
    const settings = ServerSettings(
      host: 'car.local',
      port: 9000,
      scheme: 'https',
      basePath: '',
      timeoutSeconds: 7,
    );

    final restored = ServerSettings.fromJson(settings.toJson());
    expect(restored.host, settings.host);
    expect(restored.port, settings.port);
    expect(restored.scheme, settings.scheme);
    expect(restored.timeoutSeconds, settings.timeoutSeconds);
  });

  test('validators reject localhost confusion and invalid ports', () {
    expect(validateHost('192.168.1.5'), isNull);
    expect(validateHost('http://192.168.1.5'), isNotNull);
    expect(validatePort('8000'), isNull);
    expect(validatePort('70000'), isNotNull);
  });
}
