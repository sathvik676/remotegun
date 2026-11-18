import 'package:cloud_car/models/movement_command.dart';

class CommandMapper {
  static const double defaultDeadZone = 0.12;

  /// Maps a joystick vector to one of the five commands supported by the
  /// existing backend. True diagonal motion is not available through the
  /// current REST contract, so diagonal input is resolved to its dominant axis.
  static MovementCommand map(
    JoystickVector vector, {
    required int maxSpeed,
    double deadZone = defaultDeadZone,
  }) {
    if (vector.magnitude <= deadZone) return MovementCommand.stop;

    final normalizedMagnitude = vector.magnitude.clamp(0.0, 1.0);
    final scaledSpeed = (maxSpeed * normalizedMagnitude).round();
    final speed = scaledSpeed.clamp(1, 255).toInt();

    final horizontal = vector.x.abs();
    final vertical = vector.y.abs();

    if (horizontal >= vertical) {
      return MovementCommand(
        direction: vector.x >= 0
            ? MovementDirection.right
            : MovementDirection.left,
        speed: speed,
      );
    }

    return MovementCommand(
      direction: vector.y <= 0
          ? MovementDirection.forward
          : MovementDirection.backward,
      speed: speed,
    );
  }
}
