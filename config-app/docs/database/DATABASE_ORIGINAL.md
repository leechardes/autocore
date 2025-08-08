# Estrutura do Banco de Dados AutoCore

## 📊 Visão Geral

O banco de dados do AutoCore foi projetado para ser completamente modular e configurável, permitindo que todo o sistema seja parametrizado sem necessidade de alteração de código.

## 🗂️ Grupos de Tabelas

### 1. **Core System (Núcleo do Sistema)**

#### `devices`
- **Propósito**: Registra todos os dispositivos conectados ao sistema
- **Tipos suportados**: 
  - `app_mobile` - Aplicativo Flutter
  - `esp32_display` - Display touch 2.8"
  - `esp32_relay` - Placas de relés
  - `esp32_can` - Interface CAN FuelTech
  - `esp32_control` - Controles do volante
  - `multimedia` - Sistema multimídia
- **Campos importantes**:
  - `uuid`: Identificador único universal
  - `configuration_json`: Configurações específicas do dispositivo
  - `capabilities_json`: O que o dispositivo pode fazer

#### `relay_boards` e `relay_channels`
- **Propósito**: Gerencia placas de relés e seus canais individuais
- **Recursos**:
  - Suporte a múltiplas placas
  - Cada canal configurável individualmente
  - Tipos de função: `toggle`, `momentary`, `pulse`
  - Proteção por confirmação ou senha

### 2. **UI Configuration (Interface)**

#### `screens`
- **Propósito**: Define as telas disponíveis no sistema
- **Características**:
  - Hierarquia com `parent_id`
  - **Configuração por tipo de dispositivo**:
    - Número de colunas específico (mobile, display pequeno, display grande, web)
    - Visibilidade seletiva por dispositivo
  - Grid adaptativo baseado no dispositivo

#### `screen_items`
- **Propósito**: Elementos individuais em cada tela
- **Tipos de item**:
  - `button` - Botão simples
  - `switch` - Interruptor on/off
  - `gauge` - Medidor visual
  - `display` - Exibição de dados
  - `slider` - Controle deslizante
  - `group` - Agrupador de itens
- **Configurações por dispositivo**:
  - **Tamanho**: Diferente para cada tipo de tela
  - **Posição**: Override opcional por dispositivo
  - **Visibilidade**: Mostrar/ocultar por tipo
  - **Ícones**: Específicos para mobile vs display
  - **Labels**: Versão curta para displays pequenos
  - **Confirmações**: Diferentes por dispositivo
- **Ações suportadas**:
  - `relay` - Acionar relé
  - `can_command` - Enviar comando CAN
  - `mqtt_publish` - Publicar MQTT
  - `navigate` - Navegar para outra tela
  - `macro` - Executar macro

#### `quick_actions`
- **Propósito**: Ações rápidas acessíveis do dashboard
- **Exemplo**: "Modo Camping" que liga várias luzes de uma vez

### 3. **CAN Configuration (FuelTech)**

#### `can_signals`
- **Propósito**: Define sinais CAN para leitura
- **Dados típicos**:
  - RPM do motor
  - Temperatura
  - Pressão de óleo
  - Tensão da bateria
- **Configuração**: Scale factor, offset, unidades

#### `can_commands`
- **Propósito**: Comandos enviáveis via CAN
- **Exemplo**: Comando de partida do motor

### 4. **MQTT Configuration**

#### `mqtt_topics`
- **Propósito**: Define tópicos MQTT do sistema
- **Padrões principais**:
  ```
  autocore/devices/+/status
  autocore/devices/+/command
  autocore/relays/+/state
  autocore/can/data
  autocore/config/update
  ```

### 5. **Themes & Customization**

#### `themes`
- **Propósito**: Temas visuais do sistema
- **Personalizável**:
  - Cores principais e de estado
  - Estilos de sombra (neumorphic, flat, material)
  - Fontes e raios de borda

### 6. **User Management**

#### `users`
- **Roles disponíveis**:
  - `admin` - Acesso total
  - `technician` - Configuração e manutenção
  - `operator` - Uso normal
  - `viewer` - Apenas visualização

#### `permissions`
- **Controle granular**: Por role, resource e action
- **Actions**: `create`, `read`, `update`, `delete`, `execute`

### 7. **Automation**

#### `macros`
- **Propósito**: Automações e sequências de comandos
- **Triggers**:
  - `manual` - Acionamento manual
  - `scheduled` - Agendado (cron)
  - `condition` - Baseado em condições
  - `event` - Resposta a eventos

### 8. **Monitoring**

#### `event_logs`
- **Propósito**: Log completo de todas as ações
- **Rastreabilidade**: Quem, quando, o quê, resultado

#### `telemetry_data`
- **Propósito**: Dados de telemetria dos dispositivos
- **Uso**: Histórico, análise, diagnóstico

### 9. **Device Specific Configurations**

#### `device_display_configs`
- **Propósito**: Configurações específicas por tipo de dispositivo
- **Tipos de dispositivo**:
  - `mobile` - App Flutter
  - `display_small` - Display 2.8"
  - `display_large` - Multimídia
  - `web` - Dashboard Streamlit
  - `controls` - Controles do volante
- **Configurações**:
  - Capacidades do display (resolução, touch, cores)
  - Preferências de UI (tema, fontes, animações)
  - Layout padrão (colunas, espaçamentos)
  - Recursos disponíveis (gauges, gráficos, câmera)
  - Tipo de navegação

#### `device_control_mappings`
- **Propósito**: Mapeamento de controles físicos
- **Inputs suportados**:
  - Botões físicos (prev, next, select)
  - Gestos touch (swipe, long press)
  - Teclas de atalho
- **Ações mapeáveis**:
  - Navegação entre telas
  - Execução de comandos
  - Toggle de funções
  - Scroll em listas

### 10. **Templates**

#### `config_templates`
- **Propósito**: Templates reutilizáveis
- **Tipos**:
  - Templates de veículos completos
  - Templates de telas
  - Templates de dispositivos

## 🔄 Fluxo de Dados Principal

1. **Configuração**:
   ```
   Admin → Streamlit → Database → MQTT → Devices
   ```

2. **Comando**:
   ```
   User → App/Display → MQTT → Gateway → Relay/CAN
   ```

3. **Telemetria**:
   ```
   CAN/Sensors → ESP32 → MQTT → Gateway → Database → UI
   ```

## 🎯 Características Importantes

### Flexibilidade Total
- Uso extensivo de campos JSON para configurações dinâmicas
- Nenhuma funcionalidade hardcoded
- **Configuração granular por tipo de dispositivo**:
  - Layouts diferentes para mobile vs displays
  - Funcionalidades específicas por dispositivo
  - Otimização para cada tipo de tela

### Performance
- Índices otimizados para queries comuns
- Particionamento temporal para logs (futura implementação)

### Segurança
- Senha hash para usuários
- PIN para ações rápidas
- Níveis de proteção em comandos críticos

### Escalabilidade
- Suporte a número ilimitado de dispositivos
- Múltiplas placas de relé
- Sistema de templates

## 📝 Convenções

### Nomenclatura
- Snake_case para nomes de tabelas e colunas
- Prefixo `is_` para booleanos
- Sufixo `_at` para timestamps
- Sufixo `_json` para campos JSON

### Tipos de Dados
- `integer` para IDs e contadores
- `varchar` para strings com limite
- `text` para strings longas e JSON
- `timestamp` para datas/horas
- `boolean` para flags

### Valores Padrão
- `is_active = true` para novos registros
- `created_at = CURRENT_TIMESTAMP`
- `status = 'offline'` para dispositivos

## 🚀 Próximos Passos

1. **Criar script SQL** de criação das tabelas
2. **Implementar migrations** para versionamento
3. **Criar seeds** com dados iniciais
4. **Implementar triggers** para updated_at
5. **Criar views** para queries complexas

## 🔍 Queries Exemplo

```sql
-- Buscar todos os relés ativos de uma placa
SELECT rc.* 
FROM relay_channels rc
JOIN relay_boards rb ON rc.board_id = rb.id
WHERE rb.device_id = ? AND rc.is_active = true
ORDER BY rc.channel_number;

-- Buscar itens de uma tela para dispositivo mobile
SELECT 
  si.*,
  COALESCE(si.position_mobile, si.position) as final_position,
  COALESCE(si.size_mobile, 'normal') as final_size,
  COALESCE(si.icon_mobile, si.icon) as final_icon
FROM screen_items si
WHERE si.screen_id = ? 
  AND si.is_active = true
  AND si.show_on_mobile = true
ORDER BY final_position;

-- Buscar configuração para display pequeno
SELECT 
  s.*,
  ddc.*
FROM screens s
CROSS JOIN device_display_configs ddc
WHERE ddc.device_type = 'display_small'
  AND s.show_on_display_small = true
  AND s.is_active = true
ORDER BY s.position;

-- Log de comandos do último dia
SELECT * FROM event_logs 
WHERE event_type = 'command' 
  AND timestamp > datetime('now', '-1 day')
ORDER BY timestamp DESC;
```

## 📊 Estimativa de Volumetria

- **Dispositivos**: ~10-20 registros
- **Relés**: ~50-200 canais total
- **Telas**: ~10-20 telas
- **Itens de tela**: ~100-500 itens
- **Logs**: ~1000-5000/dia (com limpeza periódica)
- **Telemetria**: ~10000-50000/dia (com agregação)

---

*Esta estrutura foi projetada para suportar todas as necessidades atuais e futuras do AutoCore, mantendo flexibilidade e performance.*