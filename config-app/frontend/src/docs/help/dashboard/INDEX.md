# Dashboard - Centro de Controle

## O que é o Dashboard?

O Dashboard é a tela principal do AutoCore, seu centro de comando para monitorar e controlar todo o sistema de automação veicular. Aqui você tem uma visão geral instantânea do status de todos os dispositivos, telemetria em tempo real e acesso rápido às principais funcionalidades.

## Áreas do Dashboard

### Cartões de Status (Parte Superior)

#### Dispositivos Online
Mostra quantos dispositivos ESP32 estão conectados e funcionando. 
- **Verde**: Todos os dispositivos esperados estão online
- **Amarelo**: Alguns dispositivos offline
- **Vermelho**: Maioria dos dispositivos offline

#### Relés Ativos
Indica quantos relés estão ligados no momento.
- Útil para verificar consumo de energia
- Clique para ir direto ao simulador de relés

#### Telemetria
Quantidade de dados de telemetria recebidos.
- Atualiza em tempo real
- Indica atividade do sistema

#### Eventos Recentes
Número de eventos registrados nas últimas 24 horas.
- Inclui acionamentos, erros e mudanças de estado

### Gráficos de Telemetria (Centro)

#### Gráfico de Temperatura
- Linha azul: Temperatura do motor
- Linha vermelha: Temperatura ambiente
- Atualização a cada 5 segundos
- Últimos 50 pontos de dados

#### Gráfico de Pressão
- Pressão de óleo
- Pressão do turbo (se equipado)
- Valores em BAR ou PSI

#### Velocímetro Virtual
- Mostra RPM atual do motor
- Indicador visual de marcha (se disponível)
- Zona vermelha para RPM máximo

### Lista de Dispositivos (Lateral)

#### Status dos Dispositivos
Lista todos os ESP32 conectados com:
- **Nome do dispositivo**
- **Tipo** (Relé, Display, Sensor)
- **Status** (Online/Offline)
- **Último contato**

#### Indicadores Visuais
- **Bolinha verde**: Online e funcionando
- **Bolinha vermelha**: Offline ou com erro
- **Bolinha amarela**: Conectando ou instável

### Ações Rápidas (Parte Inferior)

#### Botões de Acesso Rápido
- **Relés**: Abre o simulador de relés
- **Macros**: Acessa o sistema de automações
- **Monitor**: Abre o monitor MQTT
- **Configurações**: Acessa as configurações

## Como Usar

### Monitoramento Básico

1. **Verifique o Status Geral**
   - Olhe os cartões superiores
   - Verde = Tudo OK
   - Vermelho = Atenção necessária

2. **Acompanhe a Telemetria**
   - Observe os gráficos centrais
   - Valores anormais aparecem em vermelho
   - Clique no gráfico para mais detalhes

3. **Gerencie Dispositivos**
   - Clique em um dispositivo para detalhes
   - Use o botão de refresh para atualizar
   - Dispositivos offline mostram último contato

### Interpretando os Dados

#### Temperatura do Motor
- **Normal**: 80-95°C
- **Frio**: Abaixo de 80°C (aquecendo)
- **Quente**: Acima de 95°C (atenção)
- **Crítico**: Acima de 105°C (perigo)

#### RPM do Motor
- **Marcha lenta**: 800-1000 RPM
- **Condução normal**: 1500-3000 RPM
- **Potência máxima**: 3000-4500 RPM
- **Zona vermelha**: Acima de 4500 RPM

#### Status dos Relés
- Consumo normal: 3-5 relés ativos
- Muitos relés ativos pode indicar:
  - Esquecimento de desligar equipamentos
  - Possível problema no sistema

### Ações Disponíveis

#### Para Dispositivos Offline
1. Clique no dispositivo offline
2. Selecione "Tentar Reconectar"
3. Se persistir, verifique:
   - Alimentação do ESP32
   - Conexão de rede
   - Configuração do dispositivo

#### Para Telemetria Anormal
1. Clique no valor anormal
2. Veja o histórico recente
3. Compare com valores normais
4. Acione proteções se necessário

## Dicas Úteis

### Otimização da Visualização
- **Tela Cheia**: F11 para melhor visualização
- **Auto-Refresh**: Página atualiza a cada 30 segundos
- **Modo Escuro**: Reduz cansaço visual à noite

### Monitoramento Eficiente
- Configure alertas para valores críticos
- Observe padrões ao longo do tempo
- Mantenha log de eventos importantes

### Uso de Recursos
- Dashboard consome poucos recursos
- Safe para deixar aberto continuamente
- Dados são armazenados por 7 dias

## Perguntas Frequentes

**P: Por que alguns valores aparecem como "--"?**
R: Indica que o sensor não está enviando dados. Verifique se o sensor está conectado e configurado corretamente.

**P: Os gráficos não estão atualizando, o que fazer?**
R: Verifique sua conexão com o servidor. Tente recarregar a página (F5). Se persistir, verifique o status do gateway.

**P: Posso personalizar quais informações aparecem?**
R: Sim, nas configurações você pode escolher quais cartões e gráficos exibir no dashboard.

**P: Quanto tempo os dados ficam armazenados?**
R: Telemetria é mantida por 7 dias. Eventos importantes são arquivados por 30 dias.

**P: Como exportar os dados do dashboard?**
R: Use o botão de exportação (ícone de download) para salvar dados em formato CSV ou JSON.

## Solução de Problemas

### Problema: Dashboard não carrega
**Soluções**:
1. Verifique conexão de rede
2. Limpe o cache do navegador
3. Verifique se o servidor está rodando
4. Tente outro navegador

### Problema: Dados desatualizados
**Soluções**:
1. Pressione F5 para recarregar
2. Verifique data/hora do sistema
3. Confirme que o gateway está online
4. Verifique logs de erro

### Problema: Gráficos em branco
**Soluções**:
1. Aguarde alguns segundos para carregar
2. Verifique se há dados de telemetria
3. Recarregue a página
4. Verifique console do navegador (F12)

### Problema: Dispositivos aparecem offline
**Soluções**:
1. Verifique alimentação dos ESP32
2. Teste conexão MQTT
3. Reinicie o gateway
4. Verifique configuração de rede

## Indicadores e Legendas

### Cores dos Status
- **Verde**: Funcionando perfeitamente
- **Amarelo**: Atenção ou aviso
- **Vermelho**: Erro ou crítico
- **Azul**: Informação ou neutro
- **Cinza**: Desabilitado ou sem dados

### Ícones Comuns
- **Sinal**: Qualidade do sinal
- **Temperatura**: Indicador de temperatura
- **Energia**: Consumo/Energia
- **Sincronização**: Sincronizando dados
- **Aviso**: Aviso importante
- **Sucesso**: Operação bem-sucedida
- **Erro**: Erro ou falha

---

**Dica Pro**: Configure a página inicial do seu navegador para o Dashboard do AutoCore para acesso rápido ao sistema.