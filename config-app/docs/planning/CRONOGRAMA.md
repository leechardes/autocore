# 📅 Cronograma - AutoCore Config App

## 🗓️ Timeline Geral

**Início:** 07 de Agosto de 2025 (Hoje)  
**Término:** 02 de Outubro de 2025  
**Duração:** 8 semanas  
**Horas estimadas:** 320 horas

## 📊 Gantt Chart Simplificado

```
Semana:     1   2   3   4   5   6   7   8
           Ago Ago Ago Ago Set Set Set Out
Fase 1:    ████████
Fase 2:            ████████
Fase 3:                    ████████
Fase 4:                            ████
Fase 5:                                ████
Testing:    ░░  ░░  ░░  ░░  ░░  ░░  ░░  ██
Docs:       ░░  ░░  ░░  ░░  ░░  ░░  ░░  ██
```

## 🗓️ Detalhamento Semanal

### 📅 Semana 1 (07-13 Agosto)
**Sprint 1: Setup e Infraestrutura**

| Dia | Tarefa | Horas | Status |
|-----|--------|-------|--------|
| Qua 07/08 | Setup ambiente desenvolvimento | 4h | 🔄 Hoje |
| Qua 07/08 | Configurar FastAPI + SQLite | 4h | ⏳ |
| Qui 08/08 | Criar models e schemas base | 6h | ⏳ |
| Qui 08/08 | Setup frontend (HTML + Tailwind) | 2h | ⏳ |
| Sex 09/08 | Implementar autenticação JWT | 6h | ⏳ |
| Sex 09/08 | Criar componentes Alpine.js base | 2h | ⏳ |
| Seg 12/08 | Endpoints básicos da API | 6h | ⏳ |
| Seg 12/08 | Testes unitários iniciais | 2h | ⏳ |
| Ter 13/08 | Integração frontend-backend | 4h | ⏳ |
| Ter 13/08 | Review e documentação | 4h | ⏳ |

**Entregáveis:** Base funcional rodando

---

### 📅 Semana 2 (14-20 Agosto)
**Sprint 2: API Core**

| Dia | Tarefa | Horas | Status |
|-----|--------|-------|--------|
| Qua 14/08 | CRUD dispositivos (backend) | 6h | ⏳ |
| Qua 14/08 | Validações e middleware | 2h | ⏳ |
| Qui 15/08 | Interface listagem dispositivos | 4h | ⏳ |
| Qui 15/08 | Formulários de configuração | 4h | ⏳ |
| Sex 16/08 | WebSocket para real-time | 6h | ⏳ |
| Sex 16/08 | Status cards no frontend | 2h | ⏳ |
| Seg 19/08 | Sistema de notificações | 4h | ⏳ |
| Seg 19/08 | Testes de integração | 4h | ⏳ |
| Ter 20/08 | Deploy teste no Pi Zero | 4h | ⏳ |
| Ter 20/08 | Ajustes de performance | 4h | ⏳ |

**Entregáveis:** API core completa, gestão básica de dispositivos

---

### 📅 Semana 3 (21-27 Agosto)
**Sprint 3: Gestão de Dispositivos**

| Dia | Tarefa | Horas | Status |
|-----|--------|-------|--------|
| Qua 21/08 | Discovery de dispositivos | 6h | ⏳ |
| Qua 21/08 | mDNS/Bonjour integration | 2h | ⏳ |
| Qui 22/08 | Interface device cards | 4h | ⏳ |
| Qui 22/08 | Modal de configuração | 4h | ⏳ |
| Sex 23/08 | Teste de conectividade | 4h | ⏳ |
| Sex 23/08 | Health checks automáticos | 4h | ⏳ |
| Seg 26/08 | Logs de dispositivos | 4h | ⏳ |
| Seg 26/08 | Métricas e estatísticas | 4h | ⏳ |
| Ter 27/08 | Integração MQTT | 6h | ⏳ |
| Ter 27/08 | Testes end-to-end | 2h | ⏳ |

**Entregáveis:** Sistema completo de gestão de dispositivos

---

### 📅 Semana 4 (28 Agosto - 03 Setembro)
**Sprint 4: Controle de Relés**

| Dia | Tarefa | Horas | Status |
|-----|--------|-------|--------|
| Qua 28/08 | API controle de relés | 6h | ⏳ |
| Qua 28/08 | Lógica de proteções | 2h | ⏳ |
| Qui 29/08 | Interface grid de relés | 6h | ⏳ |
| Qui 29/08 | Animações e feedback | 2h | ⏳ |
| Sex 30/08 | Configuração de canais | 4h | ⏳ |
| Sex 30/08 | Ícones e customização | 4h | ⏳ |
| Seg 02/09 | Grupos e macros simples | 6h | ⏳ |
| Seg 02/09 | Testes com ESP32 real | 2h | ⏳ |
| Ter 03/09 | Otimização de latência | 4h | ⏳ |
| Ter 03/09 | Documentação de uso | 4h | ⏳ |

**Entregáveis:** Sistema de relés funcional

---

### 📅 Semana 5 (04-10 Setembro)
**Sprint 5: Editor de Telas**

| Dia | Tarefa | Horas | Status |
|-----|--------|-------|--------|
| Qua 04/09 | Estrutura drag-and-drop | 8h | ⏳ |
| Qui 05/09 | Biblioteca de componentes | 6h | ⏳ |
| Qui 05/09 | Sistema de grid | 2h | ⏳ |
| Sex 06/09 | Preview por dispositivo | 6h | ⏳ |
| Sex 06/09 | Responsividade automática | 2h | ⏳ |
| Seg 09/09 | Configuração de ações | 6h | ⏳ |
| Seg 09/09 | Salvamento de layouts | 2h | ⏳ |
| Ter 10/09 | Templates pré-definidos | 4h | ⏳ |
| Ter 10/09 | Export/Import | 4h | ⏳ |

**Entregáveis:** Editor de telas funcional

---

### 📅 Semana 6 (11-17 Setembro)
**Sprint 6: Integração CAN Bus**

| Dia | Tarefa | Horas | Status |
|-----|--------|-------|--------|
| Qua 11/09 | Parser sinais CAN | 6h | ⏳ |
| Qua 11/09 | Biblioteca FuelTech | 2h | ⏳ |
| Qui 12/09 | Interface configuração | 4h | ⏳ |
| Qui 12/09 | Tabela de sinais | 4h | ⏳ |
| Sex 13/09 | WebSocket telemetria | 6h | ⏳ |
| Sex 13/09 | Monitor tempo real | 2h | ⏳ |
| Seg 16/09 | Gráficos com Chart.js | 6h | ⏳ |
| Seg 16/09 | Sistema de alertas | 2h | ⏳ |
| Ter 17/09 | Logs e gravação | 4h | ⏳ |
| Ter 17/09 | Testes integração | 4h | ⏳ |

**Entregáveis:** Integração CAN completa

---

### 📅 Semana 7 (18-24 Setembro)
**Sprint 7: Recursos Complementares**

| Dia | Tarefa | Horas | Status |
|-----|--------|-------|--------|
| Qua 18/09 | Sistema de macros | 6h | ⏳ |
| Qua 18/09 | Editor de automações | 2h | ⏳ |
| Qui 19/09 | Gestão de usuários | 4h | ⏳ |
| Qui 19/09 | Permissões e roles | 4h | ⏳ |
| Sex 20/09 | Sistema de temas | 4h | ⏳ |
| Sex 20/09 | Dark/Light mode | 4h | ⏳ |
| Seg 23/09 | Backup/Restore | 6h | ⏳ |
| Seg 23/09 | Import/Export config | 2h | ⏳ |
| Ter 24/09 | Dashboard métricas | 4h | ⏳ |
| Ter 24/09 | Logs e auditoria | 4h | ⏳ |

**Entregáveis:** Features complementares implementadas

---

### 📅 Semana 8 (25 Set - 02 Outubro)
**Sprint 8: Otimização e Deploy**

| Dia | Tarefa | Horas | Status |
|-----|--------|-------|--------|
| Qua 25/09 | Minificação assets | 4h | ⏳ |
| Qua 25/09 | Otimização queries | 4h | ⏳ |
| Qui 26/09 | Config PWA | 4h | ⏳ |
| Qui 26/09 | Service Worker | 4h | ⏳ |
| Sex 27/09 | Testes finais Pi Zero | 6h | ⏳ |
| Sex 27/09 | Ajustes performance | 2h | ⏳ |
| Seg 30/09 | Scripts de deploy | 4h | ⏳ |
| Seg 30/09 | Documentação final | 4h | ⏳ |
| Ter 01/10 | Release preparation | 4h | ⏳ |
| Qua 02/10 | Launch v1.0.0 | 4h | ⏳ |

**Entregáveis:** Sistema em produção

## 📊 Distribuição de Esforço

| Área | Horas | % |
|------|-------|---|
| Backend Development | 96h | 30% |
| Frontend Development | 96h | 30% |
| Integração/Testes | 64h | 20% |
| Documentação | 32h | 10% |
| Deploy/DevOps | 32h | 10% |
| **Total** | **320h** | **100%** |

## 🎯 Marcos Críticos

| Data | Marco | Critério de Sucesso |
|------|-------|---------------------|
| 13/08 | Base Funcional | API rodando, frontend conectado |
| 27/08 | Dispositivos OK | CRUD completo funcionando |
| 10/09 | Interface Rica | Editor de telas operacional |
| 24/09 | Features Complete | Todas funcionalidades implementadas |
| 02/10 | **Release v1.0.0** | Sistema em produção no Pi Zero |

## 🚦 Indicadores de Progresso

### Legenda de Status
- ⏳ **Pendente** - Ainda não iniciado
- 🔄 **Em Progresso** - Em desenvolvimento
- ✅ **Concluído** - Finalizado e testado
- 🔴 **Bloqueado** - Aguardando dependência
- ⚠️ **Atrasado** - Fora do prazo

### Métricas Semanais
- **Velocity:** 40 horas/semana
- **Burndown:** Acompanhar via TODO.md
- **Quality:** Zero bugs críticos em produção
- **Performance:** Manter < 100MB RAM

## 📝 Notas Importantes

1. **Flexibilidade:** Cronograma pode ser ajustado baseado em feedback
2. **Priorização:** Features core têm precedência sobre nice-to-have
3. **Testing:** Testes contínuos no hardware real (Pi Zero)
4. **Documentação:** Atualizada incrementalmente, não deixar para o final
5. **Performance:** Validar em cada sprint no Raspberry Pi

## 🔄 Revisões

| Tipo | Frequência | Participantes |
|------|------------|---------------|
| Daily Progress | Diário | Dev (via TODO.md) |
| Sprint Review | Semanal | Stakeholders |
| Retrospectiva | Quinzenal | Time técnico |
| Demo | Mensal | Usuários finais |

---

**Última Atualização:** 07 de Agosto de 2025  
**Responsável:** Lee Chardes  
**Status:** 🟢 Aprovado para execução