class DiagnosticResult {
  const DiagnosticResult({
    required this.name,
    required this.endpoint,
    required this.success,
    required this.message,
    required this.duration,
    required this.timestamp,
    this.statusCode,
  });

  final String name;
  final String endpoint;
  final bool success;
  final String message;
  final Duration duration;
  final DateTime timestamp;
  final int? statusCode;

  String get durationLabel => '${duration.inMilliseconds} ms';

  String get timeLabel =>
      '${timestamp.hour.toString().padLeft(2, '0')}:'
      '${timestamp.minute.toString().padLeft(2, '0')}:'
      '${timestamp.second.toString().padLeft(2, '0')}';
}
