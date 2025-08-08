import React, { useState, useEffect } from 'react'
import {
  Plus,
  Edit,
  Trash2,
  Grid3x3,
  ToggleLeft,
  Gauge,
  Monitor,
  MoreHorizontal,
  Save,
  X,
  Layers
} from 'lucide-react'

import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Card } from '@/components/ui/card'
import api from '@/lib/api'

const ScreenItemsManager = ({ screen, isOpen, onClose, onUpdate }) => {
  const [items, setItems] = useState([])
  const [loading, setLoading] = useState(false)
  const [selectedItem, setSelectedItem] = useState(null)
  const [isItemDialogOpen, setIsItemDialogOpen] = useState(false)
  
  const [formData, setFormData] = useState({
    item_type: 'button',
    name: '',
    label: '',
    icon: 'circle',
    position: 1,
    size_mobile: 'normal',
    size_display_small: 'normal',
    size_display_large: 'normal',
    size_web: 'normal',
    action_type: 'relay_toggle',
    action_target: '',
    action_payload: '',
    data_source: '',
    data_path: '',
    data_format: '',
    data_unit: '',
    is_active: true
  })
  const [relayBoards, setRelayBoards] = useState([])
  const [relayChannels, setRelayChannels] = useState([])
  const [selectedBoardId, setSelectedBoardId] = useState('')
  const [selectedChannelId, setSelectedChannelId] = useState('')

  // Tipos de item disponíveis
  const itemTypes = [
    { value: 'button', label: 'Botão', icon: Grid3x3 },
    { value: 'switch', label: 'Switch', icon: ToggleLeft },
    { value: 'gauge', label: 'Medidor', icon: Gauge },
    { value: 'display', label: 'Display', icon: Monitor }
  ]

  // Tamanhos disponíveis
  const sizes = [
    { value: 'small', label: 'Pequeno' },
    { value: 'normal', label: 'Normal' },
    { value: 'large', label: 'Grande' },
    { value: 'full', label: 'Largura Total' }
  ]

  // Tipos de ação
  const actionTypes = [
    { value: 'relay_toggle', label: 'Alternar Relé' },
    { value: 'relay_on', label: 'Ligar Relé' },
    { value: 'relay_off', label: 'Desligar Relé' },
    { value: 'screen_navigate', label: 'Navegar para Tela' },
    { value: 'macro_execute', label: 'Executar Macro' },
    { value: 'none', label: 'Sem Ação' }
  ]

  // Fontes de dados
  const dataSources = [
    { value: '', label: 'Nenhuma' },
    { value: 'relay_state', label: 'Estado de Relé' },
    { value: 'can_signal', label: 'Sinal CAN' },
    { value: 'telemetry', label: 'Telemetria' },
    { value: 'static', label: 'Valor Estático' }
  ]

  // Carregar itens
  const loadItems = async () => {
    if (!screen?.id) return
    
    try {
      setLoading(true)
      const response = await api.get(`/screens/${screen.id}/items`)
      setItems(response || [])
    } catch (error) {
      console.error('Erro carregando itens:', error)
    } finally {
      setLoading(false)
    }
  }

  // Carregar placas de relé
  const loadRelayBoards = async () => {
    try {
      const boards = await api.getRelayBoards()
      setRelayBoards(boards || [])
    } catch (error) {
      console.error('Erro carregando placas de relé:', error)
    }
  }

  // Carregar canais de uma placa
  const loadRelayChannels = async (boardId) => {
    if (!boardId) {
      setRelayChannels([])
      return
    }
    
    try {
      const channels = await api.getRelayChannels()
      const boardChannels = channels.filter(ch => ch.board_id === parseInt(boardId))
      setRelayChannels(boardChannels)
    } catch (error) {
      console.error('Erro carregando canais:', error)
    }
  }

  useEffect(() => {
    if (isOpen && screen) {
      loadItems()
      loadRelayBoards()
    }
  }, [isOpen, screen])

  useEffect(() => {
    if (selectedBoardId) {
      loadRelayChannels(selectedBoardId)
    }
  }, [selectedBoardId])

  // Abrir dialog de adicionar/editar
  const openItemDialog = (item = null) => {
    if (item) {
      setSelectedItem(item)
      
      // Resetar estados primeiro
      setSelectedBoardId('')
      setSelectedChannelId('')
      
      // Usar os novos campos dedicados relay_board_id e relay_channel_id
      if (item.relay_board_id) {
        setSelectedBoardId(item.relay_board_id.toString())
      }
      
      if (item.relay_channel_id) {
        setSelectedChannelId(item.relay_channel_id.toString())
      }
      
      setFormData({
        item_type: item.item_type || 'button',
        name: item.name || '',
        label: item.label || '',
        icon: item.icon || 'circle',
        position: item.position || 1,
        size_mobile: item.size_mobile || 'normal',
        size_display_small: item.size_display_small || 'normal',
        size_display_large: item.size_display_large || 'normal',
        size_web: item.size_web || 'normal',
        action_type: item.action_type || 'relay_toggle',
        action_target: item.action_target || '',
        action_payload: item.action_payload || '',
        data_source: item.data_source || '',
        data_path: item.data_path || '',
        data_format: item.data_format || '',
        data_unit: item.data_unit || '',
        is_active: item.is_active !== false
      })
    } else {
      setSelectedItem(null)
      setSelectedBoardId('')
      setSelectedChannelId('')
      const nextPosition = items.length + 1
      setFormData({
        item_type: 'button',
        name: '',
        label: '',
        icon: 'circle',
        position: nextPosition,
        size_mobile: 'normal',
        size_display_small: 'normal',
        size_display_large: 'normal',
        size_web: 'normal',
        action_type: 'relay_toggle',
        action_target: '',
        action_payload: '',
        data_source: '',
        data_path: '',
        data_format: '',
        data_unit: '',
        is_active: true
      })
    }
    setIsItemDialogOpen(true)
  }

  // Salvar item
  const handleSaveItem = async (e) => {
    e.preventDefault()
    
    try {
      // Preparar dados para salvar
      let dataToSave = { ...formData }
      
      // Se for ação de relé, usar os campos dedicados
      if (formData.action_type?.startsWith('relay')) {
        // Usar campos dedicados para board e channel
        if (selectedBoardId) {
          dataToSave.relay_board_id = parseInt(selectedBoardId)
        }
        
        if (selectedChannelId) {
          dataToSave.relay_channel_id = parseInt(selectedChannelId)
        }
        
        // action_payload agora só precisa do tipo de ação
        const payloadObj = {}
        if (formData.action_type === 'relay_toggle') {
          payloadObj.toggle = true
        } else if (formData.action_type === 'relay_momentary') {
          payloadObj.momentary = true
        } else if (formData.action_type === 'relay_pulse') {
          payloadObj.pulse = true
        }
        
        dataToSave.action_payload = JSON.stringify(payloadObj)
        
        // action_target fica livre para outros usos
        dataToSave.action_target = null
      }
      
      if (selectedItem) {
        // Atualizar item existente
        await api.patch(`/screens/${screen.id}/items/${selectedItem.id}`, dataToSave)
      } else {
        // Criar novo item
        await api.post(`/screens/${screen.id}/items`, dataToSave)
      }
      
      await loadItems()
      setIsItemDialogOpen(false)
      setSelectedItem(null)
      setSelectedBoardId('')
      setSelectedChannelId('')
      
      if (onUpdate) onUpdate()
    } catch (error) {
      console.error('Erro salvando item:', error)
      alert(`Erro ao salvar item: ${error.message}`)
    }
  }

  // Deletar item
  const handleDeleteItem = async (item) => {
    if (!confirm(`Tem certeza que deseja remover o item "${item.label}"?`)) {
      return
    }
    
    try {
      await api.delete(`/screens/${screen.id}/items/${item.id}`)
      await loadItems()
      if (onUpdate) onUpdate()
    } catch (error) {
      console.error('Erro removendo item:', error)
      alert(`Erro ao remover item: ${error.message}`)
    }
  }

  // Ícone do tipo de item
  const getItemIcon = (type) => {
    const typeData = itemTypes.find(t => t.value === type)
    const IconComponent = typeData?.icon || Grid3x3
    return <IconComponent className="h-4 w-4" />
  }

  // Badge de tamanho
  const getSizeBadge = (item) => {
    const uniqueSizes = new Set([
      item.size_mobile,
      item.size_display_small,
      item.size_display_large,
      item.size_web
    ])
    
    if (uniqueSizes.size === 1) {
      return <Badge variant="outline">{Array.from(uniqueSizes)[0]}</Badge>
    }
    
    return <Badge variant="outline">Variado</Badge>
  }

  if (!isOpen) return null

  return (
    <>
      {/* Dialog Principal - Lista de Itens */}
      <Dialog open={isOpen} onOpenChange={onClose}>
        <DialogContent className="sm:max-w-[900px]">
          <DialogHeader>
            <DialogTitle>Gerenciar Itens - {screen?.title}</DialogTitle>
            <DialogDescription>
              Configure os itens que aparecem nesta tela
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4">
            {/* Botão Adicionar */}
            <div className="flex justify-between items-center">
              <div className="text-sm text-muted-foreground">
                {items.length} {items.length === 1 ? 'item' : 'itens'}
              </div>
              <Button onClick={() => openItemDialog()}>
                <Plus className="mr-2 h-4 w-4" />
                Adicionar Item
              </Button>
            </div>

            {/* Tabela de Itens */}
            {loading ? (
              <div className="flex items-center justify-center py-8">
                <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent" />
              </div>
            ) : items.length === 0 ? (
              <Card className="p-8 text-center">
                <Layers className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
                <p className="text-muted-foreground">Nenhum item configurado</p>
                <Button 
                  className="mt-4"
                  onClick={() => openItemDialog()}
                >
                  Adicionar Primeiro Item
                </Button>
              </Card>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead className="w-[50px]">Pos</TableHead>
                    <TableHead>Item</TableHead>
                    <TableHead>Tipo</TableHead>
                    <TableHead>Tamanho</TableHead>
                    <TableHead>Ação</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="w-[100px]">Opções</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {items
                    .sort((a, b) => a.position - b.position)
                    .map((item) => (
                      <TableRow key={item.id}>
                        <TableCell className="font-medium">
                          {item.position}
                        </TableCell>
                        <TableCell>
                          <div>
                            <div className="font-medium">{item.label}</div>
                            <div className="text-sm text-muted-foreground">{item.name}</div>
                          </div>
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center gap-2">
                            {getItemIcon(item.item_type)}
                            <span className="text-sm">{item.item_type}</span>
                          </div>
                        </TableCell>
                        <TableCell>
                          {getSizeBadge(item)}
                        </TableCell>
                        <TableCell>
                          <span className="text-sm">
                            {item.action_type || 'Nenhuma'}
                          </span>
                        </TableCell>
                        <TableCell>
                          <Badge variant={item.is_active ? 'default' : 'secondary'}>
                            {item.is_active ? 'Ativo' : 'Inativo'}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Button variant="ghost" className="h-8 w-8 p-0">
                                <MoreHorizontal className="h-4 w-4" />
                              </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end">
                              <DropdownMenuLabel>Ações</DropdownMenuLabel>
                              <DropdownMenuItem onClick={() => openItemDialog(item)}>
                                <Edit className="mr-2 h-4 w-4" />
                                Editar
                              </DropdownMenuItem>
                              <DropdownMenuSeparator />
                              <DropdownMenuItem 
                                onClick={() => handleDeleteItem(item)}
                                className="text-destructive focus:text-destructive"
                              >
                                <Trash2 className="mr-2 h-4 w-4" />
                                Remover
                              </DropdownMenuItem>
                            </DropdownMenuContent>
                          </DropdownMenu>
                        </TableCell>
                      </TableRow>
                    ))}
                </TableBody>
              </Table>
            )}
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={onClose}>
              Fechar
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Dialog de Adicionar/Editar Item */}
      <Dialog open={isItemDialogOpen} onOpenChange={setIsItemDialogOpen}>
        <DialogContent className="sm:max-w-[600px]">
          <DialogHeader>
            <DialogTitle>
              {selectedItem ? 'Editar Item' : 'Novo Item'}
            </DialogTitle>
            <DialogDescription>
              Configure as propriedades do item
            </DialogDescription>
          </DialogHeader>

          <form onSubmit={handleSaveItem} className="space-y-4">
            <Tabs defaultValue="basic" className="w-full">
              <TabsList className="grid w-full grid-cols-3">
                <TabsTrigger value="basic">Básico</TabsTrigger>
                <TabsTrigger value="size">Tamanho</TabsTrigger>
                <TabsTrigger value="action">Ação/Dados</TabsTrigger>
              </TabsList>

              <TabsContent value="basic" className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="name">Nome (ID)</Label>
                    <Input
                      id="name"
                      value={formData.name}
                      onChange={(e) => setFormData({...formData, name: e.target.value})}
                      placeholder="btn_light_1"
                      required
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="label">Rótulo</Label>
                    <Input
                      id="label"
                      value={formData.label}
                      onChange={(e) => setFormData({...formData, label: e.target.value})}
                      placeholder="Luz Sala"
                      required
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="item_type">Tipo</Label>
                    <select
                      id="item_type"
                      value={formData.item_type}
                      onChange={(e) => setFormData({...formData, item_type: e.target.value})}
                      className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
                    >
                      {itemTypes.map((type) => (
                        <option key={type.value} value={type.value}>
                          {type.label}
                        </option>
                      ))}
                    </select>
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="position">Posição</Label>
                    <Input
                      id="position"
                      type="number"
                      value={formData.position}
                      onChange={(e) => setFormData({...formData, position: parseInt(e.target.value)})}
                      min="1"
                      max="99"
                      required
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="icon">Ícone</Label>
                    <Input
                      id="icon"
                      value={formData.icon}
                      onChange={(e) => setFormData({...formData, icon: e.target.value})}
                      placeholder="lightbulb"
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="is_active">Status</Label>
                    <select
                      id="is_active"
                      value={formData.is_active ? 'true' : 'false'}
                      onChange={(e) => setFormData({...formData, is_active: e.target.value === 'true'})}
                      className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
                    >
                      <option value="true">Ativo</option>
                      <option value="false">Inativo</option>
                    </select>
                  </div>
                </div>
              </TabsContent>

              <TabsContent value="size" className="space-y-4">
                <div className="space-y-4">
                  <div className="space-y-2">
                    <Label>Tamanho - Mobile</Label>
                    <select
                      value={formData.size_mobile}
                      onChange={(e) => setFormData({...formData, size_mobile: e.target.value})}
                      className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
                    >
                      {sizes.map((size) => (
                        <option key={size.value} value={size.value}>
                          {size.label}
                        </option>
                      ))}
                    </select>
                  </div>

                  <div className="space-y-2">
                    <Label>Tamanho - Display Pequeno</Label>
                    <select
                      value={formData.size_display_small}
                      onChange={(e) => setFormData({...formData, size_display_small: e.target.value})}
                      className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
                    >
                      {sizes.map((size) => (
                        <option key={size.value} value={size.value}>
                          {size.label}
                        </option>
                      ))}
                    </select>
                  </div>

                  <div className="space-y-2">
                    <Label>Tamanho - Display Grande</Label>
                    <select
                      value={formData.size_display_large}
                      onChange={(e) => setFormData({...formData, size_display_large: e.target.value})}
                      className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
                    >
                      {sizes.map((size) => (
                        <option key={size.value} value={size.value}>
                          {size.label}
                        </option>
                      ))}
                    </select>
                  </div>

                  <div className="space-y-2">
                    <Label>Tamanho - Web</Label>
                    <select
                      value={formData.size_web}
                      onChange={(e) => setFormData({...formData, size_web: e.target.value})}
                      className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
                    >
                      {sizes.map((size) => (
                        <option key={size.value} value={size.value}>
                          {size.label}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
              </TabsContent>

              <TabsContent value="action" className="space-y-4">
                <div className="space-y-4">
                  {/* Configuração de Ação */}
                  <div className="space-y-2">
                    <Label>Tipo de Ação</Label>
                    <select
                      value={formData.action_type}
                      onChange={(e) => setFormData({...formData, action_type: e.target.value})}
                      className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
                    >
                      {actionTypes.map((type) => (
                        <option key={type.value} value={type.value}>
                          {type.label}
                        </option>
                      ))}
                    </select>
                  </div>

                  {formData.action_type && formData.action_type !== 'none' && (
                    <>
                      {/* Se for ação de relé, mostrar seleção de placa e canal */}
                      {formData.action_type.startsWith('relay') ? (
                        <>
                          <div className="space-y-2">
                            <Label>Placa de Relé</Label>
                            <select
                              value={selectedBoardId}
                              onChange={(e) => {
                                setSelectedBoardId(e.target.value)
                                setSelectedChannelId('') // Limpar canal ao trocar placa
                              }}
                              className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
                              required
                            >
                              <option value="">Selecione uma placa...</option>
                              {relayBoards.map((board) => (
                                <option key={board.id} value={board.id}>
                                  {board.name} ({board.total_channels} canais)
                                </option>
                              ))}
                            </select>
                          </div>

                          {selectedBoardId && (
                            <div className="space-y-2">
                              <Label>Canal do Relé</Label>
                              <select
                                value={selectedChannelId}
                                onChange={(e) => setSelectedChannelId(e.target.value)}
                                className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
                                required
                              >
                                <option value="">Selecione um canal...</option>
                                {relayChannels.map((channel) => (
                                  <option key={channel.id} value={channel.id}>
                                    Canal {channel.channel_number}: {channel.name}
                                  </option>
                                ))}
                              </select>
                            </div>
                          )}
                        </>
                      ) : (
                        <div className="space-y-2">
                          <Label>Alvo da Ação</Label>
                          <Input
                            value={formData.action_target}
                            onChange={(e) => setFormData({...formData, action_target: e.target.value})}
                            placeholder={
                              formData.action_type === 'screen_navigate' ? 'screen_name' :
                              formData.action_type === 'mqtt_publish' ? 'topic' :
                              'target'
                            }
                          />
                        </div>
                      )}

                      {/* Payload JSON manual apenas para não-relé */}
                      {!formData.action_type.startsWith('relay') && (
                        <div className="space-y-2">
                          <Label>Payload (JSON opcional)</Label>
                          <Input
                            value={formData.action_payload}
                            onChange={(e) => setFormData({...formData, action_payload: e.target.value})}
                            placeholder='{"param": "value"}'
                          />
                        </div>
                      )}
                    </>
                  )}

                  {/* Configuração de Dados */}
                  <div className="space-y-2">
                    <Label>Fonte de Dados</Label>
                    <select
                      value={formData.data_source}
                      onChange={(e) => setFormData({...formData, data_source: e.target.value})}
                      className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
                    >
                      {dataSources.map((source) => (
                        <option key={source.value} value={source.value}>
                          {source.label}
                        </option>
                      ))}
                    </select>
                  </div>

                  {formData.data_source && (
                    <>
                      <div className="space-y-2">
                        <Label>Caminho dos Dados</Label>
                        <Input
                          value={formData.data_path}
                          onChange={(e) => setFormData({...formData, data_path: e.target.value})}
                          placeholder={
                            formData.data_source === 'relay_state' ? 'channel_id' :
                            formData.data_source === 'can_signal' ? 'signal_name' :
                            'data_path'
                          }
                        />
                      </div>

                      <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                          <Label>Formato</Label>
                          <Input
                            value={formData.data_format}
                            onChange={(e) => setFormData({...formData, data_format: e.target.value})}
                            placeholder="%.1f"
                          />
                        </div>
                        
                        <div className="space-y-2">
                          <Label>Unidade</Label>
                          <Input
                            value={formData.data_unit}
                            onChange={(e) => setFormData({...formData, data_unit: e.target.value})}
                            placeholder="°C"
                          />
                        </div>
                      </div>
                    </>
                  )}
                </div>
              </TabsContent>
            </Tabs>

            <DialogFooter>
              <Button type="button" variant="outline" onClick={() => setIsItemDialogOpen(false)}>
                Cancelar
              </Button>
              <Button type="submit">
                {selectedItem ? 'Salvar Alterações' : 'Criar Item'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </>
  )
}

export default ScreenItemsManager