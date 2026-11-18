class MovementCommands {
  static const String forward = 'FORWARD';
  static const String backward = 'BACKWARD';
  static const String left = 'LEFT';
  static const String right = 'RIGHT';
  static const String stop = 'STOP';
}

enum MovementDirection { forward, backward, left, right, stop }

extension MovementDirectionX on MovementDirection {
  String get apiValue {
    switch (this) {
      case MovementDirection.forward:
        return MovementCommands.forward;
      case MovementDirection.backward:
        return MovementCommands.backward;
      case MovementDirection.left:
        return MovementCommands.left;
      case MovementDirection.right:
        return MovementCommands.right;
      case MovementDirection.stop:
        return MovementCommands.stop;
    }
  }

  String get label {
    switch (this) {
      case MovementDirection.forward:
        return 'Forward';
      case MovementDirection.backward:
        return 'Backward';
      case MovementDirection.left:
        return 'Left';
      case MovementDirection.right:
        return 'Right';
      case MovementDirection.stop:
        return 'Stopped';
    }
  }

  bool get isMoving => this != MovementDirection.stop;
}

class MovementCommand {
  const MovementCommand({
    required this.direction,
    required this.speed,
  });

  final MovementDirection direction;
  final int speed;

  static const stop = MovementCommand(
    direction: MovementDirection.stop,
    speed: 0,
  );

  Map<String, dynamic> toJson() {
    return {
      'command': direction.apiValue,
      'speed': speed,
    };
  }

  @override
  String toString() => '${direction.apiValue} @ $speed';
}

class JoystickVector {
  const JoystickVector({
    required this.x,
    required this.y,
    required this.magnitude,
  });

  final double x;
  final double y;
  final double magnitude;

  static const neutral = JoystickVector(x: 0, y: 0, magnitude: 0);

  bool get isActive => magnitude > 0;
}
