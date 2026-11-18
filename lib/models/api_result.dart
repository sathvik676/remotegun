import 'dart:convert';

class ApiResult {
  const ApiResult({
    required this.transportSuccess,
    this.statusCode,
    this.data,
    this.json,
    this.errorMessage,
  });

  final bool transportSuccess;
  final int? statusCode;
  final Object? data;
  final Map<String, dynamic>? json;
  final String? errorMessage;

  bool get isSuccess {
    if (!transportSuccess) return false;
    if (json?['success'] == false) return false;
    if (json?['ok'] == false) return false;
    return true;
  }

  String get displayMessage {
    final explicit = errorMessage?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    final message = json?['message'] ?? json?['detail'] ?? json?['error'];
    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString();
    }
    if (statusCode != null) return 'HTTP $statusCode';
    return 'Request completed';
  }

  String? stringField(String key) {
    final value = json?[key];
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  bool? boolField(String key) {
    final value = json?[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final text = value.toLowerCase().trim();
      if (const {'true', '1', 'yes', 'on', 'ok', 'online', 'connected'}
          .contains(text)) {
        return true;
      }
      if (const {'false', '0', 'no', 'off', 'error', 'offline', 'disconnected'}
          .contains(text)) {
        return false;
      }
    }
    return null;
  }

  int? intField(String key) {
    final value = json?[key];
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static Map<String, dynamic>? parseJson(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry<String, dynamic>(key.toString(), value),
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
