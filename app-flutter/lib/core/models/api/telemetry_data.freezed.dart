// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'telemetry_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TelemetryData _$TelemetryDataFromJson(Map<String, dynamic> json) {
  return _TelemetryData.fromJson(json);
}

/// @nodoc
mixin _$TelemetryData {
  @JsonKey(name: 'timestamp')
  DateTime get timestamp => throw _privateConstructorUsedError;
  @JsonKey(name: 'device_uuid')
  String get deviceUuid => throw _privateConstructorUsedError;
  @JsonKey(name: 'sequence')
  int get sequence => throw _privateConstructorUsedError;
  @JsonKey(name: 'data')
  Map<String, dynamic> get data => throw _privateConstructorUsedError;
  @JsonKey(name: 'signal_strength')
  int? get signalStrength => throw _privateConstructorUsedError;
  @JsonKey(name: 'battery_level')
  double? get batteryLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'temperature')
  double? get temperature => throw _privateConstructorUsedError;
  @JsonKey(name: 'humidity')
  double? get humidity => throw _privateConstructorUsedError;
  @JsonKey(name: 'pressure')
  double? get pressure => throw _privateConstructorUsedError;
  @JsonKey(name: 'relay_states')
  Map<String, bool>? get relayStates => throw _privateConstructorUsedError;
  @JsonKey(name: 'sensor_values')
  Map<String, double>? get sensorValues => throw _privateConstructorUsedError;
  @JsonKey(name: 'system_status')
  String? get systemStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'error_codes')
  List<String>? get errorCodes => throw _privateConstructorUsedError;
  @JsonKey(name: 'uptime')
  int? get uptime => throw _privateConstructorUsedError; // Em segundos
  @JsonKey(name: 'memory_usage')
  double? get memoryUsage => throw _privateConstructorUsedError; // Percentual
  @JsonKey(name: 'cpu_usage')
  double? get cpuUsage => throw _privateConstructorUsedError; // Percentual
  @JsonKey(name: 'network_status')
  String? get networkStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'wifi_strength')
  int? get wifiStrength => throw _privateConstructorUsedError;
  @JsonKey(name: 'gps_coordinates')
  Map<String, double>? get gpsCoordinates => throw _privateConstructorUsedError;
  @JsonKey(name: 'raw_payload')
  String? get rawPayload => throw _privateConstructorUsedError;

  /// Serializes this TelemetryData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TelemetryData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TelemetryDataCopyWith<TelemetryData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TelemetryDataCopyWith<$Res> {
  factory $TelemetryDataCopyWith(
    TelemetryData value,
    $Res Function(TelemetryData) then,
  ) = _$TelemetryDataCopyWithImpl<$Res, TelemetryData>;
  @useResult
  $Res call({
    @JsonKey(name: 'timestamp') DateTime timestamp,
    @JsonKey(name: 'device_uuid') String deviceUuid,
    @JsonKey(name: 'sequence') int sequence,
    @JsonKey(name: 'data') Map<String, dynamic> data,
    @JsonKey(name: 'signal_strength') int? signalStrength,
    @JsonKey(name: 'battery_level') double? batteryLevel,
    @JsonKey(name: 'temperature') double? temperature,
    @JsonKey(name: 'humidity') double? humidity,
    @JsonKey(name: 'pressure') double? pressure,
    @JsonKey(name: 'relay_states') Map<String, bool>? relayStates,
    @JsonKey(name: 'sensor_values') Map<String, double>? sensorValues,
    @JsonKey(name: 'system_status') String? systemStatus,
    @JsonKey(name: 'error_codes') List<String>? errorCodes,
    @JsonKey(name: 'uptime') int? uptime,
    @JsonKey(name: 'memory_usage') double? memoryUsage,
    @JsonKey(name: 'cpu_usage') double? cpuUsage,
    @JsonKey(name: 'network_status') String? networkStatus,
    @JsonKey(name: 'wifi_strength') int? wifiStrength,
    @JsonKey(name: 'gps_coordinates') Map<String, double>? gpsCoordinates,
    @JsonKey(name: 'raw_payload') String? rawPayload,
  });
}

/// @nodoc
class _$TelemetryDataCopyWithImpl<$Res, $Val extends TelemetryData>
    implements $TelemetryDataCopyWith<$Res> {
  _$TelemetryDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TelemetryData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? deviceUuid = null,
    Object? sequence = null,
    Object? data = null,
    Object? signalStrength = freezed,
    Object? batteryLevel = freezed,
    Object? temperature = freezed,
    Object? humidity = freezed,
    Object? pressure = freezed,
    Object? relayStates = freezed,
    Object? sensorValues = freezed,
    Object? systemStatus = freezed,
    Object? errorCodes = freezed,
    Object? uptime = freezed,
    Object? memoryUsage = freezed,
    Object? cpuUsage = freezed,
    Object? networkStatus = freezed,
    Object? wifiStrength = freezed,
    Object? gpsCoordinates = freezed,
    Object? rawPayload = freezed,
  }) {
    return _then(
      _value.copyWith(
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            deviceUuid: null == deviceUuid
                ? _value.deviceUuid
                : deviceUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            sequence: null == sequence
                ? _value.sequence
                : sequence // ignore: cast_nullable_to_non_nullable
                      as int,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            signalStrength: freezed == signalStrength
                ? _value.signalStrength
                : signalStrength // ignore: cast_nullable_to_non_nullable
                      as int?,
            batteryLevel: freezed == batteryLevel
                ? _value.batteryLevel
                : batteryLevel // ignore: cast_nullable_to_non_nullable
                      as double?,
            temperature: freezed == temperature
                ? _value.temperature
                : temperature // ignore: cast_nullable_to_non_nullable
                      as double?,
            humidity: freezed == humidity
                ? _value.humidity
                : humidity // ignore: cast_nullable_to_non_nullable
                      as double?,
            pressure: freezed == pressure
                ? _value.pressure
                : pressure // ignore: cast_nullable_to_non_nullable
                      as double?,
            relayStates: freezed == relayStates
                ? _value.relayStates
                : relayStates // ignore: cast_nullable_to_non_nullable
                      as Map<String, bool>?,
            sensorValues: freezed == sensorValues
                ? _value.sensorValues
                : sensorValues // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>?,
            systemStatus: freezed == systemStatus
                ? _value.systemStatus
                : systemStatus // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorCodes: freezed == errorCodes
                ? _value.errorCodes
                : errorCodes // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            uptime: freezed == uptime
                ? _value.uptime
                : uptime // ignore: cast_nullable_to_non_nullable
                      as int?,
            memoryUsage: freezed == memoryUsage
                ? _value.memoryUsage
                : memoryUsage // ignore: cast_nullable_to_non_nullable
                      as double?,
            cpuUsage: freezed == cpuUsage
                ? _value.cpuUsage
                : cpuUsage // ignore: cast_nullable_to_non_nullable
                      as double?,
            networkStatus: freezed == networkStatus
                ? _value.networkStatus
                : networkStatus // ignore: cast_nullable_to_non_nullable
                      as String?,
            wifiStrength: freezed == wifiStrength
                ? _value.wifiStrength
                : wifiStrength // ignore: cast_nullable_to_non_nullable
                      as int?,
            gpsCoordinates: freezed == gpsCoordinates
                ? _value.gpsCoordinates
                : gpsCoordinates // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>?,
            rawPayload: freezed == rawPayload
                ? _value.rawPayload
                : rawPayload // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TelemetryDataImplCopyWith<$Res>
    implements $TelemetryDataCopyWith<$Res> {
  factory _$$TelemetryDataImplCopyWith(
    _$TelemetryDataImpl value,
    $Res Function(_$TelemetryDataImpl) then,
  ) = __$$TelemetryDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'timestamp') DateTime timestamp,
    @JsonKey(name: 'device_uuid') String deviceUuid,
    @JsonKey(name: 'sequence') int sequence,
    @JsonKey(name: 'data') Map<String, dynamic> data,
    @JsonKey(name: 'signal_strength') int? signalStrength,
    @JsonKey(name: 'battery_level') double? batteryLevel,
    @JsonKey(name: 'temperature') double? temperature,
    @JsonKey(name: 'humidity') double? humidity,
    @JsonKey(name: 'pressure') double? pressure,
    @JsonKey(name: 'relay_states') Map<String, bool>? relayStates,
    @JsonKey(name: 'sensor_values') Map<String, double>? sensorValues,
    @JsonKey(name: 'system_status') String? systemStatus,
    @JsonKey(name: 'error_codes') List<String>? errorCodes,
    @JsonKey(name: 'uptime') int? uptime,
    @JsonKey(name: 'memory_usage') double? memoryUsage,
    @JsonKey(name: 'cpu_usage') double? cpuUsage,
    @JsonKey(name: 'network_status') String? networkStatus,
    @JsonKey(name: 'wifi_strength') int? wifiStrength,
    @JsonKey(name: 'gps_coordinates') Map<String, double>? gpsCoordinates,
    @JsonKey(name: 'raw_payload') String? rawPayload,
  });
}

/// @nodoc
class __$$TelemetryDataImplCopyWithImpl<$Res>
    extends _$TelemetryDataCopyWithImpl<$Res, _$TelemetryDataImpl>
    implements _$$TelemetryDataImplCopyWith<$Res> {
  __$$TelemetryDataImplCopyWithImpl(
    _$TelemetryDataImpl _value,
    $Res Function(_$TelemetryDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TelemetryData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? deviceUuid = null,
    Object? sequence = null,
    Object? data = null,
    Object? signalStrength = freezed,
    Object? batteryLevel = freezed,
    Object? temperature = freezed,
    Object? humidity = freezed,
    Object? pressure = freezed,
    Object? relayStates = freezed,
    Object? sensorValues = freezed,
    Object? systemStatus = freezed,
    Object? errorCodes = freezed,
    Object? uptime = freezed,
    Object? memoryUsage = freezed,
    Object? cpuUsage = freezed,
    Object? networkStatus = freezed,
    Object? wifiStrength = freezed,
    Object? gpsCoordinates = freezed,
    Object? rawPayload = freezed,
  }) {
    return _then(
      _$TelemetryDataImpl(
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        deviceUuid: null == deviceUuid
            ? _value.deviceUuid
            : deviceUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        sequence: null == sequence
            ? _value.sequence
            : sequence // ignore: cast_nullable_to_non_nullable
                  as int,
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        signalStrength: freezed == signalStrength
            ? _value.signalStrength
            : signalStrength // ignore: cast_nullable_to_non_nullable
                  as int?,
        batteryLevel: freezed == batteryLevel
            ? _value.batteryLevel
            : batteryLevel // ignore: cast_nullable_to_non_nullable
                  as double?,
        temperature: freezed == temperature
            ? _value.temperature
            : temperature // ignore: cast_nullable_to_non_nullable
                  as double?,
        humidity: freezed == humidity
            ? _value.humidity
            : humidity // ignore: cast_nullable_to_non_nullable
                  as double?,
        pressure: freezed == pressure
            ? _value.pressure
            : pressure // ignore: cast_nullable_to_non_nullable
                  as double?,
        relayStates: freezed == relayStates
            ? _value._relayStates
            : relayStates // ignore: cast_nullable_to_non_nullable
                  as Map<String, bool>?,
        sensorValues: freezed == sensorValues
            ? _value._sensorValues
            : sensorValues // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>?,
        systemStatus: freezed == systemStatus
            ? _value.systemStatus
            : systemStatus // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorCodes: freezed == errorCodes
            ? _value._errorCodes
            : errorCodes // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        uptime: freezed == uptime
            ? _value.uptime
            : uptime // ignore: cast_nullable_to_non_nullable
                  as int?,
        memoryUsage: freezed == memoryUsage
            ? _value.memoryUsage
            : memoryUsage // ignore: cast_nullable_to_non_nullable
                  as double?,
        cpuUsage: freezed == cpuUsage
            ? _value.cpuUsage
            : cpuUsage // ignore: cast_nullable_to_non_nullable
                  as double?,
        networkStatus: freezed == networkStatus
            ? _value.networkStatus
            : networkStatus // ignore: cast_nullable_to_non_nullable
                  as String?,
        wifiStrength: freezed == wifiStrength
            ? _value.wifiStrength
            : wifiStrength // ignore: cast_nullable_to_non_nullable
                  as int?,
        gpsCoordinates: freezed == gpsCoordinates
            ? _value._gpsCoordinates
            : gpsCoordinates // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>?,
        rawPayload: freezed == rawPayload
            ? _value.rawPayload
            : rawPayload // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TelemetryDataImpl implements _TelemetryData {
  const _$TelemetryDataImpl({
    @JsonKey(name: 'timestamp') required this.timestamp,
    @JsonKey(name: 'device_uuid') required this.deviceUuid,
    @JsonKey(name: 'sequence') required this.sequence,
    @JsonKey(name: 'data') required final Map<String, dynamic> data,
    @JsonKey(name: 'signal_strength') this.signalStrength,
    @JsonKey(name: 'battery_level') this.batteryLevel,
    @JsonKey(name: 'temperature') this.temperature,
    @JsonKey(name: 'humidity') this.humidity,
    @JsonKey(name: 'pressure') this.pressure,
    @JsonKey(name: 'relay_states') final Map<String, bool>? relayStates,
    @JsonKey(name: 'sensor_values') final Map<String, double>? sensorValues,
    @JsonKey(name: 'system_status') this.systemStatus,
    @JsonKey(name: 'error_codes') final List<String>? errorCodes,
    @JsonKey(name: 'uptime') this.uptime,
    @JsonKey(name: 'memory_usage') this.memoryUsage,
    @JsonKey(name: 'cpu_usage') this.cpuUsage,
    @JsonKey(name: 'network_status') this.networkStatus,
    @JsonKey(name: 'wifi_strength') this.wifiStrength,
    @JsonKey(name: 'gps_coordinates') final Map<String, double>? gpsCoordinates,
    @JsonKey(name: 'raw_payload') this.rawPayload,
  }) : _data = data,
       _relayStates = relayStates,
       _sensorValues = sensorValues,
       _errorCodes = errorCodes,
       _gpsCoordinates = gpsCoordinates;

  factory _$TelemetryDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$TelemetryDataImplFromJson(json);

  @override
  @JsonKey(name: 'timestamp')
  final DateTime timestamp;
  @override
  @JsonKey(name: 'device_uuid')
  final String deviceUuid;
  @override
  @JsonKey(name: 'sequence')
  final int sequence;
  final Map<String, dynamic> _data;
  @override
  @JsonKey(name: 'data')
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  @override
  @JsonKey(name: 'signal_strength')
  final int? signalStrength;
  @override
  @JsonKey(name: 'battery_level')
  final double? batteryLevel;
  @override
  @JsonKey(name: 'temperature')
  final double? temperature;
  @override
  @JsonKey(name: 'humidity')
  final double? humidity;
  @override
  @JsonKey(name: 'pressure')
  final double? pressure;
  final Map<String, bool>? _relayStates;
  @override
  @JsonKey(name: 'relay_states')
  Map<String, bool>? get relayStates {
    final value = _relayStates;
    if (value == null) return null;
    if (_relayStates is EqualUnmodifiableMapView) return _relayStates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, double>? _sensorValues;
  @override
  @JsonKey(name: 'sensor_values')
  Map<String, double>? get sensorValues {
    final value = _sensorValues;
    if (value == null) return null;
    if (_sensorValues is EqualUnmodifiableMapView) return _sensorValues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'system_status')
  final String? systemStatus;
  final List<String>? _errorCodes;
  @override
  @JsonKey(name: 'error_codes')
  List<String>? get errorCodes {
    final value = _errorCodes;
    if (value == null) return null;
    if (_errorCodes is EqualUnmodifiableListView) return _errorCodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'uptime')
  final int? uptime;
  // Em segundos
  @override
  @JsonKey(name: 'memory_usage')
  final double? memoryUsage;
  // Percentual
  @override
  @JsonKey(name: 'cpu_usage')
  final double? cpuUsage;
  // Percentual
  @override
  @JsonKey(name: 'network_status')
  final String? networkStatus;
  @override
  @JsonKey(name: 'wifi_strength')
  final int? wifiStrength;
  final Map<String, double>? _gpsCoordinates;
  @override
  @JsonKey(name: 'gps_coordinates')
  Map<String, double>? get gpsCoordinates {
    final value = _gpsCoordinates;
    if (value == null) return null;
    if (_gpsCoordinates is EqualUnmodifiableMapView) return _gpsCoordinates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'raw_payload')
  final String? rawPayload;

  @override
  String toString() {
    return 'TelemetryData(timestamp: $timestamp, deviceUuid: $deviceUuid, sequence: $sequence, data: $data, signalStrength: $signalStrength, batteryLevel: $batteryLevel, temperature: $temperature, humidity: $humidity, pressure: $pressure, relayStates: $relayStates, sensorValues: $sensorValues, systemStatus: $systemStatus, errorCodes: $errorCodes, uptime: $uptime, memoryUsage: $memoryUsage, cpuUsage: $cpuUsage, networkStatus: $networkStatus, wifiStrength: $wifiStrength, gpsCoordinates: $gpsCoordinates, rawPayload: $rawPayload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TelemetryDataImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.deviceUuid, deviceUuid) ||
                other.deviceUuid == deviceUuid) &&
            (identical(other.sequence, sequence) ||
                other.sequence == sequence) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.signalStrength, signalStrength) ||
                other.signalStrength == signalStrength) &&
            (identical(other.batteryLevel, batteryLevel) ||
                other.batteryLevel == batteryLevel) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.humidity, humidity) ||
                other.humidity == humidity) &&
            (identical(other.pressure, pressure) ||
                other.pressure == pressure) &&
            const DeepCollectionEquality().equals(
              other._relayStates,
              _relayStates,
            ) &&
            const DeepCollectionEquality().equals(
              other._sensorValues,
              _sensorValues,
            ) &&
            (identical(other.systemStatus, systemStatus) ||
                other.systemStatus == systemStatus) &&
            const DeepCollectionEquality().equals(
              other._errorCodes,
              _errorCodes,
            ) &&
            (identical(other.uptime, uptime) || other.uptime == uptime) &&
            (identical(other.memoryUsage, memoryUsage) ||
                other.memoryUsage == memoryUsage) &&
            (identical(other.cpuUsage, cpuUsage) ||
                other.cpuUsage == cpuUsage) &&
            (identical(other.networkStatus, networkStatus) ||
                other.networkStatus == networkStatus) &&
            (identical(other.wifiStrength, wifiStrength) ||
                other.wifiStrength == wifiStrength) &&
            const DeepCollectionEquality().equals(
              other._gpsCoordinates,
              _gpsCoordinates,
            ) &&
            (identical(other.rawPayload, rawPayload) ||
                other.rawPayload == rawPayload));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    timestamp,
    deviceUuid,
    sequence,
    const DeepCollectionEquality().hash(_data),
    signalStrength,
    batteryLevel,
    temperature,
    humidity,
    pressure,
    const DeepCollectionEquality().hash(_relayStates),
    const DeepCollectionEquality().hash(_sensorValues),
    systemStatus,
    const DeepCollectionEquality().hash(_errorCodes),
    uptime,
    memoryUsage,
    cpuUsage,
    networkStatus,
    wifiStrength,
    const DeepCollectionEquality().hash(_gpsCoordinates),
    rawPayload,
  ]);

  /// Create a copy of TelemetryData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TelemetryDataImplCopyWith<_$TelemetryDataImpl> get copyWith =>
      __$$TelemetryDataImplCopyWithImpl<_$TelemetryDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TelemetryDataImplToJson(this);
  }
}

abstract class _TelemetryData implements TelemetryData {
  const factory _TelemetryData({
    @JsonKey(name: 'timestamp') required final DateTime timestamp,
    @JsonKey(name: 'device_uuid') required final String deviceUuid,
    @JsonKey(name: 'sequence') required final int sequence,
    @JsonKey(name: 'data') required final Map<String, dynamic> data,
    @JsonKey(name: 'signal_strength') final int? signalStrength,
    @JsonKey(name: 'battery_level') final double? batteryLevel,
    @JsonKey(name: 'temperature') final double? temperature,
    @JsonKey(name: 'humidity') final double? humidity,
    @JsonKey(name: 'pressure') final double? pressure,
    @JsonKey(name: 'relay_states') final Map<String, bool>? relayStates,
    @JsonKey(name: 'sensor_values') final Map<String, double>? sensorValues,
    @JsonKey(name: 'system_status') final String? systemStatus,
    @JsonKey(name: 'error_codes') final List<String>? errorCodes,
    @JsonKey(name: 'uptime') final int? uptime,
    @JsonKey(name: 'memory_usage') final double? memoryUsage,
    @JsonKey(name: 'cpu_usage') final double? cpuUsage,
    @JsonKey(name: 'network_status') final String? networkStatus,
    @JsonKey(name: 'wifi_strength') final int? wifiStrength,
    @JsonKey(name: 'gps_coordinates') final Map<String, double>? gpsCoordinates,
    @JsonKey(name: 'raw_payload') final String? rawPayload,
  }) = _$TelemetryDataImpl;

  factory _TelemetryData.fromJson(Map<String, dynamic> json) =
      _$TelemetryDataImpl.fromJson;

  @override
  @JsonKey(name: 'timestamp')
  DateTime get timestamp;
  @override
  @JsonKey(name: 'device_uuid')
  String get deviceUuid;
  @override
  @JsonKey(name: 'sequence')
  int get sequence;
  @override
  @JsonKey(name: 'data')
  Map<String, dynamic> get data;
  @override
  @JsonKey(name: 'signal_strength')
  int? get signalStrength;
  @override
  @JsonKey(name: 'battery_level')
  double? get batteryLevel;
  @override
  @JsonKey(name: 'temperature')
  double? get temperature;
  @override
  @JsonKey(name: 'humidity')
  double? get humidity;
  @override
  @JsonKey(name: 'pressure')
  double? get pressure;
  @override
  @JsonKey(name: 'relay_states')
  Map<String, bool>? get relayStates;
  @override
  @JsonKey(name: 'sensor_values')
  Map<String, double>? get sensorValues;
  @override
  @JsonKey(name: 'system_status')
  String? get systemStatus;
  @override
  @JsonKey(name: 'error_codes')
  List<String>? get errorCodes;
  @override
  @JsonKey(name: 'uptime')
  int? get uptime; // Em segundos
  @override
  @JsonKey(name: 'memory_usage')
  double? get memoryUsage; // Percentual
  @override
  @JsonKey(name: 'cpu_usage')
  double? get cpuUsage; // Percentual
  @override
  @JsonKey(name: 'network_status')
  String? get networkStatus;
  @override
  @JsonKey(name: 'wifi_strength')
  int? get wifiStrength;
  @override
  @JsonKey(name: 'gps_coordinates')
  Map<String, double>? get gpsCoordinates;
  @override
  @JsonKey(name: 'raw_payload')
  String? get rawPayload;

  /// Create a copy of TelemetryData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TelemetryDataImplCopyWith<_$TelemetryDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
