import 'package:cloud_car/providers/car_control_provider.dart';
import 'package:cloud_car/providers/connection_provider.dart';
import 'package:cloud_car/providers/diagnostics_provider.dart';
import 'package:cloud_car/providers/settings_provider.dart';
import 'package:cloud_car/providers/telemetry_provider.dart';
import 'package:cloud_car/screens/splash_screen.dart';
import 'package:cloud_car/services/api_client.dart';
import 'package:cloud_car/services/backend_repository.dart';
import 'package:cloud_car/services/settings_repository.dart';
import 'package:cloud_car/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsRepository = SharedPreferencesSettingsRepository();
  await settingsRepository.initialize();

  final settingsProvider = SettingsProvider(settingsRepository);
  await settingsProvider.initialize();

  final apiClient = ApiClient();
  final backendRepository = BackendRepository(apiClient);

  final connectionProvider = ConnectionProvider(
    backendRepository,
    settingsProvider,
  );
  final carProvider = CarControlProvider(
    backendRepository,
    settingsProvider,
    connectionProvider,
  );
  await carProvider.initialize();

  final telemetryProvider = TelemetryProvider(connectionProvider, carProvider);
  telemetryProvider.initialize();

  final diagnosticsProvider = DiagnosticsProvider(
    backendRepository,
    settingsProvider,
  );

  connectionProvider.initialize();

  runApp(
    CloudCarApp(
      settingsProvider: settingsProvider,
      connectionProvider: connectionProvider,
      carProvider: carProvider,
      telemetryProvider: telemetryProvider,
      diagnosticsProvider: diagnosticsProvider,
      apiClient: apiClient,
    ),
  );
}

class CloudCarApp extends StatefulWidget {
  const CloudCarApp({
    super.key,
    required this.settingsProvider,
    required this.connectionProvider,
    required this.carProvider,
    required this.telemetryProvider,
    required this.diagnosticsProvider,
    required this.apiClient,
  });

  final SettingsProvider settingsProvider;
  final ConnectionProvider connectionProvider;
  final CarControlProvider carProvider;
  final TelemetryProvider telemetryProvider;
  final DiagnosticsProvider diagnosticsProvider;
  final ApiClient apiClient;

  @override
  State<CloudCarApp> createState() => _CloudCarAppState();
}

class _CloudCarAppState extends State<CloudCarApp> {
  @override
  void dispose() {
    widget.telemetryProvider.dispose();
    widget.carProvider.dispose();
    widget.connectionProvider.dispose();
    widget.diagnosticsProvider.dispose();
    widget.settingsProvider.dispose();
    widget.apiClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.settingsProvider),
        ChangeNotifierProvider.value(value: widget.connectionProvider),
        ChangeNotifierProvider.value(value: widget.carProvider),
        ChangeNotifierProvider.value(value: widget.telemetryProvider),
        ChangeNotifierProvider.value(value: widget.diagnosticsProvider),
      ],
      child: MaterialApp(
        title: 'CLOUD CAR',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        home: const SplashScreen(),
      ),
    );
  }
}
