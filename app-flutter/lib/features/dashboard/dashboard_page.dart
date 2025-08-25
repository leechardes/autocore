import 'package:autocore_app/core/extensions/context_extensions.dart';
import 'package:autocore_app/core/services/mqtt_service.dart';
import 'package:autocore_app/core/widgets/base/ac_button.dart';
import 'package:autocore_app/core/widgets/base/ac_container.dart';
import 'package:autocore_app/core/widgets/base/ac_grid.dart';
import 'package:autocore_app/core/widgets/indicators/ac_gauge.dart';
import 'package:autocore_app/core/widgets/indicators/ac_status_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  final mqttService = MqttService.instance;

  // Mock data - será substituído por dados reais via MQTT
  double batteryLevel = 85.0;
  double temperature = 23.5;
  int activeDevices = 12;
  int totalDevices = 18;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _setupMqttListeners();
  }

  void _setupMqttListeners() {
    mqttService.connectionState.listen((state) {
      if (mounted) {
        setState(() {
          isConnected = state == AutoCoreMqttState.connected;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.acTheme;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.surfaceColor,
        elevation: 0,
        title: Text(
          'AutoCore Dashboard',
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: theme.fontWeightBold,
          ),
        ),
        actions: [
          // Connection status
          Padding(
            padding: EdgeInsets.symmetric(horizontal: theme.spacingMd),
            child: ACStatusIndicator.connection(
              isConnected: isConnected,
              customLabel: isConnected ? 'MQTT Conectado' : 'MQTT Desconectado',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(theme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Cards
            _buildStatusSection(context),

            SizedBox(height: theme.spacingLg),

            // Quick Actions
            _buildQuickActionsSection(context),

            SizedBox(height: theme.spacingLg),

            // System Gauges
            _buildSystemGaugesSection(context),

            SizedBox(height: theme.spacingLg),

            // Recent Activity
            _buildRecentActivitySection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    final theme = context.acTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status do Sistema',
          style: TextStyle(
            fontSize: theme.fontSizeLarge,
            fontWeight: theme.fontWeightBold,
            color: theme.textPrimary,
          ),
        ),
        SizedBox(height: theme.spacingMd),
        ACGrid(
          type: ACGridType.responsive,
          minColumns: 2,
          maxColumns: 4,
          minItemWidth: 150,
          aspectRatio: 1.5,
          children: [
            _buildStatusCard(
              context,
              title: 'Dispositivos',
              value: '$activeDevices/$totalDevices',
              subtitle: 'Ativos',
              color: theme.successColor,
              icon: Icons.devices,
            ),
            _buildStatusCard(
              context,
              title: 'Bateria',
              value: '${batteryLevel.toInt()}%',
              subtitle: batteryLevel > 20 ? 'Normal' : 'Baixa',
              color: batteryLevel > 50
                  ? theme.successColor
                  : batteryLevel > 20
                  ? theme.warningColor
                  : theme.errorColor,
              icon: Icons.battery_charging_full,
            ),
            _buildStatusCard(
              context,
              title: 'Temperatura',
              value: '${temperature.toStringAsFixed(1)}°C',
              subtitle: 'Ambiente',
              color: theme.infoColor,
              icon: Icons.thermostat,
            ),
            _buildStatusCard(
              context,
              title: 'Uptime',
              value: '2d 14h',
              subtitle: 'Sistema',
              color: theme.primaryColor,
              icon: Icons.schedule,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    final theme = context.acTheme;

    return ACContainer(
      type: ACContainerType.elevated,
      padding: EdgeInsets.all(theme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: theme.spacingSm),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: theme.fontSizeSmall,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacingSm),
          Text(
            value,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 24,
              fontWeight: theme.fontWeightBold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: theme.textTertiary,
              fontSize: theme.fontSizeSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    final theme = context.acTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: TextStyle(
            fontSize: theme.fontSizeLarge,
            fontWeight: theme.fontWeightBold,
            color: theme.textPrimary,
          ),
        ),
        SizedBox(height: theme.spacingMd),
        ACGrid(
          type: ACGridType.responsive,
          minColumns: 2,
          maxColumns: 4,
          minItemWidth: 120,
          aspectRatio: 1.0,
          children: [
            _buildQuickActionButton(
              context,
              label: 'Todas Luzes',
              icon: Icons.lightbulb,
              onPressed: () {
                // TODO(autocore): Implementar ação
              },
            ),
            _buildQuickActionButton(
              context,
              label: 'Trancar',
              icon: Icons.lock,
              onPressed: () {
                // TODO(autocore): Implementar ação
              },
            ),
            _buildQuickActionButton(
              context,
              label: 'Alarme',
              icon: Icons.security,
              onPressed: () {
                // TODO(autocore): Implementar ação
              },
            ),
            _buildQuickActionButton(
              context,
              label: 'Emergência',
              icon: Icons.warning,
              color: theme.errorColor,
              onPressed: () {
                // TODO(autocore): Implementar ação
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    final theme = context.acTheme;

    return ACButton(
      onPressed: onPressed,
      type: ACButtonType.flat,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color ?? theme.primaryColor, size: 32),
          SizedBox(height: theme.spacingSm),
          Text(
            label,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: theme.fontSizeSmall,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemGaugesSection(BuildContext context) {
    final theme = context.acTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monitoramento',
          style: TextStyle(
            fontSize: theme.fontSizeLarge,
            fontWeight: theme.fontWeightBold,
            color: theme.textPrimary,
          ),
        ),
        SizedBox(height: theme.spacingMd),
        Row(
          children: [
            Expanded(
              child: ACContainer(
                type: ACContainerType.elevated,
                padding: EdgeInsets.all(theme.spacingMd),
                child: Column(
                  children: [
                    ACGauge(
                      type: ACGaugeType.semicircular,
                      value: batteryLevel,
                      min: 0,
                      max: 100,
                      unit: '%',
                      label: 'Bateria',
                      height: 100,
                      zones: [
                        ACGaugeZone(start: 0, end: 20, color: theme.errorColor),
                        ACGaugeZone(
                          start: 20,
                          end: 50,
                          color: theme.warningColor,
                        ),
                        ACGaugeZone(
                          start: 50,
                          end: 100,
                          color: theme.successColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: theme.spacingMd),
            Expanded(
              child: ACContainer(
                type: ACContainerType.elevated,
                padding: EdgeInsets.all(theme.spacingMd),
                child: Column(
                  children: [
                    ACGauge(
                      type: ACGaugeType.linear,
                      value: temperature,
                      min: -10,
                      max: 50,
                      unit: '°C',
                      label: 'Temperatura',
                      height: 100,
                      zones: [
                        ACGaugeZone(start: -10, end: 0, color: theme.infoColor),
                        ACGaugeZone(
                          start: 0,
                          end: 30,
                          color: theme.successColor,
                        ),
                        ACGaugeZone(
                          start: 30,
                          end: 40,
                          color: theme.warningColor,
                        ),
                        ACGaugeZone(
                          start: 40,
                          end: 50,
                          color: theme.errorColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    final theme = context.acTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Atividade Recente',
          style: TextStyle(
            fontSize: theme.fontSizeLarge,
            fontWeight: theme.fontWeightBold,
            color: theme.textPrimary,
          ),
        ),
        SizedBox(height: theme.spacingMd),
        ACContainer(
          type: ACContainerType.elevated,
          padding: EdgeInsets.all(theme.spacingMd),
          child: Column(
            children: [
              _buildActivityItem(
                context,
                icon: Icons.lightbulb,
                title: 'Luz da Sala ligada',
                time: '2 min atrás',
                status: ACStatusType.success,
              ),
              Divider(height: theme.spacingLg),
              _buildActivityItem(
                context,
                icon: Icons.lock,
                title: 'Sistema travado',
                time: '15 min atrás',
                status: ACStatusType.info,
              ),
              Divider(height: theme.spacingLg),
              _buildActivityItem(
                context,
                icon: Icons.warning,
                title: 'Bateria baixa detectada',
                time: '1 hora atrás',
                status: ACStatusType.warning,
              ),
              Divider(height: theme.spacingLg),
              _buildActivityItem(
                context,
                icon: Icons.play_circle,
                title: 'Macro "Chegada" executada',
                time: '3 horas atrás',
                status: ACStatusType.success,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String time,
    required ACStatusType status,
  }) {
    final theme = context.acTheme;

    return Row(
      children: [
        Icon(icon, color: theme.textSecondary, size: 20),
        SizedBox(width: theme.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: theme.fontSizeMedium,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  color: theme.textTertiary,
                  fontSize: theme.fontSizeSmall,
                ),
              ),
            ],
          ),
        ),
        ACStatusIndicator(
          status: status,
          size: ACIndicatorSize.small,
          showLabel: false,
        ),
      ],
    );
  }
}
