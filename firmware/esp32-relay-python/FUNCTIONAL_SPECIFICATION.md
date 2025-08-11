# 📋 ESP32 Relay Python - Especificação Funcional Completa

## 🎯 1. VISÃO GERAL DO SISTEMA

### Propósito do Firmware
O ESP32 Relay Python é um firmware MicroPython para controle de relés integrado ao ecossistema AutoCore. Oferece configuração via interface web, controle local e remoto via MQTT, além de telemetria em tempo real.

### Arquitetura Geral
```
ESP32 Relay System
├── Interface Web (HTTP Server) - Configuração e monitoramento
├── Cliente WiFi - Conectividade de rede
├── Cliente MQTT - Comunicação com backend
├── Controle GPIO - Acionamento físico dos relés
├── Sistema de Arquivos - Persistência de configurações
└── Telemetria - Monitoramento de status e métricas
```

### Fluxo de Funcionamento
1. **Boot**: Inicialização e carregamento de configurações
2. **Rede**: Tentativa de conexão WiFi ou criação de Access Point
3. **Registro**: Auto-registro com backend AutoCore
4. **MQTT**: Conexão com broker para controle remoto
5. **Operação**: Servidor HTTP + Loop MQTT em paralelo

### Estados do Sistema
- **Configuração**: Modo Access Point para setup inicial
- **Conectado**: Operação normal com WiFi conectado
- **Online**: Sistema completo com MQTT ativo
- **Offline**: Funcionamento local apenas

## ✨ 2. FUNCIONALIDADES COMPLETAS

### 2.1 Sistema de Configuração WiFi

#### Nome e Descrição
**Configuração WiFi Inteligente** - Sistema de configuração de rede com interface web responsiva.

#### Quando é Ativada
- Primeira inicialização (sem configuração)
- Falha na conexão WiFi configurada
- Reset de fábrica manual
- Timeout de conexão (15 segundos)

#### Pré-requisitos
- ESP32 inicializado
- Interface web disponível
- Navegador compatível (HTML5)

#### Comportamento Esperado
- Criação automática de Access Point com SSID único
- Interface web acessível em 192.168.4.1
- Formulário de configuração responsivo
- Validação de credenciais em tempo real
- Salvamento seguro da configuração

#### Casos de Erro
- **Credenciais inválidas**: Mantém modo AP, exibe mensagem de erro
- **Timeout de conexão**: Retorna ao modo AP após 15 segundos
- **Erro de salvamento**: Exibe alerta, mantém configuração anterior

### 2.2 Auto-Registro com Backend

#### Nome e Descrição
**Auto-Registro Inteligente** - Sistema de registro automático com backend AutoCore.

#### Quando é Ativada
- Após conexão WiFi bem-sucedida
- A cada inicialização em modo conectado
- Quando configuração de backend é alterada

#### Pré-requisitos
- Conexão WiFi estabelecida
- IP e porta do backend configurados
- Backend AutoCore acessível

#### Comportamento Esperado
- Requisição POST para `/api/devices`
- Envio de dados do dispositivo (UUID, MAC, IP)
- Recebimento de credenciais MQTT
- Salvamento automático da configuração
- Logs informativos do processo

#### Casos de Erro
- **Backend inacessível**: Usa configuração MQTT padrão
- **Erro de registro**: Continua sem MQTT
- **Dados inválidos**: Retry com dados corrigidos

### 2.3 Sistema MQTT Completo

#### Nome e Descrição
**Cliente MQTT Robusto** - Comunicação bidirecional com broker MQTT para controle e telemetria.

#### Quando é Ativada
- Após registro bem-sucedido com backend
- Configuração MQTT válida disponível
- Conexão de rede estável

#### Pré-requisitos
- Credenciais MQTT válidas
- Broker MQTT acessível
- Thread disponível para loop MQTT

#### Comportamento Esperado
- Conexão automática com credenciais
- Subscrição a tópico de comandos
- Publicação de status a cada 30 segundos
- Processamento de comandos em tempo real
- Reconexão automática em falhas

#### Casos de Erro
- **Falha de conexão**: Retry até 5 tentativas
- **Timeout de comando**: Log de erro, continua operação
- **Thread falha**: Sistema continua apenas com HTTP

### 2.4 Controle de Relés

#### Nome e Descrição
**Controle GPIO Inteligente** - Sistema de controle físico de relés com persistência de estado.

#### Quando é Ativada
- Comandos MQTT recebidos
- Solicitações via interface web
- Restauração de estado após boot

#### Pré-requisitos
- GPIOs configurados corretamente
- Estados válidos no range 0-15
- Hardware de relé conectado

#### Comportamento Esperado
- Acionamento físico dos pinos GPIO
- Salvamento imediato dos estados
- Logs detalhados das operações
- Validação de canais antes do controle

#### Casos de Erro
- **Canal inválido**: Log de erro, operação ignorada
- **Falha de GPIO**: Log de erro, tenta novamente
- **Erro de salvamento**: Log de aviso, estado perdido

### 2.5 Interface Web Responsiva

#### Nome e Descrição
**Dashboard de Configuração** - Interface web moderna para configuração e monitoramento.

#### Quando é Ativada
- Sempre disponível quando sistema ativo
- Acessível via IP do dispositivo
- Modo AP ou Station

#### Pré-requisitos
- Servidor HTTP rodando (porta 80)
- Navegador com suporte HTML5/CSS3
- JavaScript habilitado (opcional)

#### Comportamento Esperado
- Interface responsiva (mobile-first)
- Formulários com validação
- Status em tempo real
- Feedback visual das operações
- Suporte a UTF-8

#### Casos de Erro
- **Timeout de requisição**: Erro 500, tenta novamente
- **Dados malformados**: Validação, exibe erro
- **Memória insuficiente**: Página simplificada

### 2.6 Telemetria e Monitoramento

#### Nome e Descrição
**Sistema de Telemetria** - Coleta e envio de métricas de sistema em tempo real.

#### Quando é Ativada
- A cada 30 segundos via MQTT
- Sob demanda via comando `get_status`
- Requisições HTTP `/api/status`

#### Pré-requisitos
- Sistema operacional
- Conexão ativa (WiFi/MQTT)
- Memória suficiente para coleta

#### Comportamento Esperado
- Coleta automática de métricas
- Envio via MQTT em formato JSON
- Dados precisos e atualizados
- Baixo impacto na performance

#### Casos de Erro
- **Falha na coleta**: Log de aviso, dados padrão
- **Erro de envio**: Retry na próxima iteração
- **Memória insuficiente**: Métricas reduzidas

## ⚙️ 3. CONFIGURAÇÕES

### 3.1 Configuração do Dispositivo

| Parâmetro | Valor Padrão | Validação | Persistência |
|-----------|--------------|-----------|--------------|
| `device_id` | `esp32_relay_{mac_suffix}` | Alfanumérico, max 64 chars | config.json |
| `device_name` | `ESP32 Relay {mac_suffix}` | UTF-8, max 128 chars | config.json |
| `relay_channels` | 16 | Inteiro entre 1-16 | config.json |
| `configured` | false | Boolean | config.json |

### 3.2 Configuração WiFi

| Parâmetro | Valor Padrão | Validação | Persistência |
|-----------|--------------|-----------|--------------|
| `wifi_ssid` | "" | String não vazia | config.json |
| `wifi_password` | "" | Min 8 chars ou vazio | config.json |
| `ap_ssid` | `ESP32-Relay-{suffix}` | Gerado automaticamente | Temporário |
| `ap_password` | "12345678" | Fixo | Temporário |

**Timeout de Conexão**: 15 segundos  
**Tentativas de Reconexão**: Infinitas com delay de 1 segundo

### 3.3 Configuração Backend

| Parâmetro | Valor Padrão | Validação | Persistência |
|-----------|--------------|-----------|--------------|
| `backend_ip` | "10.0.10.100" | IPv4 válido | config.json |
| `backend_port` | 8081 | Porta entre 1-65535 | config.json |

**Endpoints Backend**:
- `POST /api/devices` - Registro de dispositivo
- `GET /api/mqtt/config` - Configuração MQTT

### 3.4 Configuração MQTT

| Parâmetro | Valor Padrão | Validação | Persistência |
|-----------|--------------|-----------|--------------|
| `mqtt_broker` | "10.0.10.100" | IPv4 válido | config.json |
| `mqtt_port` | 1883 | Porta entre 1-65535 | config.json |
| `mqtt_user` | `device_id` | String não vazia | config.json |
| `mqtt_password` | "" | String | config.json |
| `mqtt_registered` | false | Boolean | config.json |

**Timeouts**: 
- Conexão: 10 segundos
- Keepalive: 60 segundos
- Reconexão: 10 segundos entre tentativas

### 3.5 Estados dos Relés

| Parâmetro | Valor Padrão | Validação | Persistência |
|-----------|--------------|-----------|--------------|
| `relay_states` | `[0] * 16` | Array de 16 inteiros (0 ou 1) | config.json |

**Mapeamento GPIO**:
```
Canal 0-15: Pinos [2,4,5,12,13,14,15,16,17,18,19,21,22,23,25,26]
```

## 🌐 4. INTERFACE WEB

### 4.1 Página Principal (/)

#### Método: GET
- **URL**: `http://{ip}/`
- **Função**: Exibir dashboard de configuração
- **Template**: HTML5 responsivo com CSS inline
- **Timeout**: 2 segundos por requisição

#### Campos do Formulário:
1. **Nome do Dispositivo** (somente leitura)
   - Valor: `device_name` da configuração
   - Tipo: `text` desabilitado

2. **SSID WiFi** (obrigatório)
   - Placeholder: "Nome do seu WiFi"
   - Tipo: `text` required
   - Validação: Não vazio

3. **Senha WiFi** (opcional)
   - Placeholder: "Deixe vazio para manter senha atual"
   - Tipo: `password`
   - Comportamento: Preserva senha existente se vazio

4. **IP do Backend** (obrigatório)
   - Placeholder: "Ex: 192.168.1.100"
   - Tipo: `text` required
   - Validação: Formato IPv4

5. **Porta do Backend** (obrigatório)
   - Placeholder: "Ex: 8081"
   - Tipo: `number` required
   - Range: 1-65535

6. **Canais de Relé** (obrigatório)
   - Placeholder: "Ex: 16"
   - Tipo: `number` required
   - Range: 1-16

#### Feedback Visual:
- **Status Box**: Informações do dispositivo
- **Mensagens**: Success/Error/Info com cores
- **Loading**: Indicadores de progresso
- **Responsivo**: Mobile-first design

### 4.2 Salvamento de Configuração (/config)

#### Método: POST
- **URL**: `http://{ip}/config`
- **Content-Type**: `application/x-www-form-urlencoded`
- **Encoding**: UTF-8

#### Validações de Entrada:
- SSID não pode ser vazio
- Porta deve ser número válido
- Canais deve estar entre 1-16
- IP deve ter formato válido

#### Comportamento de Salvamento:
1. Parse dos dados POST
2. Comparação com configuração atual
3. Validação de todos os campos
4. Salvamento no config.json
5. Tentativa de conexão WiFi (se alterado)
6. Feedback visual na interface

### 4.3 Reinicialização (/reboot)

#### Método: POST
- **URL**: `http://{ip}/reboot`
- **Ação**: `machine.reset()`
- **Delay**: 2 segundos
- **Resposta**: HTML com auto-refresh

### 4.4 Reset de Fábrica (/reset)

#### Método: POST
- **URL**: `http://{ip}/reset`
- **Ação**: 
  1. Remove `config.json`
  2. `machine.reset()`
- **Delay**: 2 segundos
- **Resposta**: HTML com auto-refresh

## 🔌 5. ENDPOINTS HTTP DETALHADOS

### 5.1 GET / (Página Principal)

**URL Completa**: `http://{device_ip}/`

**Parâmetros**: Nenhum

**Headers Necessários**: Nenhum

**Formato da Resposta**: HTML5 com CSS inline

**Códigos de Status**:
- `200 OK`: Página carregada com sucesso
- `500 Internal Server Error`: Erro na geração do HTML

**Exemplo de Resposta**:
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ESP32 Config v2</title>
    <!-- CSS inline -->
</head>
<body>
    <!-- Interface completa -->
</body>
</html>
```

### 5.2 POST /config (Salvamento)

**URL Completa**: `http://{device_ip}/config`

**Parâmetros (Form Data)**:
- `wifi_ssid` (string, required): Nome da rede WiFi
- `wifi_password` (string, optional): Senha do WiFi
- `backend_ip` (string, required): IP do backend
- `backend_port` (number, required): Porta do backend
- `relay_channels` (number, required): Número de canais

**Headers Necessários**: 
- `Content-Type: application/x-www-form-urlencoded`

**Formato da Resposta**: HTML com mensagem de feedback

**Códigos de Status**:
- `200 OK`: Configuração processada (com ou sem sucesso)

**Validações Aplicadas**:
- SSID não vazio
- Backend IP formato válido
- Porta entre 1-65535
- Canais entre 1-16

**Exemplo de Requisição**:
```
POST /config HTTP/1.1
Content-Type: application/x-www-form-urlencoded

wifi_ssid=MinhaRede&wifi_password=minhasenha&backend_ip=192.168.1.100&backend_port=8081&relay_channels=16
```

### 5.3 GET /api/status (Status JSON)

**URL Completa**: `http://{device_ip}/api/status`

**Parâmetros**: Nenhum

**Headers Necessários**: Nenhum

**Formato da Resposta**: JSON

**Códigos de Status**:
- `200 OK`: Status obtido com sucesso
- `503 Service Unavailable`: Sistema não inicializado

**Exemplo de Resposta**:
```json
{
    "device_id": "esp32_relay_93ce30",
    "device_name": "ESP32 Relay 93ce30",
    "wifi_connected": true,
    "ip": "192.168.1.105",
    "mqtt_registered": true,
    "relay_states": [0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1],
    "uptime": 3600,
    "free_memory": 45000
}
```

### 5.4 POST /reboot (Reinicialização)

**URL Completa**: `http://{device_ip}/reboot`

**Parâmetros**: Nenhum

**Headers Necessários**: Nenhum

**Formato da Resposta**: HTML com auto-refresh

**Códigos de Status**:
- `200 OK`: Comando de reboot aceito

**Comportamento**: Sistema reinicia após 2 segundos

### 5.5 POST /reset (Reset de Fábrica)

**URL Completa**: `http://{device_ip}/reset`

**Parâmetros**: Nenhum

**Headers Necessários**: Nenhum

**Formato da Resposta**: HTML com auto-refresh

**Códigos de Status**:
- `200 OK`: Reset aceito

**Comportamento**: Remove configurações e reinicia

## 📡 6. INTEGRAÇÃO MQTT

### 6.1 Processo de Registro

1. **Conexão WiFi**: Estabelece conectividade
2. **Coleta de Dados**: MAC, IP, versão do firmware
3. **Requisição POST**: Envia dados para backend
4. **Recepção de Credenciais**: Broker, usuário, senha
5. **Salvamento**: Persiste configuração MQTT
6. **Conexão MQTT**: Estabelece link com broker

**URL de Registro**: `http://{backend_ip}:{backend_port}/api/devices`

**Payload de Registro**:
```json
{
    "uuid": "esp32_relay_93ce30",
    "name": "ESP32 Relay 93ce30",
    "type": "esp32_relay",
    "mac_address": "aa:bb:cc:dd:ee:ff",
    "ip_address": "192.168.1.105",
    "firmware_version": "2.0.0",
    "hardware_version": "ESP32-WROOM-32"
}
```

### 6.2 Autenticação

**Método**: Username/Password
- **Client ID**: `device_id`
- **Username**: Recebido do backend
- **Password**: Recebido do backend
- **Keep Alive**: 60 segundos

### 6.3 Tópicos Utilizados

#### Subscrição (Comandos)
**Tópico**: `autocore/devices/{device_id}/command`

**Formato das Mensagens**:
```json
{"command": "relay_on", "channel": 0}
{"command": "relay_off", "channel": 3}
{"command": "get_status"}
{"command": "reboot"}
```

#### Publicação (Status)
**Tópico**: `autocore/devices/{device_id}/status`

**Formato da Mensagem**:
```json
{
    "uuid": "esp32_relay_93ce30",
    "status": "online",
    "uptime": 3600,
    "wifi_rssi": -45,
    "free_memory": 45000,
    "relay_states": [0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1]
}
```

### 6.4 Comandos Aceitos

#### relay_on
- **Função**: Liga relé específico
- **Parâmetros**: `channel` (0-15)
- **Ação**: GPIO HIGH, salva estado
- **Resposta**: Log de confirmação

#### relay_off
- **Função**: Desliga relé específico
- **Parâmetros**: `channel` (0-15)
- **Ação**: GPIO LOW, salva estado
- **Resposta**: Log de confirmação

#### get_status
- **Função**: Solicita publicação de status
- **Parâmetros**: Nenhum
- **Ação**: Publica status imediatamente
- **Resposta**: Mensagem de status completa

#### reboot
- **Função**: Reinicia o ESP32
- **Parâmetros**: Nenhum
- **Ação**: `machine.reset()` após 1 segundo
- **Resposta**: Log de confirmação

### 6.5 Telemetria Enviada

**Frequência**: A cada 30 segundos

**Métricas Coletadas**:
- UUID do dispositivo
- Status de conexão
- Uptime em segundos
- RSSI do WiFi
- Memória livre disponível
- Estados atuais de todos os relés

### 6.6 Reconexão Automática

**Tentativas Máximas**: 5
**Intervalo entre Tentativas**: 10 segundos
**Comportamento em Falha**: 
- Log de erro
- Reset do contador se sucesso
- Parada do loop MQTT se exceder máximo

## 🔌 7. CONTROLE DE RELÉS

### 7.1 Número de Canais
**Padrão**: 16 canais (configurável de 1-16)

### 7.2 Mapeamento GPIO
```
Canal  | GPIO | Função
-------|------|--------
0      | 2    | Relé 1
1      | 4    | Relé 2
2      | 5    | Relé 3
3      | 12   | Relé 4
4      | 13   | Relé 5
5      | 14   | Relé 6
6      | 15   | Relé 7
7      | 16   | Relé 8
8      | 17   | Relé 9
9      | 18   | Relé 10
10     | 19   | Relé 11
11     | 21   | Relé 12
12     | 22   | Relé 13
13     | 23   | Relé 14
14     | 25   | Relé 15
15     | 26   | Relé 16
```

### 7.3 Estados Possíveis
- **0**: Desligado (GPIO LOW)
- **1**: Ligado (GPIO HIGH)

### 7.4 Persistência de Estados
- **Arquivo**: `config.json`
- **Campo**: `relay_states`
- **Formato**: Array de 16 inteiros (0 ou 1)
- **Salvamento**: Imediato após mudança de estado

### 7.5 Comandos de Controle

#### Via MQTT
```json
{"command": "relay_on", "channel": 0}   // Liga canal 0
{"command": "relay_off", "channel": 5}  // Desliga canal 5
```

#### Via HTTP (futuro)
- Endpoint planejado: `/api/relay/{channel}/{state}`

**Validações**:
- Canal deve estar entre 0 e (relay_channels - 1)
- Estado deve ser 0 ou 1
- GPIO deve estar disponível

## 📶 8. REDE E CONECTIVIDADE

### 8.1 Modos de Operação

#### Modo Station (STA)
- **Quando**: WiFi configurado e conectado
- **IP**: Obtido via DHCP
- **Funcionalidade**: Completa (HTTP + MQTT)

#### Modo Access Point (AP)
- **Quando**: Primeira inicialização ou falha de conexão
- **SSID**: `ESP32-Relay-{suffix}`
- **Senha**: `12345678`
- **IP**: `192.168.4.1`
- **Funcionalidade**: Apenas HTTP (configuração)

### 8.2 Processo de Configuração WiFi

1. **Verificação**: Existe configuração válida?
2. **Tentativa**: Conectar com credenciais salvas
3. **Timeout**: 15 segundos para estabelecer conexão
4. **Fallback**: Criar AP se falha na conexão
5. **Interface**: Servir página de configuração

### 8.3 Credenciais Padrão do AP
- **SSID**: `ESP32-Relay-{últimos_6_dígitos_mac}`
- **Senha**: `12345678` (fixo)
- **Segurança**: WPA2-PSK
- **Canal**: Auto (geralmente 1)

### 8.4 Timeout de Conexão
**WiFi Station**: 15 segundos máximo
- 1 segundo por tentativa
- 15 tentativas total
- Log de progresso a cada tentativa

### 8.5 Fallback para AP
**Condições**:
- Primeira inicialização
- Credenciais inválidas
- Rede indisponível
- Timeout de conexão

**Comportamento**:
- Desativa modo Station
- Ativa modo Access Point
- Inicia servidor HTTP na porta 80
- Log de status e credenciais

## 🚀 9. SISTEMA DE BOOT

### 9.1 Sequência de Inicialização

1. **Importações** (0-2s)
   - Carregamento de bibliotecas
   - Verificação de dependências
   - Logs de disponibilidade

2. **Configuração** (2-3s)
   - Geração de ID único
   - Carregamento do config.json
   - Merge com configuração padrão

3. **Rede** (3-18s)
   - Tentativa de conexão WiFi
   - Timeout de 15 segundos
   - Fallback para AP se necessário

4. **Backend** (18-25s)
   - Registro com backend AutoCore
   - Obtenção de credenciais MQTT
   - Salvamento de configuração

5. **MQTT** (25-30s)
   - Conexão com broker
   - Subscrição a tópicos
   - Início da thread MQTT

6. **HTTP** (30s+)
   - Início do servidor web
   - Sistema pronto para operação

### 9.2 Verificações Realizadas

#### Sistema
- ✅ Memória suficiente disponível
- ✅ Sistema de arquivos funcionando
- ✅ GPIOs acessíveis

#### Rede
- ✅ Interface WiFi ativa
- ✅ Configuração WiFi válida
- ✅ Conectividade de internet

#### Backend
- ✅ IP e porta configurados
- ✅ Backend respondendo
- ✅ Endpoints disponíveis

#### MQTT
- ✅ Credenciais válidas
- ✅ Broker acessível
- ✅ Tópicos criados

### 9.3 Decisões de Modo

#### Station Mode
**Condições**:
- `configured = true`
- `wifi_ssid` não vazio
- `wifi_password` disponível
- Conexão bem-sucedida

#### AP Mode
**Condições**:
- Primeira inicialização
- Falha na conexão Station
- Reset de fábrica
- Configuração inválida

### 9.4 Tempo de Boot Esperado

**Cenário Ideal** (com WiFi configurado):
- Boot completo: 30-35 segundos
- Interface web: 8-10 segundos
- MQTT online: 30 segundos

**Cenário AP** (primeira inicialização):
- Boot em AP: 5-8 segundos
- Interface web: 8 segundos

## ❌ 10. GESTÃO DE ERROS

### 10.1 Tipos de Erro Tratados

#### Erros de Sistema
- **Memória insuficiente**: Limpeza automática, interface simplificada
- **Sistema de arquivos**: Criação de configuração padrão
- **GPIO indisponível**: Log de erro, continua sem controle físico

#### Erros de Rede
- **WiFi indisponível**: Fallback para AP mode
- **Timeout de conexão**: Retry configurável
- **Perda de conexão**: Reconexão automática

#### Erros de MQTT
- **Broker inacessível**: Retry com backoff exponencial
- **Credenciais inválidas**: Log de erro, usa configuração padrão
- **Thread falha**: Reinicialização da thread

#### Erros HTTP
- **Requisição malformada**: Retorna 400 Bad Request
- **Timeout de cliente**: Encerra conexão, continua operação
- **Erro interno**: Retorna 500, log de erro

### 10.2 Comportamento em Cada Erro

#### Falha de WiFi
1. Log detalhado do erro
2. Tentativa de reconexão (15s)
3. Fallback para AP mode
4. Interface de configuração disponível

#### Erro de Backend
1. Log do erro HTTP
2. Usa configuração MQTT padrão
3. Continua operação limitada
4. Retry em próximo boot

#### Falha MQTT
1. Log de erro com detalhes
2. Contador de tentativas
3. Backoff entre tentativas
4. Fallback para HTTP-only

#### Erro GPIO
1. Log específico do canal/pino
2. Marca canal como inativo
3. Continua com outros canais
4. Estado salvo como "erro"

### 10.3 Recuperação Automática

#### Reconexão WiFi
- **Frequência**: A cada 60 segundos
- **Método**: `sta.connect()` com credenciais salvas
- **Timeout**: 15 segundos por tentativa
- **Limite**: Infinitas tentativas

#### Reconexão MQTT
- **Frequência**: A cada 10 segundos
- **Método**: Recriação do cliente
- **Limite**: 5 tentativas consecutivas
- **Reset**: Contador zerado em caso de sucesso

#### Limpeza de Memória
- **Frequência**: Após cada requisição HTTP
- **Método**: `gc.collect()`
- **Monitoramento**: Log de memória livre
- **Threshold**: < 5KB disponível

### 10.4 Logs e Mensagens

#### Formato dos Logs
```
[EMOJI] [CATEGORIA] Mensagem detalhada
```

#### Exemplos
```
✅ [WIFI] Conectado! IP: 192.168.1.105
❌ [MQTT] Erro de conexão: -2 (timeout)
🔌 [GPIO] GPIO 2 (Canal 0): ON
⚠️ [HTTP] Memória baixa: 3.5KB livre
```

#### Níveis de Log
- **✅ Info**: Operações normais
- **⚠️ Warning**: Situações de atenção
- **❌ Error**: Falhas que precisam correção
- **🔄 Debug**: Informações de desenvolvimento

## 🔄 11. PROCESSOS AUTOMÁTICOS

### 11.1 Auto-registro com Backend

**Frequência**: A cada inicialização conectada
**Processo**:
1. Coleta dados do dispositivo
2. POST para `/api/devices`
3. Processa resposta do backend
4. Salva credenciais MQTT
5. Log de resultado

**Backoff Strategy**: Não se aplica (apenas no boot)

### 11.2 Publicação de Telemetria

**Frequência**: A cada 30 segundos
**Processo**:
1. Coleta métricas do sistema
2. Monta JSON de status
3. Publica via MQTT
4. Log de confirmação

**Métricas Coletadas**:
- Uptime (em segundos desde boot)
- RSSI do WiFi
- Memória livre
- Estados de todos os relés

### 11.3 Reconexão WiFi

**Condições de Trigger**:
- Perda de conectividade detectada
- Status `not connected` em verificação

**Processo**:
1. Detecta desconexão
2. Aguarda 5 segundos
3. Tenta reconectar com credenciais salvas
4. Log de tentativa
5. Retry em caso de falha

### 11.4 Reconexão MQTT

**Condições de Trigger**:
- Exception na thread MQTT
- Timeout em `check_msg()`
- Erro de publicação

**Processo**:
1. Detecta falha MQTT
2. Log de erro com detalhes
3. Incrementa contador de tentativas
4. Aguarda 10 segundos
5. Recria cliente MQTT
6. Tenta reconexão

**Limite de Tentativas**: 5 consecutivas

### 11.5 Limpeza de Memória

**Frequência**: Após cada requisição HTTP
**Processo**:
1. Chama `gc.collect()`
2. Verifica memória livre
3. Log se abaixo de 10KB
4. Interface simplificada se <5KB

**Estratégia de Emergência**:
- Remove dados não essenciais
- Usa HTML minimalista
- Para threads não críticas

## 🛠️ 12. COMANDOS E OPERAÇÕES

### 12.1 Reset de Fábrica

**Trigger**: POST para `/reset` ou comando MQTT
**Processo**:
1. Remove arquivo `config.json`
2. Log de confirmação
3. Delay de 2 segundos
4. `machine.reset()`

**Estado Pós-Reset**:
- Configuração padrão carregada
- Modo AP ativado
- Interface de configuração disponível

### 12.2 Reboot do Sistema

**Trigger**: POST para `/reboot` ou comando MQTT
**Processo**:
1. Log de confirmação
2. Delay de 2 segundos
3. `machine.reset()`

**Preservação**:
- Todas as configurações mantidas
- Estados de relés preservados
- Logs perdidos (volatile)

### 12.3 Atualização de Configuração

**Trigger**: POST para `/config`
**Processo**:
1. Parse dos dados recebidos
2. Validação de todos os campos
3. Comparação com configuração atual
4. Merge inteligente de dados
5. Salvamento em `config.json`
6. Aplicação imediata das mudanças

### 12.4 Backup de Configuração

**Método**: Download via `/api/config` (planejado)
**Formato**: JSON com configuração completa
**Exclusões**: Senhas sensíveis mascaradas

**Estrutura do Backup**:
```json
{
    "device_info": {
        "id": "esp32_relay_93ce30",
        "name": "ESP32 Relay 93ce30",
        "firmware": "2.0.0"
    },
    "network": {
        "wifi_ssid": "MinhaRede",
        "wifi_password": "********"
    },
    "backend": {
        "ip": "192.168.1.100",
        "port": 8081
    },
    "mqtt": {
        "broker": "192.168.1.100",
        "port": 1883,
        "registered": true
    },
    "relays": {
        "channels": 16,
        "states": [0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0]
    }
}
```

## 🔐 13. SEGURANÇA

### 13.1 Autenticação MQTT

**Método**: Username/Password
- Credenciais únicas por dispositivo
- Geradas pelo backend automaticamente
- Armazenadas criptograficamente (planejado)

### 13.2 Senha do AP

**Configuração Atual**: Fixa ("12345678")
**Segurança**: WPA2-PSK
**Limitação**: 8 caracteres mínimos

**Melhorias Planejadas**:
- Senha baseada no MAC address
- Opção de senha customizada
- WPA3 quando suportado

### 13.3 Proteção de Configurações

**Validações de Entrada**:
- Comprimento máximo de strings
- Formato de IP addresses
- Range de portas válidas
- Escape de caracteres especiais

**Sanitização**:
- Remove caracteres de controle
- Valida encoding UTF-8
- Previne injeção de comandos

### 13.4 Validações de Entrada

#### SSID WiFi
- **Tamanho**: 1-32 caracteres
- **Caracteres**: UTF-8 válidos
- **Proibidos**: Caracteres de controle

#### Senhas
- **Tamanho WiFi**: 8-63 caracteres ou vazio
- **Tamanho MQTT**: Qualquer (definido pelo backend)
- **Encoding**: UTF-8

#### IPs e Portas
- **IP**: Formato IPv4 válido (xxx.xxx.xxx.xxx)
- **Porta**: Integer entre 1-65535
- **Validação**: Regex + conversão numérica

#### Dados de Relé
- **Canal**: Integer entre 0-(channels-1)
- **Estado**: 0 ou 1 apenas
- **Range Check**: Validação antes do controle GPIO

## 📋 14. EXEMPLOS DE USO COMPLETOS

### 14.1 Configuração Inicial

**Cenário**: ESP32 novo, primeira inicialização

**Passos**:
1. **Power-on**: ESP32 inicia em modo AP
2. **Conectar**: Smartphone/PC conecta ao WiFi `ESP32-Relay-XXXXXX`
3. **Navegação**: Abrir navegador em `http://192.168.4.1`
4. **Configuração**: Preencher formulário
   - SSID: "MinhaRede"
   - Senha: "minhasenha123"
   - Backend IP: "192.168.1.100"
   - Backend Port: "8081"
   - Canais: "16"
5. **Salvamento**: Clicar "Salvar Configuração"
6. **Conexão**: ESP32 conecta automaticamente ao WiFi
7. **Registro**: Sistema registra com backend AutoCore
8. **Operação**: MQTT ativo, sistema pronto

**Duração Total**: 2-3 minutos

### 14.2 Mudança de WiFi

**Cenário**: Mudança de rede WiFi

**Passos**:
1. **Acesso**: Navegar para `http://{ip_atual}`
2. **Login**: Interface web carregada
3. **Edição**: Alterar SSID para nova rede
4. **Senha**: Informar nova senha WiFi
5. **Salvamento**: Confirmar alterações
6. **Reconexão**: ESP32 tenta nova rede
7. **Sucesso**: Sistema operacional na nova rede

**Fallback**: Se falha, volta ao modo AP para reconfiguração

### 14.3 Controle via MQTT

**Cenário**: Controlar relés remotamente

**Pré-requisitos**:
- ESP32 conectado e registrado
- Cliente MQTT (mosquitto, Python, etc.)
- Acesso ao broker MQTT

**Comandos**:

```bash
# Ligar relé do canal 0
mosquitto_pub -h 192.168.1.100 \
  -t "autocore/devices/esp32_relay_93ce30/command" \
  -m '{"command":"relay_on","channel":0}'

# Desligar relé do canal 5
mosquitto_pub -h 192.168.1.100 \
  -t "autocore/devices/esp32_relay_93ce30/command" \
  -m '{"command":"relay_off","channel":5}'

# Solicitar status
mosquitto_pub -h 192.168.1.100 \
  -t "autocore/devices/esp32_relay_93ce30/command" \
  -m '{"command":"get_status"}'

# Monitorar status
mosquitto_sub -h 192.168.1.100 \
  -t "autocore/devices/+/status" -v
```

**Resposta Esperada**:
```json
{
    "uuid": "esp32_relay_93ce30",
    "status": "online",
    "uptime": 1800,
    "wifi_rssi": -42,
    "free_memory": 47500,
    "relay_states": [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
}
```

### 14.4 Monitoramento de Status

**Cenário**: Acompanhar sistema em tempo real

**Métodos**:

#### Via HTTP
```bash
curl http://192.168.1.105/api/status
```

#### Via MQTT
```bash
mosquitto_sub -h 192.168.1.100 -t "autocore/devices/+/status"
```

#### Via Interface Web
1. Abrir `http://192.168.1.105`
2. Visualizar status box com informações atuais
3. Verificar estados dos relés
4. Monitorar conectividade

### 14.5 Reset e Recuperação

**Cenário A**: Sistema com problema, precisa reset

**Reset Suave** (via interface):
1. Acessar interface web
2. Clicar "Reiniciar Sistema"
3. Aguardar 30 segundos para reboot completo

**Reset de Fábrica** (via interface):
1. Acessar interface web
2. Clicar "Reset de Fábrica"
3. Sistema volta ao modo AP
4. Reconfigurar do zero

**Cenário B**: Sistema inacessível via rede

**Reset Físico**:
1. Desligar alimentação
2. Pressionar botão BOOT (se disponível)
3. Religar mantendo BOOT pressionado
4. Sistema inicia em modo de emergência AP

**Recuperação**:
1. Conectar ao AP de emergência
2. Acessar interface de configuração
3. Reconfigurar rede e backend
4. Sistema volta ao normal

## ⚠️ 15. LIMITAÇÕES E CONSIDERAÇÕES

### 15.1 Limites de Memória

**RAM Disponível**: ~80-100KB no ESP32
**Uso Típico**:
- Sistema base: 30-40KB
- Interface web: 15-25KB
- Cliente MQTT: 10-15KB
- Buffers: 5-10KB

**Otimizações Aplicadas**:
- HTML inline (evita arquivos externos)
- Limpeza automática de memória
- Interface simplificada em emergência
- JSON minimalista

### 15.2 Timeouts Configurados

| Operação | Timeout | Comportamento |
|----------|---------|---------------|
| Conexão WiFi | 15 segundos | Fallback para AP |
| Requisição HTTP | 10 segundos | Erro, retry |
| Cliente HTTP | 2 segundos | Encerra conexão |
| Conexão MQTT | 10 segundos | Retry com backoff |
| Keep-alive MQTT | 60 segundos | Reconnect automático |

### 15.3 Número Máximo de Reconexões

**MQTT**: 5 tentativas consecutivas
- Reset em caso de sucesso
- Parada da thread se exceder limite
- Sistema continua apenas com HTTP

**WiFi**: Infinitas tentativas
- Intervalo de 60 segundos
- Fallback para AP se necessário
- Log de cada tentativa

### 15.4 Tamanho Máximo de Mensagens

**HTTP Request**: 2048 bytes
- Limitado pelo buffer de recepção
- Suficiente para formulários de configuração
- Requests maiores são truncadas

**MQTT Payload**: 512 bytes (typical)
- Limitado pela biblioteca umqtt
- Suficiente para comandos JSON
- Payloads maiores podem falhar

**JSON Config**: 4KB máximo
- Limitado pelo sistema de arquivos
- Configuração atual: ~500 bytes
- Margem suficiente para expansão

### 15.5 Considerações de Hardware

#### GPIOs Utilizados
- **Total Disponível**: 36 pinos
- **Utilizados**: 16 para relés
- **Reservados**: TX/RX (1,3), Flash (6-11)
- **Livres**: Suficientes para expansão

#### Alimentação
- **Consumo Base**: ~100mA (WiFi ativo)
- **Consumo Pico**: ~200mA (transmissão)
- **Recomendação**: Fonte 5V/1A mínimo

#### Temperatura
- **Operação**: -40°C a +85°C
- **Armazenamento**: -40°C a +125°C
- **Consideração**: Dissipação de calor se muitos relés ativos

### 15.6 Limitações de Funcionalidade

#### Não Implementado Atualmente
- ❌ HTTPS/TLS (apenas HTTP)
- ❌ Autenticação web (acesso livre)
- ❌ OTA (Over-the-Air updates)
- ❌ Logs persistentes
- ❌ Configuração de GPIO via web

#### Planejado para Futuras Versões
- 🔄 Interface web real-time
- 🔄 Dashboard com gráficos
- 🔄 Agendamento de relés
- 🔄 Sensores de entrada
- 🔄 Notificações push

### 15.7 Considerações de Rede

#### Latência MQTT
- **Típica**: 50-100ms em rede local
- **Máxima**: 1-2 segundos em rede congestionada
- **Timeout**: Comandos podem ser perdidos

#### Largura de Banda
- **Status Updates**: ~200 bytes a cada 30s
- **Comandos**: ~50 bytes por comando
- **Interface Web**: ~10KB na primeira carga

#### Estabilidade WiFi
- **Sensível**: Interferência 2.4GHz
- **Range**: Limitado pela antena integrada
- **Reconnect**: Automático, mas pode levar 30-60s

---

## 📊 RESUMO EXECUTIVO

O **ESP32 Relay Python v2.0** é um firmware completo e robusto que transforma o ESP32 em um controlador de relés inteligente integrado ao ecossistema AutoCore.

### ✅ Principais Características

1. **Auto-Configuração**: Interface web responsiva para setup zero-touch
2. **Integração Total**: Registro automático com backend AutoCore
3. **Controle Dual**: Interface local (HTTP) + controle remoto (MQTT)
4. **Robustez**: Tratamento abrangente de erros e recuperação automática
5. **Telemetria**: Monitoramento em tempo real com métricas detalhadas
6. **Flexibilidade**: Configuração dinâmica de 1 a 16 canais de relé

### 🎯 Casos de Uso Ideais

- Automação residencial e comercial
- Controle de iluminação e equipamentos
- Sistemas de irrigação automatizada
- Controle de acesso e segurança
- Monitoramento remoto de equipamentos
- Integração IoT em projetos existentes

### ⚡ Performance

- **Boot Time**: 30-35 segundos (completo)
- **Response Time**: <100ms (HTTP local)
- **MQTT Latency**: 50-100ms (rede local)
- **Memory Usage**: ~40-60KB RAM
- **Uptime**: Designed for 24/7 operation

### 🛡️ Confiabilidade

- Reconexão automática WiFi/MQTT
- Fallback inteligente para modo AP
- Persistência de estados e configurações
- Tratamento robusto de exceções
- Logs detalhados para troubleshooting

Este sistema está **pronto para produção** e oferece uma base sólida para expansões futuras no ecossistema AutoCore.

---

**Versão da Especificação**: 1.0  
**Firmware Coberto**: ESP32 Relay Python v2.0  
**Data**: 11 de Agosto de 2025  
**Autor**: Análise Funcional Completa  

**Status**: ✅ **DOCUMENTAÇÃO COMPLETA** - Pronto para uso e referência