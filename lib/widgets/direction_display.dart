import 'package:cloud_car/models/movement_command.dart';
import 'package:cloud_car/utils/app_theme.dart';
import 'package:cloud_car/widgets/app_card.dart';
import 'package:flutter/material.dart';

class DirectionDisplay extends StatelessWidget {
  const DirectionDisplay({
    super.key,
    required this.direction,
    required this.speed,
    this.isLocalCommand = true,
  });

  final MovementDirection direction;
  final int speed;
  final bool isLocalCommand;

  @override
  Widget build(BuildContext context) {
    final color = direction == MovementDirection.stop
        ? AppTheme.textMuted
        : AppTheme.cyan;

    return AppCard(
      accent: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DRIVE VECTOR',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Container(
                  key: ValueKey<MovementDirection>(direction),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.5)),
                  ),
                  child: Icon(_iconFor(direction), color: color, size: 30),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      direction.label,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$speed / 255 PWM',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isLocalCommand) ...[
            const SizedBox(height: 12),
            const Text(
              'Speed and direction are local command state. Confirmed motor '
              'telemetry is not exposed by the current backend.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconFor(MovementDirection direction) {
    switch (direction) {
      case MovementDirection.forward:
        return Icons.arrow_upward_rounded;
      case MovementDirection.backward:
        return Icons.arrow_downward_rounded;
      case MovementDirection.left:
        return Icons.arrow_back_rounded;
      case MovementDirection.right:
        return Icons.arrow_forward_rounded;
      case MovementDirection.stop:
        return Icons.stop_rounded;
    }
  }
}
