# Monitor MQTT - Comunicação em Tempo Real

## O que é o Monitor MQTT?

O Monitor MQTT é uma ferramenta de diagnóstico e acompanhamento que permite visualizar em tempo real toda a comunicação entre os dispositivos do sistema AutoCore. É como uma "janela" que mostra todas as mensagens sendo trocadas entre o gateway central e os dispositivos ESP32.

## Para que serve?

### Diagnóstico
- Verificar se os comandos estão sendo enviados corretamente
- Confirmar que os dispositivos estão respondendo
- Identificar problemas de comunicação
- Analisar atrasos ou falhas

### Desenvolvimento e Testes
- Testar novos dispositivos
- Validar configurações
- Acompanhar execução de macros
- Verificar telemetria em tempo real

### Aprendizado
- Entender como o sistema funciona
- Aprender o protocolo de comunicação
- Visualizar o fluxo de dados

## Interface do Monitor

### Área de Mensagens (Principal)

A tela principal mostra as mensagens em ordem cronológica (mais recentes primeiro), com:

- **Timestamp**: Horário exato da mensagem
- **Tópico**: Caminho/endereço da mensagem
- **Tipo**: Classificação da mensagem
- **Payload**: Conteúdo da mensagem
- **QoS**: Nível de garantia de entrega

### Painel de Filtros (Superior)

#### Filtro por Tópico
Digite parte do tópico para filtrar mensagens específicas:
- `relay` - Mostra apenas mensagens de relés
- `telemetry` - Mostra apenas telemetria
- `macro` - Mostra execução de macros

#### Filtro por Tipo
Selecione tipos específicos de mensagem:
- **Comando**: Ordens enviadas aos dispositivos
- **Status**: Respostas e confirmações
- **Telemetria**: Dados de sensores
- **Erro**: Problemas e falhas

#### Filtro por Dispositivo
Escolha um dispositivo específico para monitorar apenas suas mensagens.

### Indicadores de Status (Lateral)

#### Taxa de Mensagens
Mostra quantas mensagens por segundo estão sendo processadas:
- **0-10 msg/s**: Tráfego normal
- **10-50 msg/s**: Tráfego moderado
- **50+ msg/s**: Tráfego intenso

#### Buffer de Mensagens
Indica quantas mensagens estão na fila:
- **Verde** (0-100): Normal
- **Amarelo** (100-500): Atenção
- **Vermelho** (500+): Possível sobrecarga

## Como Usar

### Monitoramento Básico

1. **Abra o Monitor MQTT**
   - Acesse pelo menu lateral
   - Ou use o atalho no dashboard

2. **Observe o Fluxo**
   - Mensagens aparecem automaticamente
   - Mais recentes no topo
   - Rolagem automática (pode desativar)

3. **Identifique Padrões**
   - Mensagens periódicas = heartbeat
   - Grupos de mensagens = macro executando
   - Ausência de mensagens = possível problema

### Usando Filtros

#### Para Monitorar Relés
1. Digite "relay" no filtro de tópico
2. Observe comandos de liga/desliga
3. Verifique confirmações de estado

#### Para Acompanhar Macros
1. Digite "macro" no filtro
2. Veja início e fim da execução
3. Acompanhe cada ação da sequência

#### Para Verificar Telemetria
1. Filtre por "telemetry"
2. Observe valores dos sensores
3. Identifique leituras anormais

### Analisando Mensagens

#### Estrutura de um Tópico MQTT
```
autocore/device/esp32-001/relay/command
   |       |        |        |      |
   |       |        |        |      +-- Ação
   |       |        |        +--------- Função
   |       |        +------------------ ID do dispositivo
   |       +--------------------------- Categoria
   +----------------------------------- Sistema
```

#### Interpretando Payloads

**Comando de Relé**:
```json
{
  "channel": 1,
  "state": "on",
  "timestamp": "2024-08-08T10:30:00"
}
```

**Status de Dispositivo**:
```json
{
  "online": true,
  "uptime": 3600,
  "free_memory": 45000
}
```

**Dados de Telemetria**:
```json
{
  "temperature": 85.5,
  "rpm": 2500,
  "pressure": 1.2
}
```

## Tipos de Mensagens

### Mensagens de Sistema
- **Heartbeat**: Sinal de vida dos dispositivos
- **Connect**: Dispositivo se conectou
- **Disconnect**: Dispositivo desconectou
- **Error**: Erro reportado

### Mensagens de Controle
- **Command**: Comando enviado
- **Response**: Resposta ao comando
- **State**: Mudança de estado
- **Config**: Configuração alterada

### Mensagens de Dados
- **Telemetry**: Dados de sensores
- **Log**: Registro de eventos
- **Alert**: Avisos importantes

## Dicas Úteis

### Para Melhor Performance
- Use filtros para reduzir quantidade de mensagens
- Desative rolagem automática ao analisar
- Limite histórico a 100 mensagens
- Pause o monitor quando não estiver usando

### Para Diagnóstico
- Compare timestamps para medir latência
- Observe sequência de mensagens
- Verifique QoS para garantia de entrega
- Salve logs importantes

### Para Aprendizado
- Comece observando uma função simples
- Acompanhe do comando até a resposta
- Note os padrões de comunicação
- Experimente diferentes filtros

## Perguntas Frequentes

**P: O que significa QoS?**
R: Quality of Service - nível de garantia de entrega da mensagem:
- QoS 0: Máximo uma vez (mais rápido, sem garantia)
- QoS 1: Pelo menos uma vez (garantido, pode duplicar)
- QoS 2: Exatamente uma vez (mais lento, garantido único)

**P: Por que algumas mensagens aparecem duplicadas?**
R: Pode ser QoS 1 garantindo entrega ou múltiplos subscribers no mesmo tópico.

**P: Como salvar o log de mensagens?**
R: Use o botão "Exportar" no canto superior direito. Escolha formato JSON ou CSV.

**P: Posso enviar mensagens pelo monitor?**
R: Não, o monitor é somente leitura. Use o simulador ou macros para enviar comandos.

**P: O que são mensagens "retained"?**
R: Mensagens que ficam salvas no broker e são entregues imediatamente a novos subscribers.

## Solução de Problemas

### Problema: Não aparecem mensagens
**Soluções**:
1. Verifique conexão com o broker MQTT
2. Confirme que há dispositivos online
3. Remova filtros ativos
4. Recarregue a página

### Problema: Muitas mensagens, difícil acompanhar
**Soluções**:
1. Use filtros específicos
2. Pause a rolagem automática
3. Aumente o intervalo de atualização
4. Filtre por dispositivo específico

### Problema: Mensagens atrasadas
**Soluções**:
1. Verifique carga do sistema
2. Reduza quantidade de mensagens
3. Verifique latência da rede
4. Reinicie o broker MQTT se necessário

### Problema: Payload ilegível
**Soluções**:
1. Verifique formato (JSON/texto/binário)
2. Use visualização "raw" para binário
3. Confirme encoding (UTF-8)
4. Verifique se não está corrompido

## Glossário

- **Broker**: Servidor central MQTT que roteia mensagens
- **Topic**: Endereço/caminho da mensagem
- **Payload**: Conteúdo/dados da mensagem
- **Subscribe**: Inscrever-se para receber mensagens
- **Publish**: Enviar mensagem para um tópico
- **Wildcard**: Caracteres especiais (+, #) para múltiplos tópicos
- **Retain**: Manter última mensagem no broker
- **LWT**: Last Will and Testament - mensagem de desconexão

---

**Dica Pro**: Use o Monitor MQTT junto com o Simulador de Relés para ver em tempo real os comandos sendo enviados quando você aciona um relé.