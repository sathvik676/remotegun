import 'package:cloud_car/providers/car_control_provider.dart';
import 'package:cloud_car/screens/car_control_screen.dart';
import 'package:cloud_car/screens/dashboard_screen.dart';
import 'package:cloud_car/screens/diagnostics_screen.dart';
import 'package:cloud_car/screens/settings_screen.dart';
import 'package:cloud_car/screens/telemetry_screen.dart';
import 'package:cloud_car/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  static const _screens = [
    DashboardScreen(),
    CarControlScreen(),
    TelemetryScreen(),
    SettingsScreen(),
    DiagnosticsScreen(),
  ];

  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      context.read<CarControlProvider>().handleAppBackgrounded();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.pageGradient()),
        child: SafeArea(
          child: IndexedStack(index: _index, children: _screens),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.space_dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.games_rounded),
            label: 'Control',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_rounded),
            label: 'Telemetry',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.network_check_rounded),
            label: 'Diagnostics',
          ),
        ],
      ),
    );
  }
}
