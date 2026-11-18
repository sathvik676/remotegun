import 'dart:math';

import 'package:cloud_car/providers/car_control_provider.dart';
import 'package:cloud_car/providers/connection_provider.dart';
import 'package:cloud_car/providers/settings_provider.dart';
import 'package:cloud_car/utils/app_theme.dart';
import 'package:cloud_car/widgets/connection_status_chip.dart';
import 'package:cloud_car/widgets/direction_display.dart';
import 'package:cloud_car/widgets/emergency_stop.dart';
import 'package:cloud_car/widgets/joystick.dart';
import 'package:cloud_car/widgets/led_control_card.dart';
import 'package:cloud_car/widgets/speed_control.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CarControlScreen extends StatelessWidget {
  const CarControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final car = context.watch<CarControlProvider>();
    final connection = context.watch<ConnectionProvider>();
    final baseUrl = context.watch<SettingsProvider>().settings.baseUrl;
    final width = MediaQuery.sizeOf(context).width;
    final joystickSize = min(320.0, width - 64);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Control'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ConnectionStatusChip(
              status: connection.status,
              compact: true,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          if (!car.movementEnabled)
            _DisabledBanner(
              emergencyStopped: car.emergencyStopped,
              offline: !connection.isOnline,
            ),
          if (car.lastError != null) ...[
            const SizedBox(height: 10),
            _MessageBanner(message: car.lastError!, isError: true),
          ] else if (car.statusMessage != null) ...[
            const SizedBox(height: 10),
            _MessageBanner(message: car.statusMessage!, isError: false),
          ],
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;
              final joystickPanel = Column(
                children: [
                  Joystick(
                    size: joystickSize,
                    enabled: car.movementEnabled,
                    onChanged: car.updateJoystick,
                    onRelease: car.releaseJoystick,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    car.movementEnabled
                        ? 'Drag to drive • Release to STOP'
                        : 'Movement locked for safety',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              );

              final controlPanel = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SpeedControl(
                    speed: car.speed,
                    effectiveSpeed: car.effectiveSpeed,
                    onChanged: car.setSpeed,
                    onReset: () => car.setSpeed(150),
                  ),
                  const SizedBox(height: 12),
                  DirectionDisplay(
                    direction: car.direction,
                    speed: car.effectiveSpeed,
                  ),
                  const SizedBox(height: 12),
                  LedControlCard(
                    state: car.ledState,
                    enabled: connection.isOnline,
                    onChanged: (on) => car.setLed(on: on),
                  ),
                  const SizedBox(height: 12),
                  EmergencyStop(
                    isActive: car.emergencyStopped,
                    onPressed: car.activateEmergencyStop,
                    onReset: car.resetEmergencyStop,
                  ),
                ],
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: joystickPanel),
                    const SizedBox(width: 20),
                    Expanded(child: controlPanel),
                  ],
                );
              }
              return Column(
                children: [
                  joystickPanel,
                  const SizedBox(height: 20),
                  controlPanel,
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Text(
            'Backend: $baseUrl',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _DisabledBanner extends StatelessWidget {
  const _DisabledBanner({
    required this.emergencyStopped,
    required this.offline,
  });

  final bool emergencyStopped;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final color = emergencyStopped ? AppTheme.red : AppTheme.amber;
    final text = emergencyStopped
        ? 'EMERGENCY STOP LATCHED — reset it before sending movement commands.'
        : offline
            ? 'Backend disconnected — movement commands are blocked.'
            : 'Movement is currently disabled.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppTheme.red : AppTheme.cyan;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        message,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}
