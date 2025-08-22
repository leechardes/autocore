# 📚 Documentação de Ajuda - AutoCore

## Estrutura da Documentação

Esta pasta contém toda a documentação de ajuda para o usuário final do sistema AutoCore.

### Organização dos Arquivos

```
help/
├── README.md                 # Este arquivo
├── index.md                  # Página inicial de ajuda
├── dashboard/                # Ajuda do Dashboard
│   └── index.md
├── mqtt-monitor/            # Ajuda do Monitor MQTT
│   └── index.md
├── macros/                  # Ajuda do Sistema de Macros
│   └── index.md
├── relay-simulator/         # Ajuda do Simulador de Relés
│   └── index.md
├── devices/                 # Ajuda de Dispositivos
│   └── index.md
├── can-bus/                 # Ajuda do Sistema CAN Bus
│   └── index.md
├── screens/                 # Ajuda do Editor de Telas
│   └── index.md
├── themes/                  # Ajuda de Temas
│   └── index.md
└── troubleshooting/        # Solução de Problemas
    └── index.md
```

### Convenções de Escrita

1. **Linguagem**: Português brasileiro, clara e objetiva
2. **Tom**: Profissional mas amigável
3. **Público-alvo**: Usuário final sem conhecimento técnico
4. **Estrutura**:
   - Título claro
   - Visão geral breve
   - Passo a passo quando aplicável
   - Dicas úteis
   - Perguntas frequentes
   - Solução de problemas
5. **Formatação**:
   - **NÃO usar emojis/ícones** (🎛️, 📡, etc.)
   - Usar **negrito** para destaques
   - Usar _itálico_ para termos técnicos
   - Usar listas com marcadores simples (-, *)
   - Usar numeração para passos sequenciais

### Como Adicionar Nova Documentação

1. Crie uma pasta para o novo módulo
2. Adicione um arquivo `index.md` dentro da pasta
3. Siga o template padrão de documentação
4. Atualize o componente HelpButton para incluir a nova rota

### Template de Documentação

```markdown
# Título da Funcionalidade

## O que é?
Breve descrição da funcionalidade.

## Para que serve?
Explicação dos benefícios e casos de uso.

## Como usar?

### Passo 1: [Ação]
Descrição detalhada do passo.

### Passo 2: [Ação]
Descrição detalhada do passo.

## Dicas Úteis
- Dica 1
- Dica 2

## Perguntas Frequentes

**P: Pergunta comum?**
R: Resposta clara e completa.

## Solução de Problemas

### Problema: [Descrição]
**Solução**: Como resolver.
```

---

**Última Atualização:** 08 de Agosto de 2025
**Versão:** 1.0.0