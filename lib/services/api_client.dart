import 'dart:async';
import 'dart:io';

import 'package:cloud_car/models/api_result.dart';
import 'package:cloud_car/models/app_settings.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<ApiResult> get(
    ServerSettings settings,
    String path, {
    Duration? timeout,
  }) {
    return _request(
      method: 'GET',
      settings: settings,
      path: path,
      timeout: timeout,
    );
  }

  Future<ApiResult> post(
    ServerSettings settings,
    String path, {
    Object? body,
    Duration? timeout,
  }) {
    return _request(
      method: 'POST',
      settings: settings,
      path: path,
      body: body,
      timeout: timeout,
    );
  }

  Future<ApiResult> _request({
    required String method,
    required ServerSettings settings,
    required String path,
    Object? body,
    Duration? timeout,
  }) async {
    final uri = settings.buildUri(path);
    final effectiveTimeout = timeout ?? Duration(seconds: settings.timeoutSeconds);
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
    };

    try {
      final future = method == 'GET'
          ? _client.get(uri, headers: headers)
          : _client.post(uri, headers: headers, body: body);
      final response = await future.timeout(effectiveTimeout);
      final json = ApiResult.parseJson(response.body);
      final success = response.statusCode >= 200 && response.statusCode < 300;

      return ApiResult(
        transportSuccess: success,
        statusCode: response.statusCode,
        data: response.body,
        json: json,
        errorMessage: success ? null : _errorFromResponse(response.statusCode, json),
      );
    } catch (error) {
      return ApiResult(
        transportSuccess: false,
        errorMessage: _friendlyError(error, settings),
      );
    }
  }

  String _errorFromResponse(int statusCode, Map<String, dynamic>? json) {
    final detail = json?['detail'] ?? json?['message'] ?? json?['error'];
    if (detail != null && detail.toString().trim().isNotEmpty) {
      return detail.toString();
    }
    return 'Backend returned HTTP $statusCode.';
  }

  String _friendlyError(Object error, ServerSettings settings) {
    final timeoutMessage = 'Request timed out after ${settings.timeoutSeconds}s. '
        'Check that the backend is running and reachable.';
    final unreachableMessage =
        'Cannot reach ${settings.host}:${settings.port}. '
        'Check the IP address, Wi-Fi network, and Windows firewall.';

    if (error is http.ClientException) {
      final message = error.message.toLowerCase();
      if (message.contains('timed out')) return timeoutMessage;
      if (message.contains('failed host lookup') ||
          message.contains('connection refused') ||
          message.contains('network is unreachable') ||
          message.contains('socket')) {
        return unreachableMessage;
      }
      return 'Network request failed: ${error.message}';
    }

    if (error is TimeoutException) return timeoutMessage;
    if (error is SocketException) return unreachableMessage;
    if (error is HandshakeException) {
      return 'HTTPS certificate verification failed. Use a trusted certificate '
          'or switch to HTTP on a trusted local network.';
    }
    if (error is HttpException) return 'HTTP error: ${error.message}';
    if (error is FormatException) {
      return 'Backend returned a malformed response.';
    }
    return error.toString();
  }

  void close() => _client.close();
}
