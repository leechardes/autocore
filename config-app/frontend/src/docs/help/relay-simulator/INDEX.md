# Simulador de Relés - Controle Manual

## O que é o Simulador de Relés?

O Simulador de Relés é a interface de controle manual dos relés do seu veículo. Através dele você pode ligar, desligar e monitorar o estado de cada canal de relé individualmente, com feedback visual em tempo real.

## Para que serve?

### Controle Manual
- Acionar equipamentos individualmente
- Testar funcionamento de cada canal
- Controle direto sem automações

### Diagnóstico
- Verificar se relés estão funcionando
- Identificar canais com problema
- Testar antes de criar macros

### Operação de Emergência
- Controle manual quando automação falha
- Acesso rápido a funções críticas
- Override de configurações automáticas

## Interface do Simulador

### Grid de Canais (Área Principal)

Cada canal é representado por um cartão interativo mostrando:

- **Número do Canal**: CH1 a CH16
- **Nome**: Descrição do equipamento conectado
- **Ícone**: Representação visual da função
- **Estado**: Ligado (verde) ou Desligado (cinza)
- **Tipo de Acionamento**: Toggle, Momentâneo ou Pulso

### Seletor de Placa (Superior)

- Lista todas as placas de relé disponíveis
- Mostra status de conexão da placa
- Indica número de canais ativos

### Indicadores de Estado

#### Cor do Cartão
- **Verde**: Canal ligado/ativo
- **Cinza**: Canal desligado/inativo
- **Amarelo**: Aguardando confirmação
- **Vermelho**: Erro ou bloqueado
- **Azul piscante**: Canal momentâneo ativo

#### Badges Informativos
- **Proteção**: Indica nível de segurança
- **Tipo**: Toggle, Momentâneo, Pulso
- **Tempo**: Para canais com timer

## Como Usar

### Operação Básica

#### Ligar/Desligar Canal Toggle
1. Clique no cartão do canal desejado
2. Aguarde confirmação visual
3. Verde = Ligado, Cinza = Desligado

#### Usar Canal Momentâneo
1. Pressione e segure o cartão
2. Canal fica ativo enquanto pressionado
3. Solte para desativar
4. Indicador azul mostra ativação

#### Acionar Canal Pulso
1. Clique no canal
2. Ativa por tempo pré-determinado
3. Desativa automaticamente
4. Barra de progresso mostra tempo restante

### Canais com Proteção

#### Proteção por Confirmação
1. Clique no canal
2. Aparece diálogo de confirmação
3. Confirme a ação
4. Canal é acionado

#### Proteção por Senha
1. Clique no canal
2. Digite a senha
3. Confirme
4. Canal é acionado se senha correta

### Seleção de Múltiplos Canais

#### Modo de Seleção
1. Ative "Seleção Múltipla" (canto superior)
2. Clique para selecionar canais
3. Use ações em lote:
   - Ligar todos selecionados
   - Desligar todos selecionados
   - Inverter selecionados

## Tipos de Canais

### Toggle (Liga/Desliga)
- **Comportamento**: Mantém estado até próximo comando
- **Uso típico**: Luzes, ventiladores, equipamentos contínuos
- **Indicação**: Estado permanece após clique

### Momentâneo
- **Comportamento**: Ativo apenas enquanto pressionado
- **Uso típico**: Buzina, pisca alerta, sinalizações
- **Indicação**: Requer pressão contínua
- **Segurança**: Não permitido em macros

### Pulso
- **Comportamento**: Ativa por tempo determinado
- **Uso típico**: Trava elétrica, partida remota
- **Indicação**: Timer visível durante ativação

## Configurações dos Canais

### Informações Exibidas

- **Nome**: Identificação do equipamento
- **Descrição**: Detalhes adicionais (hover/toque longo)
- **Ícone**: Visual para identificação rápida
- **Cor**: Personalização visual

### Propriedades Técnicas

- **Corrente Máxima**: Limite do canal
- **Tempo Máximo**: Para canais com proteção
- **Função**: Categoria do equipamento
- **Proteção**: Nível de segurança aplicado

## Funcionalidades Especiais

### Modo Visualização
- Apenas monitora estados
- Desabilita controles
- Útil para demonstração
- Evita acionamentos acidentais

### Sincronização em Tempo Real
- Estados atualizam automaticamente
- Reflete comandos de macros
- Mostra acionamentos externos
- Sincronizado com dispositivos físicos

### Histórico de Acionamentos
- Clique no ícone de histórico
- Veja últimos 10 acionamentos
- Inclui horário e origem do comando
- Útil para auditoria

## Organização dos Canais

### Por Função
- **Iluminação**: CH1-CH4
- **Auxiliares**: CH5-CH8
- **Segurança**: CH9-CH12
- **Reserva**: CH13-CH16

### Por Prioridade
- Canais críticos primeiro
- Mais usados em posições acessíveis
- Emergência em destaque
- Secundários ao final

### Por Área do Veículo
- Frente: Faróis, guincho
- Traseira: Luzes, câmera
- Interno: Ar, som
- Externo: Auxiliares

## Segurança

### Canais Críticos
Alguns canais têm proteções especiais:
- **Guincho**: Requer atenção constante
- **Bomba Combustível**: Senha obrigatória
- **Sistema Elétrico**: Confirmação dupla

### Prevenção de Acidentes
- Delays entre acionamentos
- Verificação de conflitos
- Limites de tempo ativo
- Desligamento automático de segurança

### Registro de Ações
- Todas as ações são registradas
- Include usuário e timestamp
- Rastreabilidade completa
- Exportável para análise

## Dicas de Uso

### Para Melhor Controle
- Organize canais por frequência de uso
- Use nomes descritivos claros
- Agrupe funções relacionadas
- Mantenha reservas identificadas

### Para Diagnóstico
- Teste um canal por vez
- Observe delay de resposta
- Verifique consumo de corrente
- Compare com estado esperado

### Para Segurança
- Sempre confirme estado visual
- Use proteções em canais críticos
- Teste antes de confiar
- Mantenha documentação atualizada

## Perguntas Frequentes

**P: Por que um canal não responde ao clique?**
R: Verifique: 1) Se a placa está online, 2) Se o canal está ativo, 3) Se não há proteção ativa, 4) Se não é momentâneo (requer pressão contínua).

**P: Posso renomear os canais?**
R: Sim, vá em Configurações > Canais de Relé e edite o nome desejado.

**P: O que significa o ícone de cadeado?**
R: Indica que o canal tem algum tipo de proteção (senha ou confirmação) configurada.

**P: Como sei qual relé físico corresponde a cada canal?**
R: Consulte o diagrama de conexões na documentação técnica ou etiquetas na placa de relés.

**P: Posso controlar múltiplas placas ao mesmo tempo?**
R: Você pode alternar rapidamente entre placas, mas o controle é uma placa por vez para evitar confusão.

## Solução de Problemas

### Problema: Canal não liga/desliga
**Soluções**:
1. Verifique conexão da placa
2. Confirme que não há proteção ativa
3. Teste outro canal para comparar
4. Verifique fusível do canal
5. Consulte log de erros

### Problema: Estado não sincroniza
**Soluções**:
1. Recarregue a página (F5)
2. Verifique conexão MQTT
3. Confirme firmware do ESP32
4. Reinicie a placa de relés

### Problema: Delay grande no acionamento
**Soluções**:
1. Verifique latência de rede
2. Reduza tráfego MQTT
3. Confirme qualidade do sinal WiFi
4. Verifique carga do sistema

### Problema: Canal liga sozinho
**Soluções**:
1. Verifique macros ativas
2. Procure por curto-circuito
3. Confirme configuração do canal
4. Verifique interferência elétrica

## Indicadores Visuais

### Estados do Canal
- **Verde sólido**: Ligado e estável
- **Verde piscante**: Ligando/processando
- **Cinza**: Desligado
- **Vermelho**: Erro ou bloqueado
- **Amarelo**: Aguardando
- **Azul piscante**: Momentâneo ativo

### Ícones de Status
- **Raio**: Canal energizado
- **Cadeado**: Proteção ativa
- **Relógio**: Timer/pulso ativo
- **Alerta**: Atenção necessária
- **Check**: Comando confirmado

---

**Dica Pro**: Use o Simulador junto com o Monitor MQTT para ver os comandos sendo enviados em tempo real. Isso ajuda a entender o funcionamento e diagnosticar problemas.