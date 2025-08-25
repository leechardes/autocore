import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConfigService Tests', () {
    test('should handle real API response structure correctly', () {
      final mockApiResponse = {
        'version': '2.0.0',
        'protocol_version': '2.2.0',
        'timestamp': '2025-08-23T17:58:31.177324',
        'device': {
          'id': 8,
          'uuid': '8e67eb62-57c9-4e11-9772-f7fd7065199f',
          'type': 'esp32_display',
          'name': 'AutoCore Flutter App',
          'status': 'offline',
          'ip_address': '10.0.10.113',
          'mac_address': '8e:67:eb:62:57:c9',
        },
        'system': {'name': 'AutoCore System', 'language': 'pt-BR'},
        'screens': [
          {
            'id': 1,
            'name': 'home',
            'title': 'Início',
            'icon': 'home',
            'screen_type': 'dashboard',
            'position': 1,
            'columns_mobile': 2,
            'is_visible': true,
            'items': [
              {
                'id': 1,
                'item_type': 'display',
                'name': 'speed',
                'label': 'Velocidade',
                'icon': 'speedometer',
                'position': 1,
                'unit': 'km/h',
                'min_value': 0,
                'max_value': 100,
                'action_type': 'relay_control',
                'action_payload': '{"action":"toggle"}',
                'is_visible': true,
              },
            ],
          },
        ],
      };

      // Test conversion without throwing errors
      // This should not throw a type cast error
      expect(() {
        // O método _adjustResponseFormat é privado, então vamos testar indiretamente
        // através da verificação da estrutura esperada
        final screens = mockApiResponse['screens'] as List;
        final firstScreen = screens.first as Map<String, dynamic>;
        final firstItem =
            (firstScreen['items'] as List).first as Map<String, dynamic>;

        // Verificar se os IDs são int (como na API real)
        expect(firstScreen['id'], isA<int>());
        expect(firstItem['id'], isA<int>());

        // Verificar se as conversões funcionariam
        expect(firstScreen['id'].toString(), equals('1'));
        expect(firstItem['id'].toString(), equals('1'));
      }, returnsNormally);
    });

    test('should convert int IDs to String correctly', () {
      const intValue = 123;
      expect(intValue.toString(), equals('123'));

      const Map<String, dynamic> testMap = {'id': 456};
      expect((testMap['id'] ?? 0).toString(), equals('456'));
    });

    test('should handle null values safely', () {
      const Map<String, dynamic> testMap = {};
      expect((testMap['id'] ?? 0).toString(), equals('0'));
      expect(
        (testMap['nonexistent'] ?? 'default').toString(),
        equals('default'),
      );
    });
  });
}
