enum LedState { unknown, on, off }

extension LedStateX on LedState {
  String get label {
    switch (this) {
      case LedState.unknown:
        return 'Unknown';
      case LedState.on:
        return 'ON';
      case LedState.off:
        return 'OFF';
    }
  }

  bool? get isOn {
    switch (this) {
      case LedState.unknown:
        return null;
      case LedState.on:
        return true;
      case LedState.off:
        return false;
    }
  }
}
