import 'package:autocore_app/core/models/api/api_device_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiDeviceInfo Model Tests', () {
    test('should create ApiDeviceInfo with all required fields', () {
      // Arrange
      const uuid = 'test-uuid-12345';
      const name = 'Test Device';
      const firmwareVersion = '1.0.0';
      const hardwareVersion = '1.0.0';
      const ipAddress = '192.168.1.100';
      const macAddress = 'AA:BB:CC:DD:EE:FF';
      const mqttBroker = 'localhost';
      const mqttPort = 1883;
      const mqttClientId = 'test_client';
      const apiBaseUrl = 'http://localhost:8000';
      const deviceType = 'esp32_display';
      const timezone = 'America/Sao_Paulo';

      // Act
      const device = ApiDeviceInfo(
        uuid: uuid,
        name: name,
        firmwareVersion: firmwareVersion,
        hardwareVersion: hardwareVersion,
        ipAddress: ipAddress,
        macAddress: macAddress,
        mqttBroker: mqttBroker,
        mqttPort: mqttPort,
        mqttClientId: mqttClientId,
        apiBaseUrl: apiBaseUrl,
        deviceType: deviceType,
        timezone: timezone,
        location: null,
      );

      // Assert
      expect(device.uuid, equals(uuid));
      expect(device.name, equals(name));
      expect(device.firmwareVersion, equals(firmwareVersion));
      expect(device.hardwareVersion, equals(hardwareVersion));
      expect(device.ipAddress, equals(ipAddress));
      expect(device.macAddress, equals(macAddress));
      expect(device.mqttBroker, equals(mqttBroker));
      expect(device.mqttPort, equals(mqttPort));
      expect(device.mqttClientId, equals(mqttClientId));
      expect(device.apiBaseUrl, equals(apiBaseUrl));
      expect(device.deviceType, equals(deviceType));
      expect(device.timezone, equals(timezone));
      expect(device.location, isNull);
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      const device = ApiDeviceInfo(
        uuid: 'test-uuid',
        name: 'Test Device',
        firmwareVersion: '1.0.0',
        hardwareVersion: '1.0.0',
        ipAddress: '192.168.1.100',
        macAddress: 'AA:BB:CC:DD:EE:FF',
        mqttBroker: 'localhost',
        mqttPort: 1883,
        mqttClientId: 'test_client',
        apiBaseUrl: 'http://localhost:8000',
        deviceType: 'esp32_display',
        timezone: 'America/Sao_Paulo',
        location: null,
      );

      // Act
      final json = device.toJson();

      // Assert
      expect(json['uuid'], equals('test-uuid'));
      expect(json['name'], equals('Test Device'));
      expect(json['firmware_version'], equals('1.0.0'));
      expect(json['hardware_version'], equals('1.0.0'));
      expect(json['ip_address'], equals('192.168.1.100'));
      expect(json['mac_address'], equals('AA:BB:CC:DD:EE:FF'));
      expect(json['mqtt_broker'], equals('localhost'));
      expect(json['mqtt_port'], equals(1883));
      expect(json['mqtt_client_id'], equals('test_client'));
      expect(json['api_base_url'], equals('http://localhost:8000'));
      expect(json['device_type'], equals('esp32_display'));
      expect(json['timezone'], equals('America/Sao_Paulo'));
      expect(json['location'], isNull);
    });

    test('should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'uuid': 'test-uuid',
        'name': 'Test Device',
        'firmware_version': '1.0.0',
        'hardware_version': '1.0.0',
        'ip_address': '192.168.1.100',
        'mac_address': 'AA:BB:CC:DD:EE:FF',
        'mqtt_broker': 'localhost',
        'mqtt_port': 1883,
        'mqtt_client_id': 'test_client',
        'api_base_url': 'http://localhost:8000',
        'device_type': 'esp32_display',
        'timezone': 'America/Sao_Paulo',
        'location': null,
      };

      // Act
      final device = ApiDeviceInfo.fromJson(json);

      // Assert
      expect(device.uuid, equals('test-uuid'));
      expect(device.name, equals('Test Device'));
      expect(device.firmwareVersion, equals('1.0.0'));
      expect(device.hardwareVersion, equals('1.0.0'));
      expect(device.ipAddress, equals('192.168.1.100'));
      expect(device.macAddress, equals('AA:BB:CC:DD:EE:FF'));
      expect(device.mqttBroker, equals('localhost'));
      expect(device.mqttPort, equals(1883));
      expect(device.mqttClientId, equals('test_client'));
      expect(device.apiBaseUrl, equals('http://localhost:8000'));
      expect(device.deviceType, equals('esp32_display'));
      expect(device.timezone, equals('America/Sao_Paulo'));
      expect(device.location, isNull);
    });

    test('should handle round-trip serialization correctly', () {
      // Arrange
      const originalDevice = ApiDeviceInfo(
        uuid: 'round-trip-uuid',
        name: 'Round Trip Device',
        firmwareVersion: '2.0.0',
        hardwareVersion: '2.1.0',
        ipAddress: '10.0.0.1',
        macAddress: 'BB:CC:DD:EE:FF:AA',
        mqttBroker: 'mqtt.example.com',
        mqttPort: 8883,
        mqttClientId: 'round_trip_client',
        apiBaseUrl: 'https://api.example.com',
        deviceType: 'esp32_relay',
        timezone: 'UTC',
        location: 'Test Location',
      );

      // Act
      final json = originalDevice.toJson();
      final deserializedDevice = ApiDeviceInfo.fromJson(json);

      // Assert
      expect(deserializedDevice.uuid, equals(originalDevice.uuid));
      expect(deserializedDevice.name, equals(originalDevice.name));
      expect(
        deserializedDevice.firmwareVersion,
        equals(originalDevice.firmwareVersion),
      );
      expect(
        deserializedDevice.hardwareVersion,
        equals(originalDevice.hardwareVersion),
      );
      expect(deserializedDevice.ipAddress, equals(originalDevice.ipAddress));
      expect(deserializedDevice.macAddress, equals(originalDevice.macAddress));
      expect(deserializedDevice.mqttBroker, equals(originalDevice.mqttBroker));
      expect(deserializedDevice.mqttPort, equals(originalDevice.mqttPort));
      expect(
        deserializedDevice.mqttClientId,
        equals(originalDevice.mqttClientId),
      );
      expect(deserializedDevice.apiBaseUrl, equals(originalDevice.apiBaseUrl));
      expect(deserializedDevice.deviceType, equals(originalDevice.deviceType));
      expect(deserializedDevice.timezone, equals(originalDevice.timezone));
      expect(deserializedDevice.location, equals(originalDevice.location));
    });

    test('should handle equality correctly', () {
      // Arrange
      const device1 = ApiDeviceInfo(
        uuid: 'equality-test-uuid',
        name: 'Equality Device',
        firmwareVersion: '1.0.0',
        hardwareVersion: '1.0.0',
        ipAddress: '192.168.1.100',
        macAddress: 'AA:BB:CC:DD:EE:FF',
        mqttBroker: 'localhost',
        mqttPort: 1883,
        mqttClientId: 'equality_client',
        apiBaseUrl: 'http://localhost:8000',
        deviceType: 'esp32_display',
        timezone: 'America/Sao_Paulo',
        location: null,
      );

      const device2 = ApiDeviceInfo(
        uuid: 'equality-test-uuid',
        name: 'Equality Device',
        firmwareVersion: '1.0.0',
        hardwareVersion: '1.0.0',
        ipAddress: '192.168.1.100',
        macAddress: 'AA:BB:CC:DD:EE:FF',
        mqttBroker: 'localhost',
        mqttPort: 1883,
        mqttClientId: 'equality_client',
        apiBaseUrl: 'http://localhost:8000',
        deviceType: 'esp32_display',
        timezone: 'America/Sao_Paulo',
        location: null,
      );

      const device3 = ApiDeviceInfo(
        uuid: 'different-uuid',
        name: 'Different Device',
        firmwareVersion: '2.0.0',
        hardwareVersion: '2.0.0',
        ipAddress: '192.168.1.101',
        macAddress: 'BB:CC:DD:EE:FF:AA',
        mqttBroker: 'different-broker',
        mqttPort: 8883,
        mqttClientId: 'different_client',
        apiBaseUrl: 'https://different.com',
        deviceType: 'esp32_relay',
        timezone: 'UTC',
        location: 'Different Location',
      );

      // Act & Assert
      expect(device1, equals(device2));
      expect(device1.hashCode, equals(device2.hashCode));
      expect(device1, isNot(equals(device3)));
      expect(device1.hashCode, isNot(equals(device3.hashCode)));
    });

    test('should handle copyWith correctly', () {
      // Arrange
      const originalDevice = ApiDeviceInfo(
        uuid: 'copywith-uuid',
        name: 'Original Device',
        firmwareVersion: '1.0.0',
        hardwareVersion: '1.0.0',
        ipAddress: '192.168.1.100',
        macAddress: 'AA:BB:CC:DD:EE:FF',
        mqttBroker: 'localhost',
        mqttPort: 1883,
        mqttClientId: 'original_client',
        apiBaseUrl: 'http://localhost:8000',
        deviceType: 'esp32_display',
        timezone: 'America/Sao_Paulo',
        location: null,
      );

      // Act
      final modifiedDevice = originalDevice.copyWith(
        name: 'Modified Device',
        firmwareVersion: '2.0.0',
        location: 'New Location',
      );

      // Assert
      expect(modifiedDevice.uuid, equals(originalDevice.uuid)); // Unchanged
      expect(modifiedDevice.name, equals('Modified Device')); // Changed
      expect(modifiedDevice.firmwareVersion, equals('2.0.0')); // Changed
      expect(
        modifiedDevice.hardwareVersion,
        equals(originalDevice.hardwareVersion),
      ); // Unchanged
      expect(
        modifiedDevice.ipAddress,
        equals(originalDevice.ipAddress),
      ); // Unchanged
      expect(
        modifiedDevice.macAddress,
        equals(originalDevice.macAddress),
      ); // Unchanged
      expect(
        modifiedDevice.mqttBroker,
        equals(originalDevice.mqttBroker),
      ); // Unchanged
      expect(
        modifiedDevice.mqttPort,
        equals(originalDevice.mqttPort),
      ); // Unchanged
      expect(
        modifiedDevice.mqttClientId,
        equals(originalDevice.mqttClientId),
      ); // Unchanged
      expect(
        modifiedDevice.apiBaseUrl,
        equals(originalDevice.apiBaseUrl),
      ); // Unchanged
      expect(
        modifiedDevice.deviceType,
        equals(originalDevice.deviceType),
      ); // Unchanged
      expect(
        modifiedDevice.timezone,
        equals(originalDevice.timezone),
      ); // Unchanged
      expect(modifiedDevice.location, equals('New Location')); // Changed
    });
  });
}
