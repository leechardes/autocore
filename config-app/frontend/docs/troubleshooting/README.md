# 🛠️ Troubleshooting - Frontend AutoCore

## 🎯 Visão Geral
Guia para resolução de problemas comuns no frontend React do AutoCore Config App.

## 🚨 Problemas Comuns

### 1. Erros de Build

#### Node Version Mismatch
```bash
# Erro: Node version não compatível
Error: The engine "node" is incompatible with this module

# Solução: Verificar e atualizar Node.js
node --version  # Deve ser >= 16.0.0
npm --version   # Deve ser >= 8.0.0

# Instalar versão correta
nvm install 18
nvm use 18
```

#### Dependências Conflitantes
```bash
# Erro: Conflitos de peer dependencies
npm ERR! peer dep missing

# Solução: Limpar e reinstalar
rm -rf node_modules package-lock.json
npm cache clean --force
npm install

# Ou forçar resolução
npm install --legacy-peer-deps
```

#### Memory Issues
```bash
# Erro: JavaScript heap out of memory
FATAL ERROR: Ineffective mark-compacts near heap limit

# Solução: Aumentar memória Node.js
export NODE_OPTIONS="--max-old-space-size=4096"
npm run build

# Ou no package.json
{
  "scripts": {
    "build": "NODE_OPTIONS='--max-old-space-size=4096' vite build"
  }
}
```

### 2. Problemas de Desenvolvimento

#### Hot Reload Não Funciona
```javascript
// vite.config.js - Configurar HMR
export default defineConfig({
  server: {
    hmr: {
      port: 3001, // Porta diferente se houver conflito
      host: 'localhost'
    },
    watch: {
      usePolling: true, // Para sistemas com problemas de file watching
      interval: 1000
    }
  }
})
```

#### Erro de Proxy API
```javascript
// vite.config.js - Configurar proxy
export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
        secure: false, // Para HTTPS self-signed
        configure: (proxy, _options) => {
          proxy.on('error', (err, _req, _res) => {
            console.log('proxy error', err);
          });
        }
      }
    }
  }
})
```

#### Problemas de CORS
```javascript
// Temporário: Desabilitar CORS no navegador (apenas dev)
// Chrome: --disable-web-security --user-data-dir=/tmp/chrome_dev_test

// Solução correta: Configurar backend
// FastAPI backend
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### 3. Problemas de Comunicação

#### MQTT Não Conecta
```javascript
// Diagnóstico de conexão MQTT
const diagnoseMQTT = () => {
  const client = mqtt.connect(MQTT_BROKER_URL, {
    username: MQTT_USERNAME,
    password: MQTT_PASSWORD,
    keepalive: 60,
    connectTimeout: 4000,
    reconnectPeriod: 1000
  });
  
  client.on('connect', () => {
    console.log('✅ MQTT Connected');
    client.subscribe('test/topic');
    client.publish('test/topic', 'Hello from frontend');
  });
  
  client.on('error', (error) => {
    console.error('❌ MQTT Error:', error);
    // Verificar:
    // 1. URL do broker
    // 2. Credenciais
    // 3. Firewall/proxy
    // 4. Protocolo (ws vs wss)
  });
  
  client.on('offline', () => {
    console.warn('⚠️ MQTT Offline');
  });
};
```

#### WebSocket Desconecta
```javascript
// Implementar reconexão automática
class RobustWebSocket {
  constructor(url, protocols) {
    this.url = url;
    this.protocols = protocols;
    this.reconnectInterval = 1000;
    this.maxReconnectAttempts = 10;
    this.reconnectAttempts = 0;
    this.connect();
  }
  
  connect() {
    this.ws = new WebSocket(this.url, this.protocols);
    
    this.ws.onopen = () => {
      console.log('✅ WebSocket Connected');
      this.reconnectAttempts = 0;
    };
    
    this.ws.onclose = (event) => {
      console.warn('WebSocket Closed:', event.code, event.reason);
      this.handleReconnection();
    };
    
    this.ws.onerror = (error) => {
      console.error('WebSocket Error:', error);
    };
  }
  
  handleReconnection() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      setTimeout(() => {
        console.log(`Reconnecting... (${this.reconnectAttempts + 1}/${this.maxReconnectAttempts})`);
        this.reconnectAttempts++;
        this.connect();
      }, this.reconnectInterval * Math.pow(2, this.reconnectAttempts)); // Exponential backoff
    }
  }
}
```

### 4. Problemas de UI/UX

#### Componentes Não Renderizam
```javascript
// Debug de renderização
const DebugComponent = ({ children, name }) => {
  console.log(`Rendering ${name}`);
  
  useEffect(() => {
    console.log(`${name} mounted`);
    return () => console.log(`${name} unmounted`);
  }, [name]);
  
  return children;
};

// Uso
<DebugComponent name="DeviceCard">
  <DeviceCard device={device} />
</DebugComponent>
```

#### Estado Não Atualiza
```javascript
// Verificar dependências do useEffect
useEffect(() => {
  fetchDevices();
}, [fetchDevices]); // Pode causar loop infinito

// Solução: usar useCallback
const fetchDevices = useCallback(async () => {
  const response = await api.getDevices();
  setDevices(response.data);
}, []);

// Ou remover da dependência se não necessário
useEffect(() => {
  fetchDevices();
}, []); // Executa apenas na montagem
```

#### Problemas de Performance
```javascript
// Profiling de componentes
import { Profiler } from 'react';

const onRenderCallback = (id, phase, actualDuration) => {
  console.log({
    id,
    phase,
    actualDuration,
    baseDuration,
    startTime,
    commitTime
  });
};

<Profiler id="DeviceList" onRender={onRenderCallback}>
  <DeviceList />
</Profiler>

// React DevTools Profiler
// 1. Instalar extensão React DevTools
// 2. Aba Profiler
// 3. Record session
// 4. Analisar flame graph
```

### 5. Problemas de Build/Deploy

#### Assets Não Carregam
```javascript
// vite.config.js - Configurar base path
export default defineConfig({
  base: process.env.NODE_ENV === 'production' ? '/autocore/' : '/',
  build: {
    assetsDir: 'static',
    rollupOptions: {
      output: {
        assetFileNames: (assetInfo) => {
          let extType = assetInfo.name.split('.').at(1);
          if (/png|jpe?g|svg|gif|tiff|bmp|ico/i.test(extType)) {
            extType = 'img';
          }
          return `static/${extType}/[name]-[hash][extname]`;
        },
        chunkFileNames: 'static/js/[name]-[hash].js',
        entryFileNames: 'static/js/[name]-[hash].js'
      }
    }
  }
})
```

#### Nginx 404 em Rotas SPA
```nginx
# nginx.conf - Configurar fallback SPA
location / {
    try_files $uri $uri/ /index.html;
}

# Para subdirectory
location /autocore/ {
    alias /usr/share/nginx/html/;
    try_files $uri $uri/ /autocore/index.html;
}
```

#### Docker Build Falha
```dockerfile
# Dockerfile - Otimizar build
# Usar .dockerignore
echo "node_modules\n.git\n*.log\ndist" > .dockerignore

# Multi-stage build com cache
FROM node:18-alpine as deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine as builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

## 🔍 Debugging Tools

### Chrome DevTools
```javascript
// Console debugging
console.group('Device State');
console.log('Current devices:', devices);
console.log('Loading state:', loading);
console.log('Error state:', error);
console.groupEnd();

// Network tab
// - Verificar requests API
// - Headers de resposta
// - Tempo de resposta
// - Erros CORS

// Application tab
// - localStorage/sessionStorage
// - Service Workers
// - Cookies
// - Cache
```

### React DevTools
```javascript
// Componentes profiling
// 1. Instalar React DevTools
// 2. Usar Profiler tab
// 3. Components tab para state inspection
// 4. Search components por nome

// Hook para debug
const useDebugValue = (value, formatFn) => {
  React.useDebugValue(value, formatFn);
  return value;
};

// Custom hook debug
const useDevices = () => {
  const [devices, setDevices] = useState([]);
  const [loading, setLoading] = useState(false);
  
  useDebugValue({ deviceCount: devices.length, loading });
  
  return { devices, loading, setDevices, setLoading };
};
```

### Vite DevTools
```javascript
// vite.config.js - Debug mode
export default defineConfig({
  define: {
    __DEV__: process.env.NODE_ENV === 'development',
    __VERSION__: JSON.stringify(process.env.npm_package_version)
  },
  esbuild: {
    drop: process.env.NODE_ENV === 'production' ? ['console', 'debugger'] : []
  }
})

// Uso no código
if (__DEV__) {
  console.log('Debug info:', data);
}
```

## 📊 Logs e Monitoring

### Logging Strategy
```javascript
// utils/logger.js
class Logger {
  constructor(context) {
    this.context = context;
  }
  
  debug(message, data) {
    if (process.env.NODE_ENV === 'development') {
      console.log(`[${this.context}] DEBUG:`, message, data);
    }
  }
  
  info(message, data) {
    console.info(`[${this.context}] INFO:`, message, data);
  }
  
  warn(message, data) {
    console.warn(`[${this.context}] WARN:`, message, data);
  }
  
  error(message, error) {
    console.error(`[${this.context}] ERROR:`, message, error);
    
    // Enviar para sistema de monitoramento
    this.sendToMonitoring('error', { message, error: error.toString() });
  }
  
  sendToMonitoring(level, data) {
    if (process.env.NODE_ENV === 'production') {
      fetch('/api/logs', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          level,
          timestamp: new Date().toISOString(),
          context: this.context,
          ...data
        })
      }).catch(err => console.warn('Failed to send log:', err));
    }
  }
}

// Uso
const logger = new Logger('DeviceManager');
logger.error('Failed to fetch devices', error);
```

### Error Boundaries
```javascript
// components/ErrorBoundary.jsx
class ErrorBoundary extends Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null, errorInfo: null };
  }
  
  static getDerivedStateFromError(error) {
    return { hasError: true };
  }
  
  componentDidCatch(error, errorInfo) {
    this.setState({
      error: error,
      errorInfo: errorInfo
    });
    
    // Log error
    console.error('ErrorBoundary caught an error:', error, errorInfo);
    
    // Send to monitoring service
    this.reportError(error, errorInfo);
  }
  
  reportError(error, errorInfo) {
    const errorReport = {
      message: error.message,
      stack: error.stack,
      componentStack: errorInfo.componentStack,
      timestamp: new Date().toISOString(),
      url: window.location.href,
      userAgent: navigator.userAgent
    };
    
    fetch('/api/errors', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(errorReport)
    }).catch(err => console.warn('Failed to report error:', err));
  }
  
  render() {
    if (this.state.hasError) {
      return (
        <div className="error-boundary">
          <h2>Algo deu errado!</h2>
          <details style={{ whiteSpace: 'pre-wrap' }}>
            <summary>Ver detalhes do erro</summary>
            {this.state.error && this.state.error.toString()}
            <br />
            {this.state.errorInfo.componentStack}
          </details>
          <button onClick={() => window.location.reload()}>
            Recarregar Página
          </button>
        </div>
      );
    }
    
    return this.props.children;
  }
}
```

## 🆘 Getting Help

### Resources
- **Documentação React**: https://react.dev/
- **Vite Documentation**: https://vitejs.dev/
- **Tailwind CSS**: https://tailwindcss.com/docs
- **shadcn/ui**: https://ui.shadcn.com/
- **MQTT.js**: https://github.com/mqttjs/MQTT.js

### Internal Support
1. **Slack**: #autocore-frontend
2. **Issues**: GitHub repository issues
3. **Documentation**: Este diretório docs/
4. **Code Review**: Pull requests

### Debug Checklist
- [ ] Verificar console do navegador
- [ ] Verificar Network tab para erros de API
- [ ] Confirmar variáveis de ambiente
- [ ] Testar em modo incógnito
- [ ] Verificar versões de dependências
- [ ] Limpar cache do navegador
- [ ] Reiniciar servidor de desenvolvimento

---

**Status**: Documentação completa ✅  
**Última atualização**: 2025-01-28  
**Responsável**: Equipe Frontend