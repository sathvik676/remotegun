import 'package:cloud_car/models/app_settings.dart';
import 'package:cloud_car/models/movement_command.dart';
import 'package:cloud_car/models/telemetry.dart';
import 'package:cloud_car/providers/car_control_provider.dart';
import 'package:cloud_car/providers/connection_provider.dart';
import 'package:cloud_car/providers/settings_provider.dart';
import 'package:cloud_car/providers/telemetry_provider.dart';
import 'package:cloud_car/utils/app_theme.dart';
import 'package:cloud_car/utils/constants.dart';
import 'package:cloud_car/widgets/app_card.dart';
import 'package:cloud_car/widgets/connection_status_chip.dart';
import 'package:cloud_car/widgets/emergency_stop.dart';
import 'package:cloud_car/widgets/status_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final connection = context.watch<ConnectionProvider>();
    final telemetry = context.watch<TelemetryProvider>().snapshot;
    final car = context.watch<CarControlProvider>();
    final settings = context.watch<SettingsProvider>().settings;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [AppTheme.cyan, AppTheme.violet],
                ),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: AppTheme.background,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(AppStrings.appName),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              label: const Text(
                AppStrings.carId,
                style: TextStyle(
                  color: AppTheme.cyan,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
              backgroundColor: AppTheme.cyan.withOpacity(0.10),
              side: BorderSide(color: AppTheme.cyan.withOpacity(0.45)),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: connection.retryNow,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _HeroCard(connection: connection, settings: settings),
            const SizedBox(height: 16),
            Row(
              children: [
                ConnectionStatusChip(status: connection.status),
                const Spacer(),
                IconButton(
                  tooltip: 'Retry backend connection',
                  onPressed: connection.retryNow,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            if (connection.lastError != null) ...[
              const SizedBox(height: 10),
              _ErrorBanner(message: connection.lastError!),
            ],
            const SizedBox(height: 18),
            _StatusGrid(telemetry: telemetry, isOnline: connection.isOnline),
            const SizedBox(height: 16),
            EmergencyStop(
              isActive: car.emergencyStopped,
              onPressed: car.activateEmergencyStop,
              onReset: car.resetEmergencyStop,
            ),
            if (car.statusMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                car.statusMessage!,
                style: const TextStyle(
                  color: AppTheme.amber,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _QuickActions(connection: connection),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.connection, required this.settings});

  final ConnectionProvider connection;
  final ServerSettings settings;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      accent: AppTheme.violet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SYSTEM ONLINE',
            style: TextStyle(
              color: connection.isOnline ? AppTheme.green : AppTheme.red,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Robotic Car Command Center',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cloud-connected control through FastAPI. MQTT credentials remain '
            'on the backend and ESP32.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.dns_rounded,
                  color: AppTheme.cyan, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  settings.baseUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.cyan,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusGrid extends StatelessWidget {
  const _StatusGrid({required this.telemetry, required this.isOnline});

  final TelemetrySnapshot telemetry;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 600
                ? 2
                : 1;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: columns == 1 ? 2.4 : 1.65,
          children: [
            StatusCard(
              title: 'Backend',
              value: isOnline ? 'CONNECTED' : 'DISCONNECTED',
              subtitle: 'GET /health',
              icon: Icons.cloud_done_rounded,
              accent: isOnline ? AppTheme.green : AppTheme.red,
            ),
            StatusCard(
              title: 'ESP32',
              value: _onlineLabel(telemetry.esp32Online),
              subtitle: telemetry.esp32Online == null
                  ? 'Not exposed by backend'
                  : 'Reported by backend',
              icon: Icons.memory_rounded,
              accent: _onlineColor(telemetry.esp32Online),
            ),
            StatusCard(
              title: 'MQTT',
              value: _onlineLabel(telemetry.mqttConnected),
              subtitle: telemetry.mqttConnected == null
                  ? 'Not exposed by backend'
                  : 'Reported by backend',
              icon: Icons.hub_rounded,
              accent: _onlineColor(telemetry.mqttConnected),
            ),
            StatusCard(
              title: 'Battery',
              value: telemetry.batteryPercentage == null
                  ? '—'
                  : '${telemetry.batteryPercentage}%',
              subtitle: telemetry.batteryPercentage == null
                  ? 'Telemetry unavailable'
                  : 'Reported by backend',
              icon: Icons.battery_full_rounded,
              accent: AppTheme.amber,
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
          ],
        );
      },
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
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.red.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.red.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppTheme.red, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppTheme.red, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.connection});

  final ConnectionProvider connection;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: connection.retryNow,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Retry backend connection'),
      ),
    );
  }
}
