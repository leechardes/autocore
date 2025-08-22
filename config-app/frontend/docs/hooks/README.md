# Custom Hooks - AutoCore Config App

## Visão Geral

Documentação dos custom hooks utilizados no AutoCore Config App. Os hooks encapsulam lógica reutilizável e facilitam o gerenciamento de estado e efeitos colaterais.

## Hooks Implementados

### useToast
**Arquivo**: `src/hooks/use-toast.js`
**Propósito**: Gerenciar sistema de notificações toast
**Status**: ✅ Implementado

### useAPI (Implcíto)
**Localização**: `src/lib/api.js`
**Propósito**: Centralizar chamadas para API do backend
**Status**: ✅ Implementado como módulo

### useTheme (Implcíto)
**Localização**: Integrado no `App.jsx` e `ThemeSelector.jsx`
**Propósito**: Gerenciar tema da aplicação
**Status**: ✅ Implementado inline

### useLocalStorage (Implcíto)
**Utilizado em**: Persistência de tema e configurações
**Status**: ✅ Implementado inline onde necessário

### useMQTT (Identificado)
**Arquivo**: `src/services/mqttService.js`
**Propósito**: Gerenciar conexão MQTT WebSocket
**Status**: 🔄 Para extrair como hook

### useDevices (Potencial)
**Propósito**: Gerenciar estado dos dispositivos ESP32
**Status**: 🔍 Para implementar

### useRelays (Potencial)
**Propósito**: Gerenciar estado dos relés
**Status**: 🔍 Para implementar

### useScreens (Potencial)
**Propósito**: Gerenciar telas e layouts
**Status**: 🔍 Para implementar

## Hook Detalhados

### useToast

**Propósito**: Sistema completo de notificações toast com gerenciamento de estado

**Features**:
- Múltiplos tipos de toast (success, error, info, warning)
- Controle de duração e posição
- Ações customizadas
- Limite de toasts simultâneos
- Auto-dismiss com timeout

**Interface**:
```javascript
const { toast, dismiss, toasts } = useToast()

// Métodos disponíveis
toast({
  title: string,
  description?: string,
  variant?: 'default' | 'destructive',
  action?: {
    label: string,
    onClick: () => void
  },
  duration?: number
})

dismiss(toastId?: string)
```

**Implementação**:
```javascript
// Reducer para gerenciar estado dos toasts
const reducer = (state, action) => {
  switch (action.type) {
    case 'ADD_TOAST': return { ...state, toasts: [action.toast, ...state.toasts] }
    case 'DISMISS_TOAST': return { ...state, toasts: state.toasts.map(t => 
      t.id === action.toastId ? { ...t, open: false } : t) }
    case 'REMOVE_TOAST': return { ...state, toasts: state.toasts.filter(t => 
      t.id !== action.toastId) }
  }
}

// Hook principal
const useToast = () => {
  const [state, setState] = useState(memoryState)
  
  useEffect(() => {
    listeners.push(setState)
    return () => listeners.splice(listeners.indexOf(setState), 1)
  }, [])
  
  return { ...state, toast, dismiss }
}
```

**Uso no Projeto**:
```jsx
import { useToast } from '@/hooks/use-toast'
// OU via sonner (implementação atual)
import { toast } from 'sonner'

const DevicePage = () => {
  // Via hook customizado
  const { toast } = useToast()
  
  const handleSave = async () => {
    try {
      await api.saveDevice()
      toast({
        title: 'Sucesso!',
        description: 'Dispositivo salvo com sucesso',
        variant: 'default'
      })
    } catch (error) {
      toast({
        title: 'Erro!',
        description: 'Falha ao salvar dispositivo',
        variant: 'destructive'
      })
    }
  }
  
  // Via sonner (implementação atual)
  const handleSave2 = async () => {
    try {
      await api.saveDevice()
      toast.success('Dispositivo salvo com sucesso!')
    } catch (error) {
      toast.error('Falha ao salvar dispositivo')
    }
  }
}
```

---

## Hooks Implcítos (Para Extrair)

### useTheme

**Localização Atual**: `App.jsx` linhas 136-217

**Propósito**: Gerenciar tema da aplicação (light/dark)

**Lógica Atual**:
```jsx
// Em App.jsx
const [isDark, setIsDark] = useState(false)

useEffect(() => {
  const savedTheme = localStorage.getItem('theme')
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
  const darkMode = savedTheme === 'dark' || (!savedTheme && prefersDark)
  
  setIsDark(darkMode)
  document.documentElement.classList.toggle('dark', darkMode)
}, [])

const toggleTheme = () => {
  const newIsDark = !isDark
  setIsDark(newIsDark)
  document.documentElement.classList.toggle('dark', newIsDark)
  localStorage.setItem('theme', newIsDark ? 'dark' : 'light')
}
```

**Hook Proposto**:
```javascript
const useTheme = () => {
  const [theme, setTheme] = useState('system')
  const [isDark, setIsDark] = useState(false)
  
  useEffect(() => {
    const savedTheme = localStorage.getItem('theme') || 'system'
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    
    const updateTheme = (newTheme = savedTheme) => {
      const dark = newTheme === 'dark' || (newTheme === 'system' && mediaQuery.matches)
      setIsDark(dark)
      document.documentElement.classList.toggle('dark', dark)
      localStorage.setItem('theme', newTheme)
      setTheme(newTheme)
    }
    
    updateTheme()
    mediaQuery.addEventListener('change', () => updateTheme(theme))
    
    return () => mediaQuery.removeEventListener('change', () => updateTheme(theme))
  }, [])
  
  const changeTheme = (newTheme) => {
    updateTheme(newTheme)
  }
  
  return { theme, isDark, changeTheme, toggleTheme: () => 
    changeTheme(isDark ? 'light' : 'dark') }
}
```

---

### useAPI (Extrair de api.js)

**Localização Atual**: `src/lib/api.js`

**Propósito**: Hook para chamadas API com loading, error e cache

**Hook Proposto**:
```javascript
const useAPI = (endpoint, options = {}) => {
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  
  const { autoFetch = false, dependencies = [] } = options
  
  const fetchData = useCallback(async (params = {}) => {
    setLoading(true)
    setError(null)
    
    try {
      const result = await api.request(endpoint, params)
      setData(result)
      return result
    } catch (err) {
      setError(err)
      throw err
    } finally {
      setLoading(false)
    }
  }, [endpoint])
  
  useEffect(() => {
    if (autoFetch) {
      fetchData()
    }
  }, [fetchData, ...dependencies])
  
  return { data, loading, error, fetch: fetchData, refetch: () => fetchData() }
}

// Uso
const DevicesPage = () => {
  const { data: devices, loading, error, refetch } = useAPI('/api/devices', { autoFetch: true })
  
  if (loading) return <LoadingSpinner />
  if (error) return <ErrorMessage error={error} />
  
  return (
    <div>
      <Button onClick={refetch}>Atualizar</Button>
      {devices.map(device => <DeviceCard key={device.id} device={device} />)}
    </div>
  )
}
```

---

## Hooks Potenciais (Para Implementar)

### useDevices

```javascript
const useDevices = () => {
  const { data: devices, loading, error, refetch } = useAPI('/api/devices', { autoFetch: true })
  const [selectedDevice, setSelectedDevice] = useState(null)
  
  const addDevice = async (deviceData) => {
    const newDevice = await api.addDevice(deviceData)
    toast.success('Dispositivo adicionado com sucesso!')
    refetch()
    return newDevice
  }
  
  const updateDevice = async (id, updates) => {
    const updated = await api.updateDevice(id, updates)
    toast.success('Dispositivo atualizado!')
    refetch()
    return updated
  }
  
  const deleteDevice = async (id) => {
    await api.deleteDevice(id)
    toast.success('Dispositivo removido!')
    refetch()
  }
  
  const onlineDevices = devices?.filter(d => d.online) || []
  const offlineDevices = devices?.filter(d => !d.online) || []
  
  return {
    devices: devices || [],
    onlineDevices,
    offlineDevices,
    selectedDevice,
    setSelectedDevice,
    loading,
    error,
    refetch,
    addDevice,
    updateDevice,
    deleteDevice
  }
}
```

### useRelays

```javascript
const useRelays = () => {
  const { data: channels, loading, refetch } = useAPI('/api/relay-channels', { autoFetch: true })
  
  const toggleRelay = async (deviceId, channel) => {
    await api.toggleRelay(deviceId, channel)
    toast.success(`Relé ${channel} acionado!`)
    refetch()
  }
  
  const updateRelayConfig = async (id, config) => {
    await api.updateRelayChannel(id, config)
    toast.success('Configuração salva!')
    refetch()
  }
  
  const groupedChannels = channels?.reduce((acc, channel) => {
    const deviceId = channel.device_id
    if (!acc[deviceId]) acc[deviceId] = []
    acc[deviceId].push(channel)
    return acc
  }, {}) || {}
  
  return {
    channels: channels || [],
    groupedChannels,
    loading,
    refetch,
    toggleRelay,
    updateRelayConfig
  }
}
```

### useMQTT

```javascript
const useMQTT = (topics = []) => {
  const [client, setClient] = useState(null)
  const [messages, setMessages] = useState([])
  const [connected, setConnected] = useState(false)
  
  useEffect(() => {
    const mqttClient = new MQTTService()
    
    mqttClient.on('connect', () => setConnected(true))
    mqttClient.on('disconnect', () => setConnected(false))
    mqttClient.on('message', (topic, message) => {
      setMessages(prev => [...prev.slice(-100), { topic, message, timestamp: Date.now() }])
    })
    
    mqttClient.connect()
    setClient(mqttClient)
    
    return () => mqttClient.disconnect()
  }, [])
  
  useEffect(() => {
    if (client && connected) {
      topics.forEach(topic => client.subscribe(topic))
    }
  }, [client, connected, topics])
  
  const publish = (topic, message) => {
    if (client && connected) {
      client.publish(topic, message)
    }
  }
  
  const subscribe = (topic) => {
    if (client && connected) {
      client.subscribe(topic)
    }
  }
  
  return { messages, connected, publish, subscribe }
}
```

## Padrões de Implementação

### Estrutura Padrão de Hook

```javascript
const useCustomHook = (initialValue, options = {}) => {
  // Estado interno
  const [state, setState] = useState(initialValue)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  
  // Efeitos
  useEffect(() => {
    // Lógica de inicialização
  }, [])
  
  // Métodos auxiliares
  const handleAction = useCallback(async (...args) => {
    setLoading(true)
    setError(null)
    
    try {
      const result = await performAction(...args)
      setState(result)
      return result
    } catch (err) {
      setError(err)
      throw err
    } finally {
      setLoading(false)
    }
  }, [/* dependencies */])
  
  // Interface pública
  return {
    // Estado
    state,
    loading,
    error,
    
    // Ações
    handleAction,
    
    // Utilitários
    reset: () => setState(initialValue)
  }
}
```

### Guidelines de Desenvolvimento

1. **Naming**: `use` prefix + PascalCase
2. **Return**: Sempre retornar objeto com interface consistente
3. **Loading States**: Incluir `loading` para operações assíncronas
4. **Error Handling**: Incluir `error` e propagar exceções
5. **Dependencies**: Usar `useCallback` e `useMemo` adequadamente
6. **Cleanup**: Sempre limpar listeners e timers

## Roadmap de Hooks

### Próximas Implementações
- [ ] `useTheme` - Extrair lógica de tema
- [ ] `useAPI` - Hook genérico para API
- [ ] `useDevices` - Gerenciamento de dispositivos
- [ ] `useRelays` - Gerenciamento de relés
- [ ] `useMQTT` - Conexão MQTT
- [ ] `useScreens` - Editor de telas
- [ ] `useLocalStorage` - Persistência local
- [ ] `useWebSocket` - Conexões WebSocket

### Otimizações Futuras
- [ ] Cache inteligente com react-query
- [ ] Debounce para inputs
- [ ] Offline support
- [ ] Real-time subscriptions

## Links Relacionados

- [Data Hooks](data-hooks.md) - Hooks para gerenciamento de dados
- [UI Hooks](ui-hooks.md) - Hooks para interface de usuário
- [Utility Hooks](utility-hooks.md) - Hooks utilitários
- [API Integration](../api/README.md) - Documentação da API
- [State Management](../state/README.md) - Gerenciamento de estado