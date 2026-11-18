import 'package:cloud_car/models/movement_command.dart';
import 'package:cloud_car/providers/connection_provider.dart';
import 'package:cloud_car/providers/settings_provider.dart';
import 'package:cloud_car/providers/telemetry_provider.dart';
import 'package:cloud_car/utils/app_theme.dart';
import 'package:cloud_car/widgets/app_card.dart';
import 'package:cloud_car/widgets/connection_status_chip.dart';
import 'package:cloud_car/widgets/status_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TelemetryScreen extends StatelessWidget {
  const TelemetryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final connection = context.watch<ConnectionProvider>();
    final telemetry = context.watch<TelemetryProvider>().snapshot;
    final baseUrl = context.watch<SettingsProvider>().settings.baseUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Telemetry'),
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
          _TelemetryNotice(available: telemetry.backendTelemetryAvailable),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 800
                  ? 2
                  : constraints.maxWidth >= 560
                      ? 2
                      : 1;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: columns == 1 ? 2.3 : 1.7,
                children: [
                  StatusCard(
                    title: 'Battery',
                    value: telemetry.batteryPercentage == null
                        ? 'UNAVAILABLE'
                        : '${telemetry.batteryPercentage}%',
                    subtitle: telemetry.batteryPercentage == null
                        ? 'Backend does not expose battery yet'
                        : 'Reported by backend',
                    icon: Icons.battery_full_rounded,
                    accent: AppTheme.amber,
                  ),
                  StatusCard(
                    title: 'ESP32',
                    value: _onlineLabel(telemetry.esp32Online),
                    subtitle: 'Backend-reported device state',
                    icon: Icons.memory_rounded,
                    accent: _onlineColor(telemetry.esp32Online),
                  ),
                  StatusCard(
                    title: 'MQTT broker',
                    value: _onlineLabel(telemetry.mqttConnected),
                    subtitle: 'Only if backend exposes broker state',
                    icon: Icons.hub_rounded,
                    accent: _onlineColor(telemetry.mqttConnected),
                  ),
                  StatusCard(
                    title: 'Motor speed',
                    value: '${telemetry.motorSpeed}',
                    subtitle: telemetry.speedSource,
                    icon: Icons.speed_rounded,
                    accent: AppTheme.cyan,
                  ),
                  StatusCard(
                    title: 'Direction',
                    value: telemetry.direction.label,
                    subtitle: telemetry.directionSource,
                    icon: Icons.navigation_rounded,
                    accent: AppTheme.violet,
                  ),
                  StatusCard(
                    title: 'Last update',
                    value: _timeLabel(telemetry.lastUpdated),
                    subtitle: 'Backend health poll',
                    icon: Icons.schedule_rounded,
                    accent: AppTheme.green,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          AppCard(
            accent: AppTheme.violet,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DATA SOURCES',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                _SourceRow(
                  icon: Icons.cloud_done_rounded,
                  label: 'Backend transport',
                  value: connection.isOnline ? 'Reachable' : 'Unreachable',
                ),
                _SourceRow(
                  icon: Icons.memory_rounded,
                  label: 'ESP32 / MQTT / battery',
                  value: telemetry.backendTelemetryAvailable
                      ? 'Parsed from /health'
                      : 'Not provided by current backend',
                ),
                _SourceRow(
                  icon: Icons.gamepad_rounded,
                  label: 'Motor speed / direction',
                  value: 'Last command sent by this app',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Endpoint: $baseUrl/health',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }

  String _onlineLabel(bool? value) {
    if (value == null) return 'UNKNOWN';
    return value ? 'ONLINE' : 'OFFLINE';
  }

  Color _onlineColor(bool? value) {
    if (value == null) return AppTheme.textMuted;
    return value ? AppTheme.green : AppTheme.red;
  }

  String _timeLabel(DateTime? value) {
    if (value == null) return '—';
    return '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}:'
        '${value.second.toString().padLeft(2, '0')}';
  }
}

class _TelemetryNotice extends StatelessWidget {
  const _TelemetryNotice({required this.available});

  final bool available;

  @override
  Widget build(BuildContext context) {
    final color = available ? AppTheme.green : AppTheme.amber;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            available ? Icons.verified_rounded : Icons.info_outline_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              available
                  ? 'Optional telemetry fields were found in the backend '
                      'response and are being displayed.'
                  : 'Your current backend does not expose battery, ESP32, '
                      'MQTT, or confirmed motor telemetry. These fields stay '
                      'hidden/unknown until you choose to add a telemetry API. '
                      'No endpoint has been invented by this app.',
              style: TextStyle(color: color, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.cyan, size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 12,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
