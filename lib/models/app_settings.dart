import 'package:cloud_car/utils/constants.dart';

class ServerSettings {
  const ServerSettings({
    required this.host,
    required this.port,
    required this.scheme,
    required this.basePath,
    required this.timeoutSeconds,
  });

  final String host;
  final int port;
  final String scheme;
  final String basePath;
  final int timeoutSeconds;

  static const defaults = ServerSettings(
    host: AppDefaults.host,
    port: AppDefaults.port,
    scheme: AppDefaults.scheme,
    basePath: AppDefaults.basePath,
    timeoutSeconds: AppDefaults.connectTimeoutSeconds,
  );

  String get baseUrl {
    return Uri(scheme: scheme, host: host, port: port).toString();
  }

  Uri buildUri(String path) {
    final cleanBase = _cleanPath(basePath);
    final cleanPath = path == '/' ? '' : path.replaceAll(RegExp(r'^/+'), '');
    final fullPath = cleanBase.isEmpty
        ? '/$cleanPath'
        : '/$cleanBase/${cleanPath.isEmpty ? '' : cleanPath}';
    return Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: fullPath,
    );
  }

  ServerSettings copyWith({
    String? host,
    int? port,
    String? scheme,
    String? basePath,
    int? timeoutSeconds,
  }) {
    return ServerSettings(
      host: host ?? this.host,
      port: port ?? this.port,
      scheme: scheme ?? this.scheme,
      basePath: basePath ?? this.basePath,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'port': port,
      'scheme': scheme,
      'basePath': basePath,
      'timeoutSeconds': timeoutSeconds,
    };
  }

  factory ServerSettings.fromJson(Map<String, dynamic> json) {
    return ServerSettings(
      host: json['host'] is String && (json['host'] as String).trim().isNotEmpty
          ? json['host'] as String
          : defaults.host,
      port: json['port'] is int ? json['port'] as int : defaults.port,
      scheme: json['scheme'] is String && (json['scheme'] as String).isNotEmpty
          ? json['scheme'] as String
          : defaults.scheme,
      basePath: json['basePath'] is String
          ? json['basePath'] as String
          : defaults.basePath,
      timeoutSeconds: json['timeoutSeconds'] is int
          ? json['timeoutSeconds'] as int
          : defaults.timeoutSeconds,
    );
  }

  static String _cleanPath(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'^/+'), '')
        .replaceAll(RegExp(r'/+$'), '');
  }

  @override
  String toString() => baseUrl;
}
