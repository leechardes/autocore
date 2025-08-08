import React, { useState } from 'react';
import { HelpCircle, X, BookOpen, Zap, Shield, Lightbulb } from 'lucide-react';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { ScrollArea } from '@/components/ui/scroll-area';
import { Separator } from '@/components/ui/separator';

const HelpModal = ({ currentPage = 'dashboard' }) => {
  const [isOpen, setIsOpen] = useState(false);

  // Conteúdo de ajuda por página
  const helpContent = {
    'dashboard': {
      title: 'Dashboard',
      quickTips: [
        'Visualize o status geral do sistema em tempo real',
        'Clique nos cartões para acessar detalhes',
        'Use o botão de atualizar para recarregar dados'
      ],
      sections: [
        {
          title: 'Cartões de Status',
          content: 'Mostram informações resumidas sobre dispositivos, relés e configurações. Cores indicam o estado: verde (ok), amarelo (atenção), vermelho (problema).'
        },
        {
          title: 'Navegação Rápida',
          content: 'Use o menu lateral para acessar diferentes seções. Os ícones facilitam a identificação visual.'
        }
      ]
    },
    'devices': {
      title: 'Dispositivos',
      quickTips: [
        'Descubra automaticamente novos ESP32 na rede',
        'Configure parâmetros de cada dispositivo',
        'Monitore status e versão do firmware'
      ],
      sections: [
        {
          title: 'Descoberta Automática',
          content: 'Clique em "Descobrir" para buscar ESP32 na rede. Dispositivos aparecem automaticamente quando conectados ao MQTT.'
        },
        {
          title: 'Configuração',
          content: 'Cada dispositivo tem UUID único. Configure tipo (relés, display, sensores). Defina nome amigável para identificação.'
        },
        {
          title: 'Firmware OTA',
          content: 'Atualize firmware remotamente. Veja versão atual instalada. Rollback automático em caso de falha.'
        }
      ]
    },
    'relays': {
      title: 'Configuração de Relés',
      quickTips: [
        'Configure placas e canais individuais',
        'Defina funções e proteções por canal',
        'Teste funcionamento com simulador integrado'
      ],
      sections: [
        {
          title: 'Placas de Relé',
          content: 'Adicione placas com 8 ou 16 canais. Configure endereço GPIO base. Defina tipo de acionamento (normal/invertido).'
        },
        {
          title: 'Canais Individuais',
          content: 'Nome descritivo para cada canal. Tipo: toggle, momentâneo ou pulso. Proteções: senha, confirmação, heartbeat.'
        },
        {
          title: 'Simulador',
          content: 'Teste canais antes de usar em produção. Visualize estados em tempo real. Simule falhas e recuperação.'
        }
      ]
    },
    'macros': {
      title: 'Macros e Automações',
      quickTips: [
        'Crie sequências de comandos reutilizáveis',
        'Use delays para temporização adequada',
        'Teste sempre antes de usar em produção'
      ],
      sections: [
        {
          title: 'Criando uma Macro',
          content: 'Clique em "Nova Macro". Escolha um template ou comece do zero. Adicione ações na sequência desejada. Configure delays entre ações.'
        },
        {
          title: 'Tipos de Ação',
          content: 'Controle de Relé: liga/desliga canais. Delay: aguarda tempo especificado. Salvar/Restaurar Estado: memoriza configuração. Loop: repete ações.'
        },
        {
          title: 'Segurança',
          content: 'Canais momentâneos não podem ser usados em macros. Equipamentos críticos têm proteção adicional. Heartbeat garante segurança em caso de falha.'
        }
      ]
    },
    'screens': {
      title: 'Editor de Telas',
      quickTips: [
        'Arraste e solte componentes visuais',
        'Configure layouts para LCD/OLED',
        'Preview em tempo real'
      ],
      sections: [
        {
          title: 'Criando Telas',
          content: 'Selecione tamanho (128x64, 320x240, etc). Arraste componentes da paleta. Configure propriedades de cada elemento.'
        },
        {
          title: 'Componentes',
          content: 'Texto: labels e valores. Gauges: medidores analógicos. Gráficos: histórico de dados. Ícones: status visual.'
        },
        {
          title: 'Vinculação de Dados',
          content: 'Conecte elementos a sinais CAN. Vincule a status de relés. Configure atualização automática.'
        }
      ]
    },
    'can': {
      title: 'Configuração CAN Bus',
      quickTips: [
        'Configure sinais da ECU FuelTech',
        'Mapeie endereços e conversões',
        'Visualize telemetria em tempo real'
      ],
      sections: [
        {
          title: 'Sinais Padrão',
          content: '14 sinais FuelTech pré-configurados. RPM, TPS, MAP, temperatura, pressão óleo. Adicione sinais customizados conforme necessário.'
        },
        {
          title: 'Configuração de Sinais',
          content: 'CAN ID: endereço do sinal no barramento. Scale/Offset: conversão de valores raw. Unidade: km/h, RPM, °C, bar, etc.'
        },
        {
          title: 'Visualização',
          content: 'Gauges analógicos para monitoramento. Gráficos de histórico. Valores raw e processados.'
        }
      ]
    },
    'mqtt': {
      title: 'Monitor MQTT',
      quickTips: [
        'Filtre mensagens por tópico ou tipo',
        'Pause a rolagem para análise detalhada',
        'Exporte logs importantes'
      ],
      sections: [
        {
          title: 'Filtros',
          content: 'Use a barra de pesquisa para filtrar por tópico. Selecione tipos específicos no dropdown. Filtre por dispositivo para focar em um ESP32.'
        },
        {
          title: 'Tipos de Mensagem',
          content: 'Comando (azul): ordens enviadas. Status (verde): confirmações. Telemetria (roxo): dados de sensores. Erro (vermelho): problemas detectados.'
        },
        {
          title: 'Simulador de Relés',
          content: 'Teste comandos diretamente do monitor. Veja as mensagens sendo enviadas em tempo real. Útil para debug e desenvolvimento.'
        }
      ]
    },
    'config': {
      title: 'Gerador de Configuração',
      quickTips: [
        'Gere configs para cada ESP32',
        'Exporte em JSON, C++ ou YAML',
        'Download direto ou copie código'
      ],
      sections: [
        {
          title: 'Seleção de Dispositivo',
          content: 'Escolha ESP32 pelo UUID. Configuração é gerada automaticamente. Inclui todos os parâmetros necessários.'
        },
        {
          title: 'Formatos de Saída',
          content: 'JSON: para upload direto ao ESP32. C++: para compilar no firmware. YAML: para documentação e backup.'
        },
        {
          title: 'Conteúdo Gerado',
          content: 'Configuração de relés e canais. Layout de telas configuradas. Mapeamento de sinais CAN. Parâmetros de rede e MQTT.'
        }
      ]
    },
    'themes': {
      title: 'Temas e Aparência',
      quickTips: [
        'Personalize cores do sistema',
        'Crie temas para diferentes veículos',
        'Preview em tempo real'
      ],
      sections: [
        {
          title: 'Temas Predefinidos',
          content: 'Default: tema padrão do sistema. Racing: cores vibrantes para competição. Night: otimizado para uso noturno.'
        },
        {
          title: 'Customização',
          content: 'Cores primárias e secundárias. Fundos e bordas. Indicadores de status.'
        },
        {
          title: 'Aplicação',
          content: 'Temas por dispositivo ESP32. Override global do sistema. Sincronização automática.'
        }
      ]
    },
    'settings': {
      title: 'Configurações',
      quickTips: [
        'Configure parâmetros globais do sistema',
        'Gerencie backups e restauração',
        'Configure integrações externas'
      ],
      sections: [
        {
          title: 'Sistema',
          content: 'Endereço do broker MQTT. Porta da API (padrão 8000). Modo de operação (produção/desenvolvimento).'
        },
        {
          title: 'Backup',
          content: 'Backup automático diário. Exportar configuração completa. Restaurar de arquivo.'
        },
        {
          title: 'Integrações',
          content: 'Webhooks para eventos. API keys para acesso externo. Logs para análise.'
        }
      ]
    }
  };

  const content = helpContent[currentPage] || helpContent['dashboard'];

  return (
    <>
      {/* Botão de Ajuda */}
      <Button
        variant="ghost"
        size="icon"
        onClick={() => setIsOpen(true)}
        title="Ajuda"
      >
        <HelpCircle className="h-4 w-4" />
      </Button>

      {/* Modal de Ajuda */}
      <Dialog open={isOpen} onOpenChange={setIsOpen}>
        <DialogContent className="max-w-3xl max-h-[85vh]">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <BookOpen className="h-5 w-5" />
              Ajuda - {content.title}
            </DialogTitle>
          </DialogHeader>

          <Tabs defaultValue="quick" className="mt-4">
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="quick">
                <Zap className="h-4 w-4 mr-2" />
                Dicas Rápidas
              </TabsTrigger>
              <TabsTrigger value="guide">
                <BookOpen className="h-4 w-4 mr-2" />
                Guia Completo
              </TabsTrigger>
              <TabsTrigger value="shortcuts">
                <Lightbulb className="h-4 w-4 mr-2" />
                Atalhos
              </TabsTrigger>
            </TabsList>

            <ScrollArea className="h-[50vh] mt-4">
              <TabsContent value="quick" className="space-y-4">
                <Card>
                  <CardHeader>
                    <CardTitle className="text-base">Principais Funcionalidades</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <ul className="space-y-2">
                      {content.quickTips.map((tip, index) => (
                        <li key={index} className="flex items-start gap-2">
                          <span className="text-primary mt-1">•</span>
                          <span className="text-sm">{tip}</span>
                        </li>
                      ))}
                    </ul>
                  </CardContent>
                </Card>
              </TabsContent>

              <TabsContent value="guide" className="space-y-4">
                {content.sections.map((section, index) => (
                  <Card key={index}>
                    <CardHeader>
                      <CardTitle className="text-base">{section.title}</CardTitle>
                    </CardHeader>
                    <CardContent>
                      <p className="text-sm text-muted-foreground">
                        {section.content}
                      </p>
                    </CardContent>
                  </Card>
                ))}
              </TabsContent>

              <TabsContent value="shortcuts" className="space-y-4">
                <Card>
                  <CardHeader>
                    <CardTitle className="text-base">Atalhos do Sistema</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <h4 className="font-medium mb-2">Navegação</h4>
                      <div className="space-y-1 text-sm">
                        <div className="flex justify-between">
                          <span className="text-muted-foreground">Menu lateral</span>
                          <kbd className="px-2 py-1 bg-muted rounded text-xs">Alt + M</kbd>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-muted-foreground">Busca rápida</span>
                          <kbd className="px-2 py-1 bg-muted rounded text-xs">Ctrl + K</kbd>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-muted-foreground">Atualizar</span>
                          <kbd className="px-2 py-1 bg-muted rounded text-xs">F5</kbd>
                        </div>
                      </div>
                    </div>
                    
                    <Separator />
                    
                    <div>
                      <h4 className="font-medium mb-2">Ações</h4>
                      <div className="space-y-1 text-sm">
                        <div className="flex justify-between">
                          <span className="text-muted-foreground">Nova macro</span>
                          <kbd className="px-2 py-1 bg-muted rounded text-xs">Ctrl + N</kbd>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-muted-foreground">Salvar</span>
                          <kbd className="px-2 py-1 bg-muted rounded text-xs">Ctrl + S</kbd>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-muted-foreground">Cancelar</span>
                          <kbd className="px-2 py-1 bg-muted rounded text-xs">Esc</kbd>
                        </div>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </TabsContent>
            </ScrollArea>
          </Tabs>

          <div className="mt-4 p-3 bg-muted rounded-lg">
            <p className="text-xs text-muted-foreground">
              <strong>Precisa de mais ajuda?</strong> Consulte a documentação completa ou entre em contato com o suporte técnico.
            </p>
          </div>
        </DialogContent>
      </Dialog>
    </>
  );
};

export default HelpModal;