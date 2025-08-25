import 'package:autocore_app/core/helpers/telemetry_binding.dart';
import 'package:autocore_app/core/models/api/api_screen_config.dart';
import 'package:autocore_app/core/models/api/api_screen_item.dart';
import 'package:autocore_app/core/models/api/telemetry_data.dart';
import 'package:autocore_app/features/screens/widgets/screen_item_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DynamicScreenBuilder extends ConsumerWidget {
  final ApiScreenConfig screenConfig;
  final TelemetryData? telemetryData;
  final Map<String, bool> relayStates;
  final Map<String, double> sensorValues;
  final void Function(String, String, Map<String, dynamic>?)? onButtonPressed;
  final void Function(String, bool)? onSwitchChanged;

  const DynamicScreenBuilder({
    super.key,
    required this.screenConfig,
    this.telemetryData,
    this.relayStates = const {},
    this.sensorValues = const {},
    this.onButtonPressed,
    this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(screenConfig.title),
        backgroundColor: _getBackgroundColor(theme),
        foregroundColor: _getTextColor(theme),
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(_getConnectionIcon()),
            color: _getConnectionColor(),
            onPressed: () => _showConnectionStatus(context),
            tooltip: 'Status da conexão',
          ),
        ],
      ),
      backgroundColor: _getScreenBackgroundColor(theme),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implementar refresh da configuração
          await Future<void>.delayed(const Duration(milliseconds: 500));
        },
        child: _buildScreenContent(context, theme),
      ),
    );
  }

  Widget _buildScreenContent(BuildContext context, ThemeData theme) {
    if (screenConfig.items.isEmpty) {
      return _buildEmptyState(context);
    }

    switch (screenConfig.layoutType) {
      case 'grid':
        return _buildGridLayout(context, theme);
      case 'list':
        return _buildListLayout(context, theme);
      case 'custom':
        return _buildCustomLayout(context, theme);
      default:
        return _buildGridLayout(context, theme);
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.grid_view_outlined,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum item configurado',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esta tela ainda não possui itens configurados',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGridLayout(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: screenConfig.columns,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 1.2, // Proporção dos cards
        ),
        itemCount: screenConfig.items.length,
        itemBuilder: (context, index) {
          final item = screenConfig.items[index];
          if (!item.visible || !item.enabled) {
            return const SizedBox.shrink();
          }

          return _buildScreenItem(context, item);
        },
      ),
    );
  }

  Widget _buildListLayout(BuildContext context, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: screenConfig.items.length,
      itemBuilder: (context, index) {
        final item = screenConfig.items[index];
        if (!item.visible || !item.enabled) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildScreenItem(context, item),
        );
      },
    );
  }

  Widget _buildCustomLayout(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: screenConfig.items
            .where((item) => item.visible && item.enabled)
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildScreenItem(context, item),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildScreenItem(BuildContext context, ApiScreenItem item) {
    return ScreenItemFactory.buildItem(
      item: item,
      telemetryData: telemetryData,
      relayStates: relayStates,
      sensorValues: sensorValues,
      onButtonPressed: (command, payload) {
        onButtonPressed?.call(item.id, command, payload);
      },
      onSwitchChanged: (value) {
        onSwitchChanged?.call(item.id, value);
      },
    );
  }

  Color? _getBackgroundColor(ThemeData theme) {
    if (screenConfig.backgroundColor != null) {
      return _hexToColor(screenConfig.backgroundColor!);
    }
    return theme.appBarTheme.backgroundColor;
  }

  Color? _getTextColor(ThemeData theme) {
    if (screenConfig.textColor != null) {
      return _hexToColor(screenConfig.textColor!);
    }
    return theme.appBarTheme.foregroundColor;
  }

  Color _getScreenBackgroundColor(ThemeData theme) {
    return theme.scaffoldBackgroundColor;
  }

  IconData _getConnectionIcon() {
    final connectionStatus = TelemetryBinding.getConnectionStatus(
      telemetryData,
    );

    switch (connectionStatus) {
      case 'Online':
        return Icons.wifi;
      case 'Instável':
        return Icons.wifi_outlined;
      case 'Offline':
      case 'Desconectado':
        return Icons.wifi_off;
      default:
        return Icons.help_outline;
    }
  }

  Color _getConnectionColor() {
    return TelemetryBinding.getConnectionStatusColor(telemetryData);
  }

  void _showConnectionStatus(BuildContext context) {
    final connectionStatus = TelemetryBinding.getConnectionStatus(
      telemetryData,
    );
    final signalText = TelemetryBinding.getSignalStrengthText(
      telemetryData?.signalStrength,
    );
    final batteryText = TelemetryBinding.getBatteryLevelText(
      telemetryData?.batteryLevel,
    );
    final uptimeText = TelemetryBinding.formatUptime(telemetryData?.uptime);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Status da Conexão'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow(
              'Conexão:',
              connectionStatus,
              _getConnectionColor(),
            ),
            if (telemetryData?.signalStrength != null)
              _buildStatusRow('Sinal:', signalText, Colors.grey[600]!),
            if (telemetryData?.batteryLevel != null)
              _buildStatusRow(
                'Bateria:',
                batteryText,
                TelemetryBinding.getBatteryLevelColor(
                  telemetryData?.batteryLevel,
                ),
              ),
            if (telemetryData?.uptime != null)
              _buildStatusRow('Tempo ativo:', uptimeText, Colors.grey[600]!),
            if (telemetryData?.deviceUuid != null)
              _buildStatusRow(
                'Device UUID:',
                telemetryData!.deviceUuid,
                Colors.grey[600]!,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }

  Color? _hexToColor(String hex) {
    try {
      String cleanHex = hex.replaceAll('#', '');
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex'; // Adiciona alpha
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (e) {
      return null;
    }
  }
}
