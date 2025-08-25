# A18 - Screen Builder Implementation

## 📋 Objetivo
Implementar o sistema de construção dinâmica de telas baseado na configuração da API, com suporte a todos os tipos de items.

## 🎯 Componentes a Implementar

### 1. DynamicScreenBuilder
```dart
// lib/features/screens/dynamic_screen_builder.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autocore_app/core/models/api/api_screen_config.dart';
import 'package:autocore_app/core/models/api/api_screen_item.dart';
import 'package:autocore_app/features/screens/widgets/screen_item_factory.dart';
import 'package:autocore_app/providers/config_provider.dart';

class DynamicScreenBuilder extends ConsumerWidget {
  final ApiScreenConfig screenConfig;
  
  const DynamicScreenBuilder({
    super.key,
    required this.screenConfig,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final columns = isSmallScreen 
        ? screenConfig.columnsDisplaySmall 
        : screenConfig.columnsDisplayLarge;
    
    // Ordenar items por posição
    final sortedItems = List<ApiScreenItem>.from(screenConfig.items)
      ..sort((a, b) => a.position.compareTo(b.position));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(screenConfig.title),
        leading: Icon(_getIconData(screenConfig.icon)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildLayout(context, sortedItems, columns),
      ),
    );
  }
  
  Widget _buildLayout(BuildContext context, List<ApiScreenItem> items, int columns) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Nenhum item configurado'),
      );
    }
    
    // Grid layout baseado em columns da API
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: _getAspectRatio(columns),
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ScreenItemFactory.buildItem(item);
      },
    );
  }
  
  double _getAspectRatio(int columns) {
    // Ajustar aspect ratio baseado no número de colunas
    switch (columns) {
      case 1:
        return 2.5;
      case 2:
        return 1.5;
      case 3:
        return 1.2;
      default:
        return 1.0;
    }
  }
  
  IconData _getIconData(String iconName) {
    // Mapear nomes de ícones para IconData
    // TODO: Expandir mapeamento
    final iconMap = {
      'home': Icons.home,
      'dashboard': Icons.dashboard,
      'settings': Icons.settings,
      'lightbulb': Icons.lightbulb,
      'thermometer': Icons.thermostat,
      'speed': Icons.speed,
      'bolt': Icons.bolt,
      'water_drop': Icons.water_drop,
      'local_gas_station': Icons.local_gas_station,
    };
    
    return iconMap[iconName] ?? Icons.widgets;
  }
}
```

### 2. ScreenItemFactory
```dart
// lib/features/screens/widgets/screen_item_factory.dart
import 'package:flutter/material.dart';
import 'package:autocore_app/core/models/api/api_screen_item.dart';
import 'package:autocore_app/features/screens/widgets/button_item_widget.dart';
import 'package:autocore_app/features/screens/widgets/gauge_item_widget.dart';
import 'package:autocore_app/features/screens/widgets/display_item_widget.dart';
import 'package:autocore_app/features/screens/widgets/slider_item_widget.dart';
import 'package:autocore_app/features/screens/widgets/switch_item_widget.dart';

class ScreenItemFactory {
  static Widget buildItem(ApiScreenItem item) {
    switch (item.itemType.toLowerCase()) {
      case 'button':
        return ButtonItemWidget(item: item);
        
      case 'gauge':
        return GaugeItemWidget(item: item);
        
      case 'display':
        return DisplayItemWidget(item: item);
        
      case 'slider':
        return SliderItemWidget(item: item);
        
      case 'switch':
        return SwitchItemWidget(item: item);
        
      default:
        return _buildUnknownItem(item);
    }
  }
  
  static Widget _buildUnknownItem(ApiScreenItem item) {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.help_outline, size: 48),
            const SizedBox(height: 8),
            Text('Unknown type: ${item.itemType}'),
            Text(item.label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
```

### 3. ButtonItemWidget
```dart
// lib/features/screens/widgets/button_item_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autocore_app/core/models/api/api_screen_item.dart';
import 'package:autocore_app/infrastructure/services/relay_action_service.dart';
import 'package:autocore_app/infrastructure/services/macro_service.dart';
import 'package:autocore_app/core/utils/logger.dart';

class ButtonItemWidget extends ConsumerStatefulWidget {
  final ApiScreenItem item;
  
  const ButtonItemWidget({
    super.key,
    required this.item,
  });
  
  @override
  ConsumerState<ButtonItemWidget> createState() => _ButtonItemWidgetState();
}

class _ButtonItemWidgetState extends ConsumerState<ButtonItemWidget> {
  bool _isPressed = false;
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = widget.item;
    
    return Card(
      elevation: _isPressed ? 8 : 2,
      child: InkWell(
        onTapDown: (_) => _handleTapDown(),
        onTapUp: (_) => _handleTapUp(),
        onTapCancel: () => _handleTapUp(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconData(config.icon),
                size: 48,
                color: _getIconColor(theme),
              ),
              const SizedBox(height: 8),
              Text(
                config.label,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _handleTapDown() {
    setState(() => _isPressed = true);
    
    // Feedback háptico
    HapticFeedback.lightImpact();
    
    // Executar ação baseada no tipo
    _executeAction();
  }
  
  void _handleTapUp() {
    setState(() => _isPressed = false);
    
    // Para ações momentâneas, enviar comando OFF
    if (_isMomentaryAction()) {
      _stopMomentaryAction();
    }
  }
  
  Future<void> _executeAction() async {
    final config = widget.item;
    
    if (config.actionType == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      switch (config.actionType) {
        case 'relay_toggle':
          await _executeRelayToggle();
          break;
          
        case 'relay_momentary':
          await _executeRelayMomentary();
          break;
          
        case 'macro_execute':
          await _executeMacro();
          break;
          
        case 'navigation':
          _executeNavigation();
          break;
          
        default:
          AppLogger.warning('Unknown action type: ${config.actionType}');
      }
    } catch (e) {
      AppLogger.error('Failed to execute action', error: e);
      _showError('Falha ao executar ação');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _executeRelayToggle() async {
    final config = widget.item;
    
    if (config.relayBoardId != null && config.relayChannelId != null) {
      await RelayActionService.instance.toggleRelay(
        boardId: config.relayBoardId!,
        channelId: config.relayChannelId!,
        deviceUuid: config.relayBoard?.deviceUuid,
      );
    }
  }
  
  Future<void> _executeRelayMomentary() async {
    final config = widget.item;
    
    if (config.relayBoardId != null && config.relayChannelId != null) {
      await RelayActionService.instance.startMomentary(
        boardId: config.relayBoardId!,
        channelId: config.relayChannelId!,
        deviceUuid: config.relayBoard?.deviceUuid,
      );
    }
  }
  
  void _stopMomentaryAction() {
    final config = widget.item;
    
    if (config.actionType == 'relay_momentary' &&
        config.relayBoardId != null && 
        config.relayChannelId != null) {
      RelayActionService.instance.stopMomentary(
        boardId: config.relayBoardId!,
        channelId: config.relayChannelId!,
        deviceUuid: config.relayBoard?.deviceUuid,
      );
    }
  }
  
  Future<void> _executeMacro() async {
    // TODO: Implementar execução de macro
    AppLogger.info('Executing macro: ${widget.item.name}');
  }
  
  void _executeNavigation() {
    // TODO: Implementar navegação
    AppLogger.info('Navigating to: ${widget.item.name}');
  }
  
  bool _isMomentaryAction() {
    return widget.item.actionType == 'relay_momentary';
  }
  
  IconData _getIconData(String iconName) {
    // TODO: Expandir mapeamento de ícones
    final iconMap = {
      'lightbulb': Icons.lightbulb,
      'power': Icons.power_settings_new,
      'lock': Icons.lock,
      'garage': Icons.garage,
      'horn': Icons.volume_up,
      'flash': Icons.flash_on,
    };
    
    return iconMap[iconName] ?? Icons.touch_app;
  }
  
  Color _getIconColor(ThemeData theme) {
    if (_isPressed) {
      return theme.colorScheme.primary;
    }
    
    // Usar cor do relayChannel se disponível
    if (widget.item.relayChannel?.color != null) {
      final colorHex = widget.item.relayChannel!.color!;
      return Color(int.parse(colorHex.replaceAll('#', '0xFF')));
    }
    
    return theme.colorScheme.onSurface;
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
```

### 4. GaugeItemWidget
```dart
// lib/features/screens/widgets/gauge_item_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autocore_app/core/models/api/api_screen_item.dart';
import 'package:autocore_app/core/helpers/telemetry_binding.dart';
import 'package:autocore_app/core/widgets/indicators/circular_gauge.dart';

class GaugeItemWidget extends StatelessWidget with TelemetryBindingMixin {
  final ApiScreenItem item;
  
  const GaugeItemWidget({
    super.key,
    required this.item,
  });
  
  @override
  Widget build(BuildContext context) {
    if (item.valueSource == null) {
      return _buildStaticGauge(context);
    }
    
    return TelemetryValue(
      valueSource: extractTelemetryKey(item.valueSource),
      defaultValue: item.minValue ?? 0,
      builder: (context, value) {
        return _buildGauge(context, value ?? item.minValue ?? 0);
      },
    );
  }
  
  Widget _buildGauge(BuildContext context, double value) {
    final normalizedValue = normalizeValue(
      value,
      item.minValue ?? 0,
      item.maxValue ?? 100,
    );
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: CircularGauge(
                value: normalizedValue,
                min: item.minValue ?? 0,
                max: item.maxValue ?? 100,
                unit: item.unit ?? '',
                label: item.label,
                color: getColorForValue(normalizedValue, item.colorRanges),
                showValue: true,
                animated: true,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStaticGauge(BuildContext context) {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.speed, size: 48),
            const SizedBox(height: 8),
            Text(item.label),
            const Text('No data source', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
```

### 5. DisplayItemWidget
```dart
// lib/features/screens/widgets/display_item_widget.dart
import 'package:flutter/material.dart';
import 'package:autocore_app/core/models/api/api_screen_item.dart';
import 'package:autocore_app/core/helpers/telemetry_binding.dart';

class DisplayItemWidget extends StatelessWidget with TelemetryBindingMixin {
  final ApiScreenItem item;
  
  const DisplayItemWidget({
    super.key,
    required this.item,
  });
  
  @override
  Widget build(BuildContext context) {
    if (item.valueSource == null) {
      return _buildStaticDisplay(context);
    }
    
    return TelemetryValue(
      valueSource: extractTelemetryKey(item.valueSource),
      defaultValue: 0,
      builder: (context, value) {
        return _buildDisplay(context, value);
      },
    );
  }
  
  Widget _buildDisplay(BuildContext context, double? value) {
    final theme = Theme.of(context);
    final displayConfig = item.displayConfig ?? {};
    
    // Formatar valor
    final formattedValue = _formatValue(
      value ?? 0,
      displayConfig['format_string'] as String? ?? '##0.0',
      displayConfig['decimal_places'] as int? ?? 1,
    );
    
    final prefix = displayConfig['prefix'] as String? ?? '';
    final suffix = displayConfig['suffix'] as String? ?? item.unit ?? '';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconData(item.icon),
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              '$prefix$formattedValue$suffix',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getValueColor(value, theme),
              ),
            ),
            if (displayConfig['show_trend'] == true)
              _buildTrendIndicator(context, value),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStaticDisplay(BuildContext context) {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIconData(item.icon), size: 32),
            const SizedBox(height: 8),
            Text(item.label),
            const Text('--', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTrendIndicator(BuildContext context, double? value) {
    // TODO: Implementar indicador de tendência
    return const SizedBox.shrink();
  }
  
  String _formatValue(double value, String format, int decimalPlaces) {
    return value.toStringAsFixed(decimalPlaces);
  }
  
  Color _getValueColor(double? value, ThemeData theme) {
    if (value == null) return theme.colorScheme.onSurface;
    
    // Usar color ranges se disponível
    if (item.colorRanges != null) {
      return getColorForValue(value, item.colorRanges);
    }
    
    return theme.colorScheme.onSurface;
  }
  
  IconData _getIconData(String iconName) {
    final iconMap = {
      'thermometer': Icons.thermostat,
      'speed': Icons.speed,
      'battery': Icons.battery_full,
      'fuel': Icons.local_gas_station,
      'pressure': Icons.compress,
    };
    
    return iconMap[iconName] ?? Icons.info;
  }
}
```

## ✅ Checklist de Implementação

- [ ] Criar DynamicScreenBuilder principal
- [ ] Implementar ScreenItemFactory
- [ ] Criar ButtonItemWidget com ações
- [ ] Criar GaugeItemWidget com telemetria
- [ ] Criar DisplayItemWidget com formatação
- [ ] Adicionar SliderItemWidget (opcional)
- [ ] Adicionar SwitchItemWidget (opcional)
- [ ] Implementar layout responsivo
- [ ] Adicionar suporte a temas da API
- [ ] Testar com diferentes configurações

## 🚀 Comandos de Execução

```bash
# 1. Criar estrutura
mkdir -p lib/features/screens/widgets
cd lib/features/screens

# 2. Criar arquivos
touch dynamic_screen_builder.dart
touch widgets/screen_item_factory.dart
touch widgets/button_item_widget.dart
touch widgets/gauge_item_widget.dart
touch widgets/display_item_widget.dart

# 3. Testar widgets
flutter test test/features/screens/
```

## 📊 Resultado Esperado

Após implementação:
- ✅ Telas construídas dinamicamente da API
- ✅ Todos os tipos de items suportados
- ✅ Layout responsivo funcionando
- ✅ Telemetria binding em tempo real
- ✅ Ações de botões funcionando
- ✅ Visual consistente com tema

---

**Prioridade**: P0 - CRÍTICO
**Tempo estimado**: 6-8 horas
**Dependências**: A15, A16, A17