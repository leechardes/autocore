# 📋 AutoCore Flutter - Lista Completa de Tarefas

Este documento contém TODAS as tarefas necessárias para o desenvolvimento do app Flutter do AutoCore, organizadas por categoria e prioridade. Cada tarefa inclui estimativa de tempo e critérios de aceitação.

## 📊 Resumo Executivo

- **Total de Tarefas**: 125
- **Tarefas Completadas**: 11 (8.8%)
- **Tarefas Em Progresso**: 2
- **Tempo Estimado Total**: 70 dias úteis (10 semanas)
- **Tempo Gasto**: ~15 horas
- **Complexidade**: Alta
- **Dependências Críticas**: Sistema de Configuração JSON, Sistema de Temas, Backend MQTT

### 🚀 Status Atual (09/08/2025)
- **Projeto Iniciado**: ✅
- **Sistema de Temas**: 40% completo
- **Componentes Base**: 13% completo  
- **MQTT Service**: ✅ Implementado
- **Sistema Dinâmico**: 🚀 Em desenvolvimento
- **Próxima Sprint**: Sistema de configuração JSON e navegação dinâmica

---

## 🏗️ SETUP & CONFIGURAÇÃO (20 tarefas)

### Configuração Inicial do Projeto

- [x] **T001** - Criar projeto Flutter `autocore_mobile` ✅
  - **Tempo**: 2h
  - **Critério**: Projeto criado e executando com sucesso
  - **Dependências**: Nenhuma

- [x] **T002** - Configurar `pubspec.yaml` com todas as dependências ✅
  - **Tempo**: 1h
  - **Critério**: Todas as dependências instaladas sem conflitos
  - **Dependências**: T001

- [x] **T003** - Configurar estrutura de pastas da arquitetura Clean ✅
  - **Tempo**: 1h
  - **Critério**: Estrutura de pastas criada conforme especificação
  - **Dependências**: T001

- [x] **T004** - Configurar `analysis_options.yaml` com linting rigoroso ✅
  - **Tempo**: 0.5h
  - **Critério**: Linting configurado e sem warnings no código base
  - **Dependências**: T001

- [ ] **T005** - Setup de CI/CD básico (GitHub Actions)
  - **Tempo**: 3h
  - **Critério**: Pipeline executando build e testes automaticamente
  - **Dependências**: T002

### Configuração de Desenvolvimento

- [ ] **T006** - Configurar Flutter Inspector e DevTools
  - **Tempo**: 1h
  - **Critério**: Ferramentas de debug funcionando
  - **Dependências**: T001

- [ ] **T007** - Configurar ambientes (dev, staging, prod)
  - **Tempo**: 2h
  - **Critério**: Diferentes configurações por ambiente
  - **Dependências**: T003

- [ ] **T008** - Setup de flavors para diferentes builds
  - **Tempo**: 3h
  - **Critério**: Builds separados para cada ambiente
  - **Dependências**: T007

- [ ] **T009** - Configurar assets e recursos (ícones, fontes)
  - **Tempo**: 2h
  - **Critério**: Assets carregados corretamente
  - **Dependências**: T003

- [ ] **T010** - Configurar splash screen personalizado
  - **Tempo**: 2h
  - **Critério**: Splash screen exibido no startup
  - **Dependências**: T009

### Configuração de Dependências

- [ ] **T011** - Configurar Dependency Injection (GetIt)
  - **Tempo**: 2h
  - **Critério**: DI funcionando com módulos organizados
  - **Dependências**: T003

- [ ] **T012** - Configurar BLoC/Cubit para gerenciamento de estado
  - **Tempo**: 2h
  - **Critério**: Estados sendo gerenciados corretamente
  - **Dependências**: T011

- [ ] **T013** - Configurar roteamento com AutoRoute
  - **Tempo**: 3h
  - **Critério**: Navegação funcionando entre telas
  - **Dependências**: T012

- [ ] **T014** - Configurar SharedPreferences para storage local
  - **Tempo**: 1h
  - **Critério**: Dados persistindo localmente
  - **Dependências**: T011

- [ ] **T015** - Configurar Hive para cache offline
  - **Tempo**: 2h
  - **Critério**: Cache offline operacional
  - **Dependências**: T014

### Configuração de Segurança e Performance

- [ ] **T016** - Implementar logger customizado
  - **Tempo**: 2h
  - **Critério**: Logs estruturados e filtráveis
  - **Dependências**: T003

- [ ] **T017** - Configurar tratamento global de erros
  - **Tempo**: 3h
  - **Critério**: Erros capturados e reportados adequadamente
  - **Dependências**: T016

- [ ] **T018** - Configurar networking com Dio e interceptors
  - **Tempo**: 3h
  - **Critério**: Requisições HTTP com retry e cache
  - **Dependências**: T017

- [ ] **T019** - Implementar sistema de permissões
  - **Tempo**: 2h
  - **Critério**: Permissões solicitadas conforme necessário
  - **Dependências**: T003

- [ ] **T020** - Configurar build em modo release otimizado
  - **Tempo**: 2h
  - **Critério**: Build release funcionando sem debug info
  - **Dependências**: T005

---

## 🎨 SISTEMA DE TEMAS (15 tarefas)

### Estrutura Base do Tema

- [x] **T021** - Criar classe `ACTheme` com todas as propriedades ✅
  - **Tempo**: 4h
  - **Critério**: Modelo de tema completo e extensível
  - **Dependências**: T003

- [ ] **T022** - Implementar `ACStateColors` para cores de estado
  - **Tempo**: 2h
  - **Critério**: Cores consistentes para success/warning/error/info
  - **Dependências**: T021

- [ ] **T023** - Criar `ACTextColors` para hierarquia de texto
  - **Tempo**: 1h
  - **Critério**: Cores de texto bem definidas (primary/secondary/tertiary)
  - **Dependências**: T021

- [ ] **T024** - Implementar `ACNeumorphicShadows` para sombras
  - **Tempo**: 3h
  - **Critério**: Sombras neumórficas realistas e configuráveis
  - **Dependências**: T021

- [ ] **T025** - Criar sistema `ACSpacing` com espaçamentos consistentes
  - **Tempo**: 1h
  - **Critério**: Espaçamentos padronizados (xs, sm, md, lg, xl)
  - **Dependências**: T021

### Gerenciamento de Temas

- [x] **T026** - Implementar `ThemeProvider` com ChangeNotifier ✅
  - **Tempo**: 3h
  - **Critério**: Mudanças de tema propagadas para toda a árvore de widgets
  - **Dependências**: T021

- [ ] **T027** - Implementar cache de temas em memory e disk
  - **Tempo**: 2h
  - **Critério**: Temas carregados rapidamente e persistidos
  - **Dependências**: T026, T015

- [ ] **T028** - Criar hot reload de temas via MQTT
  - **Tempo**: 4h
  - **Critério**: Temas atualizados em tempo real via servidor
  - **Dependências**: T026, T018

- [ ] **T029** - Implementar validação de temas
  - **Tempo**: 2h
  - **Critério**: Temas inválidos rejeitados com fallback
  - **Dependências**: T026

- [ ] **T030** - Criar fallback para tema padrão
  - **Tempo**: 1h
  - **Critério**: App funciona mesmo sem tema customizado
  - **Dependências**: T026

### Extensions e Helpers

- [x] **T031** - Criar extensions no `BuildContext` para acesso ao tema ✅
  - **Tempo**: 2h
  - **Critério**: `context.acTheme` funcionando em toda a árvore
  - **Dependências**: T026

- [ ] **T032** - Implementar helpers para cálculo de cores dinâmicas
  - **Tempo**: 3h
  - **Critério**: Cores calculadas automaticamente (lighten/darken)
  - **Dependências**: T031

- [ ] **T033** - Criar helpers responsivos integrados ao tema
  - **Tempo**: 2h
  - **Critério**: `context.isMobile`, `context.isTablet` funcionando
  - **Dependências**: T031

- [ ] **T034** - Implementar sistema de breakpoints responsivos
  - **Tempo**: 2h
  - **Critério**: Breakpoints consistentes em toda a aplicação
  - **Dependências**: T033

- [ ] **T035** - Criar temas predefinidos (Dark, Light, Tesla, Custom)
  - **Tempo**: 4h
  - **Critério**: 4+ temas funcionais e visualmente distintos
  - **Dependências**: T021

---

## 🧩 COMPONENTES BASE (30 tarefas)

### Componentes Básicos

- [x] **T036** - Implementar `ACButton` com todos os tipos e variantes ✅
  - **Tempo**: 6h
  - **Critério**: Botão universal com 5+ variantes (elevated, filled, outlined, text, icon)
  - **Dependências**: T031

- [ ] **T037** - Implementar estados do `ACButton` (normal, pressed, loading, disabled)
  - **Tempo**: 3h
  - **Critério**: Estados visuais distintos e animações fluidas
  - **Dependências**: T036

- [ ] **T038** - Adicionar feedback haptic ao `ACButton`
  - **Tempo**: 2h
  - **Critério**: Vibração leve no toque (configurável)
  - **Dependências**: T037

- [ ] **T039** - Implementar confirmação opcional no `ACButton`
  - **Tempo**: 3h
  - **Critério**: Dialog de confirmação para ações críticas
  - **Dependências**: T037

- [x] **T040** - Criar `ACContainer` com suporte completo a temas ✅
  - **Tempo**: 4h
  - **Critério**: Container tematizado com sombras neumórficas
  - **Dependências**: T024, T031

### Componentes de Controle

- [x] **T041** - Implementar `ACSwitch` com animações fluidas ✅
  - **Tempo**: 4h
  - **Critério**: Switch com animação tipo iOS e feedback haptic
  - **Dependências**: T031

- [ ] **T042** - Criar `ACSlider` customizado e tematizável
  - **Tempo**: 5h
  - **Critério**: Slider com thumb neumórfico e indicador de valor
  - **Dependências**: T031

- [ ] **T043** - Implementar `ACCheckbox` com estados customizados
  - **Tempo**: 3h
  - **Critério**: Checkbox com animação de check e estados intermediários
  - **Dependências**: T031

- [ ] **T044** - Criar `ACRadioButton` com grupo de seleção
  - **Tempo**: 3h
  - **Critério**: Radio buttons agrupados com seleção única
  - **Dependências**: T031

- [ ] **T045** - Implementar `ACDropdown` com busca e filtros
  - **Tempo**: 6h
  - **Critério**: Dropdown com busca interna e múltipla seleção
  - **Dependências**: T031

### Componentes de Indicação

- [ ] **T046** - Criar `ACGauge` com múltiplos tipos (circular, linear, battery) 🚧 Em Progresso
  - **Tempo**: 8h
  - **Critério**: 3+ tipos de gauge com animações e zonas coloridas
  - **Dependências**: T031

- [ ] **T047** - Implementar `ACStatusIndicator` com pulsação
  - **Tempo**: 3h
  - **Critério**: Indicadores de status com animação de pulsação
  - **Dependências**: T031

- [ ] **T048** - Criar `ACProgressBar` linear e circular
  - **Tempo**: 4h
  - **Critério**: Progress bars com animações e texto de progresso
  - **Dependências**: T031

- [ ] **T049** - Implementar `ACBadge` para notificações
  - **Tempo**: 2h
  - **Critério**: Badges com contadores e cores de estado
  - **Dependências**: T031

- [ ] **T050** - Criar `ACAvatar` com fallback para iniciais
  - **Tempo**: 3h
  - **Critério**: Avatar com imagem, iniciais e indicador online
  - **Dependências**: T031

### Componentes de Layout

- [ ] **T051** - Implementar `ACCard` neumórfico responsivo
  - **Tempo**: 4h
  - **Critério**: Card com sombras, bordas e padding consistentes
  - **Dependências**: T040

- [x] **T052** - Criar `ACGrid` adaptativo e responsivo ✅
  - **Tempo**: 6h
  - **Critério**: Grid que se adapta automaticamente ao tamanho da tela
  - **Dependências**: T033

- [ ] **T053** - Implementar `ACList` com lazy loading
  - **Tempo**: 5h
  - **Critério**: Lista com carregamento sob demanda e pull-to-refresh
  - **Dependências**: T031

- [ ] **T054** - Criar `ACTabBar` customizável
  - **Tempo**: 4h
  - **Critério**: Tab bar com indicador animado e scroll horizontal
  - **Dependências**: T031

- [ ] **T055** - Implementar `ACExpansionTile` animado
  - **Tempo**: 3h
  - **Critério**: Tiles expansíveis com animação suave
  - **Dependências**: T031

### Componentes de Input

- [ ] **T056** - Criar `ACTextField` com validação integrada
  - **Tempo**: 5h
  - **Critério**: Input field com validação, máscaras e formatação
  - **Dependências**: T031

- [ ] **T057** - Implementar `ACTextArea` redimensionável
  - **Tempo**: 3h
  - **Critério**: Área de texto com auto-resize e contador de caracteres
  - **Dependências**: T056

- [ ] **T058** - Criar `ACNumberInput` com incremento/decremento
  - **Tempo**: 3h
  - **Critério**: Input numérico com botões +/- e validação
  - **Dependências**: T056

- [ ] **T059** - Implementar `ACDatePicker` customizado
  - **Tempo**: 4h
  - **Critério**: Date picker com tema consistente
  - **Dependências**: T031

- [ ] **T060** - Criar `ACTimePicker` para horários
  - **Tempo**: 3h
  - **Critério**: Time picker com formato 24h/12h
  - **Dependências**: T031

### Componentes de Feedback

- [ ] **T061** - Implementar `ACDialog` com tipos predefinidos
  - **Tempo**: 4h
  - **Critério**: Dialogs para confirm, alert, info com animações
  - **Dependências**: T040

- [ ] **T062** - Criar `ACSnackBar` com diferentes níveis
  - **Tempo**: 3h
  - **Critério**: Snack bars para success, warning, error, info
  - **Dependências**: T031

- [ ] **T063** - Implementar `ACTooltip` informativo
  - **Tempo**: 2h
  - **Critério**: Tooltips com posicionamento inteligente
  - **Dependências**: T031

- [ ] **T064** - Criar `ACLoadingIndicator` com animações
  - **Tempo**: 3h
  - **Critério**: Indicadores de loading personalizados
  - **Dependências**: T031

- [ ] **T065** - Implementar `ACEmptyState` para listas vazias
  - **Tempo**: 2h
  - **Critério**: Estado vazio com ilustração e CTA
  - **Dependências**: T031

---

## 📱 SISTEMA DE TELAS DINÂMICAS (25 tarefas)

### Navegação e Configuração Dinâmica

- [ ] **T066** - Implementar `ConfigService` para carregar JSON
  - **Tempo**: 4h
  - **Critério**: Serviço carrega configuração de assets, URL ou MQTT
  - **Dependências**: T052, T013

- [ ] **T067** - Criar `DynamicNavigator` para navegação entre telas
  - **Tempo**: 3h
  - **Critério**: Navegação baseada em configuração, sem rotas hardcoded
  - **Dependências**: T047, T066

- [ ] **T068** - Implementar `DynamicScreen` para renderizar telas
  - **Tempo**: 4h
  - **Critério**: Widget que constrói tela completa a partir de ScreenConfig
  - **Dependências**: T036, T066

- [ ] **T069** - Criar `DynamicWidgetBuilder` para construir widgets
  - **Tempo**: 5h
  - **Critério**: Builder que cria widgets baseado em WidgetConfig JSON
  - **Dependências**: T046, T066

- [ ] **T070** - Implementar `WidgetFactory` com todos os tipos
  - **Tempo**: 3h
  - **Critério**: Factory cria button, switch, gauge, container, text, etc
  - **Dependências**: T053, T066

### Sistema de Configuração JSON

- [ ] **T071** - Criar sistema de telas dinâmicas via JSON 🚀 Em Progresso
  - **Tempo**: 3h
  - **Critério**: Telas completamente configuráveis via JSON
  - **Dependências**: T052

- [ ] **T072** - Implementar modelo `AppConfig` completo
  - **Tempo**: 5h
  - **Critério**: Modelo Freezed para toda configuração do app
  - **Dependências**: T041, T042

- [ ] **T073** - Criar modelo `ScreenConfig` para telas
  - **Tempo**: 4h
  - **Critério**: Modelo para configuração de tela com layout e widgets
  - **Dependências**: T072

- [ ] **T074** - Criar modelo `WidgetConfig` para widgets
  - **Tempo**: 2h
  - **Critério**: Modelo para configuração de widget com propriedades e ações
  - **Dependências**: T047, T072

- [ ] **T075** - Implementar `ActionConfig` para ações
  - **Tempo**: 2h
  - **Critério**: Modelo para ações como navigate, mqtt_publish, macro
  - **Dependências**: T061, T072

### Navegação Dinâmica

- [ ] **T076** - Implementar navegação baseada em JSON
  - **Tempo**: 4h
  - **Critério**: Sistema navega entre telas definidas em JSON
  - **Dependências**: T013

- [ ] **T077** - Criar tela inicial com botões de navegação
  - **Tempo**: 4h
  - **Critério**: Home screen com navegação para outras telas
  - **Dependências**: T046, T047

- [ ] **T078** - Implementar hot reload de configuração
  - **Tempo**: 3h
  - **Critério**: Telas atualizam quando recebem nova config via MQTT
  - **Dependências**: T036, T038

- [ ] **T079** - Criar cache de configuração offline
  - **Tempo**: 3h
  - **Critério**: Configuração persiste entre sessões
  - **Dependências**: T042

- [ ] **T080** - Implementar validação de configuração
  - **Tempo**: 2h
  - **Critério**: Valida schema JSON e rejeita configs inválidas
  - **Dependências**: T036, T039

### Renderização Dinâmica

- [ ] **T081** - Implementar renderização de containers dinâmicos
  - **Tempo**: 3h
  - **Critério**: Containers, rows, columns criados de JSON
  - **Dependências**: T052

- [ ] **T082** - Implementar renderização de controles dinâmicos
  - **Tempo**: 4h
  - **Critério**: Buttons, switches, sliders criados de JSON
  - **Dependências**: T072

- [ ] **T083** - Implementar renderização de indicadores dinâmicos
  - **Tempo**: 3h
  - **Critério**: Gauges, status indicators criados de JSON
  - **Dependências**: T048, T082

- [ ] **T084** - Implementar sistema de ações dinâmicas
  - **Tempo**: 2h
  - **Critério**: Ações executadas baseadas em ActionConfig
  - **Dependências**: T061, T082

- [ ] **T085** - Implementar binding de estado dinâmico
  - **Tempo**: 3h
  - **Critério**: Widgets se atualizam com estado via stateKey
  - **Dependências**: T053, T082

### Macros e Automações

- [ ] **T086** - Criar interface para `MacrosPage`
  - **Tempo**: 4h
  - **Critério**: Lista de macros disponíveis e editor
  - **Dependências**: T053

- [ ] **T087** - Implementar visualização de macros existentes
  - **Tempo**: 3h
  - **Critério**: Lista com nome, descrição e status das macros
  - **Dependências**: T086

- [ ] **T088** - Criar editor visual de macros
  - **Tempo**: 8h
  - **Critério**: Interface drag-and-drop para criar macros
  - **Dependências**: T086

- [ ] **T089** - Implementar execução de macros
  - **Tempo**: 4h
  - **Critério**: Botões para executar macros com feedback visual
  - **Dependências**: T036, T064

- [ ] **T090** - Adicionar agendamento de macros
  - **Tempo**: 5h
  - **Critério**: Interface para agendar execução de macros
  - **Dependências**: T059, T060, T088

---

## 🔗 INTEGRAÇÃO BACKEND (20 tarefas)

### Comunicação MQTT

- [x] **T091** - Implementar `MqttService` básico ✅
  - **Tempo**: 4h
  - **Critério**: Conexão, desconexão, subscribe e publish funcionando
  - **Dependências**: T018

- [ ] **T092** - Criar sistema de tópicos estruturado
  - **Tempo**: 2h
  - **Critério**: Tópicos organizados por funcionalidade
  - **Dependências**: T091

- [ ] **T093** - Implementar reconnection automática
  - **Tempo**: 3h
  - **Critério**: Reconexão automática em caso de perda de conexão
  - **Dependências**: T091

- [ ] **T094** - Criar message handlers para diferentes tipos de dados
  - **Tempo**: 4h
  - **Critério**: Handlers específicos para temas, dispositivos, comandos
  - **Dependências**: T092

- [ ] **T095** - Implementar QoS e retenção de mensagens
  - **Tempo**: 2h
  - **Critério**: Mensagens críticas com QoS adequado
  - **Dependências**: T091

### Sincronização de Estado

- [ ] **T096** - Criar `DeviceBloc` para gerenciar estado dos dispositivos
  - **Tempo**: 4h
  - **Critério**: Estado global dos dispositivos sincronizado
  - **Dependências**: T012, T094

- [ ] **T097** - Implementar `ConnectionBloc` para status de conexão
  - **Tempo**: 3h
  - **Critério**: Status de conexão propagado para toda a app
  - **Dependências**: T012, T093

- [ ] **T098** - Criar `ConfigBloc` para configuração dinâmica 🔄 Pendente
  - **Tempo**: 4h
  - **Critério**: Configuração da interface atualizada via MQTT
  - **Dependências**: T012, T094

- [ ] **T099** - Implementar sincronização bidirecional
  - **Tempo**: 5h
  - **Critério**: Mudanças locais enviadas para servidor e vice-versa
  - **Dependências**: T096, T097

- [ ] **T100** - Criar queue de comandos para modo offline
  - **Tempo**: 4h
  - **Critério**: Comandos enfileirados e enviados quando conectar
  - **Dependências**: T015, T099

### Models e Repositories

- [ ] **T101** - Implementar models Dart para todas as entidades
  - **Tempo**: 6h
  - **Critério**: Models para Device, Relay, Screen, Theme, etc.
  - **Dependências**: T003

- [ ] **T102** - Criar repositories para acesso a dados
  - **Tempo**: 5h
  - **Critério**: Repositories com cache e fallback offline
  - **Dependências**: T101, T015

- [ ] **T103** - Implementar serialização JSON automática
  - **Tempo**: 3h
  - **Critério**: Conversão automática JSON ↔ Dart objects
  - **Dependências**: T101

- [ ] **T104** - Criar DTOs para comunicação com API
  - **Tempo**: 4h
  - **Critério**: Objects específicos para requests/responses
  - **Dependências**: T103

- [ ] **T105** - Implementar validação de dados recebidos
  - **Tempo**: 3h
  - **Critério**: Dados inválidos rejeitados com logging
  - **Dependências**: T104

### Cache e Persistência

- [ ] **T106** - Implementar cache de estados dos dispositivos
  - **Tempo**: 4h
  - **Critério**: Estados persistem entre sessões da app
  - **Dependências**: T102, T015

- [ ] **T107** - Criar sistema de cache com TTL
  - **Tempo**: 3h
  - **Critério**: Dados expiram após tempo configurável
  - **Dependências**: T106

- [ ] **T108** - Implementar sincronização incremental
  - **Tempo**: 5h
  - **Critério**: Apenas dados modificados são sincronizados
  - **Dependências**: T107

- [ ] **T109** - Criar backup/restore de configuração
  - **Tempo**: 3h
  - **Critério**: Configuração pode ser salva e restaurada
  - **Dependências**: T014, T098

- [ ] **T110** - Implementar limpeza automática de cache
  - **Tempo**: 2h
  - **Critério**: Cache antigo removido automaticamente
  - **Dependências**: T107

---

## 🧪 TESTES (15 tarefas)

### Testes Unitários

- [ ] **T111** - Testes para models e serialização
  - **Tempo**: 4h
  - **Critério**: 100% coverage nos models
  - **Dependências**: T101

- [ ] **T112** - Testes para sistema de temas
  - **Tempo**: 3h
  - **Critério**: Validação de temas e fallbacks
  - **Dependências**: T026

- [ ] **T113** - Testes para componentes base
  - **Tempo**: 6h
  - **Critério**: Testes de renderização e interação
  - **Dependências**: T036, T040

- [ ] **T114** - Testes para BLoCs e estado
  - **Tempo**: 5h
  - **Critério**: Testes de fluxo de dados e estados
  - **Dependências**: T096, T097

- [ ] **T115** - Testes para services (MQTT, Storage)
  - **Tempo**: 4h
  - **Critério**: Mocks e testes de integração
  - **Dependências**: T091, T102

### Testes de Widget

- [ ] **T116** - Testes de renderização de componentes
  - **Tempo**: 4h
  - **Critério**: Componentes renderizam corretamente
  - **Dependências**: T113

- [ ] **T117** - Testes de interação (tap, swipe, etc.)
  - **Tempo**: 3h
  - **Critério**: Interações funcionam como esperado
  - **Dependências**: T116

- [ ] **T118** - Testes de responsividade
  - **Tempo**: 4h
  - **Critério**: Layouts se adaptam a diferentes tamanhos
  - **Dependências**: T116

- [ ] **T119** - Testes de temas em componentes
  - **Tempo**: 3h
  - **Critério**: Componentes aplicam tema corretamente
  - **Dependências**: T116, T112

- [ ] **T120** - Testes de acessibilidade
  - **Tempo**: 3h
  - **Critério**: Semântica e navegação por teclado
  - **Dependências**: T116

### Testes de Integração

- [ ] **T121** - Testes E2E das jornadas principais
  - **Tempo**: 6h
  - **Critério**: Fluxos completos funcionando
  - **Dependências**: T089, T099

- [ ] **T122** - Testes de comunicação MQTT
  - **Tempo**: 4h
  - **Critério**: Mensagens enviadas e recebidas corretamente
  - **Dependências**: T094, T121

- [ ] **T123** - Testes de modo offline
  - **Tempo**: 4h
  - **Critério**: App funciona sem conexão
  - **Dependências**: T100, T121

- [ ] **T124** - Testes de performance e memória
  - **Tempo**: 3h
  - **Critério**: App mantém performance aceitável
  - **Dependências**: T121

- [ ] **T125** - Testes de diferentes dispositivos e orientações
  - **Tempo**: 4h
  - **Critério**: App funciona em mobile, tablet, landscape/portrait
  - **Dependências**: T118, T121

---

## 📊 RESUMO POR CATEGORIA

### Distribuição de Tarefas
- **Setup & Configuração**: 20 tarefas (16%)
- **Sistema de Temas**: 15 tarefas (12%)
- **Componentes Base**: 30 tarefas (24%)
- **Telas Principais**: 25 tarefas (20%)
- **Integração Backend**: 20 tarefas (16%)
- **Testes**: 15 tarefas (12%)

### Distribuição de Tempo
- **Setup & Configuração**: 38 horas (13%)
- **Sistema de Temas**: 36 horas (12%)
- **Componentes Base**: 105 horas (35%)
- **Telas Principais**: 91 horas (31%)
- **Integração Backend**: 75 horas (25%)
- **Testes**: 60 horas (20%)

**Total**: 405 horas (≈ 51 dias úteis de 8h)

### Prioridades Críticas (Path Crítico)

1. **Setup básico do projeto** (T001-T005)
2. **Sistema de temas** (T021-T031)
3. **Componentes base** (T036, T040, T041)
4. **Comunicação MQTT** (T091-T095)
5. **Telas principais** (T066-T075)
6. **Integração completa** (T096-T105)

### Dependencies Management

**Sem Dependências**: T001, T002, T004
**Dependências Críticas**: T031 (base para todos os componentes)
**Gargalos Potenciais**: T036 (ACButton), T052 (ACGrid), T091 (MqttService)

### Critérios de Aceite Globais

- ✅ **Performance**: 60fps consistente, startup < 2s
- ✅ **Qualidade**: Coverage > 80%, 0 bugs críticos
- ✅ **UX**: Animações fluidas, feedback haptic
- ✅ **Compatibilidade**: Android 6+, iOS 12+
- ✅ **Offline**: Funcionalidade completa sem internet
- ✅ **Responsivo**: Mobile, tablet, landscape/portrait
- ✅ **Acessível**: Semântica, navegação, contraste
- ✅ **Tematizável**: 100% dos componentes customizáveis

---

## 🎯 PRÓXIMOS PASSOS

### Semana 1
Focar em T001-T020 (Setup completo)

### Semana 2  
Implementar T021-T035 (Sistema de temas)

### Semanas 3-4
Desenvolver T036-T065 (Componentes base)

### Semanas 5-6
Construir T066-T090 (Telas principais)

### Semanas 7-8
Integrar T091-T110 (Backend e MQTT)

### Semanas 9-10
Finalizar T111-T125 (Testes e polimento)

Este TODO garante um desenvolvimento estruturado, com entregas incrementais e qualidade mantida ao longo de todo o projeto.