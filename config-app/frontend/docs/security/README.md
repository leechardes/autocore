# 🔐 Security - Frontend AutoCore

## 🎯 Visão Geral
Práticas e implementações de segurança no frontend React do AutoCore Config App.

## 🛡️ Estratégia de Segurança

### Princípios Fundamentais
1. **Defense in Depth**: Múltiplas camadas de proteção
2. **Principle of Least Privilege**: Acesso mínimo necessário
3. **Secure by Default**: Configurações seguras por padrão
4. **Input Validation**: Validação rigorosa de todos os inputs
5. **Output Encoding**: Sanitização de todos os outputs

## 🔑 Autenticação e Autorização

### JWT Token Management
```javascript
// Token storage e rotação
class AuthTokenManager {
  constructor() {
    this.accessToken = null;
    this.refreshToken = null;
    this.tokenExpiry = null;
  }
  
  setTokens(accessToken, refreshToken) {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.tokenExpiry = this.parseTokenExpiry(accessToken);
    
    // Store refresh token in httpOnly cookie (if possible)
    // Access token in memory only
  }
  
  isTokenExpired() {
    return Date.now() >= this.tokenExpiry;
  }
  
  async refreshAccessToken() {
    if (!this.refreshToken) {
      throw new Error('No refresh token available');
    }
    
    const response = await fetch('/api/auth/refresh', {
      method: 'POST',
      credentials: 'include', // Send httpOnly cookie
      headers: {
        'Authorization': `Bearer ${this.refreshToken}`
      }
    });
    
    if (!response.ok) {
      this.clearTokens();
      throw new Error('Token refresh failed');
    }
    
    const { accessToken, refreshToken } = await response.json();
    this.setTokens(accessToken, refreshToken);
    
    return accessToken;
  }
  
  clearTokens() {
    this.accessToken = null;
    this.refreshToken = null;
    this.tokenExpiry = null;
  }
}
```

### Permission-Based Access Control
```javascript
// Hook para verificação de permissões
const usePermissions = () => {
  const { user } = useAuth();
  
  const hasPermission = (permission) => {
    return user?.permissions?.includes(permission) || false;
  };
  
  const canAccess = (resource, action) => {
    const permission = `${resource}:${action}`;
    return hasPermission(permission) || hasPermission(`${resource}:*`);
  };
  
  return { hasPermission, canAccess };
};

// Componente de proteção
const ProtectedComponent = ({ permission, children, fallback = null }) => {
  const { hasPermission } = usePermissions();
  
  if (!hasPermission(permission)) {
    return fallback;
  }
  
  return children;
};
```

## 🚫 XSS Prevention

### Input Sanitization
```javascript
import DOMPurify from 'dompurify';

// Hook para sanitização segura
const useSafeHTML = () => {
  const sanitizeHTML = (dirty) => {
    return {
      __html: DOMPurify.sanitize(dirty, {
        ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'p', 'br'],
        ALLOWED_ATTR: []
      })
    };
  };
  
  const sanitizeInput = (input) => {
    return DOMPurify.sanitize(input, { ALLOWED_TAGS: [] });
  };
  
  return { sanitizeHTML, sanitizeInput };
};

// Componente seguro para renderizar HTML
const SafeHTML = ({ content }) => {
  const { sanitizeHTML } = useSafeHTML();
  
  return (
    <div dangerouslySetInnerHTML={sanitizeHTML(content)} />
  );
};
```

### Content Security Policy (CSP)
```javascript
// CSP headers configurados no servidor
const cspDirectives = {
  'default-src': "'self'",
  'script-src': "'self' 'unsafe-inline'", // Minimizar 'unsafe-inline'
  'style-src': "'self' 'unsafe-inline' https://fonts.googleapis.com",
  'font-src': "'self' https://fonts.gstatic.com",
  'img-src': "'self' data: https:",
  'connect-src': "'self' wss: ws:",
  'media-src': "'self'",
  'object-src': "'none'",
  'frame-ancestors': "'none'",
  'base-uri': "'self'",
  'form-action': "'self'"
};
```

## 🔒 CSRF Protection

### CSRF Token Implementation
```javascript
// Interceptor para incluir CSRF token
const csrfInterceptor = (config) => {
  const token = document.querySelector('meta[name="csrf-token"]')?.content;
  
  if (token && ['post', 'put', 'patch', 'delete'].includes(config.method)) {
    config.headers['X-CSRF-Token'] = token;
  }
  
  return config;
};

// Axios interceptor
axios.interceptors.request.use(csrfInterceptor);

// Hook para CSRF token
const useCSRFToken = () => {
  const [token, setToken] = useState(null);
  
  useEffect(() => {
    const fetchCSRFToken = async () => {
      try {
        const response = await axios.get('/api/csrf-token');
        setToken(response.data.token);
      } catch (error) {
        console.error('Failed to fetch CSRF token:', error);
      }
    };
    
    fetchCSRFToken();
  }, []);
  
  return token;
};
```

## 🔐 Secure Communication

### HTTPS Enforcement
```javascript
// Redirect para HTTPS em produção
const enforceHTTPS = () => {
  if (process.env.NODE_ENV === 'production' && 
      window.location.protocol !== 'https:') {
    window.location.href = window.location.href.replace('http:', 'https:');
  }
};

// Certificate pinning para requests críticos
const createSecureAxios = () => {
  const instance = axios.create({
    timeout: 10000,
    validateStatus: (status) => status < 500, // Não falhar em 4xx
  });
  
  // Verificação de certificado (se suportado)
  instance.interceptors.request.use((config) => {
    if (config.url.includes('/api/auth/') || config.url.includes('/api/admin/')) {
      config.validateCertificate = true;
    }
    return config;
  });
  
  return instance;
};
```

### Secure WebSocket/MQTT
```javascript
// Configuração segura para WebSocket
const createSecureWebSocket = (url, protocols) => {
  // Forçar WSS em produção
  const secureUrl = process.env.NODE_ENV === 'production' 
    ? url.replace('ws:', 'wss:')
    : url;
    
  const ws = new WebSocket(secureUrl, protocols);
  
  // Verificar origem
  ws.addEventListener('open', (event) => {
    if (event.origin && !isAllowedOrigin(event.origin)) {
      ws.close();
      throw new Error('WebSocket origin not allowed');
    }
  });
  
  return ws;
};

// MQTT over TLS
const mqttSecureConfig = {
  protocol: process.env.NODE_ENV === 'production' ? 'wss' : 'ws',
  port: process.env.NODE_ENV === 'production' ? 8084 : 8083,
  rejectUnauthorized: true, // Verificar certificados
  username: process.env.MQTT_USERNAME,
  password: process.env.MQTT_PASSWORD
};
```

## 🛡️ Data Protection

### Sensitive Data Handling
```javascript
// Classe para mascarar dados sensíveis
class SensitiveDataHandler {
  static maskEmail(email) {
    const [user, domain] = email.split('@');
    const maskedUser = user.length > 2 
      ? user.substring(0, 2) + '*'.repeat(user.length - 2)
      : user;
    return `${maskedUser}@${domain}`;
  }
  
  static maskIP(ip) {
    const parts = ip.split('.');
    return `${parts[0]}.${parts[1]}.***.**`;
  }
  
  static sanitizeLogData(data) {
    const sensitiveFields = ['password', 'token', 'secret', 'key'];
    const sanitized = { ...data };
    
    sensitiveFields.forEach(field => {
      if (sanitized[field]) {
        sanitized[field] = '[REDACTED]';
      }
    });
    
    return sanitized;
  }
}

// Hook para dados sensíveis
const useSensitiveData = () => {
  const [data, setData] = useState(null);
  
  const setSecureData = (newData) => {
    // Nunca armazenar dados sensíveis no localStorage
    setData(newData);
    
    // Log sanitizado
    console.log('Data updated:', SensitiveDataHandler.sanitizeLogData(newData));
  };
  
  const clearSensitiveData = () => {
    setData(null);
    // Forçar garbage collection se disponível
    if (window.gc) {
      window.gc();
    }
  };
  
  return { data, setSecureData, clearSensitiveData };
};
```

### Local Storage Security
```javascript
// Wrapper seguro para localStorage
class SecureStorage {
  constructor(prefix = 'autocore_') {
    this.prefix = prefix;
  }
  
  setItem(key, value, encrypt = false) {
    const fullKey = this.prefix + key;
    let finalValue = value;
    
    if (encrypt && window.crypto && window.crypto.subtle) {
      // Implementar encriptação se necessário
      finalValue = this.encrypt(value);
    }
    
    try {
      localStorage.setItem(fullKey, JSON.stringify(finalValue));
    } catch (error) {
      console.warn('Failed to save to localStorage:', error);
      // Fallback para sessionStorage
      sessionStorage.setItem(fullKey, JSON.stringify(finalValue));
    }
  }
  
  getItem(key, decrypt = false) {
    const fullKey = this.prefix + key;
    
    try {
      const item = localStorage.getItem(fullKey) || 
                   sessionStorage.getItem(fullKey);
      
      if (!item) return null;
      
      const parsed = JSON.parse(item);
      
      if (decrypt && this.isEncrypted(parsed)) {
        return this.decrypt(parsed);
      }
      
      return parsed;
    } catch (error) {
      console.warn('Failed to read from storage:', error);
      return null;
    }
  }
  
  removeItem(key) {
    const fullKey = this.prefix + key;
    localStorage.removeItem(fullKey);
    sessionStorage.removeItem(fullKey);
  }
  
  clear() {
    Object.keys(localStorage)
      .filter(key => key.startsWith(this.prefix))
      .forEach(key => localStorage.removeItem(key));
      
    Object.keys(sessionStorage)
      .filter(key => key.startsWith(this.prefix))
      .forEach(key => sessionStorage.removeItem(key));
  }
}
```

## 🔍 Security Monitoring

### Error Monitoring
```javascript
// Monitor para ataques e tentativas maliciosas
const useSecurityMonitor = () => {
  const reportSecurityEvent = (event, details) => {
    const securityEvent = {
      type: event,
      timestamp: new Date().toISOString(),
      url: window.location.href,
      userAgent: navigator.userAgent,
      details: SensitiveDataHandler.sanitizeLogData(details)
    };
    
    // Enviar para sistema de monitoramento
    fetch('/api/security/events', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(securityEvent)
    }).catch(error => {
      console.error('Failed to report security event:', error);
    });
  };
  
  useEffect(() => {
    // Monitor para tentativas de acesso não autorizado
    const handleSecurityViolation = (event) => {
      reportSecurityEvent('csp_violation', {
        violatedDirective: event.violatedDirective,
        blockedURI: event.blockedURI
      });
    };
    
    document.addEventListener('securitypolicyviolation', handleSecurityViolation);
    
    // Monitor para tentativas de manipulação de console
    const originalConsole = { ...console };
    console.warn = (...args) => {
      if (args[0]?.includes('DevTools') || args[0]?.includes('Console')) {
        reportSecurityEvent('console_access_attempt', { message: args[0] });
      }
      originalConsole.warn(...args);
    };
    
    return () => {
      document.removeEventListener('securitypolicyviolation', handleSecurityViolation);
      Object.assign(console, originalConsole);
    };
  }, []);
  
  return { reportSecurityEvent };
};
```

## 🚫 Security Headers

### Implementação de Headers
```javascript
// Middleware para headers de segurança (configurado no servidor)
const securityHeaders = {
  // XSS Protection
  'X-XSS-Protection': '1; mode=block',
  
  // Content Type Options
  'X-Content-Type-Options': 'nosniff',
  
  // Frame Options
  'X-Frame-Options': 'DENY',
  
  // Referrer Policy
  'Referrer-Policy': 'strict-origin-when-cross-origin',
  
  // Permissions Policy
  'Permissions-Policy': 'geolocation=(), microphone=(), camera=()',
  
  // HSTS (HTTPS Strict Transport Security)
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains; preload'
};

// Verificação client-side dos headers
const useSecurityHeaders = () => {
  useEffect(() => {
    const checkSecurityHeaders = async () => {
      try {
        const response = await fetch(window.location.href, { method: 'HEAD' });
        const headers = response.headers;
        
        const missingHeaders = Object.keys(securityHeaders)
          .filter(header => !headers.has(header));
          
        if (missingHeaders.length > 0) {
          console.warn('Missing security headers:', missingHeaders);
        }
      } catch (error) {
        console.error('Failed to check security headers:', error);
      }
    };
    
    checkSecurityHeaders();
  }, []);
};
```

---

**Status**: Documentação completa ✅  
**Última atualização**: 2025-01-28  
**Responsável**: Equipe Security