import 'package:cloud_car/models/led_state.dart';
import 'package:cloud_car/utils/app_theme.dart';
import 'package:cloud_car/widgets/app_card.dart';
import 'package:flutter/material.dart';

class LedControlCard extends StatelessWidget {
  const LedControlCard({
    super.key,
    required this.state,
    required this.onChanged,
    this.enabled = true,
  });

  final LedState state;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = state.isOn == true
        ? AppTheme.amber
        : state.isOn == false
            ? AppTheme.textMuted
            : AppTheme.violet;

    return AppCard(
      accent: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: color, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'LED CONTROL',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withOpacity(0.5)),
                ),
                child: Text(
                  state.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: enabled ? () => onChanged(true) : null,
                  icon: const Icon(Icons.power_settings_new_rounded, size: 18),
                  label: const Text('LED ON'),
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.amber),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: enabled ? () => onChanged(false) : null,
                  icon: const Icon(Icons.power_off_rounded, size: 18),
                  label: const Text('LED OFF'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
