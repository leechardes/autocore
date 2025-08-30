# 🚀 Deployment - Frontend AutoCore

## 🎯 Visão Geral
Guia completo para deploy e configuração do frontend React do AutoCore Config App.

## 📦 Build Process

### Vite Build Configuration
```javascript
// vite.config.js
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: process.env.NODE_ENV !== 'production',
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
        drop_debugger: true
      }
    },
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          ui: ['@radix-ui/react-dialog', '@radix-ui/react-dropdown-menu'],
          utils: ['clsx', 'tailwind-merge', 'class-variance-authority']
        }
      }
    }
  },
  server: {
    port: 3000,
    host: true,
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true
      },
      '/ws': {
        target: 'ws://localhost:8000',
        ws: true
      }
    }
  }
})
```

### Build Scripts
```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "build:staging": "vite build --mode staging",
    "build:production": "vite build --mode production",
    "preview": "vite preview",
    "analyze": "vite-bundle-analyzer dist/stats.html",
    "lint": "eslint . --ext .js,.jsx,.ts,.tsx",
    "lint:fix": "eslint . --ext .js,.jsx,.ts,.tsx --fix",
    "type-check": "tsc --noEmit"
  }
}
```

## 🌍 Environment Configuration

### Environment Files
```bash
# .env.local (Development)
VITE_API_BASE_URL=http://localhost:8000
VITE_MQTT_BROKER_URL=ws://localhost:8083
VITE_MQTT_USERNAME=autocore
VITE_MQTT_PASSWORD=development
VITE_APP_TITLE=AutoCore Config (Dev)
VITE_DEBUG_MODE=true

# .env.staging (Staging)
VITE_API_BASE_URL=https://staging-api.autocore.local
VITE_MQTT_BROKER_URL=wss://staging-mqtt.autocore.local:8084
VITE_MQTT_USERNAME=autocore_staging
VITE_MQTT_PASSWORD=staging_password
VITE_APP_TITLE=AutoCore Config (Staging)
VITE_DEBUG_MODE=false

# .env.production (Production)
VITE_API_BASE_URL=https://api.autocore.local
VITE_MQTT_BROKER_URL=wss://mqtt.autocore.local:8084
VITE_MQTT_USERNAME=autocore_prod
VITE_MQTT_PASSWORD=production_password
VITE_APP_TITLE=AutoCore Config
VITE_DEBUG_MODE=false
```

### Environment Validation
```javascript
// src/config/env.js
const requiredEnvVars = [
  'VITE_API_BASE_URL',
  'VITE_MQTT_BROKER_URL',
  'VITE_MQTT_USERNAME',
  'VITE_MQTT_PASSWORD'
];

const validateEnvironment = () => {
  const missing = requiredEnvVars.filter(
    varName => !import.meta.env[varName]
  );
  
  if (missing.length > 0) {
    throw new Error(
      `Missing required environment variables: ${missing.join(', ')}`
    );
  }
};

export const config = {
  apiBaseUrl: import.meta.env.VITE_API_BASE_URL,
  mqttBrokerUrl: import.meta.env.VITE_MQTT_BROKER_URL,
  mqttUsername: import.meta.env.VITE_MQTT_USERNAME,
  mqttPassword: import.meta.env.VITE_MQTT_PASSWORD,
  appTitle: import.meta.env.VITE_APP_TITLE || 'AutoCore Config',
  debugMode: import.meta.env.VITE_DEBUG_MODE === 'true',
  version: import.meta.env.VITE_APP_VERSION || '1.0.0'
};

validateEnvironment();
```

## 🐳 Docker Deployment

### Multi-stage Dockerfile
```dockerfile
# Multi-stage build
FROM node:18-alpine as builder

# Instalar dependências de build
RUN apk add --no-cache git

# Definir diretório de trabalho
WORKDIR /app

# Copiar package files
COPY package*.json ./
COPY tsconfig*.json ./
COPY vite.config.js ./
COPY tailwind.config.js ./
COPY postcss.config.js ./

# Instalar dependências
RUN npm ci --only=production

# Copiar código fonte
COPY src/ ./src/
COPY public/ ./public/
COPY index.html ./

# Build da aplicação
ARG NODE_ENV=production
ARG VITE_API_BASE_URL
ARG VITE_MQTT_BROKER_URL
ARG VITE_MQTT_USERNAME
ARG VITE_MQTT_PASSWORD
ARG VITE_APP_VERSION

RUN npm run build

# Production stage
FROM nginx:alpine as production

# Instalar dumb-init para gerenciamento de processos
RUN apk add --no-cache dumb-init

# Copiar arquivos construídos
COPY --from=builder /app/dist /usr/share/nginx/html

# Copiar configuração do nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# Criar usuário não-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Ajustar permissões
RUN chown -R nextjs:nodejs /usr/share/nginx/html && \
    chown -R nextjs:nodejs /var/cache/nginx && \
    chown -R nextjs:nodejs /var/log/nginx && \
    chown -R nextjs:nodejs /etc/nginx/conf.d

USER nextjs

EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:80/ || exit 1

ENTRYPOINT ["dumb-init", "--"]
CMD ["nginx", "-g", "daemon off;"]
```

### Docker Compose
```yaml
# docker-compose.yml
version: '3.8'

services:
  autocore-frontend:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        NODE_ENV: production
        VITE_API_BASE_URL: ${VITE_API_BASE_URL}
        VITE_MQTT_BROKER_URL: ${VITE_MQTT_BROKER_URL}
        VITE_MQTT_USERNAME: ${VITE_MQTT_USERNAME}
        VITE_MQTT_PASSWORD: ${VITE_MQTT_PASSWORD}
        VITE_APP_VERSION: ${GIT_COMMIT:-latest}
    ports:
      - "3000:80"
    environment:
      - NODE_ENV=production
    volumes:
      - ./logs:/var/log/nginx
    networks:
      - autocore-network
    restart: unless-stopped
    depends_on:
      - autocore-backend
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.frontend.rule=Host(`autocore.local`)"
      - "traefik.http.services.frontend.loadbalancer.server.port=80"

networks:
  autocore-network:
    external: true
```

## 🌐 Nginx Configuration

### Main Configuration
```nginx
# nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    access_log /var/log/nginx/access.log main;

    # Performance
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 4096;

    # Compression
    gzip on;
    gzip_vary on;
    gzip_min_length 10240;
    gzip_proxied expired no-cache no-store private must-revalidate;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json
        image/svg+xml;

    # Security headers
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    include /etc/nginx/conf.d/*.conf;
}
```

### Site Configuration
```nginx
# default.conf
server {
    listen 80;
    server_name localhost;
    
    root /usr/share/nginx/html;
    index index.html index.htm;

    # Security headers específicos
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "DENY" always;

    # Compressão para assets estáticos
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
    }

    # Arquivos HTML sem cache
    location ~* \.html$ {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        add_header Expires "0";
        try_files $uri $uri/ /index.html;
    }

    # Proxy para API
    location /api/ {
        proxy_pass http://autocore-backend:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # WebSocket proxy
    location /ws/ {
        proxy_pass http://autocore-backend:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 86400;
    }

    # SPA fallback
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Health check
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }

    # Error pages
    error_page 404 /index.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
```

## 🔄 CI/CD Pipeline

### GitHub Actions
```yaml
# .github/workflows/deploy.yml
name: Deploy Frontend

on:
  push:
    branches: [main, staging]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '18'
  DOCKER_REGISTRY: ghcr.io
  IMAGE_NAME: autocore/frontend

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Type check
        run: npm run type-check
        
      - name: Lint
        run: npm run lint
        
      - name: Test
        run: npm run test
        
      - name: Build
        run: npm run build
        env:
          VITE_API_BASE_URL: ${{ secrets.VITE_API_BASE_URL }}
          VITE_MQTT_BROKER_URL: ${{ secrets.VITE_MQTT_BROKER_URL }}

  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/staging'
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
        
      - name: Login to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ${{ env.DOCKER_REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
          
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v4
        with:
          images: ${{ env.DOCKER_REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=sha,prefix={{branch}}-
            
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          build-args: |
            NODE_ENV=production
            VITE_API_BASE_URL=${{ secrets.VITE_API_BASE_URL }}
            VITE_MQTT_BROKER_URL=${{ secrets.VITE_MQTT_BROKER_URL }}
            VITE_APP_VERSION=${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

## 📊 Monitoring & Analytics

### Performance Monitoring
```javascript
// src/utils/monitoring.js
export const initializeMonitoring = () => {
  // Web Vitals
  if ('web-vital' in window) {
    import('web-vitals').then(({ getCLS, getFID, getFCP, getLCP, getTTFB }) => {
      getCLS(sendToAnalytics);
      getFID(sendToAnalytics);
      getFCP(sendToAnalytics);
      getLCP(sendToAnalytics);
      getTTFB(sendToAnalytics);
    });
  }
  
  // Error tracking
  window.addEventListener('error', (event) => {
    sendErrorToMonitoring({
      message: event.message,
      filename: event.filename,
      lineno: event.lineno,
      colno: event.colno,
      stack: event.error?.stack
    });
  });
  
  // Unhandled promise rejections
  window.addEventListener('unhandledrejection', (event) => {
    sendErrorToMonitoring({
      type: 'unhandledrejection',
      reason: event.reason
    });
  });
};

const sendToAnalytics = (metric) => {
  // Enviar métricas para sistema de monitoramento
  fetch('/api/analytics/metrics', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(metric)
  }).catch(err => console.warn('Analytics failed:', err));
};
```

## 🔧 Troubleshooting

### Common Issues

#### Build Failures
```bash
# Limpar cache e dependências
rm -rf node_modules package-lock.json
npm install

# Verificar versões
node --version
npm --version

# Build com logs detalhados
npm run build -- --verbose
```

#### Memory Issues
```javascript
// vite.config.js - aumentar memória para builds grandes
export default defineConfig({
  build: {
    rollupOptions: {
      maxParallelFileOps: 2, // Reduzir paralelismo
      output: {
        manualChunks: (id) => {
          if (id.includes('node_modules')) {
            return 'vendor';
          }
        }
      }
    }
  }
})
```

#### Nginx Issues
```bash
# Testar configuração
nginx -t

# Recarregar configuração
nginx -s reload

# Verificar logs
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/access.log
```

---

**Status**: Documentação completa ✅  
**Última atualização**: 2025-01-28  
**Responsável**: Equipe DevOps