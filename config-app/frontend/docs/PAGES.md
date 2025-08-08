# 📄 Estrutura de Páginas - AutoCore Config

## 📑 Visão Geral

Documentação completa das páginas da aplicação AutoCore Config, incluindo estrutura, funcionalidades e integrações.

## 🏠 Dashboard (index.html)

### Propósito
Página principal com visão geral do sistema e acesso rápido às funcionalidades.

### Estrutura
```html
<!-- Seção de Status -->
<section id="status-cards">
  - Cards de dispositivos conectados
  - Status do sistema
  - Alertas e notificações
</section>

<!-- Ações Rápidas -->
<section id="quick-actions">
  - Botões de controle principais
  - Macros favoritas
</section>

<!-- Telemetria -->
<section id="telemetry">
  - Gráficos em tempo real
  - Dados CAN Bus
</section>
```

### Funcionalidades
- Monitor de dispositivos em tempo real
- Execução de macros
- Visualização de telemetria
- Navegação para outras seções

## 📱 Dispositivos (devices.html)

### Propósito
Gerenciamento completo de dispositivos ESP32 conectados.

### Estrutura
```html
<!-- Lista de Dispositivos -->
<div class="device-grid">
  - Cards de dispositivos
  - Status de conexão
  - Ações rápidas
</div>

<!-- Modal de Configuração -->
<dialog id="device-config">
  - Formulário de configuração
  - Parâmetros do dispositivo
  - Teste de conexão
</dialog>
```

### Funcionalidades
- Descoberta automática
- Configuração de IP/Nome
- Status em tempo real
- Atualização OTA

## 🔌 Relés (relays.html)

### Propósito
Configuração e controle dos canais de relé.

### Estrutura
```html
<!-- Seletor de Placa -->
<select id="board-selector">
  - Lista de placas de relé
</select>

<!-- Grid de Canais -->
<div class="relay-grid">
  - 16 canais por placa
  - Controles individuais
  - Status visual
</div>

<!-- Configuração de Canal -->
<aside id="channel-config">
  - Nome e descrição
  - Tipo de função
  - Proteções
  - Ícone e cor
</aside>
```

### Funcionalidades
- Controle individual de canais
- Configuração de proteções
- Teste de acionamento
- Grupos de relés

## 🖥️ Telas (screens.html)

### Propósito
Editor visual para criar e configurar telas da interface.

### Estrutura
```html
<!-- Editor Principal -->
<main class="screen-editor">
  <!-- Barra de Ferramentas -->
  <nav class="toolbar">
    - Componentes disponíveis
    - Configurações de layout
    - Preview devices
  </nav>
  
  <!-- Área de Design -->
  <div class="design-area">
    - Grid drag-and-drop
    - Preview em tempo real
  </div>
  
  <!-- Propriedades -->
  <aside class="properties-panel">
    - Configurações do item
    - Estilos e cores
    - Ações e eventos
  </aside>
</main>
```

### Funcionalidades
- Drag-and-drop de componentes
- Preview por tipo de dispositivo
- Configuração de ações
- Templates pré-definidos

## 🚗 CAN Bus (canbus.html)

### Propósito
Configuração e monitoramento de sinais CAN.

### Estrutura
```html
<!-- Configuração -->
<section id="can-config">
  - Parâmetros de conexão
  - Baudrate e filtros
</section>

<!-- Lista de Sinais -->
<section id="signals-list">
  - Tabela de sinais mapeados
  - Adicionar/editar sinais
  - Fórmulas de conversão
</section>

<!-- Monitor em Tempo Real -->
<section id="can-monitor">
  - Valores ao vivo
  - Gráficos de telemetria
  - Log de mensagens
</section>
```

### Funcionalidades
- Mapeamento de sinais FuelTech
- Monitor em tempo real
- Gravação de logs
- Alertas e limites

## ⚙️ Configurações (settings.html)

### Propósito
Configurações gerais do sistema e personalizações.

### Estrutura
```html
<!-- Navegação de Abas -->
<nav class="settings-tabs">
  - Geral
  - Temas
  - Rede
  - Segurança
  - Backup
</nav>

<!-- Conteúdo das Abas -->
<div class="tab-content">
  <!-- Geral -->
  - Idioma e região
  - Unidades de medida
  
  <!-- Temas -->
  - Seletor de tema
  - Customização de cores
  
  <!-- Rede -->
  - MQTT config
  - API settings
  
  <!-- Segurança -->
  - Usuários e senhas
  - Permissões
  
  <!-- Backup -->
  - Export/Import
  - Restauração
</div>
```

### Funcionalidades
- Gestão de usuários
- Personalização de temas
- Backup e restauração
- Configurações de rede

## 🤖 Macros (macros.html)

### Propósito
Criação e gerenciamento de automações.

### Estrutura
```html
<!-- Lista de Macros -->
<section id="macros-list">
  - Cards de macros existentes
  - Status e última execução
</section>

<!-- Editor de Macro -->
<section id="macro-editor">
  - Nome e descrição
  - Trigger (manual, scheduled, condition)
  - Sequência de ações
  - Condições
</section>
```

### Funcionalidades
- Editor visual de macros
- Agendamento
- Condições complexas
- Teste e debug

## 📋 Logs (logs.html)

### Propósito
Monitoramento e análise de eventos do sistema.

### Estrutura
```html
<!-- Filtros -->
<section id="log-filters">
  - Período
  - Tipo de evento
  - Dispositivo
  - Nível
</section>

<!-- Tabela de Logs -->
<section id="logs-table">
  - Lista paginada
  - Detalhes expandidos
  - Export CSV
</section>
```

### Funcionalidades
- Filtros avançados
- Export de dados
- Análise de erros
- Estatísticas

## 🔗 Navegação e Fluxo

### Estrutura de Navegação
```
Dashboard (index.html)
├── Dispositivos (devices.html)
├── Relés (relays.html)
├── Telas (screens.html)
├── CAN Bus (canbus.html)
├── Macros (macros.html)
├── Logs (logs.html)
└── Configurações (settings.html)
```

### Padrões Comuns

1. **Header**: Presente em todas as páginas
2. **Sidebar**: Menu de navegação lateral
3. **Breadcrumbs**: Localização atual
4. **Footer**: Versão e status

## 🎨 Temas e Estilos

Cada página suporta:
- Dark/Light mode
- Temas customizados
- Responsividade completa
- Acessibilidade (ARIA)

## 📡 Integrações

Todas as páginas se comunicam com:
- API FastAPI (REST)
- WebSocket (real-time)
- MQTT (dispositivos)
- LocalStorage (preferências)