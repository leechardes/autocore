/// Exemplo de feature module para Settings
/// Demonstra como usar a infraestrutura de feature modules
library;

import 'package:autocore_app/core/features/base_feature_module.dart';
import 'package:autocore_app/core/services/analytics_service.dart';
import 'package:autocore_app/core/services/feature_flags_service.dart';
import 'package:flutter/material.dart';

/// Feature module de exemplo para configurações avançadas
class SettingsFeatureModule extends SimpleFeatureModule {
  @override
  String get name => 'advanced_settings';
  
  @override
  String get displayName => 'Configurações Avançadas';
  
  @override
  IconData get icon => Icons.settings_applications;
  
  @override
  String get description => 'Configurações avançadas e feature flags';
  
  @override
  bool get enabled => FeatureFlagsService.instance.isEnabled('new_ui_components');
  
  @override
  Widget get mainScreen => const AdvancedSettingsScreen();
  
  @override
  Future<void> initialize() async {
    await super.initialize();
    
    // Analytics tracking
    await AnalyticsService.instance.track(
      ScreenViewEvent(screenName: 'advanced_settings_module_init')
    );
  }
}

/// Tela principal das configurações avançadas
class AdvancedSettingsScreen extends StatelessWidget {
  const AdvancedSettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Track screen view
    AnalyticsService.instance.trackScreenView('advanced_settings');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações Avançadas'),
      ),
      body: const AdvancedSettingsContent(),
    );
  }
}

/// Conteúdo da tela de configurações
class AdvancedSettingsContent extends StatefulWidget {
  const AdvancedSettingsContent({super.key});
  
  @override
  State<AdvancedSettingsContent> createState() => _AdvancedSettingsContentState();
}

class _AdvancedSettingsContentState extends State<AdvancedSettingsContent> {
  final _featureFlags = FeatureFlagsService.instance;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Feature Flags Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feature Flags',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'Controle features experimentais do app',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ..._buildFeatureFlagsList(),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Analytics Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'Provedores ativos: ${AnalyticsService.instance.activeProviders.join(', ')}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _sendTestEvent,
                  child: const Text('Enviar Evento de Teste'),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Actions Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ações',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _resetFeatureFlags,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    ),
                    child: const Text('Resetar Feature Flags'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  List<Widget> _buildFeatureFlagsList() {
    final features = _featureFlags.getAllFeatures();
    
    return features.entries.map((entry) {
      return SwitchListTile(
        title: Text(entry.key),
        subtitle: Text(_getFeatureDescription(entry.key)),
        value: entry.value,
        onChanged: (value) async {
          await _featureFlags.setOverride(entry.key, value);
          setState(() {});
          
          // Track analytics
          AnalyticsService.instance.trackButtonClick(
            'feature_flag_${entry.key}',
            'advanced_settings',
            category: 'feature_flags',
          );
        },
      );
    }).toList();
  }
  
  String _getFeatureDescription(String feature) {
    const descriptions = {
      'new_ui_components': 'Componentes de interface redesenhados',
      'dark_mode': 'Tema escuro do aplicativo',
      'animations': 'Animações e transições',
      'lazy_loading': 'Carregamento sob demanda',
      'cache_optimization': 'Otimizações de cache',
      'background_sync': 'Sincronização em segundo plano',
      'analytics': 'Coleta de dados de uso',
      'crash_reporting': 'Relatórios de erro automáticos',
      'performance_monitoring': 'Monitoramento de performance',
      'offline_mode': 'Modo offline experimental',
      'push_notifications': 'Notificações push',
      'voice_commands': 'Comandos por voz (experimental)',
      'debug_logs': 'Logs detalhados de debug',
      'mock_data': 'Dados simulados para testes',
      'force_errors': 'Forçar erros para testes',
    };
    
    return descriptions[feature] ?? 'Feature experimental';
  }
  
  void _sendTestEvent() {
    AnalyticsService.instance.track(
      ButtonClickEvent(
        buttonId: 'test_analytics',
        screen: 'advanced_settings',
        category: 'test',
      ),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Evento de teste enviado para Analytics'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  Future<void> _resetFeatureFlags() async {
    final success = await _featureFlags.resetToDefaults();
    
    if (success) {
      setState(() {});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feature flags resetadas para o padrão'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // Track analytics
      AnalyticsService.instance.trackButtonClick(
        'reset_feature_flags',
        'advanced_settings',
        category: 'admin_actions',
      );
    }
  }
}