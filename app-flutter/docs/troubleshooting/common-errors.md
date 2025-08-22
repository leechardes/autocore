# 📋 AutoCore Flutter - Lista de Tarefas (Execution-Only)

Este documento contém TODAS as tarefas necessárias para o desenvolvimento do app Flutter do AutoCore com **escopo de execução apenas**. O app carrega configurações do backend e permite apenas visualizar e executar - sem funcionalidades de configuração ou edição.

## ⚠️ ESCOPO EXECUTION-ONLY

**IMPORTANTE**: Este app é apenas uma interface de execução. Toda configuração (dispositivos, telas, macros, relés) é feita através do **AutoCore Config-App** web. O app Flutter:

- ✅ **CARREGA** configurações do backend
- ✅ **EXIBE** telas dinâmicas baseadas nas configurações
- ✅ **EXECUTA** macros via HTTP POST
- ✅ **EXECUTA** comandos de botões via HTTP
- ✅ **RECEBE** estados via MQTT (read-only)
- ❌ **NÃO** cria ou edita configurações
- ❌ **NÃO** tem editores visuais
- ❌ **NÃO** faz CRUD de dispositivos/macros/telas

## 📊 Resumo Executivo

- **Total de Tarefas**: 80 (reduzido de 125 - escopo focado + heartbeat)
- **Tarefas Completadas**: 25 (31%)
- **Novas Tarefas Críticas**: 6 (sistema de heartbeat)
- **Tempo Estimado Total**: 40 dias úteis (8 semanas)
- **Complexidade**: Alta (devido ao sistema de heartbeat crítico)
- **Dependências Críticas**: Sistema de Heartbeat, MQTT para estados, Backend API

### 🚀 Status Atual (09/01/2025)
- **Sistema de Temas**: ✅ 100% completo
- **Componentes Base**: 60% completo (focado em execução)
- **MQTT Service**: ✅ Implementado e funcional
- **Sistema Dinâmico**: ✅ 85% completo (carregamento e exibição)
- **Execução HTTP**: ✅ MacroService implementado
- **Próxima Sprint**: UI de execução de macros e estados

---

## 🏗️ SETUP & CONFIGURAÇÃO (15 tarefas)

### Configuração Inicial do Projeto

- [x] **T001** - Criar projeto Flutter `autocore_app` ✅
- [x] **T002** - Configurar `pubspec.yaml` com dependências de execução ✅
- [x] **T003** - Configurar estrutura Clean Architecture ✅  
- [x] **T004** - Configurar linting rigoroso ✅
- [ ] **T005** - Setup de CI/CD básico
- [ ] **T006** - Configurar ambientes (dev, staging, prod)

### Configuração de Dependências

- [x] **T011** - Configurar Dependency Injection (Provider) ✅
- [x] **T012** - Configurar Provider para estado ✅
- [x] **T013** - Configurar roteamento dinâmico ✅
- [x] **T014** - Configurar SharedPreferences ✅
- [x] **T015** - Configurar Hive para cache ✅

### Configuração de Performance

- [x] **T016** - Implementar logger customizado ✅
- [ ] **T017** - Configurar tratamento global de erros
- [x] **T018** - Configurar networking com Dio ✅
- [ ] **T019** - Configurar build release otimizado

---

## 🎨 SISTEMA DE TEMAS (10 tarefas) - ✅ COMPLETO

### Estrutura Base do Tema

- [x] **T021** - Criar classe `ACTheme` completa ✅
- [x] **T022** - Implementar `ACStateColors` ✅
- [x] **T023** - Criar `ACTextColors` ✅
- [x] **T024** - Implementar sombras neumórficas ✅
- [x] **T025** - Sistema `ACSpacing` ✅

### Gerenciamento de Temas

- [x] **T026** - Implementar `ThemeProvider` ✅
- [x] **T027** - Cache de temas ✅
- [x] **T030** - Fallback para tema padrão ✅
- [x] **T031** - Extensions no `BuildContext` ✅
- [x] **T035** - Temas predefinidos ✅

---

## 🧩 COMPONENTES DE EXECUÇÃO (20 tarefas)

### Componentes Básicos de Exibição

- [x] **T036** - Implementar `ACButton` universal ✅
- [ ] **T037** - Estados do `ACButton` (pressed, loading, disabled)
- [ ] **T038** - Feedback haptic no `ACButton`
- [x] **T040** - Criar `ACContainer` tematizado ✅
- [x] **T041** - Implementar `ACSwitch` ✅

### Componentes de Status e Indicação

- [x] **T046** - Criar `ACGauge` (circular, linear, battery) ✅
- [x] **T047** - Implementar `ACStatusIndicator` ✅
- [x] **T048** - Criar `ACProgressBar` ✅
- [ ] **T049** - Implementar `ACBadge` para notificações
- [ ] **T050** - Criar `ACAvatar` com fallback

### Componentes de Layout para Execução

- [ ] **T051** - Implementar `ACCard` neumórfico
- [x] **T052** - Criar `ACGrid` adaptativo ✅
- [ ] **T053** - Implementar `ACList` com lazy loading
- [ ] **T054** - Criar `ACTabBar` customizável

### Componentes de Feedback

- [ ] **T061** - Implementar `ACDialog` (confirm, alert, info)
- [ ] **T062** - Criar `ACSnackBar` (success, warning, error)  
- [ ] **T063** - Implementar `ACTooltip`
- [ ] **T064** - Criar `ACLoadingIndicator`
- [ ] **T065** - Implementar `ACEmptyState` para listas vazias

---

## 📱 SISTEMA DE INTERFACE DINÂMICA (15 tarefas)

### Carregamento de Configuração

- [x] **T066** - Implementar `ConfigService` ✅
- [x] **T067** - Criar navegação dinâmica ✅
- [x] **T068** - Implementar `DynamicScreen` ✅
- [x] **T069** - Criar `DynamicWidgetBuilder` ✅
- [x] **T070** - Implementar `WidgetFactory` ✅

### Sistema de Telas de Execução

- [x] **T071** - Sistema de telas dinâmicas ✅
- [x] **T072** - Modelo `AppConfig` completo ✅
- [x] **T073** - Modelo `ScreenConfig` ✅
- [x] **T074** - Modelo `WidgetConfig` ✅
- [x] **T075** - Implementar `ActionConfig` ✅

### Cache e Persistência

- [x] **T079** - Cache de configuração offline ✅
- [x] **T080** - Validação de configuração ✅
- [x] **T081** - Renderização de containers ✅
- [x] **T082** - Renderização de controles ✅
- [ ] **T083** - Renderização de indicadores dinâmicos

---

## 🚀 EXECUÇÃO E COMUNICAÇÃO (20 tarefas)

### Sistema de Heartbeat (CRÍTICO - SEGURANÇA)

- [ ] **T200** - Implementar `HeartbeatService` central
- [ ] **T201** - Criar `MomentaryButton` widget com heartbeat
- [ ] **T202** - Implementar timer de 500ms para heartbeat
- [ ] **T203** - Implementar timeout de 1s para detecção de falha
- [ ] **T204** - Criar feedback visual para botões momentâneos ativos
- [ ] **T205** - Implementar auto-release ao perder foco/minimizar

### Execução de Macros

- [x] **T087** - Implementar `MacroService` básico ✅
- [ ] **T088** - Criar UI para lista de macros
- [ ] **T089** - Implementar execução com feedback visual
- [ ] **T090** - Histórico de execuções

### Execução de Botões/Comandos

- [ ] **T120** - Implementar `ButtonService` para comandos
- [ ] **T121** - UI para exibição de screens dinâmicas
- [ ] **T122** - Execução de comandos com confirmação
- [ ] **T123** - Queue de comandos offline
- [ ] **T124** - Integrar heartbeat em botões momentâneos

### Comunicação MQTT (Estados)

- [x] **T091** - Implementar `MqttService` ✅
- [x] **T092** - Sistema de tópicos ✅
- [ ] **T093** - Auto-reconexão MQTT
- [ ] **T094** - Handlers para diferentes tipos de estado
- [ ] **T095** - QoS e retenção de mensagens

### Sincronização de Estado

- [ ] **T096** - Criar `DeviceBloc` para estados
- [ ] **T097** - Implementar `ConnectionBloc`
- [ ] **T098** - Estado de macros e execuções

---

## 🧪 TESTES (10 tarefas)

### Testes Unitários

- [ ] **T111** - Testes para models de execução
- [ ] **T112** - Testes para sistema de temas
- [ ] **T113** - Testes para componentes de execução
- [ ] **T114** - Testes para MacroService e ButtonService

### Testes de Widget

- [ ] **T116** - Testes de renderização
- [ ] **T117** - Testes de interação (tap, execução)
- [ ] **T118** - Testes de responsividade
- [ ] **T119** - Testes de temas

### Testes de Integração

- [ ] **T121** - Testes E2E de execução de macros
- [ ] **T122** - Testes de comunicação HTTP/MQTT

---

## 📊 RESUMO POR CATEGORIA

### Distribuição Atualizada (Execution-Only)
- **Setup & Configuração**: 15 tarefas (20%) - **80% concluído**
- **Sistema de Temas**: 10 tarefas (13%) - **✅ 100% concluído**
- **Componentes de Execução**: 20 tarefas (27%) - **40% concluído**  
- **Interface Dinâmica**: 15 tarefas (20%) - **90% concluído**
- **Execução & Comunicação**: 15 tarefas (20%) - **20% concluído**
- **Testes**: 10 tarefas (13%) - **0% concluído**

### Distribuição de Tempo
- **Setup**: 20 horas (15%) - ~16h gastas
- **Temas**: 15 horas (10%) - ✅ Completo
- **Componentes**: 45 horas (30%) - ~18h gastas
- **Interface**: 30 horas (20%) - ~27h gastas  
- **Execução**: 25 horas (18%) - ~5h gastas
- **Testes**: 20 horas (14%) - 0h gastas

**Total**: 155 horas (≈ 19 dias úteis) - **Redução de 60% no escopo**

### 🎯 Conquistas Mantidas

✅ **Sistema de Temas Completo**
- Modelo Freezed totalmente tipado
- Provider com cache e persistência  
- Extensions facilitadoras
- Suporte a múltiplos temas

✅ **Interface Dinâmica Funcional**
- Carregamento de configuração JSON
- Telas dinâmicas renderizando
- Navegação por configuração
- Widget builder para execução

✅ **Componentes Core para Execução**
- ACButton para ações
- ACContainer neumórfico  
- ACGauge para status
- ACProgressBar para feedback
- ACGrid responsivo

✅ **Comunicação Implementada**
- MacroService para execução HTTP
- MqttService para receber estados
- Sistema de tópicos estruturado

---

## 🚧 TRABALHO PRIORITÁRIO

### Sprint Crítica - SEGURANÇA (Semana 1)
1. **HeartbeatService** (T200) - CRÍTICO - Sistema central
2. **MomentaryButton** (T201) - CRÍTICO - Widget seguro
3. **Timer 500ms** (T202) - CRÍTICO - Frequência de heartbeat
4. **Timeout 1s** (T203) - CRÍTICO - Detecção de falha

### Sprint Atual (Semana 2)
1. **UI para Macros** (T088) - Lista executável
2. **ButtonService** (T120) - Execução de comandos
3. **Auto-reconexão MQTT** (T093)
4. **Estados via MQTT** (T094)

### Sprint Seguinte (Semana 3) 
1. **BLoCs de Estado** (T096-T098) 
2. **Queue Offline** (T123)
3. **Feedback Visual** (T061-T064)
4. **Testes Core** (T111-T113)

---

## 🎯 DEFINIÇÃO DE "PRONTO" (Execution-Only)

### MVP (Mínimo Viável)
- [ ] Interface carrega configuração do backend
- [ ] Lista de macros executável 
- [ ] Screens dinâmicas exibindo botões
- [ ] Execução via HTTP POST funcionando
- [ ] Estados recebidos via MQTT
- [ ] Cache offline básico

### Produção
- [ ] Todas as telas carregando dinamicamente
- [ ] Sistema de execução robusto
- [ ] Feedback visual completo
- [ ] Modo offline com queue
- [ ] Testes > 70% coverage
- [ ] Performance otimizada
- [ ] Zero crashes por 24h

---

## 📝 MUDANÇAS NO ESCOPO

### ❌ Removido (Não é responsabilidade do app)
- Editores visuais (macros, telas, dispositivos)
- CRUD de qualquer entidade
- Configuração de dispositivos
- Sistema de usuários/permissões complexo
- Drag & drop para criação
- Hot reload de configuração via edição

### ✅ Mantido (Foco em execução)
- Interface dinâmica (carregamento)
- Execução de macros (HTTP POST)
- Execução de comandos (HTTP POST) 
- Recepção de estados (MQTT)
- Cache offline (configurações carregadas)
- Sistema de temas
- Navegação dinâmica

### 🆕 Adicionado (Melhor UX de execução)
- Queue de comandos offline
- Histórico de execuções
- Feedback visual aprimorado
- Estados em tempo real via MQTT
- Performance otimizada

---

## 🏁 CONCLUSÃO

O **AutoCore Flutter** agora tem escopo bem definido como **interface de execução**. Isso resulta em:

- **60% menos código** para manter
- **Arquitetura mais simples** e focada
- **Performance melhor** (menos recursos)
- **Responsabilidades claras** (execução vs configuração)
- **Desenvolvimento mais rápido** (sem complexidade de CRUD)

O app será uma **interface elegante e responsiva** que permite aos usuários executar as configurações criadas no Config-App web, mantendo a experiência fluida e profissional esperada.

---

**Estado**: 🎯 **ESCOPO REDEFINIDO** - Ready for Execution Implementation  
**Última Atualização**: 09 de Janeiro de 2025  
**Maintainer**: Lee Chardes | **Versão**: 3.0.0-execution-only