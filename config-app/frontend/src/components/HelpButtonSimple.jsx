import React, { useState } from 'react';
import { HelpCircle, X, ChevronLeft, Home } from 'lucide-react';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';

const HelpButtonSimple = ({ helpPath = 'index', title = 'Ajuda' }) => {
  const [isOpen, setIsOpen] = useState(false);
  const [currentPath, setCurrentPath] = useState(helpPath);
  const [content, setContent] = useState('');
  const [loading, setLoading] = useState(false);

  // Conteúdo de ajuda embutido temporariamente
  const helpContent = {
    'mqtt-monitor': `
# Monitor MQTT - Ajuda Rápida

## Visão Geral
O Monitor MQTT permite visualizar em tempo real toda a comunicação entre os dispositivos.

## Como Usar
1. **Filtros**: Use os filtros superiores para encontrar mensagens específicas
2. **Pausar**: Clique em Pause para parar a rolagem automática
3. **Limpar**: Use o botão Limpar para remover todas as mensagens

## Tipos de Mensagem
- **Comando**: Ordens enviadas aos dispositivos
- **Status**: Respostas dos dispositivos
- **Telemetria**: Dados de sensores
- **Erro**: Problemas detectados

## Dicas
- Use filtros para reduzir o volume de mensagens
- Observe os timestamps para medir latência
- Exporte logs importantes para análise posterior
    `,
    'macros': `
# Macros e Automações - Ajuda Rápida

## Visão Geral
Macros são sequências de comandos que executam múltiplas ações com um clique.

## Como Criar uma Macro
1. Clique em "Nova Macro"
2. Escolha um template ou comece do zero
3. Adicione ações na sequência desejada
4. Configure delays entre ações se necessário
5. Salve e teste a macro

## Tipos de Ação
- **Controle de Relé**: Liga/desliga equipamentos
- **Delay**: Aguarda tempo especificado
- **Salvar Estado**: Memoriza configuração atual
- **Restaurar Estado**: Volta à configuração salva

## Segurança
- Canais momentâneos não podem ser usados em macros
- Equipamentos críticos têm proteção adicional
- Teste sempre antes de usar em produção
    `,
    'relay-simulator': `
# Simulador de Relés - Ajuda Rápida

## Visão Geral
Controle manual dos relés do veículo com feedback visual em tempo real.

## Como Usar
1. Selecione a placa de relé no topo
2. Clique nos canais para ligar/desligar
3. Canais verdes estão ligados
4. Canais cinza estão desligados

## Tipos de Canal
- **Toggle**: Liga/desliga com um clique
- **Momentâneo**: Ativo apenas enquanto pressionado
- **Pulso**: Ativa por tempo determinado

## Proteções
- Alguns canais requerem confirmação
- Canais críticos podem pedir senha
- Observe os ícones de cadeado
    `,
    'index': `
# Central de Ajuda - AutoCore

## Bem-vindo!
O AutoCore é seu sistema completo de automação veicular.

## Principais Recursos
- **Dashboard**: Visão geral do sistema
- **Monitor MQTT**: Comunicação em tempo real
- **Simulador de Relés**: Controle manual
- **Macros**: Automações personalizadas
- **CAN Bus**: Telemetria do veículo

## Navegação
Use o menu lateral para acessar as diferentes seções.
Cada página tem seu próprio botão de ajuda com informações específicas.

## Suporte
Para ajuda adicional, consulte a documentação completa ou entre em contato com o suporte técnico.
    `
  };

  const handleOpen = () => {
    setIsOpen(true);
    const content = helpContent[helpPath] || helpContent['index'];
    setContent(content);
  };

  return (
    <>
      {/* Botão de Ajuda */}
      <div 
        className="fixed top-20 right-6"
        style={{ position: 'fixed', top: '80px', right: '24px', zIndex: 9999 }}
      >
        <Button
          onClick={handleOpen}
          className="flex items-center gap-2 bg-primary text-primary-foreground hover:bg-primary/90 px-4 py-2 rounded-md shadow-lg"
        >
          <HelpCircle className="h-5 w-5" />
          <span>Ajuda</span>
        </Button>
      </div>

      {/* Dialog de Ajuda */}
      <Dialog open={isOpen} onOpenChange={setIsOpen}>
        <DialogContent className="max-w-3xl max-h-[80vh]">
          <DialogHeader>
            <DialogTitle className="text-xl">
              {title}
            </DialogTitle>
          </DialogHeader>

          <div className="overflow-y-auto pr-4" style={{ maxHeight: '60vh' }}>
            <div className="prose prose-sm max-w-none dark:prose-invert">
              <pre className="whitespace-pre-wrap font-sans text-sm leading-relaxed">
                {content.trim()}
              </pre>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </>
  );
};

export default HelpButtonSimple;