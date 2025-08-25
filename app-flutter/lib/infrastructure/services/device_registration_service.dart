import 'dart:io';

import 'package:autocore_app/core/constants/api_endpoints.dart';
import 'package:autocore_app/core/constants/device_constants.dart';
import 'package:autocore_app/core/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço de auto-registro de dispositivo Flutter
///
/// Usa o UUID fixo registrado no backend ao invés de gerar um novo
class DeviceRegistrationService {
  static DeviceRegistrationService? _instance;
  static DeviceRegistrationService get instance =>
      _instance ??= DeviceRegistrationService._internal();

  DeviceRegistrationService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  late final Dio _dio;
  // Usa UUID fixo do DeviceConstants
  String _deviceUuid = DeviceConstants.deviceUuid;

  /// Verifica e registra o dispositivo se necessário
  ///
  /// Retorna o UUID fixo do dispositivo
  Future<String> checkAndRegister() async {
    try {
      AppLogger.info('🔍 Iniciando verificação de registro do dispositivo');
      AppLogger.info('📱 UUID fixo do dispositivo: $_deviceUuid');

      return _deviceUuid;
    } catch (e) {
      AppLogger.error('❌ Erro no processo de verificação/registro', error: e);
      rethrow;
    }
  }

  /// Retorna o UUID fixo do dispositivo
  String getDeviceUuid() {
    return _deviceUuid;
  }

  /// Verifica se o dispositivo está registrado na API
  Future<bool> isDeviceRegistered(String uuid) async {
    try {
      AppLogger.info('🔍 Verificando se dispositivo está registrado: $uuid');

      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.deviceByUuid(uuid),
        options: Options(
          validateStatus: (status) => status == 200 || status == 404,
        ),
      );

      if (response.statusCode == 200) {
        AppLogger.info('✅ Dispositivo já está registrado');
        return true;
      } else if (response.statusCode == 404) {
        AppLogger.info('⚠️ Dispositivo não encontrado, precisa registrar');
        return false;
      }

      AppLogger.warning('⚠️ Resposta inesperada: ${response.statusCode}');
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        AppLogger.info('⚠️ Dispositivo não encontrado (404)');
        return false;
      }

      AppLogger.error('❌ Erro ao verificar registro do dispositivo', error: e);
      return false; // Assume não registrado em caso de erro
    } catch (e) {
      AppLogger.error('❌ Erro inesperado ao verificar registro', error: e);
      return false;
    }
  }

  /// Registra o dispositivo na API
  Future<bool> registerDevice([String? uuid]) async {
    try {
      final deviceUuid = uuid ?? DeviceConstants.deviceUuid;
      AppLogger.info('📝 Registrando dispositivo: $deviceUuid');

      final deviceData = await _buildDeviceRegistrationData(deviceUuid);

      // ===== LOGS DETALHADOS PARA DEBUG =====
      AppLogger.info('🔍 [DEBUG] UUID sendo enviado: $deviceUuid');
      AppLogger.info(
        '🔍 [DEBUG] URL da requisição: ${ApiEndpoints.baseUrl}${ApiEndpoints.devices}',
      );
      AppLogger.info('🔍 [DEBUG] Payload COMPLETO sendo enviado:');
      AppLogger.info('📋 ${deviceData.toString()}');
      // =====================================

      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.devices,
        data: deviceData,
        options: Options(
          validateStatus: (status) =>
              status == 201 || status == 409 || status == 500,
        ),
      );

      // ===== LOGS DE RESPOSTA DETALHADOS =====
      AppLogger.info('🔍 [DEBUG] Status Code recebido: ${response.statusCode}');
      AppLogger.info(
        '🔍 [DEBUG] Headers da resposta: ${response.headers.toString()}',
      );
      AppLogger.info(
        '🔍 [DEBUG] Response Data: ${response.data?.toString() ?? "null"}',
      );
      // =======================================

      if (response.statusCode == 201) {
        AppLogger.info('✅ Dispositivo registrado com sucesso');
        await _markAsRegistered();
        return true;
      } else if (response.statusCode == 409) {
        AppLogger.info('✅ Dispositivo já existia (409 tratado como sucesso)');
        await _markAsRegistered();
        return true;
      } else if (response.statusCode == 500) {
        AppLogger.error('❌ [DEBUG] ERRO 500 CAPTURADO!');
        AppLogger.error(
          '❌ [DEBUG] Response Body: ${response.data?.toString()}',
        );
        return false;
      }

      AppLogger.error('❌ Falha no registro: ${response.statusCode}');
      return false;
    } on DioException catch (e) {
      // ===== LOGS DETALHADOS DE DioException =====
      AppLogger.error('❌ [DEBUG] DioException capturada!');
      AppLogger.error('❌ [DEBUG] Status Code: ${e.response?.statusCode}');
      AppLogger.error(
        '❌ [DEBUG] Response Data: ${e.response?.data?.toString()}',
      );
      AppLogger.error(
        '❌ [DEBUG] Request Data: ${e.requestOptions.data?.toString()}',
      );
      AppLogger.error('❌ [DEBUG] Error Message: ${e.message}');
      // ==========================================

      if (e.response?.statusCode == 409) {
        AppLogger.info(
          '✅ Dispositivo já existe (409 - conflito tratado como sucesso)',
        );
        await _markAsRegistered();
        return true;
      }

      if (e.response?.statusCode == 500) {
        AppLogger.error('❌ [DEBUG] ERRO 500 CAPTURADO NO CATCH!');
        AppLogger.error('❌ [DEBUG] Detalhes: ${e.response?.data}');
      }

      AppLogger.error('❌ Erro Dio ao registrar dispositivo', error: e);
      return false;
    } catch (e) {
      AppLogger.error('❌ Erro inesperado ao registrar dispositivo', error: e);
      return false;
    }
  }

  /// Constrói os dados para registro do dispositivo
  Future<Map<String, dynamic>> _buildDeviceRegistrationData(String uuid) async {
    // Obtém informações da plataforma
    final platform = defaultTargetPlatform.name.toLowerCase();
    final version = await _getAppVersion();
    final ipAddress = await _getLocalIpAddress();
    final macAddress = _generateMacFromUuid(uuid);

    return {
      'uuid': uuid,
      'name': DeviceConstants.deviceName,
      'type': DeviceConstants.deviceType,
      'mac_address': macAddress,
      'ip_address': ipAddress,
      'firmware_version': version,
      'hardware_version': DeviceConstants.hardwareVersion,
      'location': DeviceConstants.defaultLocation,
      'configuration': {
        ...DeviceConstants.defaultConfiguration,
        'os': platform,
      },
      'capabilities': DeviceConstants.capabilities,
    };
  }

  /// Gera um MAC address baseado no UUID para compatibilidade
  String _generateMacFromUuid(String uuid) {
    // Remove hífens e pega os primeiros 12 caracteres
    final cleanUuid = uuid.replaceAll('-', '');
    final macPart = cleanUuid.substring(0, 12);

    // Formata como MAC address
    final buffer = StringBuffer();
    for (int i = 0; i < macPart.length; i += 2) {
      if (i > 0) buffer.write(':');
      buffer.write(macPart.substring(i, i + 2));
    }

    return buffer.toString().toLowerCase();
  }

  /// Obtém a versão do app do pubspec.yaml
  Future<String> _getAppVersion() async {
    try {
      // Em produção, isso seria obtido de package_info_plus
      // Por enquanto, retorna versão fixa
      return '1.0.0';
    } catch (e) {
      AppLogger.warning('⚠️ Não foi possível obter versão do app', error: e);
      return '1.0.0';
    }
  }

  /// Obtém o IP local do dispositivo
  Future<String> _getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback) {
            AppLogger.debug('📡 IP local encontrado: ${addr.address}');
            return addr.address;
          }
        }
      }
    } catch (e) {
      AppLogger.warning('⚠️ Não foi possível obter IP local', error: e);
    }

    return '0.0.0.0';
  }

  /// Marca o dispositivo como registrado no storage local
  Future<void> _markAsRegistered() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(DeviceConstants.registrationStatusKey, true);
      AppLogger.debug('✅ Dispositivo marcado como registrado no storage');
    } catch (e) {
      AppLogger.error('❌ Erro ao marcar como registrado', error: e);
    }
  }

  /// Verifica se está marcado como registrado localmente
  Future<bool> isMarkedAsRegistered() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(DeviceConstants.registrationStatusKey) ?? false;
    } catch (e) {
      AppLogger.error('❌ Erro ao verificar status de registro local', error: e);
      return false;
    }
  }

  /// Obtém o UUID atual do dispositivo (se existir)
  Future<String?> getCurrentDeviceUuid() async {
    return _deviceUuid;
  }

  /// Limpa os dados de registro (para testes)
  Future<void> clearRegistrationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(DeviceConstants.deviceUuidKey);
      await prefs.remove(DeviceConstants.registrationStatusKey);
      _deviceUuid = DeviceConstants.deviceUuid;

      AppLogger.info('🧹 Dados de registro limpos (modo teste)');
    } catch (e) {
      AppLogger.error('❌ Erro ao limpar dados de registro', error: e);
    }
  }

  /// Informações de diagnóstico do registro
  Future<Map<String, dynamic>> getRegistrationInfo() async {
    final uuid = await getCurrentDeviceUuid();
    final isMarked = await isMarkedAsRegistered();

    return {
      'has_uuid': uuid != null,
      'uuid': uuid,
      'marked_as_registered': isMarked,
      'service_initialized': _instance != null,
    };
  }
}
