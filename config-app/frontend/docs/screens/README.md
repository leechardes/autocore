# 📱 Screens - Documentação Frontend

## 🎯 Visão Geral
Documentação das telas e fluxos de navegação da interface web do AutoCore Config App.

## 🖥️ Telas Principais

### Dashboard Principal
- **Arquivo**: `src/pages/DashboardPage.jsx`
- **Rota**: `/`
- **Descrição**: Tela principal com visão geral dos dispositivos
- **Componentes**: Device cards, status indicators, quick actions

### Gestão de Dispositivos
- **Arquivo**: `src/pages/DevicesPage.jsx`
- **Rota**: `/devices`
- **Descrição**: Listagem e configuração de dispositivos ESP32
- **Funcionalidades**: CRUD de dispositivos, configuração WiFi

### Controle de Relés
- **Arquivo**: `src/pages/RelaysPage.jsx`
- **Rota**: `/relays`
- **Descrição**: Controle individual e em lote dos relés
- **Funcionalidades**: Toggle manual, automação, agendamento

### Configuração de Telas
- **Arquivo**: `src/pages/ScreensPageV2.jsx`
- **Rota**: `/screens`
- **Descrição**: Editor visual para layouts de tela dos dispositivos
- **Funcionalidades**: Drag & drop, preview em tempo real

### Macros e Automação
- **Arquivo**: `src/pages/MacrosPage.jsx`
- **Rota**: `/macros`
- **Descrição**: Criação e gestão de macros de automação
- **Funcionalidades**: Editor de ações, triggers, condições

### Monitor MQTT
- **Arquivo**: `src/pages/MQTTMonitorPage.jsx`
- **Rota**: `/mqtt`
- **Descrição**: Monitoramento em tempo real do tráfego MQTT
- **Funcionalidades**: Log de mensagens, filtros, debug

### Configurações de Temas
- **Arquivo**: `src/pages/DeviceThemesPage.jsx`
- **Rota**: `/themes`
- **Descrição**: Personalização visual dos dispositivos
- **Funcionalidades**: Editor de cores, fontes, layouts

### Configurações do Sistema
- **Arquivo**: `src/pages/ConfigSettingsPage.jsx`
- **Rota**: `/settings`
- **Descrição**: Configurações gerais do sistema
- **Funcionalidades**: Conectividade, backup, usuários

## 🎨 Fluxos de Navegação

### Fluxo Principal
```
Dashboard → Dispositivos → Relés → Telas → Macros
     ↑                                       ↓
     ←←←←←←←← Configurações ←←←←←←←←←←←←←←←←
```

### Fluxo de Configuração de Dispositivo
```
Dispositivos → Adicionar/Editar → WiFi → Relés → Telas → Salvar
```

### Fluxo de Criação de Macro
```
Macros → Nova Macro → Triggers → Ações → Condições → Teste → Salvar
```

## 📋 Componentes de Tela

### Layout Components
- `Header` - Cabeçalho com navegação
- `Sidebar` - Menu lateral
- `Footer` - Rodapé com status
- `Breadcrumb` - Navegação estrutural

### Page Wrapper
- `PageContainer` - Container padrão das páginas
- `PageHeader` - Cabeçalho das páginas
- `PageContent` - Conteúdo principal
- `PageActions` - Botões de ação

### Loading States
- `PageSkeleton` - Skeleton loader para páginas
- `ContentLoader` - Loader para conteúdo
- `TableSkeleton` - Skeleton para tabelas

## 🎯 Responsividade

### Breakpoints
- **Mobile**: < 640px - Stack vertical, menu colapsado
- **Tablet**: 640px - 1024px - Layout adaptativo
- **Desktop**: > 1024px - Layout completo

### Adaptações por Tela
- **Dashboard**: Cards em grid responsivo
- **Tabelas**: Scroll horizontal em mobile
- **Formulários**: Stack vertical em mobile
- **Modais**: Fullscreen em mobile

## 🔄 Estados de Carregamento

### Loading Patterns
1. **Initial Load**: Skeleton completo da página
2. **Data Refresh**: Spinner/progress em seções específicas
3. **Action Loading**: Button loading state
4. **Background Updates**: Toast notifications

### Error States
1. **Network Error**: Retry button com mensagem
2. **Permission Denied**: Redirect para login
3. **Not Found**: 404 page com navegação
4. **Server Error**: Error boundary com reload

## 🎨 Design System

### Colors
- **Primary**: Blue tones para ações principais
- **Secondary**: Gray tones para conteúdo
- **Success**: Green para status positivos
- **Warning**: Orange para alertas
- **Error**: Red para erros

### Typography
- **Headings**: font-semibold, sizes from text-sm to text-2xl
- **Body**: font-normal, text-sm to text-base
- **Captions**: font-medium, text-xs

### Spacing
- **Padding**: p-2, p-4, p-6, p-8
- **Margins**: m-2, m-4, m-6, m-8
- **Gaps**: gap-2, gap-4, gap-6, gap-8

## 📱 Mobile-First

### Princípios
1. **Touch-First**: Botões e campos otimizados para touch
2. **Thumb-Friendly**: Elementos importantes na zona do polegar
3. **Swipe Navigation**: Gestos para navegação lateral
4. **Pull-to-Refresh**: Atualização por gesto

### Performance Mobile
1. **Lazy Loading**: Componentes carregados sob demanda
2. **Virtual Scrolling**: Listas grandes virtualizadas
3. **Image Optimization**: Imagens responsivas e otimizadas
4. **Code Splitting**: Bundle splitting por rota

---

**Status**: Documentação completa ✅  
**Última atualização**: 2025-01-28  
**Responsável**: Equipe Frontend