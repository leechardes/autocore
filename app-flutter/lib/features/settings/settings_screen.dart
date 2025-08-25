import 'package:autocore_app/core/extensions/context_extensions.dart';
import 'package:autocore_app/core/utils/logger.dart';
import 'package:autocore_app/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _apiHostController;
  late TextEditingController _apiPortController;

  bool _isTestingConnections = false;
  Map<String, bool>? _connectionResults;

  @override
  void initState() {
    super.initState();
    AppLogger.init('SettingsScreen');
    _initControllers();
  }

  void _initControllers() {
    final config = ref.read(settingsProvider);

    _apiHostController = TextEditingController(text: config.apiHost);
    _apiPortController = TextEditingController(text: config.apiPort.toString());
  }

  @override
  void dispose() {
    _apiHostController.dispose();
    _apiPortController.dispose();
    AppLogger.dispose('SettingsScreen');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _resetToDefaults,
            tooltip: 'Restaurar Padrões',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(context.spacingMd),
          children: [
            // Seção API Backend
            _buildSectionHeader('API Backend (Gateway)', Icons.api),
            _buildHostField(
              controller: _apiHostController,
              label: 'Host/IP',
              hint: 'Ex: 10.0.10.119 ou autocore.local',
            ),
            SizedBox(height: context.spacingSm),
            _buildPortField(
              controller: _apiPortController,
              label: 'Porta',
              hint: 'Ex: 8081',
            ),
            _buildSwitch(
              value: config.apiUseHttps,
              label: 'Usar HTTPS',
              onChanged: (value) => _updateConfig(apiUseHttps: value),
            ),

            SizedBox(height: context.spacingLg),

            // Seção Configurações Gerais
            _buildSectionHeader('Configurações Gerais', Icons.tune),
            _buildSwitch(
              value: config.autoConnect,
              label: 'Conectar Automaticamente',
              onChanged: (value) => _updateConfig(autoConnect: value),
            ),
            _buildSwitch(
              value: config.enableHeartbeat,
              label: 'Habilitar Heartbeat (Segurança)',
              subtitle: 'Essencial para botões momentâneos',
              onChanged: (value) => _updateConfig(enableHeartbeat: value),
            ),

            if (config.enableHeartbeat) ...[
              SizedBox(height: context.spacingSm),
              _buildNumberField(
                label: 'Intervalo Heartbeat (ms)',
                value: config.heartbeatInterval,
                min: 100,
                max: 2000,
                onChanged: (value) => _updateConfig(heartbeatInterval: value),
              ),
              SizedBox(height: context.spacingSm),
              _buildNumberField(
                label: 'Timeout Heartbeat (ms)',
                value: config.heartbeatTimeout,
                min: 500,
                max: 5000,
                onChanged: (value) => _updateConfig(heartbeatTimeout: value),
              ),
            ],

            SizedBox(height: context.spacingXl),

            // Teste de Conexão
            _buildConnectionTestSection(),

            SizedBox(height: context.spacingXl),

            // Botões de Ação
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTestingConnections ? null : _testConnections,
                    icon: _isTestingConnections
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.textPrimary,
                            ),
                          )
                        : const Icon(Icons.network_check),
                    label: Text(
                      _isTestingConnections ? 'Testando...' : 'Testar Conexões',
                    ),
                  ),
                ),
                SizedBox(width: context.spacingMd),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveConfiguration,
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.successColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(
        top: context.spacingMd,
        bottom: context.spacingSm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.primaryColor),
          SizedBox(width: context.spacingSm),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: context.fontSizeSmall,
              fontWeight: context.fontWeightBold,
              color: context.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.dns),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo obrigatório';
        }
        return null;
      },
    );
  }

  Widget _buildPortField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.numbers),
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(5),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo obrigatório';
        }
        final port = int.tryParse(value);
        if (port == null || port < 1 || port > 65535) {
          return 'Porta inválida (1-65535)';
        }
        return null;
      },
    );
  }

  // Métodos removidos - não são mais necessários

  Widget _buildSwitch({
    required bool value,
    required String label,
    String? subtitle,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label),
      subtitle: subtitle != null ? Text(subtitle) : null,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        SizedBox(
          width: 100,
          child: TextFormField(
            initialValue: value.toString(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (text) {
              final newValue = int.tryParse(text) ?? value;
              if (newValue >= min && newValue <= max) {
                onChanged(newValue);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionTestSection() {
    if (_connectionResults == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resultado dos Testes',
              style: TextStyle(
                fontSize: context.fontSizeMedium,
                fontWeight: context.fontWeightBold,
              ),
            ),
            SizedBox(height: context.spacingSm),
            _buildTestResult(
              'API Backend',
              _connectionResults!['api'] ?? false,
            ),
            _buildTestResult(
              'Config Service',
              _connectionResults!['config'] ?? false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResult(String service, bool success) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacingXs),
      child: Row(
        children: [
          Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? context.successColor : context.errorColor,
            size: 20,
          ),
          SizedBox(width: context.spacingSm),
          Text(service),
          const Spacer(),
          Text(
            success ? 'Conectado' : 'Falha',
            style: TextStyle(
              color: success ? context.successColor : context.errorColor,
              fontWeight: context.fontWeightBold,
            ),
          ),
        ],
      ),
    );
  }

  void _updateConfig({
    bool? apiUseHttps,
    bool? autoConnect,
    bool? enableHeartbeat,
    int? heartbeatInterval,
    int? heartbeatTimeout,
  }) {
    final current = ref.read(settingsProvider);
    final updated = current.copyWith(
      apiUseHttps: apiUseHttps ?? current.apiUseHttps,
      autoConnect: autoConnect ?? current.autoConnect,
      enableHeartbeat: enableHeartbeat ?? current.enableHeartbeat,
      heartbeatInterval: heartbeatInterval ?? current.heartbeatInterval,
      heartbeatTimeout: heartbeatTimeout ?? current.heartbeatTimeout,
    );

    ref.read(settingsProvider.notifier).updateConfig(updated);
  }

  Future<void> _testConnections() async {
    setState(() {
      _isTestingConnections = true;
      _connectionResults = null;
    });

    AppLogger.userAction('Test connections');

    // Salvar configurações temporariamente para testar
    await _saveConfiguration(showMessage: false);

    final results = await ref.read(settingsProvider.notifier).testConnections();

    setState(() {
      _isTestingConnections = false;
      _connectionResults = results;
    });

    final allSuccess = results.values.every((success) => success);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            allSuccess
                ? 'Todos os serviços estão conectados!'
                : 'Alguns serviços não estão acessíveis',
          ),
          backgroundColor: allSuccess
              ? context.successColor
              : context.warningColor,
        ),
      );
    }
  }

  Future<void> _saveConfiguration({bool showMessage = true}) async {
    if (!_formKey.currentState!.validate()) return;

    AppLogger.userAction('Save configuration');

    final config = ref
        .read(settingsProvider)
        .copyWith(
          apiHost: _apiHostController.text,
          apiPort: int.parse(_apiPortController.text),
        );

    final success = await ref
        .read(settingsProvider.notifier)
        .saveConfig(config);

    if (showMessage && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Configurações salvas com sucesso!'
                : 'Erro ao salvar configurações',
          ),
          backgroundColor: success ? context.successColor : context.errorColor,
        ),
      );
    }
  }

  Future<void> _resetToDefaults() async {
    AppLogger.userAction('Reset to defaults');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Padrões'),
        content: const Text(
          'Isso irá restaurar todas as configurações para os valores padrão. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.warningColor,
            ),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(settingsProvider.notifier).resetToDefaults();
      _initControllers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configurações restauradas para os padrões'),
          ),
        );
      }
    }
  }
}
