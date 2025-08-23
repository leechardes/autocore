# Macros e Automações - Comandos Inteligentes

## O que são Macros?

Macros são sequências de comandos pré-programadas que executam várias ações com apenas um toque. Imagine ter um botão "Modo Trilha" que automaticamente liga os faróis auxiliares, ativa o compressor de ar, trava o diferencial e ajusta outros equipamentos - isso é uma macro!

## Para que servem?

### Conveniência
- Execute múltiplas ações com um clique
- Evite esquecer de ligar/desligar equipamentos
- Padronize operações repetitivas

### Segurança
- Sequências testadas e validadas
- Tempos de espera adequados entre ações
- Proteção contra acionamentos conflitantes

### Eficiência
- Reduza tempo de preparação
- Minimize erros operacionais
- Automatize rotinas complexas

## Tipos de Ações Disponíveis

### Controle de Relé
Liga, desliga ou alterna o estado de um ou mais relés. Você pode:
- Selecionar canais específicos
- Controlar múltiplos canais simultaneamente
- Adicionar descrição para cada ação

### Delay (Aguardar)
Insere uma pausa entre ações:
- Tempo em milissegundos (1000ms = 1 segundo)
- Útil para aguardar equipamentos iniciarem
- Evita sobrecarga ao ligar muitos equipamentos juntos

### Salvar Estado
Memoriza o estado atual dos relés:
- Salva configuração antes de mudanças
- Permite restaurar depois
- Pode salvar todos ou canais específicos

### Restaurar Estado
Volta os relés ao estado previamente salvo:
- Retorna à configuração anterior
- Útil para macros temporárias
- Funciona com estado salvo anteriormente

### Loop (Repetir)
Repete um conjunto de ações:
- Número definido de vezes
- Útil para sinalizações
- Pode criar efeitos visuais

### Mensagem MQTT
Envia mensagem personalizada:
- Para integração avançada
- Comunicação com outros sistemas
- Controle customizado

### Ações Paralelas
Executa múltiplas ações simultaneamente:
- Acelera execução
- Ações independentes
- Maior eficiência

## Como Criar uma Macro

### Passo 1: Acessar a Página de Macros
- Clique em "Macros" no menu lateral
- Ou use o botão de acesso rápido no dashboard

### Passo 2: Criar Nova Macro
1. Clique no botão "Nova Macro"
2. Escolha um template ou comece do zero
3. Digite um nome descritivo
4. Adicione uma descrição clara

### Passo 3: Adicionar Ações

#### Para Controlar Relés:
1. Clique em "Adicionar Ação"
2. Selecione "Controle de Relé"
3. Escolha a placa de relé
4. Marque os canais desejados
5. Defina a ação (Ligar/Desligar/Alternar)
6. Adicione descrição opcional

#### Para Adicionar Delay:
1. Selecione "Aguardar (Delay)"
2. Digite o tempo em milissegundos
3. Exemplo: 2000 para 2 segundos

#### Para Salvar/Restaurar Estado:
1. Selecione a ação desejada
2. Escolha a placa
3. Selecione canais ou deixe vazio para todos

### Passo 4: Organizar Sequência
- Use as setas para reordenar ações
- Botão duplicar para copiar ações similares
- Lixeira para remover ações indesejadas

### Passo 5: Configurar Opções

#### Preservar Estado Anterior
- Salva configuração antes de executar
- Permite retornar ao estado original
- Útil para macros temporárias

#### Requer Heartbeat
- Segurança adicional
- Desliga equipamentos se perder comunicação
- Recomendado para equipamentos críticos

### Passo 6: Salvar e Testar
1. Clique em "Salvar Macro"
2. Execute um teste
3. Verifique no Monitor MQTT
4. Ajuste se necessário

## Exemplos de Macros Úteis

### Modo Trilha
**Objetivo**: Preparar veículo para trilha
**Ações**:
1. Ligar faróis auxiliares
2. Aguardar 500ms
3. Ativar compressor de ar
4. Aguardar 1000ms
5. Travar diferencial
6. Ligar ventilador extra

### Emergência
**Objetivo**: Sinalização de emergência
**Ações**:
1. Salvar estado atual
2. Loop 10 vezes:
   - Ligar strobo e faróis
   - Aguardar 500ms
   - Desligar strobo e faróis
   - Aguardar 500ms
3. Restaurar estado anterior

### Modo Estacionamento
**Objetivo**: Desligar tudo ao estacionar
**Ações**:
1. Desligar todos os faróis
2. Aguardar 1000ms
3. Desligar equipamentos auxiliares
4. Desligar som e acessórios

### Show de Luz
**Objetivo**: Demonstração visual
**Ações**:
1. Sequência progressiva de luzes
2. Delays calculados para efeito
3. Finaliza com todas ligadas
4. Aguarda 3 segundos
5. Desliga tudo progressivamente

## Gerenciamento de Macros

### Editar Macro Existente
1. Clique no ícone de edição
2. Modifique ações conforme necessário
3. Salve as alterações
4. Teste novamente

### Duplicar Macro
1. Útil para criar variações
2. Clique no botão duplicar
3. Modifique a cópia
4. Salve com novo nome

### Desativar Temporariamente
1. Use o switch de ativo/inativo
2. Macro fica disponível mas não executável
3. Útil para manutenção

### Excluir Macro
1. Clique no ícone de lixeira
2. Confirme a exclusão
3. Ação não pode ser desfeita

## Segurança e Limitações

### Canais Protegidos
Alguns canais não podem ser incluídos em macros:
- **Canais momentâneos**: Requerem ação contínua
- **Guincho**: Segurança operacional
- **Equipamentos críticos**: Definidos pelo administrador

### Proteções Automáticas
- Timeout de execução (máximo 60 segundos)
- Verificação de conflitos
- Validação antes de executar
- Log de todas as execuções

### Boas Práticas
- Teste macros antes de usar em produção
- Use delays adequados entre ações
- Documente o propósito de cada macro
- Revise periodicamente macros antigas

## Dicas Avançadas

### Otimização de Sequências
- Agrupe ações relacionadas
- Use ações paralelas quando possível
- Minimize delays desnecessários
- Considere ordem de acionamento

### Macros Condicionais
- Combine com horários específicos
- Use com sensores (futura implementação)
- Crie variações para diferentes situações

### Integração com Sistema
- Monitore execução pelo MQTT
- Verifique logs de eventos
- Acompanhe estatísticas de uso

## Perguntas Frequentes

**P: Quantas ações uma macro pode ter?**
R: Não há limite fixo, mas recomenda-se máximo de 20 ações para manter a clareza e evitar timeouts.

**P: Posso executar uma macro dentro de outra?**
R: Atualmente não, mas você pode duplicar ações entre macros.

**P: As macros funcionam offline?**
R: Não, o sistema precisa estar online e conectado para executar macros.

**P: Como cancelo uma macro em execução?**
R: Clique no botão "Parar" que aparece durante a execução.

**P: Posso agendar macros para executar automaticamente?**
R: Esta funcionalidade está planejada para futuras versões.

## Solução de Problemas

### Problema: Macro não executa
**Soluções**:
1. Verifique se está ativa
2. Confirme dispositivos online
3. Verifique permissões dos canais
4. Consulte logs de erro

### Problema: Ações não funcionam como esperado
**Soluções**:
1. Aumente delays entre ações
2. Verifique ordem das ações
3. Teste ações individualmente
4. Confirme estado dos relés

### Problema: Macro para no meio
**Soluções**:
1. Verifique timeout (60 segundos máximo)
2. Procure por canais protegidos
3. Verifique conexão MQTT
4. Consulte Monitor MQTT para erros

### Problema: Estado não é restaurado
**Soluções**:
1. Confirme que salvou estado antes
2. Verifique canais selecionados
3. Aguarde conclusão completa
4. Teste manualmente os canais

## Estatísticas e Monitoramento

### Métricas Disponíveis
- **Total de execuções**: Quantas vezes foi executada
- **Última execução**: Data e hora
- **Tempo médio**: Duração típica
- **Taxa de sucesso**: Porcentagem de conclusões

### Como Interpretar
- Muitas execuções = macro útil
- Tempo variável = possível problema
- Baixa taxa de sucesso = revisar configuração

---

**Dica Pro**: Comece com macros simples e vá aumentando a complexidade conforme ganha confiança. Use o Monitor MQTT para entender exatamente o que cada ação faz.