import 'package:cloud_car/utils/app_theme.dart';
import 'package:cloud_car/widgets/app_card.dart';
import 'package:flutter/material.dart';

class EmergencyStop extends StatelessWidget {
  const EmergencyStop({
    super.key,
    required this.isActive,
    required this.onPressed,
    required this.onReset,
  });

  final bool isActive;
  final VoidCallback onPressed;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      accent: AppTheme.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppTheme.red, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'EMERGENCY STOP',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              if (isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.red.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppTheme.red),
                  ),
                  child: const Text(
                    'LATCHED',
                    style: TextStyle(
                      color: AppTheme.red,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isActive ? null : onPressed,
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: isActive
                        ? [
                            AppTheme.red.withOpacity(0.10),
                            AppTheme.red.withOpacity(0.20),
                          ]
                        : [
                            AppTheme.red.withOpacity(0.85),
                            const Color(0xFFB71C2E),
                          ],
                  ),
                  border: Border.all(
                    color: AppTheme.red,
                    width: isActive ? 1 : 2,
                  ),
                  boxShadow: isActive
                      ? []
                      : [
                          BoxShadow(
                            color: AppTheme.red.withOpacity(0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
                child: Opacity(
                  opacity: isActive ? 0.55 : 1,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stop_circle_rounded,
                          color: Colors.white, size: 34),
                      SizedBox(height: 6),
                      Text(
                        'EMERGENCY STOP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isActive) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('RESET EMERGENCY STOP'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.green,
                side: const BorderSide(color: AppTheme.green),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
