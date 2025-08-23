# A15 - Config Models Implementation

## 📋 Objetivo
Implementar todos os models necessários para consumir o endpoint `/api/config/full/{device_uuid}` com 100% de conformidade.

## 🎯 Models a Implementar

### 1. ConfigFullResponse (Principal)
```dart
// lib/core/models/config_full_response.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'config_full_response.freezed.dart';
part 'config_full_response.g.dart';

@freezed
class ConfigFullResponse with _$ConfigFullResponse {
  const factory ConfigFullResponse({
    required String version,
    @JsonKey(name: 'protocol_version') required String protocolVersion,
    required DateTime timestamp,
    required ApiDeviceInfo device,
    required SystemConfig system,
    required List<ApiScreenConfig> screens,
    required List<ApiDevice> devices,
    @JsonKey(name: 'relay_boards') required List<RelayBoardInfo> relayBoards,
    required ThemeConfig theme,
    Map<String, dynamic>? telemetry,
    @JsonKey(name: 'preview_mode') @Default(false) bool previewMode,
  }) = _ConfigFullResponse;

  factory ConfigFullResponse.fromJson(Map<String, dynamic> json) =>
      _$ConfigFullResponseFromJson(json);
}
```

### 2. ApiDeviceInfo
```dart
// lib/core/models/api_device_info.dart
@freezed
class ApiDeviceInfo with _$ApiDeviceInfo {
  const factory ApiDeviceInfo({
    required int id,
    required String uuid,
    required String type,
    required String name,
    required String status,
    @JsonKey(name: 'ip_address') String? ipAddress,
    @JsonKey(name: 'mac_address') String? macAddress,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _ApiDeviceInfo;

  factory ApiDeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$ApiDeviceInfoFromJson(json);
}
```

### 3. SystemConfig
```dart
// lib/core/models/system_config.dart
@freezed
class SystemConfig with _$SystemConfig {
  const factory SystemConfig({
    required String name,
    required String language,
    String? version,
    Map<String, dynamic>? mqtt,
    Map<String, dynamic>? network,
    Map<String, dynamic>? hardware,
  }) = _SystemConfig;

  factory SystemConfig.fromJson(Map<String, dynamic> json) =>
      _$SystemConfigFromJson(json);
}
```

### 4. ApiScreenConfig
```dart
// lib/core/models/api_screen_config.dart
@freezed
class ApiScreenConfig with _$ApiScreenConfig {
  const factory ApiScreenConfig({
    required int id,
    required String name,
    required String title,
    required String icon,
    @JsonKey(name: 'screen_type') required String screenType,
    required int position,
    @JsonKey(name: 'columns_display_small') @Default(2) int columnsDisplaySmall,
    @JsonKey(name: 'columns_display_large') @Default(3) int columnsDisplayLarge,
    @JsonKey(name: 'is_visible') @Default(true) bool isVisible,
    @JsonKey(name: 'show_on_display_small') @Default(true) bool showOnDisplaySmall,
    @JsonKey(name: 'show_on_display_large') @Default(true) bool showOnDisplayLarge,
    required List<ApiScreenItem> items,
  }) = _ApiScreenConfig;

  factory ApiScreenConfig.fromJson(Map<String, dynamic> json) =>
      _$ApiScreenConfigFromJson(json);
}
```

### 5. ApiScreenItem
```dart
// lib/core/models/api_screen_item.dart
@freezed
class ApiScreenItem with _$ApiScreenItem {
  const factory ApiScreenItem({
    required int id,
    @JsonKey(name: 'item_type') required String itemType,
    required String name,
    required String label,
    required String icon,
    required int position,
    @JsonKey(name: 'action_type') String? actionType,
    @JsonKey(name: 'relay_board_id') int? relayBoardId,
    @JsonKey(name: 'relay_channel_id') int? relayChannelId,
    @JsonKey(name: 'relay_board') RelayBoardInfo? relayBoard,
    @JsonKey(name: 'relay_channel') RelayChannelInfo? relayChannel,
    @JsonKey(name: 'display_format') String? displayFormat,
    @JsonKey(name: 'value_source') String? valueSource,
    String? unit,
    @JsonKey(name: 'min_value') double? minValue,
    @JsonKey(name: 'max_value') double? maxValue,
    @JsonKey(name: 'color_ranges') List<ColorRange>? colorRanges,
    @JsonKey(name: 'action_config') Map<String, dynamic>? actionConfig,
    @JsonKey(name: 'gauge_config') Map<String, dynamic>? gaugeConfig,
    @JsonKey(name: 'display_config') Map<String, dynamic>? displayConfig,
  }) = _ApiScreenItem;

  factory ApiScreenItem.fromJson(Map<String, dynamic> json) =>
      _$ApiScreenItemFromJson(json);
}
```

### 6. RelayBoardInfo
```dart
// lib/core/models/relay_board_info.dart
@freezed
class RelayBoardInfo with _$RelayBoardInfo {
  const factory RelayBoardInfo({
    required int id,
    @JsonKey(name: 'device_id') required int deviceId,
    @JsonKey(name: 'device_uuid') String? deviceUuid,
    @JsonKey(name: 'device_name') String? deviceName,
    @JsonKey(name: 'device_ip') String? deviceIp,
    @JsonKey(name: 'total_channels') required int totalChannels,
    @JsonKey(name: 'board_model') String? boardModel,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _RelayBoardInfo;

  factory RelayBoardInfo.fromJson(Map<String, dynamic> json) =>
      _$RelayBoardInfoFromJson(json);
}
```

### 7. RelayChannelInfo
```dart
// lib/core/models/relay_channel_info.dart
@freezed
class RelayChannelInfo with _$RelayChannelInfo {
  const factory RelayChannelInfo({
    required int id,
    @JsonKey(name: 'channel_number') required int channelNumber,
    required String name,
    String? description,
    @JsonKey(name: 'function_type') required String functionType,
    String? icon,
    String? color,
    @JsonKey(name: 'protection_mode') String? protectionMode,
    @JsonKey(name: 'default_state') @Default(false) bool defaultState,
  }) = _RelayChannelInfo;

  factory RelayChannelInfo.fromJson(Map<String, dynamic> json) =>
      _$RelayChannelInfoFromJson(json);
}
```

### 8. ThemeConfig
```dart
// lib/core/models/theme_config.dart
@freezed
class ThemeConfig with _$ThemeConfig {
  const factory ThemeConfig({
    required int id,
    required String name,
    @JsonKey(name: 'primary_color') required String primaryColor,
    @JsonKey(name: 'secondary_color') required String secondaryColor,
    @JsonKey(name: 'background_color') required String backgroundColor,
    @JsonKey(name: 'surface_color') required String surfaceColor,
    @JsonKey(name: 'text_primary') required String textPrimary,
    @JsonKey(name: 'text_secondary') required String textSecondary,
    @JsonKey(name: 'error_color') required String errorColor,
    @JsonKey(name: 'warning_color') required String warningColor,
    @JsonKey(name: 'success_color') required String successColor,
    @JsonKey(name: 'info_color') required String infoColor,
  }) = _ThemeConfig;

  factory ThemeConfig.fromJson(Map<String, dynamic> json) =>
      _$ThemeConfigFromJson(json);
}
```

### 9. ColorRange
```dart
// lib/core/models/color_range.dart
@freezed
class ColorRange with _$ColorRange {
  const factory ColorRange({
    required double min,
    required double max,
    required String color,
  }) = _ColorRange;

  factory ColorRange.fromJson(Map<String, dynamic> json) =>
      _$ColorRangeFromJson(json);
}
```

### 10. TelemetryData
```dart
// lib/core/models/telemetry_data.dart
@freezed
class TelemetryData with _$TelemetryData {
  const factory TelemetryData({
    double? speed,
    double? rpm,
    @JsonKey(name: 'engine_temp') double? engineTemp,
    @JsonKey(name: 'oil_pressure') double? oilPressure,
    @JsonKey(name: 'fuel_level') double? fuelLevel,
    @JsonKey(name: 'battery_voltage') double? batteryVoltage,
    @JsonKey(name: 'intake_temp') double? intakeTemp,
    @JsonKey(name: 'boost_pressure') double? boostPressure,
    double? lambda,
    double? tps,
    double? ethanol,
    int? gear,
    DateTime? timestamp,
    // Adicionar campos conforme necessário
  }) = _TelemetryData;

  factory TelemetryData.fromJson(Map<String, dynamic> json) =>
      _$TelemetryDataFromJson(json);
      
  factory TelemetryData.fromDynamic(Map<String, dynamic> json) {
    // Parser flexível para telemetria dinâmica
    return TelemetryData(
      speed: _parseDouble(json['speed']),
      rpm: _parseDouble(json['rpm']),
      engineTemp: _parseDouble(json['engine_temp']),
      oilPressure: _parseDouble(json['oil_pressure']),
      fuelLevel: _parseDouble(json['fuel_level']),
      batteryVoltage: _parseDouble(json['battery_voltage']),
      intakeTemp: _parseDouble(json['intake_temp']),
      boostPressure: _parseDouble(json['boost_pressure']),
      lambda: _parseDouble(json['lambda']),
      tps: _parseDouble(json['tps']),
      ethanol: _parseDouble(json['ethanol']),
      gear: _parseInt(json['gear']),
      timestamp: DateTime.now(),
    );
  }
  
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
  
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
```

## ✅ Checklist de Implementação

- [ ] Criar arquivo para cada model
- [ ] Adicionar imports do freezed
- [ ] Implementar serialização JSON
- [ ] Adicionar validações onde necessário
- [ ] Criar factory methods auxiliares
- [ ] Documentar campos complexos
- [ ] Gerar código com build_runner
- [ ] Testar parsing com JSON da API

## 🚀 Comandos de Execução

```bash
# 1. Criar estrutura de arquivos
mkdir -p lib/core/models/api
cd lib/core/models/api

# 2. Criar cada arquivo model
touch config_full_response.dart
touch api_device_info.dart
touch system_config.dart
touch api_screen_config.dart
touch api_screen_item.dart
touch relay_board_info.dart
touch relay_channel_info.dart
touch theme_config.dart
touch color_range.dart
touch telemetry_data.dart

# 3. Gerar código freezed
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Verificar compilação
flutter analyze
```

## 📊 Resultado Esperado

Após implementação:
- ✅ 10 models criados com freezed
- ✅ Serialização JSON funcionando
- ✅ 100% de conformidade com API
- ✅ Type safety garantido
- ✅ Parsing robusto de telemetria

---

**Prioridade**: P0 - CRÍTICO
**Tempo estimado**: 2-3 horas
**Dependências**: freezed, json_annotation