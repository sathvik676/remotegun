enum ConnectionStatus { connecting, online, offline }

extension ConnectionStatusX on ConnectionStatus {
  String get label {
    switch (this) {
      case ConnectionStatus.connecting:
        return 'CONNECTING';
      case ConnectionStatus.online:
        return 'BACKEND ONLINE';
      case ConnectionStatus.offline:
        return 'BACKEND OFFLINE';
    }
  }

  String get shortLabel {
    switch (this) {
      case ConnectionStatus.connecting:
        return 'Connecting';
      case ConnectionStatus.online:
        return 'Online';
      case ConnectionStatus.offline:
        return 'Offline';
    }
  }
}
