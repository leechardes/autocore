# Bem-vindo ao AutoCore

## O que é o AutoCore?

O AutoCore é um sistema completo de automação veicular que permite controlar diversos equipamentos do seu veículo de forma inteligente e integrada. Com ele, você pode gerenciar relés, criar automações personalizadas, monitorar telemetria e muito mais.

## Principais Funcionalidades

### Dashboard
Centro de controle com visão geral do sistema, mostrando status dos dispositivos, telemetria em tempo real e acesso rápido às principais funções.

### Monitor MQTT
Visualize em tempo real toda a comunicação entre os dispositivos do sistema, útil para diagnóstico e acompanhamento das operações.

### Simulador de Relés
Controle e teste os relés do seu veículo, com interface visual intuitiva mostrando o estado de cada canal.

### Macros e Automações
Crie sequências de comandos personalizadas para executar várias ações com um único toque, como "Modo Trilha" ou "Emergência".

### Sistema CAN Bus
Monitore dados do motor e ECU em tempo real, visualizando informações como RPM, temperatura, pressão e muito mais.

## Navegação Básica

### Menu Principal
O menu lateral esquerdo dá acesso a todas as funcionalidades do sistema. Clique em qualquer item para navegar.

### Barra Superior
- **Logo AutoCore**: Clique para voltar ao dashboard
- **Indicadores de Status**: Mostra conexões ativas
- **Botão de Ajuda**: Acesso rápido a esta documentação

## Primeiros Passos

### 1. Verificar Dispositivos
Acesse a página de **Dispositivos** para verificar se todos os equipamentos estão conectados e online.

### 2. Testar Relés
Use o **Simulador de Relés** para testar o funcionamento de cada canal individualmente.

### 3. Criar sua Primeira Macro
Vá em **Macros** e crie uma automação simples para familiarizar-se com o sistema.

### 4. Monitorar o Sistema
Abra o **Monitor MQTT** para acompanhar as mensagens trocadas entre os dispositivos.

## Conceitos Importantes

### Dispositivos ESP32
São os microcontroladores que fazem a interface entre o AutoCore e os equipamentos do veículo. Cada ESP32 pode controlar múltiplos relés ou sensores.

### Canais de Relé
Cada placa de relé possui 16 canais que podem ser configurados individualmente para controlar diferentes equipamentos.

### Tipos de Acionamento
- **Toggle**: Liga/desliga permanente
- **Momentâneo**: Ativa apenas enquanto pressionado
- **Pulso**: Ativa por tempo determinado

### Proteções
Alguns canais críticos possuem proteção por confirmação ou senha para evitar acionamentos acidentais.

## Segurança

### Canais Protegidos
Equipamentos críticos como guincho e bomba de combustível possuem proteção adicional.

### Macros e Automações
Canais momentâneos e críticos não podem ser incluídos em macros automáticas por segurança.

### Heartbeat
Sistema de segurança que desliga automaticamente equipamentos caso perca comunicação.

## Dicas de Uso

### Performance
- O sistema é otimizado para funcionar em hardware limitado
- Evite abrir múltiplas abas do sistema simultaneamente
- Aguarde a confirmação visual após cada comando

### Organização
- Nomeie seus canais de forma clara e descritiva
- Agrupe macros relacionadas
- Use ícones e cores para identificação visual rápida

### Manutenção
- Verifique periodicamente o status dos dispositivos
- Teste macros após criar ou editar
- Monitore o log de eventos para identificar problemas

## Suporte e Ajuda

### Ajuda Contextual
Cada página possui seu próprio botão de ajuda com informações específicas daquela funcionalidade.

### Solução de Problemas
Consulte a seção **Troubleshooting** para resolver problemas comuns.

### Indicadores Visuais
- **Verde**: Funcionando normalmente
- **Amarelo**: Atenção ou aguardando
- **Vermelho**: Erro ou offline
- **Azul**: Informação ou neutro

## Atalhos Úteis

### Navegação
- Use as teclas de seta para navegar em listas
- ESC fecha diálogos e modais
- Enter confirma ações

### Comandos Rápidos
- Clique duplo em um relé para alternar estado
- Arraste para reordenar itens em listas
- Clique com botão direito para menu contextual (onde disponível)

---

**Precisa de mais ajuda?**
Navegue pelas seções específicas usando o menu ou clique no ícone de ajuda em cada página para informações contextuais.