# 🚀 Deploy Frontend - AutoCore Config

## 📋 Visão Geral

Guia completo para deploy do frontend do AutoCore Config App no Raspberry Pi Zero 2W, focado em performance e otimização.

## 🔧 Preparação para Produção

### 1. Otimização de Assets

```bash
#!/bin/bash
# scripts/optimize.sh

# Minificar CSS customizado
npx cssnano assets/css/custom.css > assets/css/custom.min.css

# Minificar JavaScript
for file in assets/js/*.js components/**/*.js; do
  npx terser $file -o ${file%.js}.min.js --compress --mangle
done

# Otimizar imagens
find assets/images -type f \( -name "*.png" -o -name "*.jpg" \) -exec \
  convert {} -quality 85 -strip {} \;

echo "✅ Assets otimizados para produção"
```

### 2. Configuração de CDNs

```html
<!-- production.html template -->
<!-- Tailwind CSS - Produção -->
<link href="https://cdn.jsdelivr.net/npm/tailwindcss@3.4/dist/tailwind.min.css" 
      rel="stylesheet"
      integrity="sha384-..." 
      crossorigin="anonymous">

<!-- Alpine.js - Produção -->
<script defer 
        src="https://cdn.jsdelivr.net/npm/alpinejs@3.13/dist/cdn.min.js"
        integrity="sha384-..."
        crossorigin="anonymous"></script>

<!-- Lucide Icons -->
<script src="https://unpkg.com/lucide@latest/dist/umd/lucide.min.js"></script>
```

### 3. Cache e Performance

```html
<!-- Cache de assets -->
<meta http-equiv="Cache-Control" content="max-age=31536000, immutable">

<!-- Preload crítico -->
<link rel="preload" href="/assets/css/custom.min.css" as="style">
<link rel="preload" href="/assets/js/app.min.js" as="script">

<!-- DNS prefetch -->
<link rel="dns-prefetch" href="https://cdn.jsdelivr.net">
<link rel="preconnect" href="https://cdn.jsdelivr.net">
```

## 📱 PWA Setup

### 1. Manifest.json

```json
{
  "name": "AutoCore Config",
  "short_name": "AutoCore",
  "description": "Sistema de Configuração AutoCore",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#0f172a",
  "theme_color": "#3b82f6",
  "orientation": "any",
  "icons": [
    {
      "src": "/assets/images/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/assets/images/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

### 2. Service Worker

```javascript
// sw.js - Service Worker para offline
const CACHE_NAME = 'autocore-v1';
const urlsToCache = [
  '/',
  '/index.html',
  '/devices.html',
  '/relays.html',
  '/assets/css/custom.min.css',
  '/assets/js/app.min.js'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => response || fetch(event.request))
  );
});
```

## 🎴 Deploy no Raspberry Pi

### 1. Estrutura de Produção

```bash
# Estrutura no Raspberry Pi
/home/pi/autocore/
├── frontend/
│   ├── index.html
│   ├── *.html (páginas)
│   ├── assets/
│   │   ├── css/*.min.css
│   │   ├── js/*.min.js
│   │   └── images/
│   ├── components/
│   ├── manifest.json
│   └── sw.js
└── backend/
    └── ...
```

### 2. Script de Deploy

```bash
#!/bin/bash
# deploy-frontend.sh

echo "🚀 Iniciando deploy do frontend..."

# Variáveis
PI_HOST="raspberrypi.local"
PI_USER="pi"
REMOTE_PATH="/home/pi/autocore/frontend"
LOCAL_PATH="./frontend"

# 1. Otimizar assets
echo "🔧 Otimizando assets..."
./scripts/optimize.sh

# 2. Criar arquivo de versão
echo "{\"version\": \"$(date +%Y%m%d-%H%M%S)\", \"build\": \"production\"}" > $LOCAL_PATH/version.json

# 3. Sincronizar arquivos
echo "📤 Enviando arquivos para Raspberry Pi..."
rsync -avz --delete \
  --exclude='*.md' \
  --exclude='docs/' \
  --exclude='tests/' \
  --exclude='node_modules/' \
  $LOCAL_PATH/ $PI_USER@$PI_HOST:$REMOTE_PATH/

# 4. Configurar permissões
echo "🔐 Configurando permissões..."
ssh $PI_USER@$PI_HOST << 'EOF'
  chmod -R 755 /home/pi/autocore/frontend
  find /home/pi/autocore/frontend -type f -exec chmod 644 {} \;
EOF

# 5. Limpar cache do nginx (se usado)
echo "🧹 Limpando cache..."
ssh $PI_USER@$PI_HOST "sudo nginx -s reload 2>/dev/null || true"

echo "✅ Deploy do frontend concluído!"
echo "🌐 Acesse: http://$PI_HOST:8000"
```

### 3. Nginx Config (Opcional)

```nginx
# /etc/nginx/sites-available/autocore
server {
    listen 80;
    server_name raspberrypi.local;
    root /home/pi/autocore/frontend;
    
    # Compressão
    gzip on;
    gzip_types text/css application/javascript;
    gzip_min_length 1000;
    
    # Cache estático
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # API proxy
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    # WebSocket
    location /ws/ {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    # SPA fallback
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

## 📦 Build Simplificado

### Makefile para Frontend

```makefile
# frontend/Makefile
.PHONY: help build deploy clean

help:
	@echo "Comandos disponíveis:"
	@echo "  make build   - Otimiza para produção"
	@echo "  make deploy  - Deploy para Raspberry Pi"
	@echo "  make clean   - Limpa arquivos temporários"

build:
	@echo "Building frontend..."
	@./scripts/optimize.sh
	@echo "Build completo!"

deploy: build
	@echo "Deploying to Raspberry Pi..."
	@./scripts/deploy-frontend.sh

clean:
	@echo "Limpando arquivos temporários..."
	@find . -name "*.min.js" -delete
	@find . -name "*.min.css" -delete
	@echo "Limpeza concluída!"
```

## ⚡ Otimizações Específicas para Pi Zero

### 1. Lazy Loading

```javascript
// Carregar componentes sob demanda
Alpine.data('lazyComponent', () => ({
  loaded: false,
  
  async load() {
    if (!this.loaded) {
      const module = await import(`/components/${this.component}.js`);
      this.loaded = true;
    }
  }
}))
```

### 2. Throttling e Debouncing

```javascript
// Limitar atualizações frequentes
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

// Uso em eventos
window.addEventListener('resize', debounce(() => {
  // Atualizar layout
}, 250));
```

### 3. Redução de Requisições

```javascript
// Batch de requisições
const batchRequests = {
  queue: [],
  timer: null,
  
  add(request) {
    this.queue.push(request);
    if (!this.timer) {
      this.timer = setTimeout(() => this.flush(), 100);
    }
  },
  
  async flush() {
    const batch = this.queue.splice(0);
    await API.post('/api/batch', { requests: batch });
    this.timer = null;
  }
};
```

## 📏 Monitoramento

### Performance Metrics

```javascript
// Monitorar performance
if ('performance' in window) {
  window.addEventListener('load', () => {
    const perfData = performance.getEntriesByType('navigation')[0];
    console.log('Load time:', perfData.loadEventEnd - perfData.fetchStart, 'ms');
    
    // Enviar métricas para o backend
    API.post('/api/metrics', {
      loadTime: perfData.loadEventEnd - perfData.fetchStart,
      domReady: perfData.domContentLoadedEventEnd - perfData.fetchStart,
      resources: performance.getEntriesByType('resource').length
    });
  });
}
```

## 🎉 Verificação Pós-Deploy

```bash
#!/bin/bash
# verify-deploy.sh

echo "🔍 Verificando deploy..."

# Testar acesso
curl -s -o /dev/null -w "%{http_code}" http://raspberrypi.local:8000

# Verificar versão
curl -s http://raspberrypi.local:8000/version.json | jq '.version'

# Testar API
curl -s http://raspberrypi.local:8000/api/health

echo "✅ Deploy verificado com sucesso!"
```

## 📝 Checklist de Deploy

- [ ] Assets otimizados (CSS/JS minificados)
- [ ] Imagens comprimidas
- [ ] PWA configurado (manifest + SW)
- [ ] Cache headers configurados
- [ ] GZIP habilitado
- [ ] Lazy loading implementado
- [ ] Versão atualizada
- [ ] Backup realizado
- [ ] Testes de performance
- [ ] Monitoramento ativo