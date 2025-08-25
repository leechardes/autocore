import 'dart:async';

import 'package:autocore_app/app.dart';
import 'package:autocore_app/core/utils/logger.dart';
import 'package:autocore_app/infrastructure/services/config_service.dart';
import 'package:autocore_app/infrastructure/services/device_registration_service.dart';
import 'package:autocore_app/infrastructure/services/mqtt_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.init('AutoCoreApp');

  // Inicializar sistema de auto-registro de dispositivo
  unawaited(_initializeDeviceRegistration());

  // Conectar ao MQTT broker com configuração padrão
  unawaited(_connectMqtt());

  runApp(const ProviderScope(child: AutoCoreApp()));
}

/// Inicializa o sistema de auto-registro do dispositivo
Future<void> _initializeDeviceRegistration() async {
  try {
    AppLogger.info('🚀 Iniciando sistema de auto-registro do dispositivo');

    final registrationService = DeviceRegistrationService.instance;
    final configService = ConfigService.instance;

    // Verifica e gera UUID se necessário
    final deviceUuid = await registrationService.checkAndRegister();
    AppLogger.info('📱 Device UUID: $deviceUuid');

    // Pré-carrega configuração (isso disparará auto-registro se necessário)
    try {
      await configService.preloadConfig(deviceUuid: deviceUuid);
      AppLogger.info('✅ Sistema de auto-registro inicializado com sucesso');
    } catch (e) {
      AppLogger.warning(
        '⚠️ Não foi possível pré-carregar configuração',
        error: e,
      );
      // Continua mesmo sem configuração, será tentada posteriormente
    }

    // Log das informações de diagnóstico
    final regInfo = await registrationService.getRegistrationInfo();
    final cacheInfo = configService.getCacheInfo();

    AppLogger.info('📊 Status do registro: $regInfo');
    AppLogger.info('📦 Status do cache: $cacheInfo');
  } catch (e) {
    AppLogger.error('❌ Erro ao inicializar auto-registro', error: e);
    // Continua mesmo com erro no registro, app deve funcionar offline
  }
}

Future<void> _connectMqtt() async {
  try {
    AppLogger.info('Inicializando conexão MQTT via API');

    // Conectar usando configuração da API
    await MqttService.instance.connect();

    AppLogger.info('Conectado ao MQTT broker com sucesso');
  } catch (e) {
    AppLogger.error('Erro ao conectar ao MQTT', error: e);
    // Continua mesmo sem MQTT, modo offline
  }
}
