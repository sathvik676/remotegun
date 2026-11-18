import 'package:cloud_car/utils/app_theme.dart';
import 'package:cloud_car/utils/constants.dart';
import 'package:cloud_car/widgets/app_card.dart';
import 'package:flutter/material.dart';

class SpeedControl extends StatelessWidget {
  const SpeedControl({
    super.key,
    required this.speed,
    required this.effectiveSpeed,
    required this.onChanged,
    required this.onReset,
    this.enabled = true,
  });

  final int speed;
  final int effectiveSpeed;
  final ValueChanged<int> onChanged;
  final VoidCallback onReset;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      accent: AppTheme.violet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed_rounded,
                  color: AppTheme.violet, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'MOTOR SPEED',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              TextButton(
                onPressed: onReset,
                child: const Text('Reset 150'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  '$speed',
                  key: ValueKey<int>(speed),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'PWM',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const Spacer(),
              Text(
                'Applied: $effectiveSpeed',
                style: const TextStyle(
                  color: AppTheme.cyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Slider(
            value: speed.clamp(AppDefaults.minSpeed, AppDefaults.maxSpeed)
                .toDouble(),
            min: AppDefaults.minSpeed.toDouble(),
            max: AppDefaults.maxSpeed.toDouble(),
            divisions: AppDefaults.maxSpeed - AppDefaults.minSpeed,
            label: '$speed',
            onChanged: enabled
                ? (value) => onChanged(value.round())
                : null,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0', style: TextStyle(color: AppTheme.textMuted)),
                Text('255', style: TextStyle(color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
