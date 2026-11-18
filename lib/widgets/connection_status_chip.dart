import 'package:cloud_car/models/connection_state.dart';
import 'package:cloud_car/utils/app_theme.dart';
import 'package:flutter/material.dart';

class ConnectionStatusChip extends StatelessWidget {
  const ConnectionStatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  final ConnectionStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 6 : 9,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.8), blurRadius: 10),
              ],
            ),
          ),
          SizedBox(width: compact ? 6 : 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              compact ? status.shortLabel : status.label,
              key: ValueKey<ConnectionStatus>(status),
              style: TextStyle(
                color: color,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.online:
        return AppTheme.green;
      case ConnectionStatus.connecting:
        return AppTheme.amber;
      case ConnectionStatus.offline:
        return AppTheme.red;
    }
  }
}
