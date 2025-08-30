# 🤖 A05-PERFORMANCE-ANALYZER - Template para Analisador de Performance

## 📋 Objetivo

Template para criação de agentes que analisam e otimizam a performance do banco de dados.

## 🎯 Tarefas

1. Analisar queries lentas
2. Identificar gargalos de performance
3. Sugerir otimizações de índices
4. Monitorar crescimento de tabelas
5. Gerar relatórios de performance
6. Alertar sobre problemas críticos

## 🔧 Comandos

```sql
-- Análise de queries
EXPLAIN QUERY PLAN SELECT * FROM table_name WHERE condition;

-- Estatísticas de tabelas
SELECT name, COUNT(*) as rows FROM sqlite_master 
JOIN pragma_table_info(name) GROUP BY name;

-- Análise de índices
SELECT * FROM sqlite_master WHERE type='index';
```

## ✅ Checklist de Validação

- [ ] Queries analisadas
- [ ] Gargalos identificados
- [ ] Índices analisados
- [ ] Recomendações geradas
- [ ] Relatório de performance criado
- [ ] Alertas configurados
- [ ] Métricas coletadas

## 📊 Resultado Esperado

Banco de dados otimizado com performance monitorada continuamente.