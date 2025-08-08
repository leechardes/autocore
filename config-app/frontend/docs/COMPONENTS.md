# 📦 Catálogo de Componentes - AutoCore Config

## 📋 Visão Geral

Catálogo completo de componentes reutilizáveis do AutoCore Config App. Todos os componentes são construídos com HTML puro + Tailwind CSS + Alpine.js, sem necessidade de build process.

## 🎨 Componentes Base

### Button
```javascript
// components/ui/button.js
Alpine.data('button', () => ({
  variant: 'primary', // primary, secondary, danger, ghost
  size: 'md', // sm, md, lg
  loading: false,
  disabled: false,
  
  click() {
    if (!this.disabled && !this.loading) {
      this.$dispatch('button-click')
    }
  }
}))
```

**Uso:**
```html
<button x-data="button" 
        :class="`btn-${variant} btn-${size}`"
        :disabled="disabled || loading"
        @click="click">
  <span x-show="loading" class="spinner"></span>
  <span x-text="$el.textContent"></span>
</button>
```

### Card
```javascript
// components/ui/card.js
Alpine.data('card', () => ({
  title: '',
  collapsed: false,
  
  toggle() {
    this.collapsed = !this.collapsed
  }
}))
```

### Modal
```javascript
// components/ui/modal.js
Alpine.data('modal', () => ({
  open: false,
  title: '',
  
  show() { this.open = true },
  hide() { this.open = false }
}))
```

### Table
```javascript
// components/ui/table.js
Alpine.data('dataTable', () => ({
  data: [],
  sortBy: null,
  sortAsc: true,
  search: '',
  
  get filteredData() {
    // Lógica de filtro e ordenação
  }
}))
```

## 🏗️ Componentes de Layout

### Navbar
```javascript
// components/layout/navbar.js
Alpine.data('navbar', () => ({
  mobileMenuOpen: false,
  currentPage: 'dashboard',
  
  navigate(page) {
    this.currentPage = page
    window.location.href = `/${page}.html`
  }
}))
```

### Sidebar
```javascript
// components/layout/sidebar.js
Alpine.data('sidebar', () => ({
  collapsed: localStorage.getItem('sidebarCollapsed') === 'true',
  
  toggle() {
    this.collapsed = !this.collapsed
    localStorage.setItem('sidebarCollapsed', this.collapsed)
  }
}))
```

## 🚗 Componentes Específicos AutoCore

### Device Card
```javascript
// components/modules/device-card.js
Alpine.data('deviceCard', (device) => ({
  device: device,
  status: 'offline',
  loading: false,
  
  async checkStatus() {
    this.loading = true
    const res = await API.get(`/devices/${this.device.id}/status`)
    this.status = res.status
    this.loading = false
  },
  
  configure() {
    Alpine.store('modal').show('device-config', this.device)
  }
}))
```

### Relay Control
```javascript
// components/modules/relay-control.js
Alpine.data('relayControl', (channel) => ({
  channel: channel,
  state: false,
  toggling: false,
  
  async toggle() {
    if (this.channel.protection_mode === 'confirm') {
      if (!confirm('Confirmar ação?')) return
    }
    
    this.toggling = true
    await API.post(`/relays/${this.channel.id}/toggle`)
    this.state = !this.state
    this.toggling = false
  }
}))
```

### Screen Builder
```javascript
// components/modules/screen-builder.js
Alpine.data('screenBuilder', () => ({
  items: [],
  selectedItem: null,
  gridColumns: 2,
  
  addItem(type) {
    this.items.push({
      id: Date.now(),
      type: type,
      position: this.items.length
    })
  },
  
  removeItem(id) {
    this.items = this.items.filter(i => i.id !== id)
  }
}))
```

### CAN Signal Monitor
```javascript
// components/modules/can-monitor.js
Alpine.data('canMonitor', () => ({
  signals: [],
  connected: false,
  
  async connect() {
    // WebSocket connection
    this.ws = new WebSocket('ws://localhost:8000/ws/can')
    this.ws.onmessage = (e) => {
      this.signals = JSON.parse(e.data)
    }
  }
}))
```

## 📊 Componentes de Visualização

### Gauge
```javascript
// components/ui/gauge.js
Alpine.data('gauge', (config) => ({
  value: 0,
  min: config.min || 0,
  max: config.max || 100,
  unit: config.unit || '',
  
  get percentage() {
    return ((this.value - this.min) / (this.max - this.min)) * 100
  }
}))
```

### Status Badge
```javascript
// components/ui/badge.js
Alpine.data('statusBadge', (status) => ({
  status: status,
  
  get color() {
    return {
      'online': 'green',
      'offline': 'gray',
      'error': 'red',
      'warning': 'yellow'
    }[this.status] || 'gray'
  }
}))
```

## 🎯 Uso dos Componentes

### Importação
```html
<!-- No head da página -->
<script src="/components/ui/button.js"></script>
<script src="/components/modules/device-card.js"></script>
```

### Inicialização
```html
<div x-data="deviceCard({ id: 1, name: 'ESP32 Principal' })">
  <!-- Conteúdo do componente -->
</div>
```

### Comunicação entre Componentes
```javascript
// Usando Alpine Store
Alpine.store('devices', {
  list: [],
  selected: null,
  
  select(device) {
    this.selected = device
    this.$dispatch('device-selected', device)
  }
})

// Ouvindo eventos
<div @device-selected="handleSelection($event.detail)">
```

## 🔧 Padrões e Convenções

1. **Nomenclatura**: kebab-case para arquivos, camelCase para dados
2. **Estrutura**: Um componente por arquivo
3. **Estado**: Usar Alpine.store para estado global
4. **Eventos**: Prefixar com nome do componente
5. **Estilos**: Classes Tailwind, customizações mínimas

## 📚 Referências

- [Alpine.js Docs](https://alpinejs.dev)
- [Tailwind CSS](https://tailwindcss.com)
- [Lucide Icons](https://lucide.dev)