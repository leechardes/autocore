# 🔄 State Management - Frontend AutoCore

## 🎯 Visão Geral
Documentação do gerenciamento de estado no frontend React do AutoCore Config App.

## 📊 Estratégia de Estado

### Filosofia
- **Local First**: Estado local quando possível
- **Lift State Up**: Compartilhamento quando necessário
- **Global Minimal**: Estado global apenas para dados compartilhados
- **Server State**: Diferenciação entre estado de UI e servidor

### Tipos de Estado
1. **UI State**: Estado da interface (modais, formulários, navegação)
2. **Server State**: Dados do backend (devices, relays, macros)
3. **Client State**: Configurações locais (tema, preferências)
4. **Derived State**: Estado computado de outros estados

## 🏗️ Arquitetura de Estado

```
┌─────────────────────────────────────────────────────────┐
│                  Global State                           │
│  ├── User Authentication                                │
│  ├── App Configuration                                  │
│  └── MQTT Connection Status                             │
├─────────────────────────────────────────────────────────┤
│                  Feature State                          │
│  ├── Device Management                                  │
│  ├── Relay Control                                      │
│  ├── Macro Automation                                   │
│  └── Theme Customization                                │
├─────────────────────────────────────────────────────────┤
│                  Component State                        │
│  ├── Form Inputs                                        │
│  ├── Modal Visibility                                   │
│  ├── Loading States                                     │
│  └── Local UI State                                     │
└─────────────────────────────────────────────────────────┘
```

## 🎣 Custom Hooks para Estado

### Data Management Hooks

#### useDevices
```javascript
const {
  devices,
  loading,
  error,
  addDevice,
  updateDevice,
  deleteDevice,
  refreshDevices
} = useDevices();
```

#### useRelays
```javascript
const {
  relays,
  loading,
  toggleRelay,
  setRelayState,
  bulkControl,
  relayStates
} = useRelays(deviceId);
```

#### useMacros
```javascript
const {
  macros,
  createMacro,
  updateMacro,
  deleteMacro,
  executeMacro,
  macroStatus
} = useMacros();
```

#### useThemes
```javascript
const {
  themes,
  currentTheme,
  applyTheme,
  createTheme,
  updateTheme,
  deleteTheme
} = useThemes();
```

### UI State Hooks

#### useModal
```javascript
const {
  isOpen,
  open,
  close,
  toggle,
  data
} = useModal('deviceConfigModal');
```

#### useToast
```javascript
const {
  toast,
  success,
  error,
  warning,
  info
} = useToast();
```

#### useLocalStorage
```javascript
const [value, setValue] = useLocalStorage('key', defaultValue);
```

## 📡 Real-time State Management

### MQTT State Updates
```javascript
// useMqttState hook
const useMqttState = (topic) => {
  const [data, setData] = useState(null);
  const [connected, setConnected] = useState(false);
  
  useEffect(() => {
    const mqtt = getMqttClient();
    
    mqtt.subscribe(topic);
    mqtt.on('message', (receivedTopic, message) => {
      if (receivedTopic === topic) {
        setData(JSON.parse(message.toString()));
      }
    });
    
    return () => mqtt.unsubscribe(topic);
  }, [topic]);
  
  return { data, connected };
};
```

### WebSocket State
```javascript
// useWebSocket hook
const useWebSocket = (url) => {
  const [socket, setSocket] = useState(null);
  const [lastMessage, setLastMessage] = useState(null);
  const [connectionStatus, setConnectionStatus] = useState('Disconnected');
  
  // Connection management
  // Message handling
  // Reconnection logic
  
  return { socket, lastMessage, connectionStatus, sendMessage };
};
```

## 🌐 Global State with Context

### Auth Context
```javascript
// contexts/AuthContext.jsx
const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  
  const login = async (credentials) => {
    // Login logic
  };
  
  const logout = () => {
    // Logout logic
  };
  
  return (
    <AuthContext.Provider value={{ user, login, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
```

### MQTT Context
```javascript
// contexts/MqttContext.jsx
const MqttContext = createContext();

export const MqttProvider = ({ children }) => {
  const [client, setClient] = useState(null);
  const [connected, setConnected] = useState(false);
  const [messages, setMessages] = useState([]);
  
  // MQTT connection management
  // Message handling
  // Subscription management
  
  return (
    <MqttContext.Provider value={{ client, connected, messages, publish, subscribe }}>
      {children}
    </MqttContext.Provider>
  );
};
```

## 🔄 State Synchronization

### Optimistic Updates
```javascript
const useOptimisticUpdate = (mutationFn, queryKey) => {
  const [isUpdating, setIsUpdating] = useState(false);
  
  const mutate = async (data) => {
    setIsUpdating(true);
    
    // Optimistic update
    updateLocalState(data);
    
    try {
      await mutationFn(data);
      // Success - state already updated
    } catch (error) {
      // Revert optimistic update
      revertLocalState();
      throw error;
    } finally {
      setIsUpdating(false);
    }
  };
  
  return { mutate, isUpdating };
};
```

### Cache Management
```javascript
// Simple cache implementation
const useCache = (key, fetcher, ttl = 300000) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  useEffect(() => {
    const cachedData = localStorage.getItem(`cache_${key}`);
    const cachedTime = localStorage.getItem(`cache_time_${key}`);
    
    if (cachedData && Date.now() - parseInt(cachedTime) < ttl) {
      setData(JSON.parse(cachedData));
      setLoading(false);
      return;
    }
    
    // Fetch fresh data
    fetcher()
      .then(result => {
        setData(result);
        localStorage.setItem(`cache_${key}`, JSON.stringify(result));
        localStorage.setItem(`cache_time_${key}`, Date.now().toString());
      })
      .catch(setError)
      .finally(() => setLoading(false));
  }, [key, fetcher, ttl]);
  
  return { data, loading, error };
};
```

## 🎯 State Patterns

### Reducer Pattern
```javascript
// For complex state logic
const deviceReducer = (state, action) => {
  switch (action.type) {
    case 'LOAD_DEVICES':
      return { ...state, loading: true, error: null };
    case 'LOAD_DEVICES_SUCCESS':
      return { ...state, loading: false, devices: action.payload };
    case 'LOAD_DEVICES_ERROR':
      return { ...state, loading: false, error: action.payload };
    case 'ADD_DEVICE':
      return { 
        ...state, 
        devices: [...state.devices, action.payload] 
      };
    case 'UPDATE_DEVICE':
      return {
        ...state,
        devices: state.devices.map(device => 
          device.id === action.payload.id 
            ? { ...device, ...action.payload }
            : device
        )
      };
    case 'DELETE_DEVICE':
      return {
        ...state,
        devices: state.devices.filter(device => device.id !== action.payload)
      };
    default:
      return state;
  }
};
```

### State Machine Pattern
```javascript
// For complex UI flows
const useStateMachine = (initialState, transitions) => {
  const [state, setState] = useState(initialState);
  
  const transition = (event, payload) => {
    const newState = transitions[state]?.[event];
    if (newState) {
      setState(newState);
      return { state: newState, payload };
    }
    return { state, payload };
  };
  
  return [state, transition];
};

// Usage
const [modalState, transitionModal] = useStateMachine('closed', {
  closed: { open: 'opening' },
  opening: { opened: 'open', cancel: 'closed' },
  open: { close: 'closing', submit: 'submitting' },
  closing: { closed: 'closed' },
  submitting: { success: 'closed', error: 'open' }
});
```

## 📊 State Debugging

### DevTools Integration
```javascript
// Development state logging
const useStateLogger = (name, state) => {
  useEffect(() => {
    if (process.env.NODE_ENV === 'development') {
      console.log(`[${name}] State updated:`, state);
    }
  }, [name, state]);
};
```

### State Persistence
```javascript
// Persist state to localStorage
const usePersistedState = (key, defaultValue) => {
  const [state, setState] = useState(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : defaultValue;
    } catch (error) {
      return defaultValue;
    }
  });
  
  const setValue = (value) => {
    try {
      setState(value);
      window.localStorage.setItem(key, JSON.stringify(value));
    } catch (error) {
      console.error(`Error saving to localStorage:`, error);
    }
  };
  
  return [state, setValue];
};
```

## 🔄 State Migration

### Version Management
```javascript
// Handle state schema changes
const migrateState = (state, version) => {
  const migrations = {
    '1.1.0': (oldState) => ({
      ...oldState,
      devices: oldState.devices.map(device => ({
        ...device,
        firmware_version: device.firmware_version || '1.0.0'
      }))
    }),
    '1.2.0': (oldState) => ({
      ...oldState,
      settings: {
        ...oldState.settings,
        mqtt_qos: oldState.settings.mqtt_qos || 1
      }
    })
  };
  
  let migratedState = state;
  Object.keys(migrations).forEach(migrationVersion => {
    if (shouldMigrate(version, migrationVersion)) {
      migratedState = migrations[migrationVersion](migratedState);
    }
  });
  
  return migratedState;
};
```

---

**Status**: Documentação completa ✅  
**Última atualização**: 2025-01-28  
**Responsável**: Equipe Frontend