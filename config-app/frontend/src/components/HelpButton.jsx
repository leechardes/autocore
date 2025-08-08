import React, { useState } from 'react';
import { HelpCircle, X, ChevronLeft, Home, ExternalLink } from 'lucide-react';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { ScrollArea } from '@/components/ui/scroll-area';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';

const HelpButton = ({ helpPath = 'index', title = 'Ajuda' }) => {
  const [isOpen, setIsOpen] = useState(false);
  const [currentPath, setCurrentPath] = useState(helpPath);
  const [content, setContent] = useState('');
  const [loading, setLoading] = useState(false);
  const [history, setHistory] = useState([]);

  // Mapa de caminhos para arquivos de ajuda
  const helpFiles = {
    'index': '/src/docs/help/index.md',
    'dashboard': '/src/docs/help/dashboard/index.md',
    'mqtt-monitor': '/src/docs/help/mqtt-monitor/index.md',
    'macros': '/src/docs/help/macros/index.md',
    'relay-simulator': '/src/docs/help/relay-simulator/index.md',
    'devices': '/src/docs/help/devices/index.md',
    'can-bus': '/src/docs/help/can-bus/index.md',
    'screens': '/src/docs/help/screens/index.md',
    'themes': '/src/docs/help/themes/index.md',
    'troubleshooting': '/src/docs/help/troubleshooting/index.md',
  };

  const loadHelpContent = async (path) => {
    setLoading(true);
    try {
      const filePath = helpFiles[path] || helpFiles['index'];
      const response = await fetch(filePath);
      
      if (!response.ok) {
        throw new Error('Arquivo não encontrado');
      }
      
      const text = await response.text();
      setContent(text);
      setCurrentPath(path);
    } catch (error) {
      console.error('Erro carregando ajuda:', error);
      setContent(`# Erro ao carregar ajuda

Não foi possível carregar o conteúdo de ajuda para esta página.

Por favor, tente novamente ou consulte a documentação online.`);
    } finally {
      setLoading(false);
    }
  };

  const handleOpen = () => {
    setIsOpen(true);
    setHistory([]);
    loadHelpContent(helpPath);
  };

  const handleNavigate = (newPath) => {
    if (newPath !== currentPath) {
      setHistory([...history, currentPath]);
      loadHelpContent(newPath);
    }
  };

  const handleBack = () => {
    if (history.length > 0) {
      const previousPath = history[history.length - 1];
      setHistory(history.slice(0, -1));
      loadHelpContent(previousPath);
    }
  };

  const handleHome = () => {
    if (currentPath !== 'index') {
      setHistory([]);
      loadHelpContent('index');
    }
  };

  // Componente personalizado para links internos no Markdown
  const MarkdownLink = ({ href, children }) => {
    // Verifica se é um link interno para outra página de ajuda
    if (href && href.startsWith('#help-')) {
      const helpKey = href.replace('#help-', '');
      return (
        <button
          className="text-primary hover:underline cursor-pointer"
          onClick={() => handleNavigate(helpKey)}
        >
          {children}
        </button>
      );
    }
    
    // Link externo
    return (
      <a
        href={href}
        target="_blank"
        rel="noopener noreferrer"
        className="text-primary hover:underline inline-flex items-center gap-1"
      >
        {children}
        <ExternalLink className="h-3 w-3" />
      </a>
    );
  };

  return (
    <>
      {/* Botão de Ajuda */}
      <Button
        variant="ghost"
        size="icon"
        onClick={handleOpen}
        className="fixed top-4 right-4 z-40"
        title={title}
      >
        <HelpCircle className="h-5 w-5" />
      </Button>

      {/* Dialog de Ajuda */}
      <Dialog open={isOpen} onOpenChange={setIsOpen}>
        <DialogContent className="max-w-4xl max-h-[90vh] p-0">
          <DialogHeader className="p-6 pb-0">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                {history.length > 0 && (
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={handleBack}
                    className="h-8 w-8"
                  >
                    <ChevronLeft className="h-4 w-4" />
                  </Button>
                )}
                {currentPath !== 'index' && (
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={handleHome}
                    className="h-8 w-8"
                  >
                    <Home className="h-4 w-4" />
                  </Button>
                )}
                <DialogTitle className="text-xl">
                  Central de Ajuda - AutoCore
                </DialogTitle>
              </div>
              <Button
                variant="ghost"
                size="icon"
                onClick={() => setIsOpen(false)}
                className="h-8 w-8"
              >
                <X className="h-4 w-4" />
              </Button>
            </div>
          </DialogHeader>

          <ScrollArea className="h-[70vh] px-6 pb-6">
            {loading ? (
              <div className="flex items-center justify-center py-12">
                <div className="text-center">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto mb-4"></div>
                  <p className="text-muted-foreground">Carregando conteúdo de ajuda...</p>
                </div>
              </div>
            ) : (
              <div className="prose prose-sm max-w-none dark:prose-invert">
                <ReactMarkdown
                  remarkPlugins={[remarkGfm]}
                  components={{
                    a: MarkdownLink,
                    // Personalizar tabelas para melhor visualização
                    table: ({ children }) => (
                      <div className="overflow-x-auto">
                        <table className="min-w-full divide-y divide-border">
                          {children}
                        </table>
                      </div>
                    ),
                    // Personalizar blocos de código
                    pre: ({ children }) => (
                      <pre className="bg-muted p-4 rounded-lg overflow-x-auto">
                        {children}
                      </pre>
                    ),
                    // Personalizar listas
                    ul: ({ children }) => (
                      <ul className="list-disc pl-6 space-y-2">
                        {children}
                      </ul>
                    ),
                    ol: ({ children }) => (
                      <ol className="list-decimal pl-6 space-y-2">
                        {children}
                      </ol>
                    ),
                  }}
                >
                  {content}
                </ReactMarkdown>
              </div>
            )}
          </ScrollArea>

          {/* Rodapé com links rápidos */}
          <div className="border-t px-6 py-4 bg-muted/50">
            <div className="flex flex-wrap gap-2 text-sm">
              <span className="text-muted-foreground">Acesso rápido:</span>
              <button
                className="text-primary hover:underline"
                onClick={() => handleNavigate('index')}
              >
                Início
              </button>
              <span className="text-muted-foreground">•</span>
              <button
                className="text-primary hover:underline"
                onClick={() => handleNavigate('troubleshooting')}
              >
                Solução de Problemas
              </button>
              <span className="text-muted-foreground">•</span>
              <button
                className="text-primary hover:underline"
                onClick={() => handleNavigate('macros')}
              >
                Macros
              </button>
              <span className="text-muted-foreground">•</span>
              <button
                className="text-primary hover:underline"
                onClick={() => handleNavigate('relay-simulator')}
              >
                Simulador
              </button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </>
  );
};

export default HelpButton;