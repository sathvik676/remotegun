import 'package:cloud_car/models/movement_command.dart';
import 'package:cloud_car/utils/command_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dead-zone input maps to STOP', () {
    final command = CommandMapper.map(
      const JoystickVector(x: 0.03, y: -0.04, magnitude: 0.05),
      maxSpeed: 150,
    );

    expect(command.direction, MovementDirection.stop);
    expect(command.speed, 0);
  });

  test('forward input maps to FORWARD with scaled speed', () {
    final command = CommandMapper.map(
      const JoystickVector(x: 0, y: -0.5, magnitude: 0.5),
      maxSpeed: 200,
    );

    expect(command.direction, MovementDirection.forward);
    expect(command.speed, 100);
    expect(command.toJson(), {'command': 'FORWARD', 'speed': 100});
  });

  test('diagonal input resolves to the dominant supported axis', () {
    final right = CommandMapper.map(
      const JoystickVector(x: 0.8, y: -0.4, magnitude: 0.9),
      maxSpeed: 150,
    );
    final forward = CommandMapper.map(
      const JoystickVector(x: 0.3, y: -0.9, magnitude: 0.9),
      maxSpeed: 150,
    );

    expect(right.direction, MovementDirection.right);
    expect(forward.direction, MovementDirection.forward);
  });

  test('backward input maps to BACKWARD', () {
    final command = CommandMapper.map(
      const JoystickVector(x: 0, y: 1, magnitude: 1),
      maxSpeed: 255,
    );

    expect(command.direction, MovementDirection.backward);
    expect(command.speed, 255);
  });
}
