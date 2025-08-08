import React, { useState, useEffect } from 'react'
import { 
  Plus, 
  Search, 
  Filter, 
  MoreHorizontal, 
  Monitor,
  MonitorSpeaker,
  Smartphone,
  Tablet,
  Settings,
  Trash2,
  Edit,
  Copy,
  Eye,
  EyeOff,
  Layout,
  Type,
  Image,
  BarChart3,
  Gauge,
  Clock,
  Thermometer,
  Fuel,
  Zap,
  Activity,
  Navigation
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
import { Textarea } from '@/components/ui/textarea'
import api from '@/lib/api'
import ScreenPreview from '@/components/ScreenPreview'

const ScreensPage = () => {
  const [screens, setScreens] = useState([])
  const [screenItems, setScreenItems] = useState([])
  const [devices, setDevices] = useState([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedScreen, setSelectedScreen] = useState(null)
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false)
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false)
  const [isDesignerOpen, setIsDesignerOpen] = useState(false)
  const [designerScreen, setDesignerScreen] = useState(null)
  
  // Preview states
  const [selectedPreviewScreen, setSelectedPreviewScreen] = useState(null)
  const [previewTheme, setPreviewTheme] = useState('dark')
  const [showPixels, setShowPixels] = useState(false)

  const [formData, setFormData] = useState({
    name: '',
    description: '',
    device_id: '',
    screen_type: 'OLED_128x64',
    resolution_width: 128,
    resolution_height: 64,
    refresh_rate: 1000,
    is_visible: true,
    theme: 'dark',
    orientation: 'landscape'
  })

  // Tipos de tela disponíveis
  const screenTypes = [
    { 
      value: 'OLED_128x64', 
      label: 'OLED 128x64', 
      icon: MonitorSpeaker, 
      width: 128, 
      height: 64,
      description: 'Display OLED padrão 0.96"'
    },
    { 
      value: 'OLED_128x32', 
      label: 'OLED 128x32', 
      icon: Monitor, 
      width: 128, 
      height: 32,
      description: 'Display OLED compacto'
    },
    { 
      value: 'LCD_160x80', 
      label: 'LCD 160x80', 
      icon: Smartphone, 
      width: 160, 
      height: 80,
      description: 'LCD ST7735 0.96"'
    },
    { 
      value: 'LCD_240x240', 
      label: 'LCD 240x240', 
      icon: Tablet, 
      width: 240, 
      height: 240,
      description: 'LCD IPS 1.3" quadrado'
    },
    { 
      value: 'TFT_320x240', 
      label: 'TFT 320x240', 
      icon: Tablet, 
      width: 320, 
      height: 240,
      description: 'TFT ILI9341 2.4"'
    }
  ]

  // Tipos de componentes para tela
  const componentTypes = [
    { value: 'text', label: 'Texto', icon: Type, description: 'Texto estático ou dinâmico' },
    { value: 'gauge', label: 'Indicador', icon: Gauge, description: 'Medidor circular' },
    { value: 'bar', label: 'Barra', icon: BarChart3, description: 'Barra de progresso' },
    { value: 'graph', label: 'Gráfico', icon: Activity, description: 'Gráfico de linha' },
    { value: 'icon', label: 'Ícone', icon: Image, description: 'Ícone ou símbolo' },
    { value: 'clock', label: 'Relógio', icon: Clock, description: 'Hora atual' },
    { value: 'temp', label: 'Temperatura', icon: Thermometer, description: 'Sensor de temperatura' },
    { value: 'fuel', label: 'Combustível', icon: Fuel, description: 'Nível de combustível' },
    { value: 'voltage', label: 'Voltagem', icon: Zap, description: 'Voltagem da bateria' },
    { value: 'gps', label: 'GPS', icon: Navigation, description: 'Coordenadas GPS' }
  ]

  // Carregar dados
  const loadData = async () => {
    try {
      setLoading(true)
      const [screensData, devicesData] = await Promise.all([
        api.getScreens(),
        api.getDevices()
      ])
      
      setScreens(screensData)
      setDevices(devicesData.filter(d => d.type === 'esp32_display'))
      
      // Selecionar primeira tela para preview se não houver uma selecionada
      if (!selectedPreviewScreen && screensData.length > 0) {
        setSelectedPreviewScreen(screensData[0])
      }
    } catch (error) {
      console.error('Erro carregando telas:', error)
    } finally {
      setLoading(false)
    }
  }

  // Carregar itens de uma tela específica
  const loadScreenItems = async (screenId) => {
    try {
      const items = await api.getScreenItems(screenId)
      setScreenItems(items)
    } catch (error) {
      console.error('Erro carregando itens da tela:', error)
    }
  }

  useEffect(() => {
    loadData()
  }, [])

  // Filtrar telas
  const filteredScreens = screens.filter(screen =>
    screen.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    screen.description?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    screen.screen_type.toLowerCase().includes(searchTerm.toLowerCase())
  )

  // Status badge para tela
  const getScreenBadge = (isVisible) => {
    return (
      <Badge variant={isVisible ? 'default' : 'secondary'} className="flex items-center gap-1">
        {isVisible ? (
          <>
            <Eye className="h-3 w-3" />
            Visível
          </>
        ) : (
          <>
            <EyeOff className="h-3 w-3" />
            Oculta
          </>
        )}
      </Badge>
    )
  }

  // Get device name
  const getDeviceName = (deviceId) => {
    const device = devices.find(d => d.id === deviceId)
    return device ? device.name : 'Dispositivo não encontrado'
  }

  // Get screen type info
  const getScreenTypeInfo = (type) => {
    return screenTypes.find(t => t.value === type) || screenTypes[0]
  }

  // Toggle visibility
  const toggleScreenVisibility = async (screenId) => {
    try {
      const screen = screens.find(s => s.id === screenId)
      await api.updateScreen(screenId, { is_visible: !screen.is_visible })
      await loadData()
    } catch (error) {
      console.error('Erro alternando visibilidade:', error)
    }
  }

  // Salvar tela
  const handleSaveScreen = async (e) => {
    e.preventDefault()
    
    try {
      const screenTypeInfo = getScreenTypeInfo(formData.screen_type)
      const screenData = {
        ...formData,
        resolution_width: screenTypeInfo.width,
        resolution_height: screenTypeInfo.height
      }

      if (selectedScreen) {
        await api.updateScreen(selectedScreen.id, screenData)
      } else {
        await api.createScreen(screenData)
      }
      
      await loadData()
      setIsAddDialogOpen(false)
      setIsEditDialogOpen(false)
      resetForm()
      
    } catch (error) {
      console.error('Erro salvando tela:', error)
    }
  }

  // Deletar tela
  const handleDeleteScreen = async (screen) => {
    try {
      await api.deleteScreen(screen.id)
      await loadData()
    } catch (error) {
      console.error('Erro deletando tela:', error)
    }
  }

  // Duplicar tela
  const handleDuplicateScreen = async (screen) => {
    try {
      const duplicateData = {
        ...screen,
        name: `${screen.name} (Cópia)`,
        id: undefined
      }
      delete duplicateData.id
      delete duplicateData.created_at
      delete duplicateData.updated_at
      
      await api.createScreen(duplicateData)
      await loadData()
    } catch (error) {
      console.error('Erro duplicando tela:', error)
    }
  }

  // Reset form
  const resetForm = () => {
    setFormData({
      name: '',
      description: '',
      device_id: '',
      screen_type: 'OLED_128x64',
      resolution_width: 128,
      resolution_height: 64,
      refresh_rate: 1000,
      is_visible: true,
      theme: 'dark',
      orientation: 'landscape'
    })
    setSelectedScreen(null)
  }

  // Open edit dialog
  const openEditDialog = (screen) => {
    setSelectedScreen(screen)
    setFormData({
      name: screen.name || '',
      description: screen.description || '',
      device_id: screen.device_id || '',
      screen_type: screen.screen_type || 'OLED_128x64',
      resolution_width: screen.resolution_width || 128,
      resolution_height: screen.resolution_height || 64,
      refresh_rate: screen.refresh_rate || 1000,
      is_visible: screen.is_visible ?? true,
      theme: screen.theme || 'dark',
      orientation: screen.orientation || 'landscape'
    })
    setIsEditDialogOpen(true)
  }

  // Open screen designer
  const openScreenDesigner = async (screen) => {
    setDesignerScreen(screen)
    await loadScreenItems(screen.id)
    setIsDesignerOpen(true)
  }

  // Form dialog content
  const ScreenFormDialog = ({ isOpen, onOpenChange, title, description }) => (
    <Dialog open={isOpen} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>{title}</DialogTitle>
          <DialogDescription>{description}</DialogDescription>
        </DialogHeader>
        
        <form onSubmit={handleSaveScreen} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="name">Nome da Tela</Label>
              <Input
                id="name"
                value={formData.name}
                onChange={(e) => setFormData({...formData, name: e.target.value})}
                placeholder="Ex: Dashboard Principal"
                required
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="device_id">Dispositivo</Label>
              <select
                id="device_id"
                value={formData.device_id}
                onChange={(e) => setFormData({...formData, device_id: e.target.value})}
                className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
                required
              >
                <option value="">Selecione um dispositivo</option>
                {devices.map((device) => (
                  <option key={device.id} value={device.id}>
                    {device.name} ({device.ip_address})
                  </option>
                ))}
              </select>
            </div>
          </div>
          
          <div className="space-y-2">
            <Label htmlFor="description">Descrição</Label>
            <Textarea
              id="description"
              value={formData.description}
              onChange={(e) => setFormData({...formData, description: e.target.value})}
              placeholder="Descrição da tela e sua finalidade"
              rows={3}
            />
          </div>
          
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="screen_type">Tipo de Display</Label>
              <select
                id="screen_type"
                value={formData.screen_type}
                onChange={(e) => {
                  const type = getScreenTypeInfo(e.target.value)
                  setFormData({
                    ...formData, 
                    screen_type: e.target.value,
                    resolution_width: type.width,
                    resolution_height: type.height
                  })
                }}
                className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
              >
                {screenTypes.map((type) => (
                  <option key={type.value} value={type.value}>
                    {type.label} ({type.width}x{type.height})
                  </option>
                ))}
              </select>
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="refresh_rate">Taxa de Atualização (ms)</Label>
              <Input
                id="refresh_rate"
                type="number"
                value={formData.refresh_rate}
                onChange={(e) => setFormData({...formData, refresh_rate: parseInt(e.target.value)})}
                min="100"
                max="10000"
                step="100"
              />
            </div>
          </div>
          
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="theme">Tema</Label>
              <select
                id="theme"
                value={formData.theme}
                onChange={(e) => setFormData({...formData, theme: e.target.value})}
                className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
              >
                <option value="dark">Escuro</option>
                <option value="light">Claro</option>
                <option value="auto">Automático</option>
              </select>
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="orientation">Orientação</Label>
              <select
                id="orientation"
                value={formData.orientation}
                onChange={(e) => setFormData({...formData, orientation: e.target.value})}
                className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
              >
                <option value="landscape">Paisagem</option>
                <option value="portrait">Retrato</option>
              </select>
            </div>
          </div>
          
          <div className="flex items-center space-x-2">
            <Switch
              id="is_visible"
              checked={formData.is_visible}
              onCheckedChange={(checked) => setFormData({...formData, is_visible: checked})}
            />
            <Label htmlFor="is_visible">Tela Visível</Label>
          </div>
          
          <DialogFooter>
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              Cancelar
            </Button>
            <Button type="submit">
              {selectedScreen ? 'Salvar Alterações' : 'Criar Tela'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent"></div>
        <span className="ml-2 text-muted-foreground">Carregando configuração de telas...</span>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Configuração de Telas</h1>
          <p className="text-muted-foreground">
            Configure layouts visuais para displays LCD/OLED conectados aos dispositivos ESP32
          </p>
        </div>
        <Button onClick={() => setIsAddDialogOpen(true)}>
          <Plus className="mr-2 h-4 w-4" />
          Nova Tela
        </Button>
      </div>

      {/* Stats Cards */}
      <div className="grid gap-4 md:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total de Telas</CardTitle>
            <Monitor className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{screens.length}</div>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Telas Ativas</CardTitle>
            <Eye className="h-4 w-4 text-green-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">
              {screens.filter(s => s.is_visible === true).length}
            </div>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Displays ESP32</CardTitle>
            <MonitorSpeaker className="h-4 w-4 text-blue-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-blue-600">
              {devices.length}
            </div>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Tipos Diferentes</CardTitle>
            <Layout className="h-4 w-4 text-purple-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-purple-600">
              {[...new Set(screens.map(s => s.screen_type))].length}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Search & Filter */}
      <div className="flex items-center space-x-2">
        <div className="relative flex-1 max-w-sm">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="Buscar telas..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="pl-9"
          />
        </div>
        <Button variant="outline">
          <Filter className="mr-2 h-4 w-4" />
          Filtros
        </Button>
      </div>

      <Tabs defaultValue="list" className="space-y-4">
        <div className="flex items-center justify-between">
          <TabsList>
            <TabsTrigger value="list">Lista</TabsTrigger>
            <TabsTrigger value="grid">Grade</TabsTrigger>
            <TabsTrigger value="preview">Preview</TabsTrigger>
          </TabsList>
        </div>

        {/* Lista de Telas */}
        <TabsContent value="list">
          <Card>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Tela</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Dispositivo</TableHead>
                  <TableHead>Tipo/Resolução</TableHead>
                  <TableHead>Taxa Refresh</TableHead>
                  <TableHead>Tema</TableHead>
                  <TableHead className="w-[100px]">Ações</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredScreens.map((screen) => {
                  const typeInfo = getScreenTypeInfo(screen.screen_type)
                  const TypeIcon = typeInfo.icon
                  return (
                    <TableRow key={screen.id}>
                      <TableCell>
                        <div className="flex items-center space-x-3">
                          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-blue-100 dark:bg-blue-900">
                            <TypeIcon className="h-4 w-4 text-blue-600 dark:text-blue-300" />
                          </div>
                          <div>
                            <div className="font-medium">{screen.name}</div>
                            {screen.description && (
                              <div className="text-sm text-muted-foreground">{screen.description}</div>
                            )}
                          </div>
                        </div>
                      </TableCell>
                      <TableCell>
                        {getScreenBadge(screen.is_visible)}
                      </TableCell>
                      <TableCell>
                        <div className="text-sm">{getDeviceName(screen.device_id)}</div>
                      </TableCell>
                      <TableCell>
                        <div>
                          <div className="font-medium">{typeInfo.label}</div>
                          <div className="text-sm text-muted-foreground">
                            {screen.resolution_width}×{screen.resolution_height}
                          </div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="text-sm">{screen.refresh_rate}ms</div>
                      </TableCell>
                      <TableCell>
                        <Badge variant="outline">
                          {screen.theme === 'dark' ? 'Escuro' : screen.theme === 'light' ? 'Claro' : 'Auto'}
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
                            <DropdownMenuItem onClick={() => openScreenDesigner(screen)}>
                              <Layout className="mr-2 h-4 w-4" />
                              Designer
                            </DropdownMenuItem>
                            <DropdownMenuItem onClick={() => openEditDialog(screen)}>
                              <Edit className="mr-2 h-4 w-4" />
                              Editar
                            </DropdownMenuItem>
                            <DropdownMenuItem onClick={() => handleDuplicateScreen(screen)}>
                              <Copy className="mr-2 h-4 w-4" />
                              Duplicar
                            </DropdownMenuItem>
                            <DropdownMenuItem onClick={() => toggleScreenVisibility(screen.id)}>
                              {screen.is_visible ? (
                                <>
                                  <EyeOff className="mr-2 h-4 w-4" />
                                  Ocultar
                                </>
                              ) : (
                                <>
                                  <Eye className="mr-2 h-4 w-4" />
                                  Mostrar
                                </>
                              )}
                            </DropdownMenuItem>
                            <DropdownMenuSeparator />
                            <AlertDialog>
                              <AlertDialogTrigger asChild>
                                <DropdownMenuItem 
                                  onSelect={(e) => e.preventDefault()}
                                  className="text-destructive focus:text-destructive"
                                >
                                  <Trash2 className="mr-2 h-4 w-4" />
                                  Deletar
                                </DropdownMenuItem>
                              </AlertDialogTrigger>
                              <AlertDialogContent>
                                <AlertDialogHeader>
                                  <AlertDialogTitle>Deletar Tela</AlertDialogTitle>
                                  <AlertDialogDescription>
                                    Tem certeza que deseja deletar a tela "{screen.name}"? 
                                    Esta ação não pode ser desfeita e todos os itens da tela serão perdidos.
                                  </AlertDialogDescription>
                                </AlertDialogHeader>
                                <AlertDialogFooter>
                                  <AlertDialogCancel>Cancelar</AlertDialogCancel>
                                  <AlertDialogAction 
                                    onClick={() => handleDeleteScreen(screen)}
                                    className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
                                  >
                                    Deletar
                                  </AlertDialogAction>
                                </AlertDialogFooter>
                              </AlertDialogContent>
                            </AlertDialog>
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
            {filteredScreens.map((screen) => {
              const typeInfo = getScreenTypeInfo(screen.screen_type)
              const TypeIcon = typeInfo.icon
              return (
                <Card key={screen.id} className="overflow-hidden">
                  <CardContent className="p-4">
                    <div className="flex items-center justify-between mb-3">
                      <div className="flex items-center space-x-2">
                        <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-blue-100 dark:bg-blue-900">
                          <TypeIcon className="h-4 w-4 text-blue-600 dark:text-blue-300" />
                        </div>
                        {getScreenBadge(screen.is_visible)}
                      </div>
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => openScreenDesigner(screen)}
                      >
                        <Layout className="h-4 w-4" />
                      </Button>
                    </div>
                    
                    <div className="space-y-2">
                      <h3 className="font-semibold">{screen.name}</h3>
                      <p className="text-sm text-muted-foreground">
                        {getDeviceName(screen.device_id)}
                      </p>
                      <div className="flex items-center justify-between text-sm">
                        <span className="text-muted-foreground">{typeInfo.label}</span>
                        <span className="text-muted-foreground">
                          {screen.resolution_width}×{screen.resolution_height}
                        </span>
                      </div>
                    </div>
                    
                    <div className="flex items-center justify-between mt-3 pt-3 border-t">
                      <Badge variant="outline">
                        {screen.theme === 'dark' ? 'Escuro' : screen.theme === 'light' ? 'Claro' : 'Auto'}
                      </Badge>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => openEditDialog(screen)}
                      >
                        <Settings className="h-4 w-4" />
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              )
            })}
          </div>
        </TabsContent>

        {/* Preview das Telas */}
        <TabsContent value="preview">
          {filteredScreens.length > 0 ? (
            <div className="space-y-6">
              {/* Seletor de tela */}
              <Card>
                <CardHeader>
                  <CardTitle>Seletor de Tela</CardTitle>
                  <CardDescription>Escolha uma tela para visualizar o preview em tempo real</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
                    {filteredScreens.map((screen) => {
                      const typeInfo = getScreenTypeInfo(screen.screen_type)
                      const TypeIcon = typeInfo.icon
                      const isSelected = selectedPreviewScreen?.id === screen.id
                      
                      return (
                        <Button
                          key={screen.id}
                          variant={isSelected ? "default" : "outline"}
                          className="h-auto p-4 justify-start"
                          onClick={() => setSelectedPreviewScreen(screen)}
                        >
                          <div className="flex items-center space-x-3">
                            <div className={`flex h-8 w-8 items-center justify-center rounded-lg ${
                              isSelected ? 'bg-primary-foreground/20' : 'bg-blue-100 dark:bg-blue-900'
                            }`}>
                              <TypeIcon className={`h-4 w-4 ${
                                isSelected ? 'text-primary-foreground' : 'text-blue-600 dark:text-blue-300'
                              }`} />
                            </div>
                            <div className="text-left">
                              <div className="font-medium">{screen.name}</div>
                              <div className={`text-sm ${
                                isSelected ? 'text-primary-foreground/70' : 'text-muted-foreground'
                              }`}>
                                {typeInfo.label} • {screen.resolution_width}×{screen.resolution_height}
                              </div>
                            </div>
                          </div>
                        </Button>
                      )
                    })}
                  </div>
                </CardContent>
              </Card>

              {/* Preview da tela selecionada */}
              <Card>
                <CardHeader>
                  <CardTitle>Preview em Tempo Real</CardTitle>
                  <CardDescription>
                    Simulação visual da tela como apareceria no dispositivo ESP32
                  </CardDescription>
                </CardHeader>
                <CardContent className="flex justify-center">
                  <ScreenPreview 
                    screen={selectedPreviewScreen}
                    items={screenItems}
                    theme={previewTheme}
                    showPixels={showPixels}
                    setTheme={setPreviewTheme}
                    setShowPixels={setShowPixels}
                  />
                </CardContent>
              </Card>

              {/* Informações técnicas */}
              {selectedPreviewScreen && (
                <Card>
                  <CardHeader>
                    <CardTitle>Informações Técnicas</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                      <div>
                        <Label className="text-sm font-medium text-muted-foreground">Device</Label>
                        <p className="text-sm">{getDeviceName(selectedPreviewScreen.device_id)}</p>
                      </div>
                      <div>
                        <Label className="text-sm font-medium text-muted-foreground">Resolução</Label>
                        <p className="text-sm">{selectedPreviewScreen.resolution_width}×{selectedPreviewScreen.resolution_height} pixels</p>
                      </div>
                      <div>
                        <Label className="text-sm font-medium text-muted-foreground">Taxa de Refresh</Label>
                        <p className="text-sm">{selectedPreviewScreen.refresh_rate}ms</p>
                      </div>
                      <div>
                        <Label className="text-sm font-medium text-muted-foreground">Orientação</Label>
                        <p className="text-sm capitalize">{selectedPreviewScreen.orientation}</p>
                      </div>
                      <div>
                        <Label className="text-sm font-medium text-muted-foreground">Tema Padrão</Label>
                        <p className="text-sm capitalize">{selectedPreviewScreen.theme}</p>
                      </div>
                      <div>
                        <Label className="text-sm font-medium text-muted-foreground">Status</Label>
                        <div className="flex items-center gap-2">
                          {getScreenBadge(selectedPreviewScreen.is_visible)}
                        </div>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              )}
            </div>
          ) : (
            <div className="text-center py-12">
              <Monitor className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
              <h3 className="text-lg font-semibold mb-2">Nenhuma tela para preview</h3>
              <p className="text-muted-foreground">
                Configure suas telas primeiro para visualizar o preview
              </p>
            </div>
          )}
        </TabsContent>
      </Tabs>

      {/* Empty State */}
      {filteredScreens.length === 0 && !loading && (
        <div className="text-center py-12">
          <Monitor className="mx-auto h-12 w-12 text-muted-foreground/50" />
          <h3 className="mt-2 text-sm font-semibold">Nenhuma tela encontrada</h3>
          <p className="mt-1 text-sm text-muted-foreground">
            {searchTerm ? 'Tente uma busca diferente.' : 'Configure sua primeira tela LCD/OLED.'}
          </p>
          {!searchTerm && (
            <Button className="mt-4" onClick={() => setIsAddDialogOpen(true)}>
              <Plus className="mr-2 h-4 w-4" />
              Nova Tela
            </Button>
          )}
        </div>
      )}

      {/* Add Screen Dialog */}
      <ScreenFormDialog
        isOpen={isAddDialogOpen}
        onOpenChange={(open) => {
          setIsAddDialogOpen(open)
          if (!open) resetForm()
        }}
        title="Nova Tela"
        description="Configure uma nova tela LCD/OLED para seus dispositivos ESP32."
      />

      {/* Edit Screen Dialog */}
      <ScreenFormDialog
        isOpen={isEditDialogOpen}
        onOpenChange={(open) => {
          setIsEditDialogOpen(open)
          if (!open) resetForm()
        }}
        title="Editar Tela"
        description="Modifique as configurações da tela."
      />

      {/* Screen Designer Dialog - Placeholder for future implementation */}
      <Dialog open={isDesignerOpen} onOpenChange={setIsDesignerOpen}>
        <DialogContent className="max-w-6xl max-h-[90vh]">
          <DialogHeader>
            <DialogTitle>
              Designer de Tela: {designerScreen?.name}
            </DialogTitle>
            <DialogDescription>
              Editor visual drag-and-drop para criar layouts de tela
            </DialogDescription>
          </DialogHeader>
          
          <div className="flex-1 flex items-center justify-center py-12 border-2 border-dashed border-muted rounded-lg">
            <div className="text-center">
              <Layout className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
              <h3 className="text-lg font-semibold mb-2">Designer Visual</h3>
              <p className="text-muted-foreground mb-4">
                Editor drag-and-drop será implementado na próxima etapa
              </p>
              <div className="space-y-2 text-sm text-muted-foreground">
                <p>Funcionalidades planejadas:</p>
                <ul className="list-disc list-inside space-y-1">
                  <li>Arrastar e soltar componentes</li>
                  <li>Redimensionamento visual</li>
                  <li>Preview em tempo real</li>
                  <li>Biblioteca de templates</li>
                </ul>
              </div>
            </div>
          </div>
          
          <DialogFooter>
            <Button variant="outline" onClick={() => setIsDesignerOpen(false)}>
              Fechar
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}

export default ScreensPage