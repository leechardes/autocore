import React, { useState, useEffect } from 'react'
import { 
  Plus, 
  Search, 
  Filter, 
  MoreHorizontal, 
  Power,
  PowerOff,
  Settings,
  Trash2,
  Edit,
  Zap,
  ToggleLeft,
  ToggleRight,
  Lightbulb,
  Fan,
  Car,
  Shield,
  Clock,
  Palette,
  RotateCcw,
  X,
  CheckCircle
} from 'lucide-react'

import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from '@/components/ui/alert-dialog'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { Switch } from '@/components/ui/switch'
import { Label } from '@/components/ui/label'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import api from '@/lib/api'

const RelaysPage = () => {
  const [boards, setBoards] = useState([])
  const [channels, setChannels] = useState([])
  const [devices, setDevices] = useState([])
  const [availableDevices, setAvailableDevices] = useState([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedChannel, setSelectedChannel] = useState(null)
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false)
  const [isChannelDialogOpen, setIsChannelDialogOpen] = useState(false)
  const [isBoardDialogOpen, setIsBoardDialogOpen] = useState(false)
  const [isEditBoardDialogOpen, setIsEditBoardDialogOpen] = useState(false)
  const [selectedBoard, setSelectedBoard] = useState(null)
  
  const [boardFormData, setBoardFormData] = useState({
    device_id: '',
    total_channels: 16,
    board_model: 'ESP32_16CH'
  })
  
  const [editBoardFormData, setEditBoardFormData] = useState({
    board_model: 'ESP32_16CH',
    total_channels: 16
  })

  const [formData, setFormData] = useState({
    name: '',
    description: '',
    function_type: 'toggle',
    icon: 'lightbulb',
    color: '#FFFF00',
    protection_mode: 'none'
  })

  // Carregar dados
  const loadData = async () => {
    try {
      setLoading(true)
      const [boardsData, channelsData, devicesData, availableDevicesData] = await Promise.all([
        api.getRelayBoards(),
        api.getRelayChannels(),
        api.getDevices(),
        api.getAvailableRelayDevices()
      ])
      setBoards(boardsData)
      setChannels(channelsData)
      setDevices(devicesData)
      setAvailableDevices(availableDevicesData)
    } catch (error) {
      console.error('Erro carregando relés:', error)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadData()
  }, [])

  // Filtrar canais
  const filteredChannels = channels.filter(channel =>
    channel.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    channel.description?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    channel.function_type.toLowerCase().includes(searchTerm.toLowerCase())
  )


  // Ícones disponíveis para canais
  const channelIcons = [
    { value: 'lightbulb', label: 'Iluminação', icon: Lightbulb },
    { value: 'light-high', label: 'Farol Alto', icon: Lightbulb },
    { value: 'light-low', label: 'Farol Baixo', icon: Lightbulb },
    { value: 'light-fog', label: 'Milha', icon: Lightbulb },
    { value: 'light-emergency', label: 'Emergência', icon: Zap },
    { value: 'fan', label: 'Ventilação', icon: Fan },
    { value: 'car', label: 'Automotive', icon: Car },
    { value: 'power', label: 'Energia', icon: Power },
    { value: 'zap', label: 'Elétrico', icon: Zap },
    { value: 'shield', label: 'Proteção', icon: Shield },
    { value: 'winch', label: 'Guincho', icon: Power },
    { value: 'air-compressor', label: 'Compressor', icon: Fan },
    { value: 'power-inverter', label: 'Inversor', icon: Zap },
    { value: 'radio', label: 'Rádio', icon: Power },
    { value: 'fuel-pump', label: 'Bomba', icon: Power },
    { value: 'diff-lock', label: 'Diferencial', icon: Car },
    { value: 'camera', label: 'Câmera', icon: Power },
    { value: 'aux', label: 'Auxiliar', icon: Settings }
  ]

  // Cores disponíveis
  const channelColors = [
    '#FFFF00', '#FF6B35', '#F7931E', '#FFD23F',
    '#06FFA5', '#4ECDC4', '#45B7D1', '#96CEB4',
    '#FECA57', '#FF9FF3', '#54A0FF', '#5F27CD'
  ]


  // Salvar configuração do canal
  const handleSaveChannel = async (e) => {
    e.preventDefault()
    
    if (!selectedChannel) {
      alert('Nenhum canal selecionado')
      return
    }
    
    if (!formData.name.trim()) {
      alert('Nome do canal é obrigatório')
      return
    }
    
    try {
      const result = await api.updateRelayChannel(selectedChannel.id, formData)
      await loadData()
      setIsEditDialogOpen(false)
      resetForm()
    } catch (error) {
      console.error('Erro salvando canal:', error)
      alert(`Erro ao salvar canal: ${error.message}`)
    }
  }

  // Reset form
  const resetForm = () => {
    setFormData({
      name: '',
      description: '',
      function_type: 'toggle',
      icon: 'lightbulb',
      color: '#FFFF00',
      protection_mode: 'none'
    })
    setSelectedChannel(null)
  }

  // Open edit dialog
  const openEditDialog = (channel) => {
    setSelectedChannel(channel)
    setFormData({
      name: channel.name || '',
      description: channel.description || '',
      function_type: channel.function_type || 'toggle',
      icon: channel.icon || 'lightbulb',
      color: channel.color || '#FFFF00',
      protection_mode: channel.protection_mode || 'none'
    })
    setIsEditDialogOpen(true)
  }


  // Resetar canal para configurações padrão
  const handleResetChannel = async (channel) => {
    if (!confirm(`Tem certeza que deseja resetar o canal "${channel.name}" para as configurações padrão?`)) {
      return
    }
    
    try {
      await api.resetRelayChannel(channel.id)
      await loadData()
    } catch (error) {
      console.error('Erro resetando canal:', error)
      alert(`Erro ao resetar canal: ${error.message}`)
    }
  }

  // Desativar canal (soft delete)
  const handleDeactivateChannel = async (channel) => {
    if (!confirm(`Tem certeza que deseja desativar o canal "${channel.name}"?\n\nO canal ficará oculto mas pode ser reativado depois.`)) {
      return
    }
    
    try {
      await api.deleteRelayChannel(channel.id)
      await loadData()
    } catch (error) {
      console.error('Erro desativando canal:', error)
      alert(`Erro ao desativar canal: ${error.message}`)
    }
  }

  // Reativar canal
  const handleActivateChannel = async (channelId) => {
    try {
      await api.activateRelayChannel(channelId)
      await loadData()
    } catch (error) {
      console.error('Erro reativando canal:', error)
      alert(`Erro ao reativar canal: ${error.message}`)
    }
  }

  // Editar placa
  const handleEditBoard = (board) => {
    setSelectedBoard(board)
    setEditBoardFormData({
      board_model: board.board_model || 'ESP32_16CH',
      total_channels: board.total_channels || 16
    })
    setIsEditBoardDialogOpen(true)
  }
  
  // Salvar edição da placa
  const handleSaveEditBoard = async (e) => {
    e.preventDefault()
    
    if (!selectedBoard) return
    
    try {
      // Só enviar o modelo, pois número de canais não pode ser alterado
      const updateData = {
        board_model: editBoardFormData.board_model
      }
      
      await api.updateRelayBoard(selectedBoard.id, updateData)
      await loadData()
      setIsEditBoardDialogOpen(false)
      setSelectedBoard(null)
      alert('Placa atualizada com sucesso!')
    } catch (error) {
      console.error('Erro atualizando placa:', error)
      alert(`Erro ao atualizar placa: ${error.message}`)
    }
  }

  // Excluir placa
  const handleDeleteBoard = async (board) => {
    const device = devices.find(d => d.id === board.device_id)
    const deviceName = device ? device.name : `Dispositivo ${board.device_id}`
    
    if (!confirm(`Tem certeza que deseja excluir a placa do dispositivo "${deviceName}"?\n\nIsso também desativará todos os ${board.total_channels} canais associados.`)) {
      return
    }
    
    try {
      await api.deleteRelayBoard(board.id)
      await loadData()
      alert('Placa excluída com sucesso!')
    } catch (error) {
      console.error('Erro excluindo placa:', error)
      alert(`Erro ao excluir placa: ${error.message}`)
    }
  }

  // Salvar nova placa de relé
  const handleSaveBoard = async (e) => {
    e.preventDefault()
    
    if (!boardFormData.device_id) {
      alert('Selecione um dispositivo')
      return
    }
    
    try {
      
      // Buscar o nome do dispositivo selecionado
      const selectedDevice = availableDevices.find(d => d.id == boardFormData.device_id)
      const deviceName = selectedDevice ? selectedDevice.name : 'Placa de Relé'
      
      // Adicionar o nome baseado no dispositivo
      const dataToSend = {
        ...boardFormData,
        name: deviceName // Usar o nome do dispositivo
      }
      
      const result = await api.createRelayBoard(dataToSend)
      
      try {
        await loadData()
      } catch (loadError) {
        console.error('❌ Erro recarregando dados:', loadError)
        // Continue mesmo se loadData falhar
      }
      
      setIsBoardDialogOpen(false)
      resetBoardForm()
      
      alert(`Placa criada com sucesso para o dispositivo "${deviceName}"!`)
    } catch (error) {
      console.error('❌ ERRO NO PROCESSO:', error)
      alert(`Erro ao criar placa: ${error.message}`)
    }
  }

  // Reset board form
  const resetBoardForm = () => {
    setBoardFormData({
      device_id: '',
      total_channels: 16,
      board_model: 'ESP32_16CH'
    })
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent"></div>
        <span className="ml-2 text-muted-foreground">Carregando configuração de relés...</span>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Configuração de Relés</h1>
          <p className="text-muted-foreground">
            Configure canais de relé, tipos de função e proteções
          </p>
        </div>
        
        <Button onClick={() => setIsBoardDialogOpen(true)}>
          <Plus className="mr-2 h-4 w-4" />
          Nova Placa
        </Button>
      </div>

      {/* Stats & Board Info */}
      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Placas Conectadas</CardTitle>
            <Settings className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{boards.length}</div>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total de Canais</CardTitle>
            <ToggleLeft className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{channels.length}</div>
          </CardContent>
        </Card>
      </div>

      {/* Board Info */}
      {boards.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Placas de Relé</CardTitle>
            <CardDescription>Informações das placas conectadas</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
              {boards.map((board) => {
                // Buscar o nome do dispositivo associado
                const device = devices.find(d => d.id === board.device_id)
                const deviceName = device ? device.name : `Dispositivo ${board.device_id}`
                
                return (
                  <div key={board.id} className="rounded-lg border p-4">
                    <div className="flex items-center justify-between mb-2">
                      <div className="flex-1">
                        <h4 className="font-semibold">{deviceName}</h4>
                        <p className="text-sm text-muted-foreground">{board.board_model}</p>
                      </div>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" className="h-8 w-8 p-0">
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuLabel>Ações</DropdownMenuLabel>
                          <DropdownMenuItem 
                            onClick={() => handleEditBoard(board)}
                          >
                            <Edit className="mr-2 h-4 w-4" />
                            Editar
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          <DropdownMenuItem 
                            onClick={() => handleDeleteBoard(board)}
                            className="text-destructive focus:text-destructive"
                          >
                            <Trash2 className="mr-2 h-4 w-4" />
                            Excluir
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </div>
                    <Badge variant="outline">
                      {board.total_channels} canais
                    </Badge>
                  </div>
                )
              })}
            </div>
          </CardContent>
        </Card>
      )}

      <Tabs defaultValue="channels" className="space-y-4">
        <div className="flex items-center justify-between">
          <TabsList>
            <TabsTrigger value="channels">Canais</TabsTrigger>
            <TabsTrigger value="grid">Visão em Grade</TabsTrigger>
          </TabsList>
          
          <div className="flex items-center space-x-2">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <Input
                placeholder="Buscar canais..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-9 max-w-sm"
              />
            </div>
            <Button variant="outline">
              <Filter className="mr-2 h-4 w-4" />
              Filtros
            </Button>
          </div>
        </div>

        {/* Tabela de Canais */}
        <TabsContent value="channels">
          <Card>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Canal</TableHead>
                  <TableHead>Tipo</TableHead>
                  <TableHead>Proteção</TableHead>
                  <TableHead className="w-[100px]">Ações</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredChannels.map((channel) => {
                  const IconComponent = channelIcons.find(i => i.value === channel.icon)?.icon || Lightbulb
                  return (
                    <TableRow key={channel.id}>
                      <TableCell>
                        <div className="flex items-center space-x-3">
                          <div 
                            className="flex h-8 w-8 items-center justify-center rounded-lg"
                            style={{ backgroundColor: `${channel.color}20`, color: channel.color }}
                          >
                            <IconComponent className="h-4 w-4" />
                          </div>
                          <div>
                            <div className="font-medium">{channel.name}</div>
                            <div className="text-sm text-muted-foreground">
                              Canal {channel.channel_number}
                              {channel.description && ` • ${channel.description}`}
                            </div>
                          </div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <Badge variant="outline">
                          {channel.function_type}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <Badge variant={channel.protection_mode !== 'none' ? 'secondary' : 'outline'}>
                          {channel.protection_mode === 'confirm' ? 'Confirmação' : 
                           channel.protection_mode === 'confirmation' ? 'Confirmação' : 
                           channel.protection_mode === 'password' ? 'Senha' : 'Nenhuma'}
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
                            <DropdownMenuItem onClick={() => openEditDialog(channel)}>
                              <Edit className="mr-2 h-4 w-4" />
                              Configurar
                            </DropdownMenuItem>
                            <DropdownMenuSeparator />
                            <DropdownMenuItem onClick={() => handleResetChannel(channel)}>
                              <RotateCcw className="mr-2 h-4 w-4" />
                              Resetar
                            </DropdownMenuItem>
                            <DropdownMenuItem 
                              onClick={() => handleDeactivateChannel(channel)}
                              className="text-destructive focus:text-destructive"
                            >
                              <X className="mr-2 h-4 w-4" />
                              Desativar
                            </DropdownMenuItem>
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </TableCell>
                    </TableRow>
                  )
                })}
              </TableBody>
            </Table>
          </Card>
        </TabsContent>

        {/* Visão em Grade */}
        <TabsContent value="grid">
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
            {filteredChannels.map((channel) => {
              const IconComponent = channelIcons.find(i => i.value === channel.icon)?.icon || Lightbulb
              return (
                <Card key={channel.id} className="relative overflow-hidden">
                  <CardContent className="p-4">
                    <div className="flex items-center justify-between mb-3">
                      <div 
                        className="flex h-10 w-10 items-center justify-center rounded-lg"
                        style={{ backgroundColor: `${channel.color}20`, color: channel.color }}
                      >
                        <IconComponent className="h-5 w-5" />
                      </div>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => openEditDialog(channel)}
                      >
                        <Settings className="h-4 w-4" />
                      </Button>
                    </div>
                    
                    <div>
                      <h3 className="font-semibold">{channel.name}</h3>
                      <p className="text-sm text-muted-foreground">
                        Canal {channel.channel_number}
                      </p>
                      {channel.description && (
                        <p className="text-xs text-muted-foreground mt-1">
                          {channel.description}
                        </p>
                      )}
                    </div>
                    
                    <div className="flex items-center justify-between mt-3">
                      <Badge variant="outline" className="text-xs">
                        {channel.function_type}
                      </Badge>
                      {channel.protection_mode !== 'none' && (
                        <Badge variant="secondary" className="text-xs">
                          <Shield className="h-3 w-3 mr-1" />
                          Protegido
                        </Badge>
                      )}
                    </div>
                  </CardContent>
                </Card>
              )
            })}
          </div>
        </TabsContent>
      </Tabs>

      {/* Edit Channel Dialog */}
      <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
        <DialogContent className="sm:max-w-[500px]">
          <DialogHeader>
            <DialogTitle>Configurar Canal</DialogTitle>
            <DialogDescription>
              Configure as propriedades e comportamento do canal de relé.
            </DialogDescription>
          </DialogHeader>
          
          <form onSubmit={handleSaveChannel} className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="name">Nome do Canal</Label>
                <Input
                  id="name"
                  value={formData.name}
                  onChange={(e) => setFormData({...formData, name: e.target.value})}
                  placeholder="Ex: Farol Alto"
                  required
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="function_type">Tipo de Função</Label>
                <select
                  id="function_type"
                  value={formData.function_type}
                  onChange={(e) => setFormData({...formData, function_type: e.target.value})}
                  className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
                >
                  <option value="toggle">Toggle (Liga/Desliga)</option>
                  <option value="momentary">Momentary (Pulso)</option>
                  <option value="pulse">Pulse (Tempo)</option>
                </select>
              </div>
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="description">Descrição</Label>
              <Input
                id="description"
                value={formData.description}
                onChange={(e) => setFormData({...formData, description: e.target.value})}
                placeholder="Descrição opcional do canal"
              />
            </div>
            
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="icon">Ícone</Label>
                <select
                  id="icon"
                  value={formData.icon}
                  onChange={(e) => setFormData({...formData, icon: e.target.value})}
                  className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
                >
                  {channelIcons.map((icon) => (
                    <option key={icon.value} value={icon.value}>
                      {icon.label}
                    </option>
                  ))}
                </select>
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="color">Cor</Label>
                <div className="flex gap-2">
                  <input
                    type="color"
                    id="color"
                    value={formData.color}
                    onChange={(e) => setFormData({...formData, color: e.target.value})}
                    className="w-10 h-10 rounded border border-input"
                  />
                  <div className="flex flex-wrap gap-1">
                    {channelColors.slice(0, 8).map((color) => (
                      <button
                        key={color}
                        type="button"
                        onClick={() => setFormData({...formData, color})}
                        className="w-6 h-6 rounded border-2"
                        style={{ 
                          backgroundColor: color,
                          borderColor: formData.color === color ? '#000' : 'transparent'
                        }}
                      />
                    ))}
                  </div>
                </div>
              </div>
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="protection_mode">Modo de Proteção</Label>
              <select
                id="protection_mode"
                value={formData.protection_mode}
                onChange={(e) => setFormData({...formData, protection_mode: e.target.value})}
                className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
              >
                <option value="none">Nenhuma Proteção</option>
                <option value="confirm">Pedir Confirmação</option>
                <option value="confirmation">Pedir Confirmação (Legacy)</option>
                <option value="password">Pedir Senha</option>
              </select>
            </div>
            
            <DialogFooter>
              <Button type="button" variant="outline" onClick={() => setIsEditDialogOpen(false)}>
                Cancelar
              </Button>
              <Button type="submit">
                Salvar Configuração
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Create Board Dialog */}
      <Dialog open={isBoardDialogOpen} onOpenChange={setIsBoardDialogOpen}>
        <DialogContent className="sm:max-w-[500px]">
          <DialogHeader>
            <DialogTitle>Nova Placa de Relé</DialogTitle>
            <DialogDescription>
              Criar uma nova placa de relé com canais configurados automaticamente.
            </DialogDescription>
          </DialogHeader>
          
          <form onSubmit={handleSaveBoard} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="device_id">Dispositivo ESP32 Relay</Label>
              <select
                id="device_id"
                value={boardFormData.device_id}
                onChange={(e) => setBoardFormData({...boardFormData, device_id: e.target.value})}
                className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
                required
              >
                <option value="">
                  {availableDevices.length === 0 
                    ? "Nenhum dispositivo ESP32_RELAY disponível" 
                    : "Selecione um dispositivo ESP32_RELAY"}
                </option>
                {availableDevices.map((device) => (
                  <option key={device.id} value={device.id}>
                    {device.name} ({device.uuid}) - {device.status}
                  </option>
                ))}
              </select>
              {availableDevices.length === 0 && (
                <p className="text-sm text-muted-foreground">
                  Todos os dispositivos ESP32_RELAY já possuem placas cadastradas ou não há dispositivos deste tipo.
                </p>
              )}
            </div>
            
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="total_channels">Número de Canais</Label>
                <select
                  id="total_channels"
                  value={boardFormData.total_channels}
                  onChange={(e) => setBoardFormData({...boardFormData, total_channels: parseInt(e.target.value)})}
                  className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
                >
                  <option value={4}>4 canais</option>
                  <option value={8}>8 canais</option>
                  <option value={16}>16 canais</option>
                  <option value={32}>32 canais</option>
                </select>
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="board_model">Modelo da Placa</Label>
                <select
                  id="board_model"
                  value={boardFormData.board_model}
                  onChange={(e) => setBoardFormData({...boardFormData, board_model: e.target.value})}
                  className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
                >
                  <option value="ESP32_4CH">ESP32 4 Canais</option>
                  <option value="ESP32_8CH">ESP32 8 Canais</option>
                  <option value="ESP32_16CH">ESP32 16 Canais</option>
                  <option value="ESP32_32CH">ESP32 32 Canais</option>
                  <option value="CUSTOM">Personalizado</option>
                </select>
              </div>
            </div>
            
            <DialogFooter>
              <Button type="button" variant="outline" onClick={() => setIsBoardDialogOpen(false)}>
                Cancelar
              </Button>
              <Button type="submit" disabled={availableDevices.length === 0}>
                <Plus className="mr-2 h-4 w-4" />
                {availableDevices.length === 0 ? "Nenhum Dispositivo Disponível" : "Criar Placa"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Edit Board Dialog */}
      <Dialog open={isEditBoardDialogOpen} onOpenChange={setIsEditBoardDialogOpen}>
        <DialogContent className="sm:max-w-[400px]">
          <DialogHeader>
            <DialogTitle>Editar Placa de Relé</DialogTitle>
            <DialogDescription>
              {selectedBoard && (
                <>
                  Editando placa do dispositivo:{' '}
                  <strong>
                    {devices.find(d => d.id === selectedBoard.device_id)?.name || 'Dispositivo'}
                  </strong>
                </>
              )}
            </DialogDescription>
          </DialogHeader>
          
          <form onSubmit={handleSaveEditBoard} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="edit_board_model">Modelo da Placa</Label>
              <select
                id="edit_board_model"
                value={editBoardFormData.board_model}
                onChange={(e) => setEditBoardFormData({...editBoardFormData, board_model: e.target.value})}
                className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
              >
                <option value="ESP32_4CH">ESP32 4 Canais</option>
                <option value="ESP32_8CH">ESP32 8 Canais</option>
                <option value="ESP32_16CH">ESP32 16 Canais</option>
                <option value="ESP32_32CH">ESP32 32 Canais</option>
                <option value="RELAY16CH-12V">Módulo 16 Canais 12V</option>
                <option value="RELAY16CH-5V">Módulo 16 Canais 5V</option>
                <option value="CUSTOM">Personalizado</option>
              </select>
            </div>
            
            <div className="space-y-2">
              <Label>Número de Canais</Label>
              <Input
                value={editBoardFormData.total_channels}
                disabled
                className="opacity-50"
              />
              <p className="text-xs text-muted-foreground">
                O número de canais não pode ser alterado após a criação
              </p>
            </div>
            
            <DialogFooter>
              <Button 
                type="button" 
                variant="outline" 
                onClick={() => {
                  setIsEditBoardDialogOpen(false)
                  setSelectedBoard(null)
                }}
              >
                Cancelar
              </Button>
              <Button type="submit">
                Salvar Alterações
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Empty State */}
      {filteredChannels.length === 0 && !loading && (
        <div className="text-center py-12">
          <ToggleLeft className="mx-auto h-12 w-12 text-muted-foreground/50" />
          <h3 className="mt-2 text-sm font-semibold">Nenhum canal encontrado</h3>
          <p className="mt-1 text-sm text-muted-foreground">
            {searchTerm ? 'Tente uma busca diferente.' : 'Configure suas placas de relé primeiro.'}
          </p>
        </div>
      )}
    </div>
  )
}

export default RelaysPage