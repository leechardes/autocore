import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_device_info.freezed.dart';
part 'api_device_info.g.dart';

@freezed
class ApiDeviceInfo with _$ApiDeviceInfo {
  const factory ApiDeviceInfo({
    @JsonKey(name: 'uuid') required String uuid,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'firmware_version') required String firmwareVersion,
    @JsonKey(name: 'hardware_version') required String hardwareVersion,
    @JsonKey(name: 'ip_address') required String ipAddress,
    @JsonKey(name: 'mac_address') required String macAddress,
    @JsonKey(name: 'mqtt_broker') required String mqttBroker,
    @JsonKey(name: 'mqtt_port') required int mqttPort,
    @JsonKey(name: 'mqtt_client_id') required String mqttClientId,
    @JsonKey(name: 'api_base_url') required String apiBaseUrl,
    @JsonKey(name: 'device_type') required String deviceType,
    @JsonKey(name: 'timezone') String? timezone,
    @JsonKey(name: 'location') String? location,
  }) = _ApiDeviceInfo;

  factory ApiDeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$ApiDeviceInfoFromJson(json);
}
