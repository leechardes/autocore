# Endpoints - Sinais CAN

Sistema completo de gerenciamento de sinais CAN Bus para telemetria automotiva em tempo real.

## 📋 Visão Geral

Os endpoints de sinais CAN permitem:
- Gerenciar definições de sinais CAN Bus
- Configurar parâmetros de decodificação (scale, offset, byte order)
- Organizar sinais por categorias (motor, transmissão, sensores)
- Popular banco com sinais padrão FuelTech
- Suporte completo a CRUD para sinais customizados

## 🚗 Endpoints de Sinais CAN

### `GET /api/can-signals`

Lista todos os sinais CAN configurados no sistema.

**Parâmetros de Query:**
- `category` (string, opcional): Filtrar por categoria específica

**Resposta:**
```json
[
  {
    "id": 1,
    "signal_name": "rpm",
    "can_id": "0x5F0",
    "start_bit": 24,
    "length_bits": 16,
    "byte_order": "little_endian",
    "data_type": "unsigned",
    "scale_factor": 1.0,
    "offset": 0.0,
    "unit": "RPM",
    "min_value": 0.0,
    "max_value": 8000.0,
    "description": "Rotação por minuto do motor",
    "category": "engine",
    "is_active": true
  },
  {
    "id": 2,
    "signal_name": "engine_temp",
    "can_id": "0x5F0",
    "start_bit": 8,
    "length_bits": 8,
    "byte_order": "little_endian",
    "data_type": "unsigned",
    "scale_factor": 1.0,
    "offset": -40.0,
    "unit": "°C",
    "min_value": -40.0,
    "max_value": 150.0,
    "description": "Temperatura do líquido de arrefecimento",
    "category": "engine",
    "is_active": true
  },
  {
    "id": 3,
    "signal_name": "vehicle_speed",
    "can_id": "0x5F1",
    "start_bit": 0,
    "length_bits": 16,
    "byte_order": "little_endian",
    "data_type": "unsigned",
    "scale_factor": 0.1,
    "offset": 0.0,
    "unit": "km/h",
    "min_value": 0.0,
    "max_value": 300.0,
    "description": "Velocidade do veículo",
    "category": "vehicle",
    "is_active": true
  }
]
```

**Códigos de Status:**
- `200` - Sinais retornados com sucesso
- `500` - Erro interno do servidor

---

### `GET /api/can-signals/{signal_id}`

Busca um sinal CAN específico por ID.

**Parâmetros de Path:**
- `signal_id` (integer): ID do sinal CAN

**Resposta:**
```json
{
  "id": 1,
  "signal_name": "rpm",
  "can_id": "0x5F0",
  "start_bit": 24,
  "length_bits": 16,
  "byte_order": "little_endian",
  "data_type": "unsigned",
  "scale_factor": 1.0,
  "offset": 0.0,
  "unit": "RPM",
  "min_value": 0.0,
  "max_value": 8000.0,
  "description": "Rotação por minuto do motor - sinal padrão FuelTech",
  "category": "engine",
  "is_active": true,
  "created_at": "2025-01-22T08:00:00Z",
  "updated_at": "2025-01-22T08:00:00Z",
  "usage_count": 156,
  "last_seen": "2025-01-22T10:15:30Z"
}
```

**Códigos de Status:**
- `200` - Sinal encontrado
- `404` - Sinal não encontrado
- `500` - Erro interno do servidor

---

### `POST /api/can-signals`

Cria um novo sinal CAN personalizado.

**Body (JSON):**
```json
{
  "signal_name": "boost_pressure",
  "can_id": "0x5F2",
  "start_bit": 16,
  "length_bits": 16,
  "byte_order": "little_endian",
  "data_type": "signed",
  "scale_factor": 0.01,
  "offset": -100.0,
  "unit": "kPa",
  "min_value": -100.0,
  "max_value": 200.0,
  "description": "Pressão do turbo/supercharger",
  "category": "engine",
  "is_active": true
}
```

**Campos Obrigatórios:**
- `signal_name` - Nome único do sinal
- `can_id` - ID da mensagem CAN (formato hex)
- `start_bit` - Bit inicial na mensagem (0-63)
- `length_bits` - Número de bits do sinal (1-32)

**Campos Opcionais:**
- `byte_order` - Ordem dos bytes (`little_endian`, `big_endian`) - padrão: `little_endian`
- `data_type` - Tipo de dados (`unsigned`, `signed`) - padrão: `unsigned`
- `scale_factor` - Fator de escala - padrão: `1.0`
- `offset` - Offset de valor - padrão: `0.0`
- `unit` - Unidade de medida
- `min_value` / `max_value` - Valores mínimo e máximo
- `description` - Descrição detalhada
- `category` - Categoria do sinal - padrão: `custom`

**Resposta:**
```json
{
  "id": 15,
  "signal_name": "boost_pressure",
  "message": "Sinal CAN criado com sucesso"
}
```

**Códigos de Status:**
- `201` - Sinal criado com sucesso
- `400` - Dados inválidos ou nome já existe
- `500` - Erro interno do servidor

---

### `PUT /api/can-signals/{signal_id}`

Atualiza um sinal CAN existente.

**Parâmetros de Path:**
- `signal_id` (integer): ID do sinal

**Body (JSON) - Parcial:**
```json
{
  "description": "Nova descrição mais detalhada",
  "scale_factor": 0.02,
  "max_value": 250.0,
  "is_active": false
}
```

**Resposta:**
```json
{
  "id": 15,
  "signal_name": "boost_pressure",
  "message": "Sinal CAN atualizado com sucesso"
}
```

**Códigos de Status:**
- `200` - Sinal atualizado com sucesso
- `400` - Dados inválidos ou nome já existe
- `404` - Sinal não encontrado
- `500` - Erro interno do servidor

---

### `DELETE /api/can-signals/{signal_id}`

Remove um sinal CAN do sistema.

**Parâmetros de Path:**
- `signal_id` (integer): ID do sinal

**Resposta:**
```json
{
  "message": "Sinal CAN removido com sucesso"
}
```

**Códigos de Status:**
- `200` - Sinal removido com sucesso
- `404` - Sinal não encontrado
- `500` - Erro interno do servidor

---

### `POST /api/can-signals/seed`

Popula o banco com sinais CAN padrão do FuelTech.

**Resposta:**
```json
{
  "message": "14 sinais CAN padrão adicionados com sucesso",
  "count": 14
}
```

**Se banco já possui sinais:**
```json
{
  "message": "Banco já possui sinais CAN configurados",
  "count": 0
}
```

**Códigos de Status:**
- `200` - Operação executada com sucesso
- `500` - Erro interno do servidor

## 🏷️ Categorias de Sinais

### Engine (`engine`)
Sinais do motor:
- `rpm` - Rotação por minuto
- `engine_temp` - Temperatura do motor
- `oil_pressure` - Pressão do óleo
- `oil_temp` - Temperatura do óleo
- `intake_temp` - Temperatura do ar admitido
- `boost_pressure` - Pressão do turbo
- `lambda` - Sensor lambda/AFR

### Transmission (`transmission`)
Sinais da transmissão:
- `gear` - Marcha atual
- `transmission_temp` - Temperatura da transmissão
- `clutch_position` - Posição da embreagem

### Vehicle (`vehicle`)
Sinais do veículo:
- `vehicle_speed` - Velocidade do veículo
- `wheel_speed_fl` - Velocidade roda dianteira esquerda
- `wheel_speed_fr` - Velocidade roda dianteira direita
- `brake_pressure` - Pressão dos freios

### Fuel (`fuel`)
Sinais de combustível:
- `fuel_level` - Nível de combustível
- `fuel_pressure` - Pressão de combustível
- `fuel_temp` - Temperatura do combustível
- `ethanol_content` - Conteúdo de etanol

### Electrical (`electrical`)
Sinais elétricos:
- `battery_voltage` - Tensão da bateria
- `alternator_voltage` - Tensão do alternador
- `ignition_timing` - Avanço de ignição

### Sensors (`sensors`)
Outros sensores:
- `throttle_position` - Posição do acelerador (TPS)
- `map_sensor` - Pressão absoluta do coletor
- `maf_sensor` - Fluxo de massa de ar

## 🔧 Parâmetros de Decodificação

### CAN ID (Identificador da Mensagem)
```json
{
  "can_id": "0x5F0",
  "description": "ID hexadecimal da mensagem CAN",
  "format": "0x + 3 dígitos hex",
  "examples": ["0x5F0", "0x5F1", "0x5F2", "0x7E0"]
}
```

### Start Bit e Length
```json
{
  "start_bit": 24,
  "length_bits": 16,
  "description": "Posição e tamanho do sinal na mensagem",
  "bit_numbering": "LSB 0 (little-endian padrão)",
  "max_bits_per_signal": 32,
  "max_bits_per_message": 64
}
```

### Byte Order
```json
{
  "little_endian": {
    "description": "Byte menos significativo primeiro",
    "usage": "Padrão na maioria dos sistemas automotivos",
    "example": "0x1234 -> [0x34, 0x12]"
  },
  "big_endian": {
    "description": "Byte mais significativo primeiro", 
    "usage": "Redes industriais, alguns protocolos específicos",
    "example": "0x1234 -> [0x12, 0x34]"
  }
}
```

### Scale Factor e Offset
```json
{
  "formula": "physical_value = (raw_value * scale_factor) + offset",
  "examples": {
    "temperature": {
      "raw_range": "0-255",
      "scale_factor": 1.0,
      "offset": -40.0,
      "physical_range": "-40°C to 215°C"
    },
    "pressure": {
      "raw_range": "0-65535",
      "scale_factor": 0.01,
      "offset": -100.0,
      "physical_range": "-100 to 555.35 kPa"
    }
  }
}
```

## 📊 Sinais Padrão FuelTech

### Mensagem 0x5F0 (Engine Data 1)
```json
{
  "can_id": "0x5F0",
  "frequency": "100ms",
  "signals": [
    {
      "name": "engine_temp",
      "start_bit": 8,
      "length_bits": 8,
      "scale": 1.0,
      "offset": -40.0,
      "unit": "°C"
    },
    {
      "name": "oil_pressure", 
      "start_bit": 16,
      "length_bits": 8,
      "scale": 0.1,
      "offset": 0.0,
      "unit": "bar"
    },
    {
      "name": "rpm",
      "start_bit": 24,
      "length_bits": 16,
      "scale": 1.0,
      "offset": 0.0,
      "unit": "RPM"
    }
  ]
}
```

### Mensagem 0x5F1 (Vehicle Data)
```json
{
  "can_id": "0x5F1",
  "frequency": "50ms",
  "signals": [
    {
      "name": "vehicle_speed",
      "start_bit": 0,
      "length_bits": 16,
      "scale": 0.1,
      "offset": 0.0,
      "unit": "km/h"
    },
    {
      "name": "throttle_position",
      "start_bit": 16,
      "length_bits": 8,
      "scale": 0.392,
      "offset": 0.0,
      "unit": "%"
    }
  ]
}
```

### Mensagem 0x5F2 (Fuel & Air)
```json
{
  "can_id": "0x5F2",
  "frequency": "200ms",
  "signals": [
    {
      "name": "lambda",
      "start_bit": 0,
      "length_bits": 16,
      "scale": 0.001,
      "offset": 0.0,
      "unit": "λ"
    },
    {
      "name": "fuel_pressure",
      "start_bit": 16,
      "length_bits": 16,
      "scale": 0.01,
      "offset": 0.0,
      "unit": "bar"
    }
  ]
}
```

## 🔄 Decodificação de Sinais

### Processo de Decodificação
```python
def decode_can_signal(raw_data, signal_config):
    """
    Decodifica sinal CAN baseado na configuração
    """
    # 1. Extrair bits do sinal
    start_bit = signal_config['start_bit']
    length_bits = signal_config['length_bits']
    
    # 2. Extrair valor raw
    raw_value = extract_bits(raw_data, start_bit, length_bits)
    
    # 3. Aplicar tipo de dados (signed/unsigned)
    if signal_config['data_type'] == 'signed':
        raw_value = convert_to_signed(raw_value, length_bits)
    
    # 4. Aplicar escala e offset
    physical_value = (raw_value * signal_config['scale_factor']) + signal_config['offset']
    
    # 5. Validar limites
    if signal_config['min_value'] is not None:
        physical_value = max(physical_value, signal_config['min_value'])
    if signal_config['max_value'] is not None:
        physical_value = min(physical_value, signal_config['max_value'])
    
    return physical_value

def extract_bits(data, start_bit, length_bits):
    """
    Extrai bits específicos de uma mensagem CAN
    """
    # Converter bytes para inteiro (little-endian)
    value = int.from_bytes(data, byteorder='little')
    
    # Criar máscara para extrair bits
    mask = (1 << length_bits) - 1
    
    # Extrair e retornar valor
    return (value >> start_bit) & mask
```

### Exemplo de Uso
```cpp
// ESP32 - Decodificar mensagem CAN
void procesCanMessage(uint32_t can_id, uint8_t* data, uint8_t len) {
    if (can_id == 0x5F0) {
        // RPM (bits 24-39)
        uint16_t rpm_raw = (data[3] << 8) | data[4];
        float rpm = rpm_raw * 1.0 + 0.0;  // scale=1.0, offset=0.0
        
        // Engine temp (bits 8-15)
        uint8_t temp_raw = data[1];
        float engine_temp = temp_raw * 1.0 - 40.0;  // scale=1.0, offset=-40.0
        
        // Enviar via telemetria
        sendTelemetry("rpm", rpm, "RPM");
        sendTelemetry("engine_temp", engine_temp, "°C");
    }
}
```

## 📈 Validação e Qualidade

### Validação de Sinais
```python
def validate_can_signal(signal_data):
    """
    Valida configuração de sinal CAN
    """
    errors = []
    
    # Validar CAN ID
    if not is_valid_can_id(signal_data['can_id']):
        errors.append("CAN ID inválido")
    
    # Validar posição dos bits
    if signal_data['start_bit'] + signal_data['length_bits'] > 64:
        errors.append("Sinal excede tamanho da mensagem CAN")
    
    # Validar escala e offset
    if signal_data['scale_factor'] == 0:
        errors.append("Scale factor não pode ser zero")
    
    # Validar limites
    if signal_data['min_value'] >= signal_data['max_value']:
        errors.append("Valor mínimo deve ser menor que máximo")
    
    return errors
```

### Detecção de Conflitos
```python
def detect_signal_conflicts(signals):
    """
    Detecta sobreposição de bits entre sinais
    """
    conflicts = []
    signals_by_can_id = {}
    
    # Agrupar por CAN ID
    for signal in signals:
        can_id = signal['can_id']
        if can_id not in signals_by_can_id:
            signals_by_can_id[can_id] = []
        signals_by_can_id[can_id].append(signal)
    
    # Verificar sobreposições
    for can_id, signal_list in signals_by_can_id.items():
        for i, signal1 in enumerate(signal_list):
            for signal2 in signal_list[i+1:]:
                if signals_overlap(signal1, signal2):
                    conflicts.append({
                        'can_id': can_id,
                        'signal1': signal1['signal_name'],
                        'signal2': signal2['signal_name']
                    })
    
    return conflicts
```

## ⚠️ Considerações

### Performance
- Decodificação de sinais deve ser otimizada para tempo real
- Cache de configurações para evitar consultas ao banco
- Processamento assíncrono para não bloquear comunicação CAN

### Precisão
- Configurações de escala e offset devem ser precisas
- Validar limites físicos dos sensores
- Considerar resolução disponível (número de bits)

### Compatibilidade
- Diferentes ECUs podem usar protocolos diferentes
- Sinais customizados requerem documentação detalhada
- Manter compatibilidade com versões anteriores

### Manutenção
- Backup de configurações customizadas
- Versionamento de mudanças em sinais
- Logs de decodificação para debugging