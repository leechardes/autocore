import 'package:autocore_app/core/extensions/context_extensions.dart';
import 'package:autocore_app/core/utils/logger.dart';
import 'package:autocore_app/features/dashboard/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Tela principal do dashboard
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    AppLogger.init('DashboardScreen');
    // Agendar o carregamento após a construção do widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConfiguration();
    });
  }

  Future<void> _loadConfiguration() async {
    AppLogger.info('Recarregando configuração do dashboard');
    await ref.read(dashboardProvider.notifier).loadData();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoCore'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConfiguration,
            tooltip: 'Recarregar',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardState.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 64, color: context.textTertiary),
                  SizedBox(height: context.spacingMd),
                  Text(
                    'Modo Offline',
                    style: TextStyle(
                      fontSize: context.fontSizeLarge,
                      color: context.textSecondary,
                    ),
                  ),
                  SizedBox(height: context.spacingSm),
                  Text(
                    dashboardState.error!,
                    style: TextStyle(
                      fontSize: context.fontSizeSmall,
                      color: context.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.spacingMd),
                  ElevatedButton.icon(
                    onPressed: _loadConfiguration,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(context.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle Card (opcional)
                  _buildVehicleCard(),

                  SizedBox(height: context.spacingLg),

                  // Screen Navigation Buttons
                  _buildScreenButtons(),

                  SizedBox(height: context.spacingLg),

                  // Quick Actions (Macros)
                  _buildQuickActions(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onEmergencyStop,
        backgroundColor: context.errorColor,
        tooltip: 'Parada de Emergência',
        child: const Icon(Icons.stop, size: 32),
      ),
    );
  }

  Widget _buildVehicleCard() {
    final dashboardState = ref.watch(dashboardProvider);
    final systemStatus = dashboardState.systemStatus;
    final deviceInfo = dashboardState.config?.deviceInfo;

    // Se não tiver informações do dispositivo, mostrar card básico
    if (deviceInfo == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.spacingMd),
        child: Column(
          children: [
            const Icon(Icons.directions_car, size: 64),
            SizedBox(height: context.spacingSm),
            Text(
              deviceInfo.name,
              style: TextStyle(
                fontSize: context.fontSizeLarge,
                fontWeight: context.fontWeightBold,
              ),
            ),
            Text(
              deviceInfo.deviceType,
              style: TextStyle(
                fontSize: context.fontSizeSmall,
                color: context.textSecondary,
              ),
            ),
            SizedBox(height: context.spacingMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusIndicator(
                  'Sistema',
                  (systemStatus['mqttConnected'] ?? false) == true
                      ? 'ON'
                      : 'OFF',
                  (systemStatus['mqttConnected'] ?? false) == true,
                ),
                if (systemStatus['battery'] != null)
                  _buildStatusIndicator(
                    'Bateria',
                    '${(systemStatus['battery'] as Map?)?['voltage'] ?? 0}V',
                    (((systemStatus['battery'] as Map?)?['level'] ?? 0)
                            as num) >
                        20,
                  ),
                if (systemStatus['temperature'] != null)
                  _buildStatusIndicator(
                    'Temp',
                    '${systemStatus['temperature']}°C',
                    true,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, String value, bool isActive) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: context.fontSizeMedium,
            fontWeight: context.fontWeightBold,
            color: isActive ? context.successColor : context.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: context.fontSizeSmall,
            color: context.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildScreenButtons() {
    final screens = ref.watch(dashboardProvider).config?.screens;

    if (screens == null || screens.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTROLES',
          style: TextStyle(
            fontSize: context.fontSizeSmall,
            fontWeight: context.fontWeightBold,
            color: context.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: context.spacingSm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: context.isMobile ? 2 : 4,
            crossAxisSpacing:
                16.0, // 16px conforme especificação A33-PHASE2-IMPORTANT-FIXES
            mainAxisSpacing:
                16.0, // 16px conforme especificação A33-PHASE2-IMPORTANT-FIXES
            childAspectRatio: 1.2,
          ),
          itemCount: screens.length,
          itemBuilder: (context, index) {
            final screen = screens[index];
            return _buildScreenButton(
              screen.id.toString(),
              screen.name,
              _getIconFromName(screen.icon ?? 'widgets'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildScreenButton(String id, String name, IconData icon) {
    return Card(
      child: InkWell(
        onTap: () {
          AppLogger.info('Navegando para tela com ID: $id');
          AppLogger.userAction('Navigate to screen', params: {'screen': id});
          context.go('/screen/$id');
        },
        borderRadius: BorderRadius.circular(context.borderRadiusMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: context.primaryColor,
            ), // 20px conforme especificação A33-PHASE2-IMPORTANT-FIXES
            SizedBox(height: context.spacingSm),
            Text(
              name,
              style: TextStyle(
                fontSize: context.fontSizeSmall,
                fontWeight: context.fontWeightBold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    // Por enquanto, não há macros na configuração completa
    // TODO: Implementar quando macros forem adicionadas ao config/full
    return const SizedBox.shrink();
  }

  void _onEmergencyStop() {
    AppLogger.warning('EMERGENCY STOP ACTIVATED');
    // TODO(autocore): Implementar parada de emergência
    // HeartbeatService.instance.emergencyStopAll();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Parada de Emergência Ativada!'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    AppLogger.dispose('DashboardScreen');
    super.dispose();
  }

  IconData _getIconFromName(String name) {
    switch (name.toLowerCase()) {
      case 'lightbulb':
        return Icons.lightbulb;
      case 'settings_input_component':
        return Icons.settings_input_component;
      case 'toggle_on':
        return Icons.toggle_on;
      case 'explore':
        return Icons.explore;
      case 'home':
        return Icons.home;
      case 'security':
        return Icons.security;
      case 'warning':
        return Icons.warning;
      case 'play_circle':
        return Icons.play_circle;
      default:
        return Icons.widgets;
    }
  }
}
