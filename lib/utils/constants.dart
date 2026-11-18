class AppStrings {
  static const String appName = 'CLOUD CAR';
  static const String carId = 'CAR001';
  static const String tagline = 'Robotic Control Interface';
}

class AppDefaults {
  // Android emulator maps the development machine to 10.0.2.2.
  // A physical phone must use the laptop's LAN IP, for example 192.168.1.5.
  static const String host = '10.0.2.2';
  static const int port = 8000;
  static const String scheme = 'http';
  static const String basePath = '';

  static const int speed = 150;
  static const int minSpeed = 0;
  static const int maxSpeed = 255;

  static const int connectTimeoutSeconds = 4;
  static const int healthIntervalSeconds = 5;
  static const int maxRetrySeconds = 30;
}

class ApiPaths {
  static const String root = '/';
  static const String health = '/health';
  static const String command = '/command';

  static String led(String state) => '/led/${state.toUpperCase()}';
}

class StorageKeys {
  static const String serverSettings = 'cloudcar.server_settings.v1';
}
