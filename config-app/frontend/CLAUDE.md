# 🤖 Instruções para Claude - Config-App Frontend

## 🎯 Visão Geral

Frontend SPA (Single Page Application) usando **React + Vite + shadcn/ui + Tailwind CSS**. Build process otimizado para produção com deploy estático.

## 🏗️ Arquitetura

### Por que mudamos para shadcn/ui?

1. **Produtividade 10x** - Componentes prontos e consistentes
2. **Visual profissional** - Design system moderno e polido
3. **Manutenibilidade** - Documentação oficial e comunidade ativa
4. **Performance** - Bundle otimizado (~150KB gzip)

### Stack Moderna

```json
{
  "framework": "React 18",
  "bundler": "Vite 5",
  "ui": "shadcn/ui",
  "styling": "Tailwind CSS",
  "icons": "Lucide React",
  "language": "JavaScript (JSX)"
}
```

## 📁 Estrutura

```
frontend/
├── public/             # Assets estáticos
├── src/
│   ├── components/     # Componentes React
│   │   └── ui/        # shadcn/ui components
│   ├── pages/         # Páginas da aplicação
│   ├── lib/           # Utilitários (utils.js)
│   ├── hooks/         # Custom React hooks
│   ├── types/         # TypeScript types (futuro)
│   ├── App.jsx        # Componente principal
│   ├── main.jsx       # Entry point
│   └── index.css      # Estilos globais
├── index.html         # Template HTML
├── vite.config.js     # Configuração Vite
├── tailwind.config.js # Configuração Tailwind
├── components.json    # Configuração shadcn/ui
└── package.json       # Dependências e scripts
```

## 🎨 Design System

### Inspirado em shadcn/ui

```html
<!-- Botão estilo shadcn -->
<button class="inline-flex items-center justify-center rounded-md text-sm font-medium 
               ring-offset-background transition-colors focus-visible:outline-none 
               focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 
               disabled:pointer-events-none disabled:opacity-50
               bg-primary text-primary-foreground hover:bg-primary/90
               h-10 px-4 py-2">
    Click me
</button>
```

### Variáveis CSS

```css
/* custom.css */
:root {
  --background: 0 0% 100%;
  --foreground: 222.2 84% 4.9%;
  --primary: 222.2 47.4% 11.2%;
  --primary-foreground: 210 40% 98%;
  --secondary: 210 40% 96.1%;
  --secondary-foreground: 222.2 47.4% 11.2%;
  --muted: 210 40% 96.1%;
  --muted-foreground: 215.4 16.3% 46.9%;
  --accent: 210 40% 96.1%;
  --accent-foreground: 222.2 47.4% 11.2%;
  --destructive: 0 84.2% 60.2%;
  --destructive-foreground: 210 40% 98%;
  --border: 214.3 31.8% 91.4%;
  --input: 214.3 31.8% 91.4%;
  --ring: 222.2 84% 4.9%;
  --radius: 0.5rem;
}

.dark {
  --background: 222.2 84% 4.9%;
  --foreground: 210 40% 98%;
  /* ... */
}
```

## 📝 Padrões Alpine.js

### Componente Básico

```javascript
// js/components/devices.js
Alpine.data('devicesManager', () => ({
    devices: [],
    loading: false,
    error: null,
    
    async init() {
        await this.loadDevices();
    },
    
    async loadDevices() {
        this.loading = true;
        try {
            const response = await api.get('/devices');
            this.devices = response.data;
        } catch (e) {
            this.error = e.message;
        } finally {
            this.loading = false;
        }
    },
    
    async toggleDevice(id) {
        // lógica
    }
}));
```

### No HTML

```html
<div x-data="devicesManager" x-init="init">
    <!-- Loading State -->
    <div x-show="loading" class="animate-pulse">
        Carregando...
    </div>
    
    <!-- Error State -->
    <div x-show="error" class="text-red-500">
        <span x-text="error"></span>
    </div>
    
    <!-- Content -->
    <div x-show="!loading && !error">
        <template x-for="device in devices" :key="device.id">
            <div class="p-4 border rounded-lg">
                <h3 x-text="device.name"></h3>
                <button @click="toggleDevice(device.id)">
                    Toggle
                </button>
            </div>
        </template>
    </div>
</div>
```

## 🔌 API Client

### Configuração

```javascript
// js/api.js
const API_BASE = 'http://localhost:8000/api';

const api = {
    async get(endpoint) {
        const response = await fetch(`${API_BASE}${endpoint}`);
        if (!response.ok) throw new Error(response.statusText);
        return await response.json();
    },
    
    async post(endpoint, data) {
        const response = await fetch(`${API_BASE}${endpoint}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        if (!response.ok) throw new Error(response.statusText);
        return await response.json();
    },
    
    async patch(endpoint, data) {
        // similar
    },
    
    async delete(endpoint) {
        // similar
    }
};
```

## 🎯 Páginas Principais

### 1. Dashboard

```html
<!-- Métricas principais -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
    <div class="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
        <h3>Dispositivos Online</h3>
        <p class="text-3xl font-bold" x-text="stats.devicesOnline"></p>
    </div>
    <!-- mais cards -->
</div>
```

### 2. Dispositivos

```html
<!-- Lista de dispositivos -->
<div class="space-y-4">
    <template x-for="device in devices">
        <div class="bg-white dark:bg-gray-800 rounded-lg p-4">
            <!-- Status indicator -->
            <div class="flex items-center justify-between">
                <div>
                    <h3 x-text="device.name"></h3>
                    <p x-text="device.type" class="text-sm text-gray-500"></p>
                </div>
                <div :class="device.status === 'online' ? 'bg-green-500' : 'bg-red-500'"
                     class="w-3 h-3 rounded-full"></div>
            </div>
        </div>
    </template>
</div>
```

### 3. Relés

```html
<!-- Grid de controles de relé -->
<div class="grid grid-cols-2 md:grid-cols-4 gap-4">
    <template x-for="channel in channels">
        <button @click="toggleRelay(channel.id)"
                :class="channel.state ? 'bg-green-500' : 'bg-gray-300'"
                class="p-6 rounded-lg transition-colors">
            <i :data-lucide="channel.icon"></i>
            <p x-text="channel.name"></p>
        </button>
    </template>
</div>
```

### 4. Configurador de Telas

```html
<!-- Drag & Drop Editor -->
<div x-data="screenEditor">
    <!-- Canvas -->
    <div class="border-2 border-dashed border-gray-300 min-h-[400px]"
         @drop="onDrop($event)"
         @dragover.prevent>
        <!-- Screen items -->
    </div>
    
    <!-- Toolbar -->
    <div class="mt-4">
        <!-- Component palette -->
    </div>
</div>
```

## 🎨 Componentes UI Reutilizáveis

### Modal

```html
<!-- Modal Alpine.js -->
<div x-data="{ open: false }">
    <button @click="open = true">Abrir Modal</button>
    
    <div x-show="open" 
         x-transition
         class="fixed inset-0 z-50 flex items-center justify-center"
         @click.away="open = false">
        <div class="bg-white rounded-lg p-6 max-w-md">
            <!-- Content -->
        </div>
    </div>
</div>
```

### Toast Notifications

```javascript
// js/components/toast.js
Alpine.data('toast', () => ({
    messages: [],
    
    show(message, type = 'info') {
        const id = Date.now();
        this.messages.push({ id, message, type });
        setTimeout(() => this.remove(id), 3000);
    },
    
    remove(id) {
        this.messages = this.messages.filter(m => m.id !== id);
    }
}));
```

### Tabs

```html
<div x-data="{ tab: 'tab1' }">
    <!-- Tab Headers -->
    <div class="flex space-x-1 border-b">
        <button @click="tab = 'tab1'" 
                :class="tab === 'tab1' ? 'border-b-2 border-blue-500' : ''"
                class="px-4 py-2">
            Tab 1
        </button>
        <!-- mais tabs -->
    </div>
    
    <!-- Tab Content -->
    <div x-show="tab === 'tab1'" class="p-4">
        Content 1
    </div>
    <!-- mais conteúdos -->
</div>
```

## 📱 Responsividade

### Breakpoints Tailwind

```html
<!-- Mobile First -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
    <!-- Responsive grid -->
</div>

<!-- Hide/Show -->
<div class="block md:hidden">Mobile only</div>
<div class="hidden md:block">Desktop only</div>
```

### Menu Mobile

```html
<div x-data="{ mobileMenu: false }">
    <!-- Hamburger -->
    <button @click="mobileMenu = !mobileMenu" class="md:hidden">
        <i data-lucide="menu"></i>
    </button>
    
    <!-- Menu -->
    <nav :class="mobileMenu ? 'block' : 'hidden'" 
         class="md:block">
        <!-- Links -->
    </nav>
</div>
```

## 🌙 Dark Mode

```html
<script>
// Detecta e aplica tema
if (localStorage.theme === 'dark' || 
    (!('theme' in localStorage) && 
     window.matchMedia('(prefers-color-scheme: dark)').matches)) {
    document.documentElement.classList.add('dark');
}

// Toggle function
function toggleTheme() {
    if (document.documentElement.classList.contains('dark')) {
        document.documentElement.classList.remove('dark');
        localStorage.theme = 'light';
    } else {
        document.documentElement.classList.add('dark');
        localStorage.theme = 'dark';
    }
}
</script>
```

## 🚀 Comandos de Desenvolvimento

### Scripts Disponíveis

```bash
# Desenvolvimento
npm run dev          # Inicia servidor Vite (http://localhost:3000)
npm run build        # Build para produção
npm run preview      # Preview do build de produção

# Qualidade de código
npm run lint         # Verifica código com ESLint
npm run format       # Formata código com Prettier

# shadcn/ui
npx shadcn@latest add [component]  # Adiciona componente
npx shadcn@latest update          # Atualiza componentes
```

### Performance e Otimizações

1. **Bundle Splitting** - Chunks automáticos (vendor, ui)
2. **Tree Shaking** - Remove código não utilizado
3. **Code Splitting** - Lazy loading de páginas/componentes
4. **Asset Optimization** - Compressão automática de imagens

## 🧪 Testes

### Teste Manual Checklist

- [ ] Funciona no mobile (320px)
- [ ] Funciona no tablet (768px)
- [ ] Funciona no desktop (1920px)
- [ ] Dark mode funciona
- [ ] Formulários validam
- [ ] API errors são tratados
- [ ] Loading states funcionam
- [ ] Navegação funciona

### Debug Tips

```javascript
// Debug Alpine.js
Alpine.store('debug', true);

// No componente
if (Alpine.store('debug')) {
    console.log('State:', this.$data);
}
```

## 🚨 Erros Comuns

### Alpine não inicializa

```html
<!-- ERRADO: Alpine antes do defer -->
<script src="alpine.js"></script>
<div x-data="...">

<!-- CERTO: defer no script -->
<script defer src="alpine.js"></script>
```

### Tailwind não funciona

```html
<!-- Verificar se CDN está carregando -->
<script src="https://cdn.tailwindcss.com"></script>
```

### CORS errors

```javascript
// Backend deve permitir origem
// Verificar CORS no FastAPI
```

## 📦 Deploy

### Development

```bash
# Com Vite (recomendado)
npm run dev

# Com preview (testa build)
npm run build && npm run preview
```

### Production

```bash
# 1. Build para produção
npm run build

# 2. Deploy para Raspberry Pi
scp -r dist/* pi@raspberrypi.local:/var/www/autocore/

# 3. Nginx config
location / {
    root /var/www/autocore;
    try_files $uri $uri/ /index.html;
    
    # Cache assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}

# 4. API Proxy (opcional)
location /api {
    proxy_pass http://localhost:8000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

## 🎯 Checklist de Qualidade

- [ ] HTML semântico
- [ ] Classes Tailwind organizadas
- [ ] Alpine.js sem memory leaks
- [ ] Imagens otimizadas
- [ ] Lazy loading aplicado
- [ ] Dark mode testado
- [ ] Mobile first
- [ ] Acessibilidade básica (ARIA)
- [ ] Performance < 100KB total

## 💡 Dicas

1. **KISS** - Keep It Simple, Stupid
2. **Mobile First** - Sempre
3. **CDN Cache** - Use versões específicas em produção
4. **Component Thinking** - Reutilize código
5. **Progressive Enhancement** - Funciona sem JS

## 🎓 Recursos

- [Alpine.js DevTools](https://github.com/alpine-collective/alpinejs-devtools)
- [Tailwind Cheatsheet](https://tailwindcomponents.com/cheatsheet/)
- [Lucide Icons](https://lucide.dev/icons/)
- [shadcn/ui Examples](https://ui.shadcn.com/examples)

---

**Última Atualização:** 07 de agosto de 2025  
**Versão:** 2.0.0  
**Maintainer:** Lee Chardes