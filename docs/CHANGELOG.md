# Changelog - AutoCore

## [Unreleased] - 2025-08-08

### Adicionado
- **Sistema de Ajuda Completo**
  - Componente `HelpModal` com documentação formatada usando Tabs e Cards
  - Documentação contextual para cada página (Dashboard, Devices, Relays, Macros, etc.)
  - Botão de ajuda integrado no header ao lado do botão de refresh
  - Atalhos do sistema documentados

- **Melhorias no Sistema de Macros**
  - Campo `allow_in_macro` na tabela `relay_channels` para controle de permissões
  - Filtros de segurança impedindo uso de canais momentâneos em macros
  - Proteção especial para canais críticos (guincho/winch)
  - UI melhorada mostrando nomes dos canais junto com números
  - Seleção de canais para ações de salvar/restaurar estado

- **Scripts de Setup do Raspberry Pi**
  - `setup_raspberry_pi.sh` - Setup completo automatizado
  - `monitor_boot.sh` - Monitor de boot com notificações
  - `find_raspberry.sh` - Busca automática na rede
  - `download_64bit_desktop.sh` - Download da versão recomendada
  - Suporte para Raspberry Pi OS 64-bit Desktop (recomendado)

### Modificado
- **MacroActionEditor**
  - Agora filtra canais baseado em `allow_in_macro` e `function_type`
  - Interface de seleção de canais melhorada para save/restore state
  - Mostra nomes descritivos dos canais ao invés de apenas números

- **MacrosPage**
  - Adicionado botão de ajuda local
  - Correções de sintaxe JSX

- **App.jsx**
  - Integração do HelpModal no header principal
  - Reorganização dos botões do header (Theme, Refresh, Help)

### Segurança
- Canais do tipo "momentary" automaticamente excluídos de macros
- Canais com `allow_in_macro=false` não aparecem no editor de macros
- Script de atualização para definir permissões em canais existentes

### Correções
- Corrigido erro de sintaxe JSX no MacrosPage (Dialog não fechado)
- Corrigida migração Alembic para suportar SQLite (batch_alter_table)
- Melhorada compatibilidade de gravação de SD Card no macOS

## [0.2.0] - 2025-08-07

### Adicionado
- Sistema completo de macros e automações
- Monitor MQTT em tempo real
- Simulador de relés integrado
- Suporte para múltiplos tipos de canais (toggle, momentary, pulse)

### Modificado
- Migração para React + Vite + shadcn/ui
- Performance otimizada para Raspberry Pi Zero 2W
- Interface completamente responsiva

## [0.1.0] - 2025-08-06

### Inicial
- Estrutura base do projeto
- Database com SQLAlchemy
- API FastAPI
- Frontend inicial
- Documentação básica