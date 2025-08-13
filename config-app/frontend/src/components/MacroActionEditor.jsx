import React, { useState, useEffect } from 'react';
import {
  Plus,
  Trash2,
  MoveUp,
  MoveDown,
  Zap,
  Clock,
  RefreshCw,
  Save,
  RotateCcw,
  Send,
  Layers,
  Copy
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from '@/components/ui/dialog';
import { Checkbox } from '@/components/ui/checkbox';
import api from '@/lib/api';

const MacroActionEditor = ({ actions = [], onChange }) => {
  const [showAddDialog, setShowAddDialog] = useState(false);
  const [editingIndex, setEditingIndex] = useState(null);
  const [currentAction, setCurrentAction] = useState({
    type: 'relay',
    board_id: null,
    target: 1,
    action: 'on'
  });
  const [relayBoards, setRelayBoards] = useState([]);
  const [selectedChannels, setSelectedChannels] = useState([]);
  const [boardChannels, setBoardChannels] = useState([]);
  const [loadingChannels, setLoadingChannels] = useState(false);

  // Carregar placas de relé disponíveis
  useEffect(() => {
    loadRelayBoards();
  }, []);

  // Carregar canais quando mudar a placa para qualquer tipo de ação que use board_id
  useEffect(() => {
    if (currentAction.board_id && 
        (currentAction.type === 'relay' || 
         currentAction.type === 'save_state' || 
         currentAction.type === 'restore_state')) {
      loadBoardChannels(currentAction.board_id);
    }
  }, [currentAction.board_id, currentAction.type]);

  const loadRelayBoards = async () => {
    try {
      const boards = await api.getSimulatorBoards();
      setRelayBoards(boards);
      // Se não houver board_id selecionado, selecionar o primeiro
      if (!currentAction.board_id && boards.length > 0) {
        setCurrentAction(prev => ({ ...prev, board_id: boards[0].board_id }));
      }
    } catch (error) {
      console.error('Erro carregando placas:', error);
    }
  };

  const loadBoardChannels = async (boardId) => {
    try {
      setLoadingChannels(true);
      const channels = await api.getBoardChannelsWithState(boardId);
      console.log('Canais carregados:', channels); // Debug
      setBoardChannels(channels);
    } catch (error) {
      console.error('Erro carregando canais:', error);
      setBoardChannels([]);
    } finally {
      setLoadingChannels(false);
    }
  };

  // Tipos de ação disponíveis
  const actionTypes = [
    { value: 'relay', label: 'Controle de Relé', icon: Zap },
    { value: 'delay', label: 'Aguardar (Delay)', icon: Clock },
    { value: 'loop', label: 'Loop (Repetir)', icon: RefreshCw },
    { value: 'save_state', label: 'Salvar Estado', icon: Save },
    { value: 'restore_state', label: 'Restaurar Estado', icon: RotateCcw },
    { value: 'mqtt', label: 'Mensagem MQTT', icon: Send },
    { value: 'parallel', label: 'Ações Paralelas', icon: Layers }
  ];

  // Adicionar ou editar ação
  const handleSaveAction = () => {
    const newActions = [...actions];
    
    // Formatar ação baseado no tipo
    let formattedAction = { ...currentAction };
    
    // Converter valores conforme o tipo
    if (currentAction.type === 'relay') {
      // Incluir board_id
      formattedAction.board_id = currentAction.board_id;
      
      // Usar canais selecionados se disponível, senão usar target
      if (selectedChannels.length > 0) {
        formattedAction.target = selectedChannels.length === 1 ? selectedChannels[0] : selectedChannels;
      } else if (currentAction.target && currentAction.target.includes(',')) {
        formattedAction.target = currentAction.target.split(',').map(t => parseInt(t.trim()));
      } else {
        formattedAction.target = parseInt(currentAction.target);
      }
    } else if (currentAction.type === 'delay') {
      formattedAction.ms = parseInt(currentAction.ms || 1000);
      delete formattedAction.target;
      delete formattedAction.action;
    } else if (currentAction.type === 'loop') {
      formattedAction.count = parseInt(currentAction.count || 1);
      formattedAction.actions = currentAction.actions || [];
      delete formattedAction.target;
      delete formattedAction.action;
    } else if (currentAction.type === 'save_state' || currentAction.type === 'restore_state') {
      // Incluir board_id
      formattedAction.board_id = currentAction.board_id;
      
      // Usar canais selecionados ou o campo targets se digitado manualmente
      if (selectedChannels.length > 0) {
        formattedAction.targets = selectedChannels;
      } else if (currentAction.targets) {
        formattedAction.targets = currentAction.targets.split(',').map(t => parseInt(t.trim()));
      }
      delete formattedAction.target;
      delete formattedAction.action;
    } else if (currentAction.type === 'mqtt') {
      formattedAction.topic = currentAction.topic || 'autocore/gateway/macros/execute';
      formattedAction.payload = currentAction.payload || {};
      delete formattedAction.target;
      delete formattedAction.action;
    }
    
    if (editingIndex !== null) {
      newActions[editingIndex] = formattedAction;
    } else {
      newActions.push(formattedAction);
    }
    
    onChange(newActions);
    setShowAddDialog(false);
    setEditingIndex(null);
    setCurrentAction({ type: 'relay', target: 1, action: 'on' });
  };

  // Remover ação
  const removeAction = (index) => {
    const newActions = actions.filter((_, i) => i !== index);
    onChange(newActions);
  };

  // Mover ação para cima
  const moveUp = (index) => {
    if (index === 0) return;
    const newActions = [...actions];
    [newActions[index - 1], newActions[index]] = [newActions[index], newActions[index - 1]];
    onChange(newActions);
  };

  // Mover ação para baixo
  const moveDown = (index) => {
    if (index === actions.length - 1) return;
    const newActions = [...actions];
    [newActions[index], newActions[index + 1]] = [newActions[index + 1], newActions[index]];
    onChange(newActions);
  };

  // Editar ação existente
  const editAction = (index) => {
    const action = actions[index];
    setCurrentAction(action);
    setEditingIndex(index);
    
    // Se for ação de relé ou save/restore state, configurar canais selecionados e carregar canais da placa
    if (action.type === 'relay' || action.type === 'save_state' || action.type === 'restore_state') {
      if (action.board_id) {
        loadBoardChannels(action.board_id);
      }
      
      // Para relay, usar target
      if (action.type === 'relay' && action.target) {
        if (Array.isArray(action.target)) {
          setSelectedChannels(action.target);
        } else {
          setSelectedChannels([action.target]);
        }
      }
      // Para save/restore state, usar targets
      else if ((action.type === 'save_state' || action.type === 'restore_state') && action.targets) {
        if (Array.isArray(action.targets)) {
          setSelectedChannels(action.targets);
        } else {
          setSelectedChannels([action.targets]);
        }
      }
    } else {
      setSelectedChannels([]);
    }
    setShowAddDialog(true);
  };

  // Duplicar ação
  const duplicateAction = (index) => {
    const newActions = [...actions];
    newActions.splice(index + 1, 0, { ...actions[index] });
    onChange(newActions);
  };

  // Renderizar ícone da ação
  const getActionIcon = (type) => {
    const actionType = actionTypes.find(t => t.value === type);
    const Icon = actionType?.icon || Zap;
    return <Icon className="h-4 w-4" />;
  };

  // Descrição da ação
  const getActionDescription = (action) => {
    switch (action.type) {
      case 'relay':
        const targets = Array.isArray(action.target) ? action.target.join(', ') : action.target;
        const boardInfo = action.board_id ? `Placa ${action.board_id} - ` : '';
        const actionText = action.action === 'on' ? 'Ligar' : action.action === 'off' ? 'Desligar' : 'Alternar';
        const labelText = action.label ? ` (${action.label})` : '';
        return `${boardInfo}CH ${targets} → ${actionText}${labelText}`;
      case 'delay':
        return `Aguardar ${action.ms}ms`;
      case 'loop':
        return `Repetir ${action.count === -1 ? '∞' : action.count}x (${action.actions?.length || 0} ações)`;
      case 'save_state':
        const saveBoardInfo = action.board_id ? `Placa ${action.board_id} - ` : '';
        return action.targets ? 
          `${saveBoardInfo}Salvar estado dos canais ${Array.isArray(action.targets) ? action.targets.join(', ') : action.targets}` : 
          `${saveBoardInfo}Salvar estado de todos os canais`;
      case 'restore_state':
        const restoreBoardInfo = action.board_id ? `Placa ${action.board_id} - ` : '';
        return action.targets ? 
          `${restoreBoardInfo}Restaurar estado dos canais ${Array.isArray(action.targets) ? action.targets.join(', ') : action.targets}` : 
          `${restoreBoardInfo}Restaurar estado de todos os canais`;
      case 'mqtt':
        return `MQTT: ${action.topic}`;
      case 'parallel':
        return `Executar ${action.actions?.length || 0} ações em paralelo`;
      default:
        return action.type;
    }
  };

  return (
    <div className="space-y-4">
      {/* Lista de ações */}
      <div className="space-y-2">
        {actions.length === 0 ? (
          <Card className="p-8 text-center text-muted-foreground">
            <p className="text-lg mb-2">📝 Nenhuma ação configurada</p>
            <p className="text-sm">Clique em "Adicionar Ação" para começar</p>
            <div className="mt-4 text-left max-w-md mx-auto space-y-2">
              <p className="text-xs font-semibold">Tipos de ação disponíveis:</p>
              <ul className="text-xs space-y-1">
                <li>⚡ <strong>Relé</strong> - Liga/desliga relés</li>
                <li>⏱️ <strong>Delay</strong> - Aguarda um tempo</li>
                <li>🔄 <strong>Loop</strong> - Repete ações</li>
                <li>💾 <strong>Salvar Estado</strong> - Guarda estado atual</li>
                <li>↩️ <strong>Restaurar</strong> - Volta ao estado salvo</li>
              </ul>
            </div>
          </Card>
        ) : (
          actions.map((action, index) => (
            <Card key={index} className="p-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="text-muted-foreground">
                    {index + 1}.
                  </div>
                  {getActionIcon(action.type)}
                  <div>
                    <div className="font-medium">{getActionDescription(action)}</div>
                    {action.label && (
                      <div className="text-sm text-muted-foreground">{action.label}</div>
                    )}
                  </div>
                </div>
                
                <div className="flex items-center gap-1">
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => moveUp(index)}
                    disabled={index === 0}
                  >
                    <MoveUp className="h-4 w-4" />
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => moveDown(index)}
                    disabled={index === actions.length - 1}
                  >
                    <MoveDown className="h-4 w-4" />
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => duplicateAction(index)}
                  >
                    <Copy className="h-4 w-4" />
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => editAction(index)}
                  >
                    <Badge variant="outline">Editar</Badge>
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => removeAction(index)}
                  >
                    <Trash2 className="h-4 w-4 text-destructive" />
                  </Button>
                </div>
              </div>
            </Card>
          ))
        )}
      </div>

      {/* Botão adicionar */}
      <Button
        onClick={() => {
          const defaultBoardId = relayBoards[0]?.board_id || null;
          setCurrentAction({ type: 'relay', board_id: defaultBoardId, target: 1, action: 'on' });
          setSelectedChannels([]);
          setEditingIndex(null);
          // Carregar canais da primeira placa se existir
          if (defaultBoardId) {
            loadBoardChannels(defaultBoardId);
          }
          setShowAddDialog(true);
        }}
        className="w-full"
      >
        <Plus className="mr-2 h-4 w-4" />
        Adicionar Ação
      </Button>

      {/* Dialog de adicionar/editar ação */}
      <Dialog open={showAddDialog} onOpenChange={setShowAddDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {editingIndex !== null ? 'Editar Ação' : 'Adicionar Nova Ação'}
            </DialogTitle>
            <DialogDescription>
              Configure os parâmetros da ação
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4 py-4">
            {/* Tipo de ação */}
            <div className="space-y-2">
              <Label>Tipo de Ação</Label>
              <Select
                value={currentAction.type}
                onValueChange={(value) => {
                  const newAction = { ...currentAction, type: value };
                  // Se mudar para save_state ou restore_state, adicionar board_id default
                  if ((value === 'save_state' || value === 'restore_state') && !newAction.board_id) {
                    newAction.board_id = relayBoards[0]?.board_id || null;
                  }
                  setCurrentAction(newAction);
                }}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {actionTypes.map(type => (
                    <SelectItem key={type.value} value={type.value}>
                      <div className="flex items-center gap-2">
                        {React.createElement(type.icon, { className: "h-4 w-4" })}
                        {type.label}
                      </div>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* Campos específicos por tipo */}
            {currentAction.type === 'relay' && (
              <>
                <div className="space-y-2">
                  <Label>Placa de Relé</Label>
                  <Select
                    value={currentAction.board_id?.toString()}
                    onValueChange={(value) => {
                      setCurrentAction({ ...currentAction, board_id: parseInt(value) });
                      setSelectedChannels([]); // Limpar seleção ao trocar de placa
                    }}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Selecione a placa" />
                    </SelectTrigger>
                    <SelectContent>
                      {relayBoards.map(board => (
                        <SelectItem key={board.board_id} value={board.board_id.toString()}>
                          Placa {board.board_id} - {board.device_uuid}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-2">
                  <Label>Canais de Relé</Label>
                  {loadingChannels ? (
                    <div className="p-4 text-center text-muted-foreground">
                      Carregando canais...
                    </div>
                  ) : boardChannels.length > 0 ? (
                    <div className="grid grid-cols-2 gap-2 p-3 border rounded-lg max-h-64 overflow-y-auto">
                      {boardChannels
                        .filter(channel => channel.function_type !== 'momentary' && channel.allow_in_macro !== false) // Filtrar momentâneos e canais não permitidos em macros
                        .map((channel) => {
                          const isSelected = selectedChannels.includes(channel.channel_number);
                          return (
                            <div key={channel.channel_number} className="flex items-center space-x-2 p-1">
                              <Checkbox
                                id={`ch-${channel.channel_number}`}
                                checked={isSelected}
                                onCheckedChange={(checked) => {
                                  if (checked) {
                                    setSelectedChannels([...selectedChannels, channel.channel_number]);
                                  } else {
                                    setSelectedChannels(selectedChannels.filter(c => c !== channel.channel_number));
                                  }
                                }}
                              />
                              <Label
                                htmlFor={`ch-${channel.channel_number}`}
                                className="text-sm font-normal cursor-pointer flex-1"
                              >
                                <span className="font-medium">CH{channel.channel_number}</span>
                                {channel.name && (
                                  <span className="text-muted-foreground ml-1">- {channel.name}</span>
                                )}
                                {channel.function_type === 'pulse' && (
                                  <Badge variant="outline" className="ml-1 text-xs">Pulso</Badge>
                                )}
                              </Label>
                            </div>
                          );
                        })}
                    </div>
                  ) : (
                    <div className="p-4 text-center text-muted-foreground">
                      Selecione uma placa para ver os canais disponíveis
                    </div>
                  )}
                  <p className="text-xs text-muted-foreground">
                    Selecione um ou mais canais para controlar. Alguns canais podem estar desabilitados para uso em macros.
                  </p>
                </div>
                
                <div className="space-y-2">
                  <Label>Ação</Label>
                  <Select
                    value={currentAction.action}
                    onValueChange={(value) => setCurrentAction({ ...currentAction, action: value })}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="on">Ligar</SelectItem>
                      <SelectItem value="off">Desligar</SelectItem>
                      <SelectItem value="toggle">Alternar</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                
                <div className="space-y-2">
                  <Label>Descrição (opcional)</Label>
                  <Input
                    value={currentAction.label || ''}
                    onChange={(e) => setCurrentAction({ ...currentAction, label: e.target.value })}
                    placeholder="Ex: Faróis, Sirene, etc"
                  />
                  <p className="text-xs text-muted-foreground">
                    Use para identificar facilmente a ação na sequência
                  </p>
                </div>
              </>
            )}

            {currentAction.type === 'delay' && (
              <div className="space-y-2">
                <Label>Tempo de Espera (ms)</Label>
                <Input
                  type="number"
                  value={currentAction.ms || 1000}
                  onChange={(e) => setCurrentAction({ ...currentAction, ms: e.target.value })}
                  placeholder="1000"
                />
                <p className="text-xs text-muted-foreground">
                  1000ms = 1 segundo
                </p>
              </div>
            )}

            {currentAction.type === 'loop' && (
              <>
                <div className="space-y-2">
                  <Label>Número de Repetições</Label>
                  <Input
                    type="number"
                    value={currentAction.count || 1}
                    onChange={(e) => setCurrentAction({ ...currentAction, count: e.target.value })}
                    placeholder="3"
                  />
                  <p className="text-xs text-muted-foreground">
                    Use -1 para loop infinito
                  </p>
                </div>
                <div className="p-3 bg-muted rounded">
                  <p className="text-sm text-muted-foreground">
                    ⚠️ As ações dentro do loop devem ser configuradas após salvar
                  </p>
                </div>
              </>
            )}

            {(currentAction.type === 'save_state' || currentAction.type === 'restore_state') && (
              <>
                <div className="space-y-2">
                  <Label>Placa de Relé</Label>
                  <Select
                    value={currentAction.board_id?.toString()}
                    onValueChange={(value) => {
                      setCurrentAction({ ...currentAction, board_id: parseInt(value) });
                      setSelectedChannels([]); // Limpar seleção ao trocar de placa
                    }}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Selecione a placa" />
                    </SelectTrigger>
                    <SelectContent>
                      {relayBoards.map(board => (
                        <SelectItem key={board.board_id} value={board.board_id.toString()}>
                          Placa {board.board_id} - {board.device_uuid}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-2">
                  <Label>Canais para {currentAction.type === 'save_state' ? 'Salvar' : 'Restaurar'}</Label>
                  {loadingChannels ? (
                    <div className="p-4 text-center text-muted-foreground">
                      Carregando canais...
                    </div>
                  ) : boardChannels.length > 0 ? (
                    <div className="grid grid-cols-2 gap-2 p-3 border rounded-lg max-h-64 overflow-y-auto">
                      {boardChannels
                        .filter(channel => channel.function_type !== 'momentary' && channel.allow_in_macro !== false)
                        .map((channel) => {
                          const isSelected = selectedChannels.includes(channel.channel_number);
                          return (
                            <div key={channel.channel_number} className="flex items-center space-x-2 p-1">
                              <Checkbox
                                id={`state-ch-${channel.channel_number}`}
                                checked={isSelected}
                                onCheckedChange={(checked) => {
                                  if (checked) {
                                    setSelectedChannels([...selectedChannels, channel.channel_number]);
                                  } else {
                                    setSelectedChannels(selectedChannels.filter(c => c !== channel.channel_number));
                                  }
                                }}
                              />
                              <Label
                                htmlFor={`state-ch-${channel.channel_number}`}
                                className="text-sm font-normal cursor-pointer flex-1"
                              >
                                <span className="font-medium">CH{channel.channel_number}</span>
                                {channel.name && (
                                  <span className="text-muted-foreground ml-1">- {channel.name}</span>
                                )}
                              </Label>
                            </div>
                          );
                        })}
                    </div>
                  ) : (
                    <div className="p-4 text-center text-muted-foreground">
                      Selecione uma placa para ver os canais disponíveis
                    </div>
                  )}
                  <p className="text-xs text-muted-foreground">
                    Selecione os canais que deseja {currentAction.type === 'save_state' ? 'salvar o estado' : 'restaurar o estado'}. 
                    Deixe vazio para aplicar a todos os canais.
                  </p>
                </div>
              </>
            )}

            {currentAction.type === 'mqtt' && (
              <>
                <div className="space-y-2">
                  <Label>Tópico MQTT</Label>
                  <Input
                    value={currentAction.topic || ''}
                    onChange={(e) => setCurrentAction({ ...currentAction, topic: e.target.value })}
                    placeholder="autocore/gateway/macros/execute"
                  />
                </div>
                <div className="space-y-2">
                  <Label>Mensagem (JSON)</Label>
                  <Input
                    value={currentAction.message || ''}
                    onChange={(e) => setCurrentAction({ ...currentAction, message: e.target.value })}
                    placeholder='{"status": "active"}'
                  />
                </div>
              </>
            )}
          </div>

          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setShowAddDialog(false)}>
              Cancelar
            </Button>
            <Button onClick={handleSaveAction}>
              {editingIndex !== null ? 'Salvar' : 'Adicionar'}
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default MacroActionEditor;