import 'package:cloud_car/models/diagnostics_result.dart';
import 'package:cloud_car/providers/connection_provider.dart';
import 'package:cloud_car/providers/diagnostics_provider.dart';
import 'package:cloud_car/providers/settings_provider.dart';
import 'package:cloud_car/utils/app_theme.dart';
import 'package:cloud_car/widgets/app_card.dart';
import 'package:cloud_car/widgets/connection_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final diagnostics = context.watch<DiagnosticsProvider>();
    final connection = context.watch<ConnectionProvider>();
    final baseUrl = context.watch<SettingsProvider>().settings.baseUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Diagnostics'),
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
          AppCard(
            accent: AppTheme.cyan,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT TARGET',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  baseUrl,
                  style: const TextStyle(
                    color: AppTheme.cyan,
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  connection.lastError ?? 'No connection errors reported.',
                  style: TextStyle(
                    color:
                        connection.lastError == null ? AppTheme.textMuted : AppTheme.red,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: diagnostics.isRunning
                      ? null
                      : diagnostics.runSafeSuite,
                  icon: diagnostics.isRunning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  label: const Text('Run safe checks'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                tooltip: 'Clear results',
                onPressed: diagnostics.clear,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Safe checks call GET /, GET /health, then POST /command with STOP. '
            'LED tests are manual so they do not change hardware unexpectedly.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => diagnostics.testLed(on: true),
                  icon: const Icon(Icons.lightbulb_outline_rounded),
                  label: const Text('LED ON'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => diagnostics.testLed(on: false),
                  icon: const Icon(Icons.power_off_rounded),
                  label: const Text('LED OFF'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: connection.retryNow,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry backend health check'),
            ),
          ),
          const SizedBox(height: 18),
          if (diagnostics.hasResults) ...[
            const Text(
              'RESULTS',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            ...diagnostics.results.map(
              (result) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ResultTile(result: result),
              ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No diagnostics run yet.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result});

  final DiagnosticResult result;

  @override
  Widget build(BuildContext context) {
    final color = result.success ? AppTheme.green : AppTheme.red;
    return AppCard(
      accent: color,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            result.success ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        result.name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      result.timeLabel,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${result.endpoint}  •  HTTP ${result.statusCode ?? '—'}  •  '
                  '${result.durationLabel}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  result.message,
                  style: TextStyle(color: color, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
