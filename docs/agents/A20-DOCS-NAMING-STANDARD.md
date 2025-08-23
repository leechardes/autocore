# A20 - Padronização de Nomenclatura de Documentação

## 📋 Objetivo
Padronizar a nomenclatura de todos os arquivos .md nas pastas docs/ do projeto, convertendo para MAIÚSCULAS mantendo .md minúsculo.

## 🎯 Tarefas
1. Buscar todas as pastas docs/ recursivamente no projeto
2. Identificar arquivos .md que precisam ser renomeados
3. Aplicar transformação apropriada:
   - Arquivos normais: NOME-EM-MAIUSCULA.md
   - Arquivos de agentes: AXX-NOME-EM-MAIUSCULA.md (preservar numeração)
4. Renomear fisicamente os arquivos
5. Adicionar regra de nomenclatura aos arquivos de configuração

## 🔧 Comandos
```bash
# Buscar e renomear arquivos
find . -path "*/docs/*.md" -type f
git mv [arquivo_antigo] [arquivo_novo]
```

## ✅ Checklist de Validação
- [ ] Todos os arquivos .md em docs/ renomeados
- [ ] Arquivos de agentes mantém numeração AXX
- [ ] Regra adicionada ao README.md
- [ ] Regra adicionada ao CLAUDE.md local
- [ ] Regra adicionada ao CLAUDE.md global

## 📊 Resultado Esperado
Todos os arquivos de documentação seguindo o padrão de MAIÚSCULAS com extensão .md minúscula.