# Integração com API - AutoCore Config App

## Visão Geral

Documentação completa da integração do frontend React com a API FastAPI do backend. O sistema utiliza uma classe `AutoCoreAPI` centralizada para todas as comunicações.

## Arquitetura de Integração

```
Frontend (React/Vite)     Backend (FastAPI)
┌───────────────────────┐  ┌────────────────────┐
│ Components             │  │ FastAPI Routes    │
│   │                    │  │   │               │
│   └─> AutoCoreAPI      │  │   └─> /api/*       │
│        │               │  │                   │
│        └─> HTTP/JSON ───┼─┼── SQLAlchemy    │
│                       │  │        │          │
│ Toast Notifications   │  │        └─> SQLite  │
└───────────────────────┘  └────────────────────┘

        WebSocket/MQTT (Tempo Real)
     ┌───────────────────────────────────┐
     │ MQTT Service (ESP32 Communication) │
     └───────────────────────────────────┘
```

## AutoCoreAPI Class

### Configuração

```javascript
// src/lib/api.js
class AutoCoreAPI {
  constructor() {
    this.baseURL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8081/api'
    this.timeout = 10000 // 10 seconds
  }
}

// Instance única para toda a aplicação
const api = new AutoCoreAPI()
export default api
```

### Variáveis de Ambiente

```bash
# .env.local
VITE_API_BASE_URL=http://localhost:8081/api
VITE_API_PORT=8081
VITE_WEBSOCKET_URL=ws://localhost:8081/ws
```

### Métodos HTTP Genéricos

```javascript
// Métodos base
api.get(endpoint, params)      // GET com query parameters
api.post(endpoint, data)       // POST com JSON body
api.patch(endpoint, data)      // PATCH para updates parciais
api.put(endpoint, data)        // PUT para updates completos
api.delete(endpoint)           // DELETE

// Método universal
api.request(endpoint, options)
```

## Endpoints por Módulo

### 1. System Endpoints

#### Status e Saúde do Sistema

```javascript
// Verificar status da API
const status = await api.getStatus()
// Retorna: { status: 'online', uptime: '2h 30m', version: '1.0.0' }

// Health check simples
const health = await api.getHealth()
// Retorna: { status: 'ok', timestamp: '2025-08-22T...' }

// Testar conectividade
const isOnline = await api.testConnection()
// Retorna: boolean
```

### 2. Device Management

#### Dispositivos ESP32

```javascript
// Listar todos os dispositivos
const devices = await api.getDevices()
// Retorna: [{ id: 1, name: 'ESP32-001', ip: '192.168.1.100', online: true, ... }]

// Obter dispositivo específico
const device = await api.getDevice(1)

// Criar novo dispositivo
const newDevice = await api.createDevice({
  name: 'ESP32-Display-001',
  device_type: 'display',
  ip_address: '192.168.1.101',
  port: 80
})

// Atualizar dispositivo
const updated = await api.updateDevice(1, {
  name: 'ESP32-Display-Updated',
  is_active: true
})

// Remover dispositivo
const result = await api.deleteDevice(1)

// Dispositivos disponíveis para relés
const relayDevices = await api.getAvailableRelayDevices()
```

### 3. Relay Management

#### Placas de Relé

```javascript
// Listar placas de relé
const boards = await api.getRelayBoards()
// Retorna: [{ id: 1, device_id: 1, name: 'Placa Principal', channels: 8, ... }]

// Criar placa de relé
const board = await api.createRelayBoard({
  device_id: 1,
  name: 'Placa Luzes',
  total_channels: 8,
  board_type: 'relay_8ch'
})

// Atualizar/Deletar placas
const updated = await api.updateRelayBoard(1, { name: 'Nova Placa' })
const result = await api.deleteRelayBoard(1)
```

#### Canais de Relé

```javascript
// Listar canais (todos ou de uma placa)
const channels = await api.getRelayChannels() // Todos
const boardChannels = await api.getRelayChannels(1) // Placa específica

// Alternar estado do relé
const result = await api.toggleRelay(channelId)
// Retorna: { success: true, new_state: true, channel_id: 1 }

// Definir estado específico
const result = await api.setRelayState(channelId, true) // Liga
const result = await api.setRelayState(channelId, false) // Desliga

// CRUD de canais
const channel = await api.createRelayChannel({
  board_id: 1,
  channel_number: 1,
  name: 'Luz Principal',
  description: 'Luz do teto da cabine'
})

const updated = await api.updateRelayChannel(1, {
  name: 'Luz Cabine',
  auto_off_delay: 300 // 5 minutos
})

// Operações especiais
const result = await api.activateRelayChannel(1)
const result = await api.resetRelayChannel(1)
```

#### Operações em Lote

```javascript
// Atualizar múltiplos canais
const result = await api.batchUpdateRelays([
  { id: 1, name: 'Canal 1 Updated' },
  { id: 2, name: 'Canal 2 Updated' }
])

// Alternar múltiplos relés
const result = await api.batchToggleRelays([1, 2, 3])
```

### 4. Screen Management

#### Telas e Layouts

```javascript
// Listar telas
const screens = await api.getScreens()
// Retorna: [{ id: 1, name: 'Tela Principal', width: 240, height: 320, ... }]

// CRUD de telas
const screen = await api.createScreen({
  name: 'Dashboard Principal',
  width: 240,
  height: 320,
  device_id: 1,
  is_visible: true
})

const updated = await api.updateScreen(1, { name: 'Nova Tela' })
const result = await api.deleteScreen(1)
```

#### Itens de Tela

```javascript
// Listar itens de uma tela
const items = await api.getScreenItems(screenId)

// Adicionar item à tela
const item = await api.createScreenItem(screenId, {
  type: 'label',
  x: 10,
  y: 20,
  width: 100,
  height: 30,
  text: 'RPM: {can_rpm}',
  font_size: 14,
  text_color: '#FFFFFF'
})

// Atualizar posição/propriedades
const updated = await api.updateScreenItem(screenId, itemId, {
  x: 20,
  y: 40,
  text: 'Velocidade: {can_speed} km/h'
})

// Remover item
const result = await api.deleteScreenItem(screenId, itemId)
```

### 5. Theme Management

```javascript
// Listar temas disponíveis
const themes = await api.getThemes()
// Retorna: [{ id: 1, name: 'Dark Theme', colors: {...}, ... }]

// Tema padrão
const defaultTheme = await api.getDefaultTheme()

// CRUD de temas
const theme = await api.createTheme({
  name: 'Custom Theme',
  background_color: '#1a1a1a',
  text_color: '#ffffff',
  accent_color: '#007acc'
})

const updated = await api.updateTheme(1, { name: 'Dark Pro' })
const result = await api.deleteTheme(1)
```

### 6. Configuration Generation

```javascript
// Gerar configuração para dispositivo específico
const config = await api.generateDeviceConfig('esp32-uuid-123')
// Retorna: { json_config: {...}, cpp_code: '...', yaml_config: '...' }

// Exportar configuração completa
const jsonConfig = await api.exportConfig('json')
const yamlConfig = await api.exportConfig('yaml')
const cppConfig = await api.exportConfig('cpp')

// Importar configuração
const result = await api.importConfig(configData)

// Configuração completa para preview
const fullConfig = await api.getFullConfig()
const previewConfig = await api.getPreviewConfig()
```

### 7. CAN Bus Integration

```javascript
// Listar sinais CAN
const signals = await api.getCANSignals()
const engineSignals = await api.getCANSignals('engine')

// CRUD de sinais
const signal = await api.createCANSignal({
  name: 'engine_rpm',
  can_id: '0x100',
  start_bit: 0,
  length: 16,
  factor: 0.25,
  offset: 0,
  unit: 'rpm',
  category: 'engine'
})

const updated = await api.updateCANSignal(1, { factor: 0.5 })
const result = await api.deleteCANSignal(1)

// Popular com sinais padrão FuelTech
const result = await api.seedCANSignals()
```

### 8. Macros System

```javascript
// Listar macros
const macros = await api.getMacros() // Apenas ativas
const allMacros = await api.getMacros(false) // Todas

// CRUD de macros
const macro = await api.createMacro({
  name: 'Sequencia Partida',
  description: 'Liga bomba, aguarda, liga starter',
  actions: [
    { type: 'relay_on', channel_id: 1, delay: 0 },
    { type: 'wait', duration: 2000 },
    { type: 'relay_on', channel_id: 2, delay: 0 }
  ]
})

// Executar macro
const result = await api.executeMacro(macroId)
const testResult = await api.executeMacro(macroId, null, true) // Modo teste

// Controle de execução
const status = await api.getMacroStatus(macroId)
const result = await api.stopMacro(macroId)
const result = await api.emergencyStop() // Para todas as macros

// Templates de macro
const templates = await api.getMacroTemplates()
const newMacro = await api.createMacroFromTemplate(templateId, 'Minha Macro')
```

### 9. Relay Simulator

```javascript
// Listar simuladores
const simulators = await api.listRelaySimulators()

// Criar/Remover simulador
const result = await api.createRelaySimulator(boardId)
const result = await api.removeRelaySimulator(boardId)

// Status do simulador
const status = await api.getRelaySimulatorStatus(boardId)

// Controlar canais do simulador
const result = await api.toggleRelayChannel(boardId, channel)
const result = await api.setRelayChannelState(boardId, channel, true)

// Reset completo
const result = await api.resetRelaySimulator(boardId)
```

## Error Handling

### Padrão de Tratamento de Erros

```javascript
// Em componentes
const handleApiCall = async () => {
  try {
    setLoading(true)
    const result = await api.someMethod()
    setData(result)
    toast.success('Operação realizada com sucesso!')
  } catch (error) {
    console.error('Erro na API:', error)
    toast.error(api.getErrorMessage(error))
  } finally {
    setLoading(false)
  }
}
```

### Tipos de Erro

```javascript
// Timeout
// Erro: "Request timeout - verifique a conexão com o servidor"

// Servidor offline
// Erro: "Servidor indisponível - verifique se a API está rodando"

// HTTP Status Errors
// Erro: "HTTP 404: Not Found"
// Erro: "HTTP 500: Internal Server Error"

// Network Error
// Erro: "Failed to fetch"
```

### Retry Logic

```javascript
// Retry automático com backoff exponencial
const result = await api.retryRequest(
  () => api.getSomeData(),
  3,  // max retries
  1000 // initial delay
)
```

## Interceptors e Middleware

### Request Interceptor (Futuro)

```javascript
class AutoCoreAPI {
  // Adicionar interceptor para auth headers
  addAuthInterceptor() {
    // Implementar autenticação JWT se necessário
  }
  
  // Interceptor para logging
  addLoggingInterceptor() {
    // Log de todas as requisições em desenvolvimento
  }
}
```

## Otimizações

### Caching

```javascript
// Cache simples em memória (futuro)
class AutoCoreAPI {
  constructor() {
    this.cache = new Map()
    this.cacheTimeout = 30000 // 30 seconds
  }
  
  async getCachedData(key, fetchFn) {
    const cached = this.cache.get(key)
    if (cached && Date.now() - cached.timestamp < this.cacheTimeout) {
      return cached.data
    }
    
    const data = await fetchFn()
    this.cache.set(key, { data, timestamp: Date.now() })
    return data
  }
}
```

### Request Deduplication

```javascript
// Evitar requisições duplicadas simultâneas
class AutoCoreAPI {
  constructor() {
    this.pendingRequests = new Map()
  }
  
  async deduplicateRequest(key, requestFn) {
    if (this.pendingRequests.has(key)) {
      return this.pendingRequests.get(key)
    }
    
    const promise = requestFn()
    this.pendingRequests.set(key, promise)
    
    try {
      const result = await promise
      return result
    } finally {
      this.pendingRequests.delete(key)
    }
  }
}
```

## Debugging

### Debug Global

```javascript
// Disponível no console do navegador
window.api.getDebugInfo()
// Retorna: { baseURL, timeout, online, timestamp }

// Testar conectividade
window.api.testConnection()

// Ver cache (quando implementado)
window.api.cache
```

### Development Tools

```javascript
// Em desenvolvimento, log todas as requisições
if (import.meta.env.DEV) {
  const originalRequest = api.request
  api.request = function(endpoint, options) {
    console.log(`🚀 API Request: ${endpoint}`, options)
    return originalRequest.call(this, endpoint, options)
  }
}
```

## Performance

### Métricas

- **Request Timeout**: 10 segundos
- **Retry Attempts**: 3 tentativas com backoff exponencial
- **Bundle Size**: ~15KB (classe API)
- **Memory Usage**: <1MB (incluindo cache)

### Otimizações Implementadas

1. **AbortController** para cancelar requisições
2. **Error normalization** para UX consistente
3. **Timeout configuravel** por request
4. **Global instance** para reutilização
5. **Debug tools** para desenvolvimento

## Roadmap

### Implementações Futuras

- [ ] **Caching inteligente** com react-query
- [ ] **Offline support** com IndexedDB
- [ ] **Request batching** para operações múltiplas
- [ ] **WebSocket integration** para tempo real
- [ ] **GraphQL** para queries complexas
- [ ] **Authentication** com JWT tokens
- [ ] **Rate limiting** client-side
- [ ] **Request metrics** e analytics

## Links Relacionados

- [Endpoints](endpoints.md) - Lista completa de endpoints
- [WebSocket](websocket.md) - Comunicação tempo real
- [Error Handling](error-handling.md) - Tratamento de erros
- [Backend API](../../backend/docs/api/README.md) - Documentação do backend