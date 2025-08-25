import 'package:autocore_app/core/utils/logger.dart';

/// Serviço para mapear board_id para UUID de dispositivos
///
/// Responsável por:
/// - Mapear IDs numéricos de placas para UUIDs de dispositivos
/// - Fornecer informações sobre dispositivos
/// - Validar se dispositivos estão disponíveis
class DeviceMappingService {
  static DeviceMappingService? _instance;
  static DeviceMappingService get instance =>
      _instance ??= DeviceMappingService._();

  DeviceMappingService._();

  /// Mapeamento de board_id para UUID de dispositivos
  ///
  /// **IMPORTANTE**: Este mapeamento deve corresponder exatamente aos
  /// dispositivos configurados no backend AutoCore Config-App
  static const Map<int, DeviceInfo> _boardToDevice = {
    1: DeviceInfo(
      uuid: 'esp32-relay-001',
      name: 'Relés Principais',
      type: 'esp32-relay',
      channelCount: 8,
      description: 'Placa principal de relés para controles essenciais',
    ),
    2: DeviceInfo(
      uuid: 'esp32-relay-002',
      name: 'Relés Auxiliares',
      type: 'esp32-relay',
      channelCount: 8,
      description: 'Placa auxiliar para controles adicionais',
    ),
    3: DeviceInfo(
      uuid: 'esp32-relay-003',
      name: 'Relés de Força',
      type: 'esp32-relay',
      channelCount: 4,
      description: 'Placa para controles de alta corrente (guincho, partida)',
    ),
    4: DeviceInfo(
      uuid: 'esp32-io-001',
      name: 'E/S Digitais',
      type: 'esp32-io',
      channelCount: 16,
      description: 'Placa de entradas e saídas digitais',
    ),
    5: DeviceInfo(
      uuid: 'esp32-analog-001',
      name: 'Entradas Analógicas',
      type: 'esp32-analog',
      channelCount: 8,
      description: 'Placa para leituras analógicas (sensores, bateria)',
    ),
  };

  /// Obtém UUID do dispositivo baseado no board_id
  String? getDeviceUuid(int boardId) {
    final device = _boardToDevice[boardId];
    if (device == null) {
      AppLogger.warning('Board ID não encontrado no mapeamento: $boardId');
      return null;
    }

    AppLogger.debug('Mapeamento board_id $boardId -> ${device.uuid}');
    return device.uuid;
  }

  /// Obtém informações completas do dispositivo
  DeviceInfo? getDeviceInfo(int boardId) {
    final device = _boardToDevice[boardId];
    if (device == null) {
      AppLogger.warning('Board ID não encontrado: $boardId');
    }
    return device;
  }

  /// Obtém UUID do dispositivo ou lança exceção se não encontrado
  String getDeviceUuidOrThrow(int boardId) {
    final uuid = getDeviceUuid(boardId);
    if (uuid == null) {
      throw Exception('Dispositivo não encontrado para board_id: $boardId');
    }
    return uuid;
  }

  /// Valida se um board_id é válido
  bool isValidBoardId(int boardId) {
    return _boardToDevice.containsKey(boardId);
  }

  /// Valida se um channel é válido para o board_id
  bool isValidChannel(int boardId, int channel) {
    final device = _boardToDevice[boardId];
    if (device == null) return false;

    return channel >= 1 && channel <= device.channelCount;
  }

  /// Obtém todos os dispositivos disponíveis
  Map<int, DeviceInfo> getAllDevices() {
    return Map<int, DeviceInfo>.from(_boardToDevice);
  }

  /// Obtém todos os UUIDs de dispositivos
  List<String> getAllDeviceUuids() {
    return _boardToDevice.values.map((device) => device.uuid).toList();
  }

  /// Encontra board_id pelo UUID (busca reversa)
  int? findBoardIdByUuid(String uuid) {
    for (final entry in _boardToDevice.entries) {
      if (entry.value.uuid == uuid) {
        return entry.key;
      }
    }
    return null;
  }

  /// Valida combinação board_id + channel e retorna informações
  ValidationResult validateBoardChannel(int boardId, int channel) {
    final device = _boardToDevice[boardId];

    if (device == null) {
      return ValidationResult(
        isValid: false,
        error: 'Board ID $boardId não existe no mapeamento',
      );
    }

    if (channel < 1 || channel > device.channelCount) {
      return ValidationResult(
        isValid: false,
        error:
            'Canal $channel inválido para ${device.name} (máximo: ${device.channelCount})',
      );
    }

    return ValidationResult(
      isValid: true,
      deviceInfo: device,
      topic: 'autocore/devices/${device.uuid}/relays/set',
    );
  }

  /// Obtém tópico MQTT para comandos de um dispositivo
  String getCommandTopic(int boardId, {String command = 'set'}) {
    final uuid = getDeviceUuidOrThrow(boardId);
    return 'autocore/devices/$uuid/relays/$command';
  }

  /// Obtém tópico MQTT para heartbeat de um dispositivo
  String getHeartbeatTopic(int boardId) {
    return getCommandTopic(boardId, command: 'heartbeat');
  }

  /// Obtém tópico MQTT para status de um dispositivo
  String getStatusTopic(int boardId) {
    final uuid = getDeviceUuidOrThrow(boardId);
    return 'autocore/devices/$uuid/status';
  }
}

/// Informações de um dispositivo
class DeviceInfo {
  final String uuid;
  final String name;
  final String type;
  final int channelCount;
  final String description;

  const DeviceInfo({
    required this.uuid,
    required this.name,
    required this.type,
    required this.channelCount,
    required this.description,
  });

  @override
  String toString() =>
      'DeviceInfo(uuid: $uuid, name: $name, channels: $channelCount)';

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'name': name,
    'type': type,
    'channel_count': channelCount,
    'description': description,
  };
}

/// Resultado da validação de board_id + channel
class ValidationResult {
  final bool isValid;
  final String? error;
  final DeviceInfo? deviceInfo;
  final String? topic;

  const ValidationResult({
    required this.isValid,
    this.error,
    this.deviceInfo,
    this.topic,
  });

  @override
  String toString() {
    if (isValid) {
      return 'ValidationResult(valid: ${deviceInfo?.name})';
    } else {
      return 'ValidationResult(invalid: $error)';
    }
  }
}
