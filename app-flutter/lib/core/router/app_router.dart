import 'package:autocore_app/core/extensions/context_extensions.dart';
import 'package:autocore_app/core/models/api/api_screen_config.dart';
import 'package:autocore_app/core/models/api/telemetry_data.dart';
import 'package:autocore_app/core/utils/logger.dart';
import 'package:autocore_app/features/dashboard/dashboard_screen.dart';
import 'package:autocore_app/features/dashboard/providers/dashboard_provider.dart';
import 'package:autocore_app/features/screens/dynamic_screen_builder.dart';
import 'package:autocore_app/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Alias para compatibilidade
final appRouterProvider = Provider<RouterConfig<Object>>((ref) {
  return ref.watch(routerProvider);
});

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          ),
          // Rota dinâmica para telas do backend
          GoRoute(
            path: '/screen/:id',
            name: 'dynamic_screen',
            pageBuilder: (context, state) {
              final screenId = state.pathParameters['id'] ?? '';
              return CustomTransitionPage(
                key: state.pageKey,
                child: DynamicScreenWrapper(screenId: screenId),
                transitionsBuilder: _slideTransition,
              );
            },
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder: _slideTransition,
            ),
          ),
        ],
      ),
    ],
  );
});

Widget _slideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  const begin = Offset(1.0, 0.0);
  const end = Offset.zero;
  const curve = Curves.easeInOut;

  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

  return SlideTransition(position: animation.drive(tween), child: child);
}

// App Shell with navigation
class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          if (!context.isMobile)
            NavigationRail(
              selectedIndex: _getSelectedIndex(context),
              onDestinationSelected: (index) => _onItemTapped(context, index),
              labelType: NavigationRailLabelType.all,
              destinations: _navigationItems.map((item) {
                return NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: Text(item.label),
                );
              }).toList(),
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: context.isMobile
          ? NavigationBar(
              selectedIndex: _getSelectedIndex(context),
              onDestinationSelected: (index) => _onItemTapped(context, index),
              destinations: _navigationItems.map((item) {
                return NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                );
              }).toList(),
            )
          : null,
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    switch (location) {
      case '/':
        return 0;
      case '/settings':
        return 1;
      default:
        return 0;
    }
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.goNamed('dashboard');
        break;
      case 1:
        context.goNamed('settings');
        break;
      default:
        context.goNamed('dashboard');
        break;
    }
  }
}

// Navigation items
class NavigationItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });
}

final _navigationItems = [
  const NavigationItem(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    route: '/',
  ),
  const NavigationItem(
    label: 'Configurações',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    route: '/settings',
  ),
];

// Widget para telas dinâmicas
class DynamicScreenWrapper extends ConsumerStatefulWidget {
  final String screenId;

  const DynamicScreenWrapper({super.key, required this.screenId});

  @override
  ConsumerState<DynamicScreenWrapper> createState() =>
      _DynamicScreenWrapperState();
}

class _DynamicScreenWrapperState extends ConsumerState<DynamicScreenWrapper> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final config = dashboardState.config;

    // TODO: Obter telemetria real quando MQTT estiver conectado
    const TelemetryData? telemetryData = null; // Placeholder para telemetria

    if (config == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Carregando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Busca a tela pelo ID
    ApiScreenConfig? screen;
    try {
      screen = config.screens.firstWhere(
        (s) => s.id.toString() == widget.screenId,
      );
    } catch (e) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Tela com ID "${widget.screenId}" não encontrada'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Voltar ao Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    // USA O DynamicScreenBuilder COM NOSSOS WIDGETS CUSTOMIZADOS!
    return DynamicScreenBuilder(
      screenConfig: screen,
      telemetryData: telemetryData,
      relayStates: const {}, // TODO: Obter do MQTT quando conectado
      sensorValues: const {}, // TODO: Obter do MQTT quando conectado
      onButtonPressed: _handleButtonCommand,
      onSwitchChanged: _handleSwitchCommand,
    );
  }

  void _handleButtonCommand(
    String itemId,
    String command,
    Map<String, dynamic>? payload,
  ) {
    // TODO: Implementar execução de comando via MQTT/API
    AppLogger.info('Button command: $itemId - $command - payload: $payload');

    // Por enquanto, apenas feedback visual
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comando $command executado'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleSwitchCommand(String itemId, bool value) {
    // TODO: Implementar toggle via MQTT/API
    AppLogger.info('Switch command: $itemId - value: $value');

    // Por enquanto, apenas feedback visual
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switch ${value ? "ligado" : "desligado"}'),
          backgroundColor: value ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
