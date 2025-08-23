# Endpoints - Dispositivos

Gerenciamento completo de dispositivos ESP32 no sistema AutoCore.

## 📋 Visão Geral

Os endpoints de dispositivos permitem:
- Listar dispositivos conectados
- Registrar novos dispositivos
- Atualizar configurações
- Monitorar status e telemetria

## 🔗 Endpoints

### `GET /api/devices`

Lista todos os dispositivos cadastrados no sistema.

**Parâmetros de Query:**
- Nenhum

**Resposta:**
```json
[
  {
    "id": 1,
    "uuid": "esp32-display-001",
    "name": "Display Principal",
    "type": "esp32_display",
    "mac_address": "AA:BB:CC:DD:EE:FF",
    "ip_address": "192.168.1.100",
    "firmware_version": "1.2.3",
    "hardware_version": "v2.1",
    "status": "online",
    "last_seen": "2025-01-22T10:00:00Z",
    "location": "Sala de Controle",
    "is_active": true,
    "created_at": "2025-01-20T08:00:00Z",
    "updated_at": "2025-01-22T10:00:00Z"
  }
]
```

---

### `GET /api/devices/{device_id}`

Busca um dispositivo específico por ID numérico ou UUID.

**Parâmetros de Path:**
- `device_id` (string): ID numérico ou UUID do dispositivo

**Resposta:**
```json
{
  "id": 1,
  "uuid": "esp32-display-001",
  "name": "Display Principal",
  "type": "esp32_display",
  "configuration_json": "{\"location\":\"Sala\",\"theme\":\"dark\"}",
  "capabilities_json": "{\"has_touch\":true,\"resolution\":\"320x240\"}"
}
```

**Códigos de Status:**
- `200` - Dispositivo encontrado
- `404` - Dispositivo não encontrado

---

### `POST /api/devices`

Registra um novo dispositivo no sistema.

**Body (JSON):**
```json
{
  "uuid": "esp32-relay-002",
  "name": "Relé Garagem",
  "type": "esp32_relay",
  "mac_address": "BB:CC:DD:EE:FF:AA",
  "ip_address": "192.168.1.101",
  "firmware_version": "1.1.0",
  "hardware_version": "v1.5"
}
```

**Resposta:**
```json
{
  "id": 2,
  "uuid": "esp32-relay-002",
  "name": "Relé Garagem",
  "status": "offline",
  "message": "Dispositivo criado com sucesso"
}
```

**Códigos de Status:**
- `201` - Dispositivo criado
- `409` - UUID já existe
- `400` - Dados inválidos

---

### `PATCH /api/devices/{device_identifier}`

Atualiza um dispositivo existente. Aceita ID numérico ou UUID.

**Parâmetros de Path:**
- `device_identifier` (string): ID numérico ou UUID

**Body (JSON) - Parcial:**
```json
{
  "name": "Novo Nome",
  "ip_address": "192.168.1.150",
  "location": "Nova Localização",
  "configuration": {
    "theme": "light",
    "brightness": 80
  },
  "capabilities": {
    "has_touch": true,
    "has_wifi": true
  }
}
```

**Resposta:**
```json
{
  "id": 1,
  "uuid": "esp32-display-001",
  "name": "Novo Nome",
  "ip_address": "192.168.1.150",
  "message": "Dispositivo atualizado com sucesso"
}
```

**Códigos de Status:**
- `200` - Atualizado com sucesso
- `404` - Dispositivo não encontrado
- `400` - Dados inválidos

---

### `DELETE /api/devices/{device_id}`

Remove um dispositivo (soft delete).

**Parâmetros de Path:**
- `device_id` (integer): ID numérico do dispositivo

**Resposta:**
```json
{
  "message": "Dispositivo removido com sucesso"
}
```

**Códigos de Status:**
- `200` - Removido com sucesso
- `404` - Dispositivo não encontrado

---

### `GET /api/devices/available-for-relays`

Lista dispositivos ESP32_RELAY que ainda não possuem placa cadastrada.

**Resposta:**
```json
[
  {
    "id": 3,
    "uuid": "esp32-relay-003",
    "name": "Relé Disponível",
    "type": "esp32_relay",
    "status": "online"
  }
]
```

---

### `GET /api/devices/uuid/{device_uuid}`

Busca dispositivo especificamente pelo UUID (usado pelo ESP32).

**Parâmetros de Path:**
- `device_uuid` (string): UUID do dispositivo

**Resposta:**
Mesma estrutura do `GET /api/devices/{device_id}`

## 🔄 Fluxo de Auto-Registro ESP32

1. **ESP32 Inicia**: Dispositivo conecta na rede
2. **Anuncia Presença**: Envia dados via MQTT
3. **Auto-Registro**: `POST /api/devices` com dados do hardware
4. **Atualiza Status**: `PATCH /api/devices/{uuid}` com IP atual
5. **Heartbeat**: Atualizações periódicas de status

## 📝 Tipos de Dispositivos

- `esp32_display` - Displays com interface touchscreen
- `esp32_relay` - Placas de controle de relés
- `hmi_display` - Interfaces HMI industriais
- `gateway` - Gateways de comunicação

## 🔍 Campos de Configuração

### configuration_json
```json
{
  "location": "Sala de Controle",
  "device_type": "esp32_display",
  "theme": "dark",
  "brightness": 75,
  "sleep_timeout": 300,
  "wifi_ssid": "AutoCore_WiFi"
}
```

### capabilities_json
```json
{
  "has_touch": true,
  "has_wifi": true,
  "has_bluetooth": false,
  "resolution": "320x240",
  "memory_mb": 4,
  "storage_mb": 16,
  "gpio_pins": 32
}
```

## ⚠️ Considerações

- UUIDs devem ser únicos no sistema
- Dispositivos inativos não aparecem em algumas listagens
- MAC addresses são usados para identificação de hardware
- IPs podem mudar dinamicamente (DHCP)
- Status é atualizado automaticamente via MQTT