# 🤖 Sistema de Agentes - AutoCore Gateway

## 📋 Catálogo de Agentes

### Agentes Disponíveis

#### A99-DOC-UPDATER
- **Arquivo**: [DOC-UPDATER.md](./DOC-UPDATER.md)
- **Tipo**: Maintenance
- **Status**: Ativo
- **Função**: Padronização e atualização de documentação
- **Frequência**: Sob demanda
- **Última Execução**: 2025-01-27

## 📁 Estrutura do Sistema

```
agents/
├── README.md              # Este arquivo
├── DOC-UPDATER.md        # Agente atualizador
├── templates/            # Templates de agentes
├── active/               # Agentes ativos (futuros)
└── executed/             # Histórico de execução
    └── [relatórios]
```

## 🔧 Como Usar

### Executar Agente
```bash
# Via Claude Code
"Execute o agente A99-DOC-UPDATER"
```

### Criar Novo Agente
1. Usar template em `templates/`
2. Seguir nomenclatura AXX-NOME.md
3. Documentar em catálogo acima
4. Adicionar em `active/` se permanente

## 📊 Relatórios

Todos os relatórios de execução são salvos em `executed/` com timestamp para rastreabilidade.

## 🎯 Próximos Agentes

- A01-MQTT-MONITOR: Monitoramento de tópicos MQTT
- A02-DEVICE-VALIDATOR: Validação de dispositivos ESP32
- A03-TELEMETRY-ANALYZER: Análise de dados de telemetria

---

**Versão**: 1.0.0  
**Última Atualização**: 2025-01-27