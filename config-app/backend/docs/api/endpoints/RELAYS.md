# Endpoints - Relés

Gerenciamento completo de placas de relé e canais individuais para controle de dispositivos elétricos.

## 📋 Visão Geral

Os endpoints de relés permitem:
- Gerenciar placas de relé conectadas a dispositivos ESP32_RELAY
- Configurar canais individuais com nomes, ícones e proteções
- Controlar configurações avançadas de segurança
- Ativar/desativar canais dinamicamente

## 🔌 Endpoints de Placas de Relé

### `GET /api/relays/boards`

Lista todas as placas de relé ativas conectadas a dispositivos ativos.

**Resposta:**
```json
[
  {
    "id": 1,
    "device_id": 2,
    "name": "Relé Principal",
    "total_channels": 16,
    "board_model": "ESP32-RELAY-16CH",
    "is_active": true
  }
]
```

**Códigos de Status:**
- `200` - Lista retornada com sucesso
- `500` - Erro interno do servidor

---

### `POST /api/relays/boards`

Cria uma nova placa de relé associada a um dispositivo ESP32_RELAY.

**Body (JSON):**
```json
{
  "device_id": 3,
  "total_channels": 8,
  "board_model": "ESP32-RELAY-8CH"
}
```

**Validações:**
- `device_id` é obrigatório e deve ser um número válido
- Dispositivo deve existir e ser do tipo `esp32_relay`
- Dispositivo não pode já ter uma placa cadastrada
- `total_channels` padrão é 16 se não especificado

**Resposta:**
```json
{
  "success": true,
  "message": "Placa criada com sucesso",
  "name": "Placa do Relé Garagem"
}
```

**Códigos de Status:**
- `201` - Placa criada com sucesso
- `400` - Dados inválidos ou dispositivo já possui placa
- `404` - Dispositivo não encontrado
- `500` - Erro interno do servidor

---

### `PATCH /api/relays/boards/{board_id}`

Atualiza configurações de uma placa de relé existente.

**Parâmetros de Path:**
- `board_id` (integer): ID da placa de relé

**Body (JSON) - Parcial:**
```json
{
  "board_model": "ESP32-RELAY-16CH-V2"
}
```

**Resposta:**
```json
{
  "message": "Placa 1 atualizada com sucesso"
}
```

**Códigos de Status:**
- `200` - Atualizada com sucesso
- `400` - Não é possível alterar número de canais após criação
- `404` - Placa não encontrada
- `500` - Erro interno do servidor

---

### `DELETE /api/relays/boards/{board_id}`

Desativa uma placa de relé e todos os seus canais (soft delete).

**Parâmetros de Path:**
- `board_id` (integer): ID da placa de relé

**Resposta:**
```json
{
  "message": "Placa 1 e seus canais desativados com sucesso"
}
```

**Códigos de Status:**
- `200` - Desativada com sucesso
- `404` - Placa não encontrada
- `500` - Erro interno do servidor

## 🔘 Endpoints de Canais de Relé

### `GET /api/relays/channels`

Lista todos os canais de relé ativos de placas ativas.

**Parâmetros de Query:**
- `board_id` (integer, opcional): Filtrar por placa específica

**Resposta:**
```json
[
  {
    "id": 1,
    "board_id": 1,
    "channel_number": 1,
    "name": "Luz Principal",
    "description": "Controla iluminação da sala principal",
    "function_type": "toggle",
    "icon": "lightbulb",
    "color": "#FFA500",
    "protection_mode": "none"
  },
  {
    "id": 2,
    "board_id": 1,
    "channel_number": 2,
    "name": "Portão Garagem",
    "description": "Acionamento do portão automático",
    "function_type": "pulse",
    "icon": "garage",
    "color": "#4CAF50",
    "protection_mode": "password"
  }
]
```

**Códigos de Status:**
- `200` - Lista retornada com sucesso
- `500` - Erro interno do servidor

---

### `PATCH /api/relays/channels/{channel_id}`

Atualiza configurações de um canal específico.

**Parâmetros de Path:**
- `channel_id` (integer): ID do canal

**Body (JSON) - Parcial:**
```json
{
  "name": "Novo Nome do Canal",
  "description": "Nova descrição",
  "function_type": "pulse",
  "icon": "lightbulb-on",
  "color": "#FF5722",
  "protection_mode": "confirmation",
  "max_activation_time": 5000,
  "allow_in_macro": true
}
```

**Campos Disponíveis:**
- `name` - Nome do canal
- `description` - Descrição detalhada
- `function_type` - `toggle`, `pulse`, `momentary`
- `icon` - Nome do ícone
- `color` - Cor em hexadecimal
- `protection_mode` - `none`, `confirmation`, `password`
- `max_activation_time` - Tempo máximo de ativação (ms)
- `allow_in_macro` - Se permite uso em macros

**Resposta:**
```json
{
  "id": 1,
  "board_id": 1,
  "channel_number": 1,
  "name": "Novo Nome do Canal",
  "description": "Nova descrição",
  "function_type": "pulse",
  "icon": "lightbulb-on",
  "color": "#FF5722",
  "protection_mode": "confirmation"
}
```

**Códigos de Status:**
- `200` - Atualizado com sucesso
- `404` - Canal não encontrado
- `400` - Dados inválidos
- `500` - Erro interno do servidor

---

### `POST /api/relays/channels/{channel_id}/reset`

Reseta todas as configurações de um canal para valores padrão.

**Parâmetros de Path:**
- `channel_id` (integer): ID do canal

**Resposta:**
```json
{
  "id": 1,
  "board_id": 1,
  "channel_number": 1,
  "name": "Canal 1",
  "description": null,
  "function_type": "toggle",
  "icon": "outlet",
  "color": "#757575",
  "protection_mode": "none"
}
```

**Códigos de Status:**
- `200` - Reset executado com sucesso
- `404` - Canal não encontrado
- `500` - Erro interno do servidor

---

### `DELETE /api/relays/channels/{channel_id}`

Desativa um canal de relé (soft delete).

**Parâmetros de Path:**
- `channel_id` (integer): ID do canal

**Resposta:**
```json
{
  "message": "Canal 1 desativado com sucesso"
}
```

**Códigos de Status:**
- `200` - Desativado com sucesso
- `404` - Canal não encontrado
- `500` - Erro interno do servidor

---

### `POST /api/relays/channels/{channel_id}/activate`

Reativa um canal de relé desativado.

**Parâmetros de Path:**
- `channel_id` (integer): ID do canal

**Resposta:**
```json
{
  "id": 1,
  "board_id": 1,
  "channel_number": 1,
  "name": "Canal 1",
  "description": "Canal reativado",
  "function_type": "toggle",
  "icon": "outlet",
  "color": "#757575",
  "protection_mode": "none"
}
```

**Códigos de Status:**
- `200` - Reativado com sucesso
- `404` - Canal não encontrado
- `500` - Erro interno do servidor

## 🛡️ Modos de Proteção

### `none`
- Sem proteção adicional
- Acionamento direto via interface

### `confirmation`
- Requer confirmação antes de acionar
- Dialog "Tem certeza?" na interface

### `password`
- Requer senha específica para acionamento
- Configurada por canal individualmente

## ⚡ Tipos de Função

### `toggle`
- Liga/desliga alternadamente
- Estado mantido até próximo comando
- Ideal para: luzes, equipamentos contínuos

### `pulse`
- Pulso rápido (padrão 1 segundo)
- Retorna ao estado inicial automaticamente
- Ideal para: portões, campainha, reset

### `momentary`
- Ativo apenas enquanto pressionado
- Desativa ao soltar o botão
- Ideal para: controles manuais

## 🎨 Padrões de Cores

- `#4CAF50` - Verde (seguro, OK)
- `#FF9800` - Laranja (atenção, cuidado)
- `#F44336` - Vermelho (perigo, crítico)
- `#2196F3` - Azul (informação, normal)
- `#9C27B0` - Roxo (especial, premium)
- `#757575` - Cinza (padrão, neutro)

## 🔄 Fluxo de Criação

1. **Registrar Dispositivo ESP32_RELAY**
   - `POST /api/devices`

2. **Criar Placa de Relé**
   - `POST /api/relays/boards`
   - Canais são criados automaticamente

3. **Configurar Canais**
   - `PATCH /api/relays/channels/{id}`
   - Definir nomes, ícones, proteções

4. **Usar em Telas**
   - Canais aparecem em `GET /api/relays/channels`
   - Podem ser associados a botões em screens

## ⚠️ Considerações

- Placas são automaticamente associadas a dispositivos ESP32_RELAY
- Canais são criados automaticamente ao criar uma placa
- Alteração do número de canais não é permitida após criação
- Desativação de placa desativa todos os canais
- IDs de canais permanecem estáveis para referência em screens
- Eventos são registrados automaticamente para auditoria

## 🔗 Integração com Telas

Os canais configurados podem ser usados em screen items:

```json
{
  "item_type": "button",
  "name": "luz_principal",
  "label": "Luz Principal",
  "action_type": "relay_toggle",
  "relay_board_id": 1,
  "relay_channel_id": 1
}
```