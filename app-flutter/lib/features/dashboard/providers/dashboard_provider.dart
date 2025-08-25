import 'dart:async';

import 'package:autocore_app/core/models/api/config_full_response.dart';
import 'package:autocore_app/core/utils/logger.dart';
import 'package:autocore_app/infrastructure/services/api_service.dart';
import 'package:autocore_app/infrastructure/services/config_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider do estado do dashboard
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      return DashboardNotifier();
    });

// Estado do Dashboard
class DashboardState {
  final bool isLoading;
  final ConfigFullResponse? config;
  final Map<String, dynamic> systemStatus;
  final DateTime? lastUpdate;
  final String? error;

  DashboardState({
    this.isLoading = false,
    this.config,
    this.systemStatus = const {},
    this.lastUpdate,
    this.error,
  });

  DashboardState copyWith({
    bool? isLoading,
    ConfigFullResponse? config,
    Map<String, dynamic>? systemStatus,
    DateTime? lastUpdate,
    String? error,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      config: config ?? this.config,
      systemStatus: systemStatus ?? this.systemStatus,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      error: error,
    );
  }
}

// Notifier do Dashboard
class DashboardNotifier extends StateNotifier<DashboardState> {
  late final ApiService _apiService;
  late final ConfigService _configService;
  Timer? _refreshTimer;

  // UUID do dispositivo fixo
  static const String _deviceUuid = '8e67eb62-57c9-4e11-9772-f7fd7065199f';

  DashboardNotifier() : super(DashboardState()) {
    _apiService = ApiService.instance;
    _configService = ConfigService.instance;
    // Agendar carregamento inicial para não modificar estado durante build
    Future.microtask(() {
      loadData();
      _startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refreshData();
    });
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Carregando configuração completa do dashboard');

      // Carregar configuração completa
      final config = await _configService.getFullConfig(
        deviceUuid: _deviceUuid,
      );

      // Tentar carregar status do sistema (opcional)
      Map<String, dynamic> systemStatus = {};
      try {
        systemStatus = await _apiService.getSystemStatus();
      } catch (e) {
        AppLogger.warning('Não foi possível carregar status do sistema: $e');
        // Continua sem status - não é crítico
      }

      state = state.copyWith(
        isLoading: false,
        config: config,
        systemStatus: systemStatus,
        lastUpdate: DateTime.now(),
      );

      AppLogger.info(
        'Dashboard carregado com sucesso - ${config.screens.length} telas',
      );
    } catch (e) {
      AppLogger.error('Erro ao carregar dashboard', error: e);

      // Sem dados mockados - apenas mostra erro
      state = state.copyWith(
        isLoading: false,
        error:
            'Não foi possível carregar os dados da API. Verifique a conexão.',
        lastUpdate: DateTime.now(),
      );
    }
  }

  Future<void> refreshData() async {
    if (state.isLoading) return;

    try {
      final status = await _apiService.getSystemStatus();
      state = state.copyWith(systemStatus: status, lastUpdate: DateTime.now());
    } catch (e) {
      AppLogger.debug('Auto-refresh falhou: $e');
    }
  }

  Future<bool> executeMacro(int macroId) async {
    try {
      final command = {
        'type': 'macro_execute',
        'macro_id': macroId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final success = await _apiService.executeCommand(command);

      if (success) {
        AppLogger.userAction('Macro executada', params: {'macroId': macroId});
      }

      return success;
    } catch (e) {
      AppLogger.error('Erro ao executar macro', error: e);
      return false;
    }
  }

  Future<bool> executeButton(String screenId, String buttonId) async {
    try {
      final command = {
        'type': 'button_press',
        'screen_id': screenId,
        'button_id': buttonId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final success = await _apiService.executeCommand(command);

      if (success) {
        AppLogger.userAction(
          'Botão executado',
          params: {'screenId': screenId, 'buttonId': buttonId},
        );
      }

      return success;
    } catch (e) {
      AppLogger.error('Erro ao executar botão', error: e);
      return false;
    }
  }
}
