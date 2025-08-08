import React, { useState, useEffect } from 'react';
import { 
  Play, 
  Square, 
  Plus, 
  Edit, 
  Trash2, 
  Zap,
  Heart,
  Save,
  RefreshCw,
  Clock,
  Activity,
  AlertTriangle,
  Sparkles,
  Mountain,
  Power,
  ParkingCircle,
  HelpCircle
} from 'lucide-react';
import MacroActionEditor from '@/components/MacroActionEditor';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Switch } from '@/components/ui/switch';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { toast } from '@/hooks/use-toast';
import api from '@/lib/api';
import HelpButtonSimple from '@/components/HelpButtonSimple';

const MacrosPage = () => {
  const [macros, setMacros] = useState([]);
  const [runningMacros, setRunningMacros] = useState({});
  const [loading, setLoading] = useState(true);
  const [selectedMacro, setSelectedMacro] = useState(null);
  const [showDetails, setShowDetails] = useState(false);
  const [showCreate, setShowCreate] = useState(false);
  const [showEdit, setShowEdit] = useState(false);
  const [editingMacro, setEditingMacro] = useState(null);
  const [templates, setTemplates] = useState([]);
  const [newMacro, setNewMacro] = useState(null);

  // Ícones por nome de macro
  const macroIcons = {
    'Show de Luz': Sparkles,
    'Emergência': AlertTriangle,
    'Modo Trilha': Mountain,
    'Desligar Tudo': Power,
    'Modo Estacionamento': ParkingCircle
  };

  // Cores por tipo
  const macroColors = {
    'Show de Luz': 'bg-purple-500',
    'Emergência': 'bg-red-500',
    'Modo Trilha': 'bg-green-500',
    'Desligar Tudo': 'bg-gray-500',
    'Modo Estacionamento': 'bg-blue-500'
  };

  useEffect(() => {
    loadMacros();
    loadTemplates();
  }, []);

  const loadMacros = async () => {
    try {
      setLoading(true);
      const data = await api.getMacros();
      setMacros(data);
    } catch (error) {
      console.error('Erro carregando macros:', error);
      toast({
        title: 'Erro',
        description: 'Não foi possível carregar as macros',
        variant: 'destructive'
      });
    } finally {
      setLoading(false);
    }
  };

  const loadTemplates = async () => {
    try {
      const data = await api.getMacroTemplates();
      setTemplates(data);
    } catch (error) {
      console.error('Erro carregando templates:', error);
    }
  };

  const loadMacroDetails = async (macroId) => {
    try {
      const data = await api.getMacro(macroId);
      setSelectedMacro(data);
      setShowDetails(true);
    } catch (error) {
      console.error('Erro carregando detalhes:', error);
      toast({
        title: 'Erro',
        description: 'Não foi possível carregar os detalhes da macro',
        variant: 'destructive'
      });
    }
  };

  const executeMacro = async (macroId, macroName) => {
    try {
      // Marcar como executando
      setRunningMacros(prev => ({ ...prev, [macroId]: true }));
      
      const response = await api.executeMacro(macroId);
      
      toast({
        title: 'Macro Executada',
        description: `${macroName} foi iniciada com sucesso`,
      });
      
      // Simular duração (em produção viria do WebSocket)
      setTimeout(() => {
        setRunningMacros(prev => {
          const newState = { ...prev };
          delete newState[macroId];
          return newState;
        });
        
        toast({
          title: 'Macro Concluída',
          description: `${macroName} foi executada com sucesso`,
        });
      }, 5000);
      
      // Recarregar para atualizar contadores
      loadMacros();
    } catch (error) {
      console.error('Erro executando macro:', error);
      setRunningMacros(prev => {
        const newState = { ...prev };
        delete newState[macroId];
        return newState;
      });
      
      toast({
        title: 'Erro',
        description: 'Não foi possível executar a macro',
        variant: 'destructive'
      });
    }
  };

  const stopMacro = async (macroId, macroName) => {
    try {
      await api.stopMacro(macroId);
      
      setRunningMacros(prev => {
        const newState = { ...prev };
        delete newState[macroId];
        return newState;
      });
      
      toast({
        title: 'Macro Parada',
        description: `${macroName} foi interrompida`,
      });
    } catch (error) {
      console.error('Erro parando macro:', error);
      toast({
        title: 'Erro',
        description: 'Não foi possível parar a macro',
        variant: 'destructive'
      });
    }
  };

  const deleteMacro = async (macroId) => {
    if (!confirm('Tem certeza que deseja remover esta macro?')) return;
    
    try {
      await api.deleteMacro(macroId);
      toast({
        title: 'Sucesso',
        description: 'Macro removida com sucesso',
      });
      loadMacros();
    } catch (error) {
      console.error('Erro removendo macro:', error);
      toast({
        title: 'Erro',
        description: 'Não foi possível remover a macro',
        variant: 'destructive'
      });
    }
  };

  const createFromTemplate = async (templateId) => {
    try {
      // Buscar template selecionado
      const template = templates.find(t => t.id === templateId);
      if (!template) return;
      
      // Preparar nova macro baseada no template
      setNewMacro({
        name: template.name,
        description: template.description,
        trigger_type: 'manual',
        action_sequence: template.action_sequence,
        preserve_state: template.preserve_state || false,
        requires_heartbeat: template.requires_heartbeat || false
      });
      
      setShowCreate(false);
      setShowEdit(true);
    } catch (error) {
      console.error('Erro preparando macro:', error);
      toast({
        title: 'Erro',
        description: 'Não foi possível preparar a macro',
        variant: 'destructive'
      });
    }
  };
  
  const createNewMacro = async () => {
    if (!newMacro) return;
    
    try {
      await api.createMacro({
        name: newMacro.name,
        description: newMacro.description,
        trigger_type: newMacro.trigger_type || 'manual',
        action_sequence: newMacro.action_sequence,
        preserve_state: newMacro.preserve_state,
        requires_heartbeat: newMacro.requires_heartbeat
      });
      
      toast({
        title: 'Sucesso',
        description: 'Macro criada com sucesso',
      });
      
      setNewMacro(null);
      setShowEdit(false);
      loadMacros();
    } catch (error) {
      console.error('Erro criando macro:', error);
      toast({
        title: 'Erro',
        description: 'Não foi possível criar a macro',
        variant: 'destructive'
      });
    }
  };

  const openEditDialog = async (macroId) => {
    try {
      const data = await api.getMacro(macroId);
      setEditingMacro(data);
      setShowEdit(true);
    } catch (error) {
      console.error('Erro carregando macro para edição:', error);
      toast({
        title: 'Erro',
        description: 'Não foi possível carregar a macro para edição',
        variant: 'destructive'
      });
    }
  };

  const saveMacroChanges = async () => {
    // Se for nova macro, criar ao invés de atualizar
    if (newMacro) {
      return createNewMacro();
    }
    
    if (!editingMacro) return;
    
    try {
      await api.updateMacro(editingMacro.id, {
        name: editingMacro.name,
        description: editingMacro.description,
        is_active: editingMacro.is_active,
        action_sequence: editingMacro.action_sequence,
        preserve_state: editingMacro.trigger_config?.preserve_state,
        requires_heartbeat: editingMacro.trigger_config?.requires_heartbeat
      });
      
      toast({
        title: 'Sucesso',
        description: 'Macro atualizada com sucesso',
      });
      
      setShowEdit(false);
      setEditingMacro(null);
      loadMacros();
    } catch (error) {
      console.error('Erro salvando macro:', error);
      toast({
        title: 'Erro',
        description: 'Não foi possível salvar as alterações',
        variant: 'destructive'
      });
    }
  };

  const renderActionSequence = (actions) => {
    if (!actions || !Array.isArray(actions)) return null;
    
    return (
      <div className="space-y-2">
        {actions.map((action, index) => (
          <div key={index} className="flex items-center gap-2 text-sm">
            <Badge variant="outline" className="w-20">
              {action.type}
            </Badge>
            <span className="text-muted-foreground">
              {action.label || action.target || action.message || action.topic || ''}
            </span>
            {action.ms && (
              <Badge variant="secondary">{action.ms}ms</Badge>
            )}
            {action.count && (
              <Badge variant="secondary">
                {action.count === -1 ? '∞' : `${action.count}x`}
              </Badge>
            )}
          </div>
        ))}
      </div>
    );
  };

  return (
    <div className="container mx-auto p-6 max-w-7xl">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-3xl font-bold">Macros e Automações</h1>
          <p className="text-muted-foreground">
            Sequências de ações programáveis para o sistema
          </p>
        </div>
        
        <div className="flex items-center gap-2">
          <Button 
            variant="outline"
            size="sm"
            onClick={() => alert('Ajuda - Macros e Automações\n\n• Crie sequências de comandos automatizadas\n• Use delays para temporização\n• Salve e restaure estados\n• Canais momentâneos não podem ser usados\n• Teste sempre antes de usar em produção')}
            className="gap-2"
          >
            <HelpCircle className="h-4 w-4" />
            Ajuda
          </Button>
          
          <Dialog open={showCreate} onOpenChange={setShowCreate}>
          <DialogTrigger asChild>
            <Button>
              <Plus className="mr-2 h-4 w-4" />
              Nova Macro
            </Button>
          </DialogTrigger>
          <DialogContent className="max-w-2xl">
            <DialogHeader>
              <DialogTitle>Criar Nova Macro</DialogTitle>
              <DialogDescription>
                Escolha um template para começar
              </DialogDescription>
            </DialogHeader>
            
            <div className="grid gap-4">
              {/* Opção de criar macro vazia */}
              <Card 
                className="cursor-pointer hover:border-primary border-dashed"
                onClick={() => {
                  setNewMacro({
                    name: 'Nova Macro',
                    description: 'Descrição da macro',
                    trigger_type: 'manual',
                    action_sequence: [],
                    preserve_state: false,
                    requires_heartbeat: false
                  });
                  setShowCreate(false);
                  setShowEdit(true);
                }}
              >
                <CardHeader className="pb-3">
                  <div className="flex items-center gap-2">
                    <Plus className="h-5 w-5" />
                    <CardTitle className="text-lg">Macro Vazia</CardTitle>
                  </div>
                  <CardDescription>Criar uma macro do zero</CardDescription>
                </CardHeader>
              </Card>
              
              {/* Templates */}
              {templates.map(template => (
                <Card 
                  key={template.id} 
                  className="cursor-pointer hover:border-primary"
                  onClick={() => createFromTemplate(template.id)}
                >
                  <CardHeader className="pb-3">
                    <div className="flex justify-between items-start">
                      <CardTitle className="text-lg">{template.name}</CardTitle>
                      <Badge>{template.category}</Badge>
                    </div>
                    <CardDescription>{template.description}</CardDescription>
                  </CardHeader>
                </Card>
              ))}
            </div>
          </DialogContent>
        </Dialog>
        </div>
      </div>

      {/* Estatísticas */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">Total de Macros</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{macros.length}</div>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">Em Execução</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-500">
              {Object.keys(runningMacros).length}
            </div>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">Com Heartbeat</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-orange-500">
              {macros.filter(m => m.trigger_config?.requires_heartbeat).length}
            </div>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">Total Execuções</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {macros.reduce((acc, m) => acc + (m.execution_count || 0), 0)}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Grid de Macros */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {macros.map(macro => {
          const Icon = macroIcons[macro.name] || Zap;
          const isRunning = runningMacros[macro.id];
          const colorClass = macroColors[macro.name] || 'bg-primary';
          
          return (
            <Card key={macro.id} className={isRunning ? 'border-green-500' : ''}>
              <CardHeader>
                <div className="flex justify-between items-start">
                  <div className={`p-3 rounded-lg ${colorClass} text-white`}>
                    <Icon className="h-6 w-6" />
                  </div>
                  <div className="flex gap-1">
                    {macro.trigger_config?.requires_heartbeat && (
                      <Badge variant="outline" className="text-orange-500">
                        <Heart className="h-3 w-3 mr-1" />
                        Heartbeat
                      </Badge>
                    )}
                    {macro.trigger_config?.preserve_state && (
                      <Badge variant="outline" className="text-blue-500">
                        <Save className="h-3 w-3 mr-1" />
                        Estado
                      </Badge>
                    )}
                  </div>
                </div>
                
                <CardTitle className="mt-4">{macro.name}</CardTitle>
                <CardDescription>{macro.description}</CardDescription>
              </CardHeader>
              
              <CardContent>
                <div className="space-y-4">
                  {/* Estatísticas */}
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">Execuções:</span>
                    <span className="font-medium">{macro.execution_count || 0}</span>
                  </div>
                  
                  {macro.last_executed && (
                    <div className="flex justify-between text-sm">
                      <span className="text-muted-foreground">Última execução:</span>
                      <span className="font-medium">
                        {new Date(macro.last_executed).toLocaleString('pt-BR')}
                      </span>
                    </div>
                  )}
                  
                  {/* Ações */}
                  <div className="flex gap-2">
                    {isRunning ? (
                      <Button 
                        className="flex-1" 
                        variant="destructive"
                        onClick={() => stopMacro(macro.id, macro.name)}
                      >
                        <Square className="mr-2 h-4 w-4" />
                        Parar
                      </Button>
                    ) : (
                      <Button 
                        className="flex-1" 
                        variant="default"
                        onClick={() => executeMacro(macro.id, macro.name)}
                      >
                        <Play className="mr-2 h-4 w-4" />
                        Executar
                      </Button>
                    )}
                    
                    <Button 
                      variant="outline" 
                      size="icon"
                      onClick={() => loadMacroDetails(macro.id)}
                    >
                      <Activity className="h-4 w-4" />
                    </Button>
                    
                    <Button 
                      variant="outline" 
                      size="icon"
                      onClick={() => openEditDialog(macro.id)}
                    >
                      <Edit className="h-4 w-4" />
                    </Button>
                    
                    <Button 
                      variant="outline" 
                      size="icon"
                      onClick={() => deleteMacro(macro.id)}
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
                </div>
                
                {isRunning && (
                  <Alert className="mt-4">
                    <RefreshCw className="h-4 w-4 animate-spin" />
                    <AlertDescription>
                      Macro em execução...
                    </AlertDescription>
                  </Alert>
                )}
              </CardContent>
            </Card>
          );
        })}
      </div>

      {/* Dialog de Detalhes */}
      <Dialog open={showDetails} onOpenChange={setShowDetails}>
        <DialogContent className="max-w-3xl max-h-[80vh] overflow-y-auto">
          {selectedMacro && (
            <>
              <DialogHeader>
                <DialogTitle>{selectedMacro.name}</DialogTitle>
                <DialogDescription>{selectedMacro.description}</DialogDescription>
              </DialogHeader>
              
              <Tabs defaultValue="sequence" className="mt-4">
                <TabsList className="grid w-full grid-cols-3">
                  <TabsTrigger value="sequence">Sequência</TabsTrigger>
                  <TabsTrigger value="config">Configuração</TabsTrigger>
                  <TabsTrigger value="stats">Estatísticas</TabsTrigger>
                </TabsList>
                
                <TabsContent value="sequence" className="space-y-4">
                  <Card>
                    <CardHeader>
                      <CardTitle className="text-sm">Sequência de Ações</CardTitle>
                    </CardHeader>
                    <CardContent>
                      {renderActionSequence(selectedMacro.action_sequence)}
                    </CardContent>
                  </Card>
                </TabsContent>
                
                <TabsContent value="config" className="space-y-4">
                  <Card>
                    <CardHeader>
                      <CardTitle className="text-sm">Configurações</CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-2">
                      <div className="flex justify-between">
                        <span>Tipo de Trigger:</span>
                        <Badge>{selectedMacro.trigger_type}</Badge>
                      </div>
                      <div className="flex justify-between">
                        <span>Preserva Estado:</span>
                        <Badge variant={selectedMacro.trigger_config?.preserve_state ? 'default' : 'outline'}>
                          {selectedMacro.trigger_config?.preserve_state ? 'Sim' : 'Não'}
                        </Badge>
                      </div>
                      <div className="flex justify-between">
                        <span>Requer Heartbeat:</span>
                        <Badge variant={selectedMacro.trigger_config?.requires_heartbeat ? 'destructive' : 'outline'}>
                          {selectedMacro.trigger_config?.requires_heartbeat ? 'Sim' : 'Não'}
                        </Badge>
                      </div>
                      {selectedMacro.trigger_config?.total_duration_ms && (
                        <div className="flex justify-between">
                          <span>Duração Total:</span>
                          <Badge variant="secondary">
                            {(selectedMacro.trigger_config.total_duration_ms / 1000).toFixed(1)}s
                          </Badge>
                        </div>
                      )}
                    </CardContent>
                  </Card>
                </TabsContent>
                
                <TabsContent value="stats" className="space-y-4">
                  <Card>
                    <CardHeader>
                      <CardTitle className="text-sm">Estatísticas de Uso</CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-2">
                      <div className="flex justify-between">
                        <span>Total de Execuções:</span>
                        <span className="font-bold">{selectedMacro.execution_count || 0}</span>
                      </div>
                      <div className="flex justify-between">
                        <span>Última Execução:</span>
                        <span className="font-bold">
                          {selectedMacro.last_executed 
                            ? new Date(selectedMacro.last_executed).toLocaleString('pt-BR')
                            : 'Nunca'}
                        </span>
                      </div>
                      <div className="flex justify-between">
                        <span>Criada em:</span>
                        <span className="font-bold">
                          {new Date(selectedMacro.created_at).toLocaleString('pt-BR')}
                        </span>
                      </div>
                      <div className="flex justify-between">
                        <span>Status:</span>
                        <Badge variant={selectedMacro.is_active ? 'default' : 'secondary'}>
                          {selectedMacro.is_active ? 'Ativa' : 'Inativa'}
                        </Badge>
                      </div>
                    </CardContent>
                  </Card>
                </TabsContent>
              </Tabs>
            </>
          )}
        </DialogContent>
      </Dialog>

      {/* Dialog de Edição/Criação */}
      <Dialog open={showEdit} onOpenChange={(open) => {
        setShowEdit(open);
        if (!open) {
          setEditingMacro(null);
          setNewMacro(null);
        }
      }}>
        <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{newMacro ? 'Criar Nova Macro' : 'Editar Macro'}</DialogTitle>
            <DialogDescription>
              {newMacro ? 'Configure a nova macro baseada no template' : 'Edite as propriedades da macro'}
            </DialogDescription>
          </DialogHeader>
          
          {(editingMacro || newMacro) && (
            <div className="space-y-4 py-4">
              <div className="space-y-2">
                <Label htmlFor="edit-name">Nome</Label>
                <Input
                  id="edit-name"
                  value={(editingMacro || newMacro).name}
                  onChange={(e) => {
                    if (newMacro) {
                      setNewMacro({...newMacro, name: e.target.value});
                    } else {
                      setEditingMacro({...editingMacro, name: e.target.value});
                    }
                  }}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="edit-description">Descrição</Label>
                <Textarea
                  id="edit-description"
                  value={(editingMacro || newMacro).description || ''}
                  onChange={(e) => {
                    if (newMacro) {
                      setNewMacro({...newMacro, description: e.target.value});
                    } else {
                      setEditingMacro({...editingMacro, description: e.target.value});
                    }
                  }}
                  rows={3}
                />
              </div>
              
              {editingMacro && (
                <div className="flex items-center justify-between">
                  <Label htmlFor="edit-active">Macro Ativa</Label>
                  <Switch
                    id="edit-active"
                    checked={editingMacro.is_active}
                    onCheckedChange={(checked) => setEditingMacro({...editingMacro, is_active: checked})}
                  />
                </div>
              )}
              
              <div className="flex items-center justify-between">
                <Label htmlFor="edit-preserve">Preservar Estado Anterior</Label>
                <Switch
                  id="edit-preserve"
                  checked={
                    newMacro 
                      ? newMacro.preserve_state || false
                      : editingMacro.trigger_config?.preserve_state || false
                  }
                  onCheckedChange={(checked) => {
                    if (newMacro) {
                      setNewMacro({...newMacro, preserve_state: checked});
                    } else {
                      setEditingMacro({
                        ...editingMacro,
                        trigger_config: {
                          ...editingMacro.trigger_config,
                          preserve_state: checked
                        }
                      });
                    }
                  }}
                />
              </div>
              
              <div className="flex items-center justify-between">
                <Label htmlFor="edit-heartbeat">Requer Heartbeat</Label>
                <Switch
                  id="edit-heartbeat"
                  checked={
                    newMacro 
                      ? newMacro.requires_heartbeat || false
                      : editingMacro.trigger_config?.requires_heartbeat || false
                  }
                  onCheckedChange={(checked) => {
                    if (newMacro) {
                      setNewMacro({...newMacro, requires_heartbeat: checked});
                    } else {
                      setEditingMacro({
                        ...editingMacro,
                        trigger_config: {
                          ...editingMacro.trigger_config,
                          requires_heartbeat: checked
                        }
                      });
                    }
                  }}
                />
              </div>
              
              {/* Editor de Sequência de Ações */}
              <div className="space-y-2">
                <Label>Sequência de Ações</Label>
                <MacroActionEditor
                  actions={(editingMacro || newMacro).action_sequence || []}
                  onChange={(newActions) => {
                    if (newMacro) {
                      setNewMacro({...newMacro, action_sequence: newActions});
                    } else {
                      setEditingMacro({...editingMacro, action_sequence: newActions});
                    }
                  }}
                />
              </div>
              
              <div className="flex justify-end gap-2 pt-4">
                <Button variant="outline" onClick={() => {
                  setShowEdit(false);
                  setEditingMacro(null);
                  setNewMacro(null);
                }}>
                  Cancelar
                </Button>
                <Button onClick={saveMacroChanges}>
                  <Save className="mr-2 h-4 w-4" />
                  {newMacro ? 'Criar Macro' : 'Salvar Alterações'}
                </Button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default MacrosPage;