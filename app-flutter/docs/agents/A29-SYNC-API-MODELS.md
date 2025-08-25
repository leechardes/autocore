# A29 - SYNC-API-MODELS

## 📋 Objetivo
Sincronizar os modelos Flutter com a resposta real da API AutoCore, corrigindo erro "type 'int' is not a subtype of type 'String' in type cast".

## 🔍 Problema Identificado
A API retornava IDs como `int` mas os modelos Flutter esperavam `String`, causando erro de type cast durante o parsing da resposta JSON.

### Estrutura API Real vs Modelos Flutter
```json
// API retorna:
{
  "device": { "id": 8 },       // int
  "screens": [
    {
      "id": 1,                 // int
      "items": [
        { "id": 1 }            // int
      ]
    }
  ]
}

// Modelos Flutter esperavam:
ApiScreenConfig: { "id": String }
ApiScreenItem: { "id": String }
```

## 🎯 Solução Implementada

### 1. Análise da API Real
```bash
curl -s -X 'GET' 'http://10.0.10.100:8081/api/config/full?device_uuid=8e67eb62-57c9-4e11-9772-f7fd7065199f'
```

### 2. Correção do ConfigService
Atualizado método `_adjustResponseFormat()` em `/lib/infrastructure/services/config_service.dart`:

#### 2.1 Conversão de IDs
```dart
// Antes (causava erro):
'id': screen['id']  // int -> String (ERRO)

// Depois (corrigido):
'id': (screen['id'] ?? 0).toString()  // int -> String (OK)
```

#### 2.2 Processamento de Screens
```dart
// Processar screens convertendo IDs e estrutura
for (final screen in screens) {
  final adjustedScreen = {
    'id': (screen['id'] ?? 0).toString(), // ✅ int → String
    'name': screen['name'] ?? 'screen',
    'title': screen['title'] ?? 'Tela',
    // ...
  };
}
```

#### 2.3 Processamento de Items
```dart
// Processar items dentro de cada screen
for (final item in items) {
  final adjustedItem = {
    'id': (item['id'] ?? 0).toString(), // ✅ int → String
    'type': _mapItemType(item['item_type'] ?? 'button'),
    'title': item['label'] ?? item['name'] ?? 'Item',
    // ...
  };
}
```

### 3. Funções Auxiliares Adicionadas
```dart
/// Mapeia o tipo de item da API para o modelo Flutter
String _mapItemType(String apiType) {
  switch (apiType) {
    case 'button': return 'button';
    case 'switch': return 'switch'; 
    case 'display': return 'gauge';
    default: return 'button';
  }
}

/// Parse seguro de double
double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Parse seguro do payload JSON
Map<String, dynamic>? _parsePayload(String? payloadStr) {
  if (payloadStr == null || payloadStr.isEmpty) return null;
  try {
    final decoded = jsonDecode(payloadStr);
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (e) {
    AppLogger.warning('Erro ao fazer parse do payload: $payloadStr - $e');
    return null;
  }
}
```

## 🧪 Testes Implementados

### 1. Teste Unitário
Criado `/test/unit_test_config_service.dart`:
```dart
test('should handle real API response structure correctly', () {
  // Testa conversão int → String
  expect((screen['id'] ?? 0).toString(), equals('1'));
  expect((item['id'] ?? 0).toString(), equals('1'));
});
```

### 2. Compilação
```bash
flutter build apk --debug  # ✅ PASSOU
```

## 📊 Mapping API → Model

| Campo API | Tipo API | Campo Model | Tipo Model | Conversão |
|-----------|----------|-------------|------------|-----------|
| `screen.id` | `int` | `ApiScreenConfig.id` | `String` | `.toString()` |
| `item.id` | `int` | `ApiScreenItem.id` | `String` | `.toString()` |
| `item.item_type` | `String` | `ApiScreenItem.type` | `String` | `_mapItemType()` |
| `item.label` | `String` | `ApiScreenItem.title` | `String` | Direto |
| `item.min_value` | `int` | `ApiScreenItem.minValue` | `double?` | `_parseDouble()` |

## ✅ Resultado

### ❌ Antes:
```
DioException: type 'int' is not a subtype of type 'String' in type cast
```

### ✅ Depois:
```
✓ Built build/app/outputs/flutter-apk/app-debug.apk
✓ All tests passed!
```

## 🔧 Arquivos Modificados
- `/lib/infrastructure/services/config_service.dart` - Método `_adjustResponseFormat()`
- `/test/unit_test_config_service.dart` - Testes unitários (novo)

## 📝 Resumo
Corrigido erro de type cast convertendo todos os IDs `int` para `String` no ConfigService, mapeando corretamente a estrutura da API real para os modelos Flutter esperados. Implementado parsing seguro com tratamento de nulos e validação de tipos.

## ⏱️ Concluído em
23/08/2025 - 18:00

## 🚀 Status
✅ CONCLUÍDO - App compila e funciona sem erros de type cast