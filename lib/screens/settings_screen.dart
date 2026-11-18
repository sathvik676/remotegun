import 'package:cloud_car/models/app_settings.dart';
import 'package:cloud_car/providers/connection_provider.dart';
import 'package:cloud_car/providers/settings_provider.dart';
import 'package:cloud_car/utils/app_theme.dart';
import 'package:cloud_car/utils/constants.dart';
import 'package:cloud_car/utils/validators.dart';
import 'package:cloud_car/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  late final TextEditingController _basePathController;
  late String _scheme;
  late int _timeoutSeconds;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>().settings;
    _hostController = TextEditingController(text: settings.host);
    _portController = TextEditingController(text: '${settings.port}');
    _basePathController = TextEditingController(text: settings.basePath);
    _scheme = settings.scheme;
    _timeoutSeconds = settings.timeoutSeconds;
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _basePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SettingsProvider>().settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Server Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _NetworkWarning(),
          const SizedBox(height: 16),
          AppCard(
            accent: AppTheme.cyan,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'BACKEND CONNECTION',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    value: _scheme,
                    decoration: const InputDecoration(
                      labelText: 'Protocol',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'http', child: Text('http')),
                      DropdownMenuItem(value: 'https', child: Text('https')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _scheme = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _hostController,
                    validator: validateHost,
                    autocorrect: false,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'Server IP or hostname',
                      hintText: '192.168.1.5',
                      prefixIcon: Icon(Icons.dns_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _portController,
                    validator: validatePort,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      hintText: '8000',
                      prefixIcon: Icon(Icons.numbers_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _basePathController,
                    validator: validateBasePath,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Base path (optional)',
                      hintText: '/',
                      prefixIcon: Icon(Icons.folder_open_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Preview(url: _previewUrl()),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save settings'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _testConnection,
                    icon: const Icon(Icons.network_check_rounded),
                    label: const Text('Save and test connection'),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: _resetDefaults,
                    icon: const Icon(Icons.restore_rounded),
                    label: const Text('Reset to emulator default'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            accent: AppTheme.violet,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SAVED CONFIGURATION',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                _InfoRow(label: 'Base URL', value: saved.baseUrl),
                _InfoRow(label: 'Timeout', value: '${saved.timeoutSeconds}s'),
                _InfoRow(label: 'Car ID', value: AppStrings.carId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _previewUrl() {
    final port = int.tryParse(_portController.text.trim()) ?? 0;
    final path = _basePathController.text.trim();
    final host = _hostController.text.trim().isEmpty
        ? '<host>'
        : _hostController.text.trim();
    return '$_scheme://$host:$port$path';
  }

  ServerSettings _buildSettings() {
    final current = context.read<SettingsProvider>().settings;
    return ServerSettings(
      host: _hostController.text.trim(),
      port: int.parse(_portController.text.trim()),
      scheme: _scheme,
      basePath: _basePathController.text.trim(),
      timeoutSeconds: _timeoutSeconds == current.timeoutSeconds
          ? current.timeoutSeconds
          : _timeoutSeconds,
    );
  }

  Future<bool> _save({bool retry = false}) async {
    if (!_formKey.currentState!.validate()) return false;
    final ok = await context.read<SettingsProvider>().save(_buildSettings());
    if (!mounted) return ok;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Server settings saved.' : 'Could not save server settings.',
        ),
      ),
    );
    if (ok && retry) {
      await context.read<ConnectionProvider>().retryNow();
    }
    return ok;
  }

  Future<void> _testConnection() async {
    final saved = await _save(retry: false);
    if (!saved || !mounted) return;
    await context.read<ConnectionProvider>().retryNow();
    if (!mounted) return;
    final isOnline = context.read<ConnectionProvider>().isOnline;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isOnline
              ? 'Backend connection successful.'
              : 'Backend unreachable. Check IP, firewall, and port.',
        ),
      ),
    );
  }

  Future<void> _resetDefaults() async {
    final ok = await context.read<SettingsProvider>().resetToDefaults();
    if (!mounted) return;
    final settings = context.read<SettingsProvider>().settings;
    setState(() {
      _hostController.text = settings.host;
      _portController.text = '${settings.port}';
      _basePathController.text = settings.basePath;
      _scheme = settings.scheme;
      _timeoutSeconds = settings.timeoutSeconds;
    });
    if (ok) await context.read<ConnectionProvider>().retryNow();
  }
}

class _NetworkWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.amber.withOpacity(0.4)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppTheme.amber, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'localhost on the phone means the phone itself. For a physical '
              'phone, use the laptop LAN IP (for example 192.168.1.5). For the '
              'Android emulator, 10.0.2.2 points to the host machine. The '
              'backend must bind to 0.0.0.0 and Windows Firewall must allow '
              'port 8000.',
              style: TextStyle(color: AppTheme.amber, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        url,
        style: const TextStyle(
          color: AppTheme.cyan,
          fontFamily: 'monospace',
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
