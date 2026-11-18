final RegExp _hostPattern = RegExp(
  r'^(?=.{1,253}$)(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.?)+$',
);

String? validateHost(String? value) {
  final host = value?.trim() ?? '';
  if (host.isEmpty) return 'Enter the server IP address or hostname.';
  if (host.contains('://')) {
    return 'Enter only the host (for example 192.168.1.5), not a full URL.';
  }
  if (host.contains('/')) return 'Do not include a path in the host field.';
  if (host.contains(' ')) return 'Host cannot contain spaces.';
  if (!_hostPattern.hasMatch(host)) return 'Enter a valid IP address or hostname.';
  return null;
}

String? validatePort(String? value) {
  final port = int.tryParse((value ?? '').trim());
  if (port == null) return 'Enter a numeric port.';
  if (port < 1 || port > 65535) return 'Port must be between 1 and 65535.';
  return null;
}

String? validateBasePath(String? value) {
  final path = (value ?? '').trim();
  if (path.isEmpty) return null;
  if (!path.startsWith('/')) return 'Base path must start with /.';
  if (path == '/') return null;
  if (path.contains('?') || path.contains('#')) {
    return 'Base path cannot contain query strings or fragments.';
  }
  return null;
}
