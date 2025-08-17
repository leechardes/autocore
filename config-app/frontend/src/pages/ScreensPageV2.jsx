import React, { useState, useEffect } from 'react'
import { 
  Plus, 
  Search, 
  Filter, 
  MoreHorizontal, 
  Monitor,
  Smartphone,
  Eye,
  EyeOff,
  Home,
  Lightbulb,
  Settings as SettingsIcon,
  Shield,
  BarChart3,
  Layout,
  Edit,
  Trash2,
  Grid3x3,
  Lock,
  Layers,
  Play
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
import ScreenItemsManager from '@/components/ScreenItemsManager'
import ScreenPreview from '@/components/ScreenPreview'

const ScreensPageV2 = () => {
  const [screens, setScreens] = useState([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedScreen, setSelectedScreen] = useState(null)
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false)
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false)
  const [isItemsManagerOpen, setIsItemsManagerOpen] = useState(false)
  const [screenForItems, setScreenForItems] = useState(null)
  const [isPreviewOpen, setIsPreviewOpen] = useState(false)

  const [formData, setFormData] = useState({
    name: '',
    title: '',
    icon: 'home',
    screen_type: 'control',
    parent_id: null,
    position: 1,
    columns_mobile: 2,
    columns_display_small: 3,
    columns_display_large: 4,
    columns_web: 6,
    is_visible: true,
    required_permission: null,
    show_on_mobile: true,
    show_on_display_small: true,
    show_on_display_large: true,
    show_on_web: true,
    show_on_controls: false
  })

  // Ícones disponíveis
  const availableIcons = [
    { value: 'home', label: 'Início', icon: Home },
    { value: 'lightbulb', label: 'Iluminação', icon: Lightbulb },
    { value: 'tools', label: 'Acessórios', icon: SettingsIcon },
    { value: 'settings', label: 'Sistemas', icon: SettingsIcon },
    { value: 'chart', label: 'Diagnóstico', icon: BarChart3 },
    { value: 'shield', label: 'Segurança', icon: Shield },
    { value: 'layout', label: 'Layout', icon: Layout }
  ]

  // Tipos de tela
  const screenTypes = [
    { value: 'dashboard', label: 'Dashboard' },
    { value: 'control', label: 'Controle' },
    { value: 'settings', label: 'Configurações' },
    { value: 'info', label: 'Informações' }
  ]

  // Permissões
  const permissions = [
    { value: null, label: 'Nenhuma' },
    { value: 'operator', label: 'Operador' },
    { value: 'admin', label: 'Administrador' }
  ]

  // Carregar dados
  const loadData = async () => {
    try {
      setLoading(true)
      const screensData = await api.getScreens()
      setScreens(screensData)
    } catch (error) {
      console.error('Erro carregando telas:', error)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadData()
  }, [])

  // Filtrar telas
  const filteredScreens = screens.filter(screen =>
    screen.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    screen.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
    screen.screen_type?.toLowerCase().includes(searchTerm.toLowerCase())
  )

  // Badges de visibilidade
  const getVisibilityBadges = (screen) => {
    const badges = []
    if (screen.show_on_mobile) badges.push({ label: 'Mobile', color: 'bg-blue-500' })
    if (screen.show_on_display_small) badges.push({ label: 'LCD P', color: 'bg-green-500' })
    if (screen.show_on_display_large) badges.push({ label: 'LCD G', color: 'bg-purple-500' })
    if (screen.show_on_web) badges.push({ label: 'Web', color: 'bg-orange-500' })
    if (screen.show_on_controls) badges.push({ label: 'Controles', color: 'bg-red-500' })
    return badges
  }

  // Ícone da tela
  const getScreenIcon = (iconName) => {
    const iconData = availableIcons.find(i => i.value === iconName)
    const IconComponent = iconData?.icon || Home
    return <IconComponent className="h-4 w-4" />
  }

  // Salvar tela
  const handleSaveScreen = async (e) => {
    e.preventDefault()
    try {
      if (selectedScreen) {
        // Atualizar
        await api.patch(`/screens/${selectedScreen.id}`, formData)
      } else {
        // Criar nova
        await api.post('/screens', formData)
      }
      await loadData()
      setIsEditDialogOpen(false)
      setIsAddDialogOpen(false)
      resetForm()
    } catch (error) {
      console.error('Erro salvando tela:', error)
      alert(`Erro ao salvar tela: ${error.message}`)
    }
  }

  // Deletar tela
  const handleDeleteScreen = async (screen) => {
    if (!confirm(`Tem certeza que deseja remover a tela "${screen.title}"?`)) {
      return
    }
    
    try {
      await api.delete(`/screens/${screen.id}`)
      await loadData()
    } catch (error) {
      console.error('Erro removendo tela:', error)
      alert(`Erro ao remover tela: ${error.message}`)
    }
  }

  // Abrir dialog de edição
  const openEditDialog = (screen) => {
    setSelectedScreen(screen)
    setFormData({
      name: screen.name,
      title: screen.title,
      icon: screen.icon || 'home',
      screen_type: screen.screen_type || 'control',
      parent_id: screen.parent_id,
      position: screen.position || 1,
      columns_mobile: screen.columns_mobile || 2,
      columns_display_small: screen.columns_display_small || 3,
      columns_display_large: screen.columns_display_large || 4,
      columns_web: screen.columns_web || 6,
      is_visible: screen.is_visible,
      required_permission: screen.required_permission,
      show_on_mobile: screen.show_on_mobile,
      show_on_display_small: screen.show_on_display_small,
      show_on_display_large: screen.show_on_display_large,
      show_on_web: screen.show_on_web,
      show_on_controls: screen.show_on_controls
    })
    setIsEditDialogOpen(true)
  }

  // Reset form
  const resetForm = () => {
    setFormData({
      name: '',
      title: '',
      icon: 'home',
      screen_type: 'control',
      parent_id: null,
      position: 1,
      columns_mobile: 2,
      columns_display_small: 3,
      columns_display_large: 4,
      columns_web: 6,
      is_visible: true,
      required_permission: null,
      show_on_mobile: true,
      show_on_display_small: true,
      show_on_display_large: true,
      show_on_web: true,
      show_on_controls: false
    })
    setSelectedScreen(null)
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent"></div>
        <span className="ml-2 text-muted-foreground">Carregando telas...</span>
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
            Gerencie as telas do sistema para diferentes dispositivos e interfaces
          </p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={() => {
            setIsPreviewOpen(true)
          }}>
            <Play className="mr-2 h-4 w-4" />
            Visualizar
          </Button>
          <Button onClick={() => setIsAddDialogOpen(true)}>
            <Plus className="mr-2 h-4 w-4" />
            Nova Tela
          </Button>
        </div>
      </div>

      {/* Stats */}
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
            <CardTitle className="text-sm font-medium">Telas Visíveis</CardTitle>
            <Eye className="h-4 w-4 text-green-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">
              {screens.filter(s => s.is_visible).length}
            </div>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Com Permissão</CardTitle>
            <Lock className="h-4 w-4 text-orange-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-orange-600">
              {screens.filter(s => s.required_permission).length}
            </div>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Tipos</CardTitle>
            <Layout className="h-4 w-4 text-purple-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-purple-600">
              {[...new Set(screens.map(s => s.screen_type))].length}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Search */}
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
      </div>

      {/* Table */}
      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Tela</TableHead>
              <TableHead>Tipo</TableHead>
              <TableHead>Visibilidade</TableHead>
              <TableHead>Colunas</TableHead>
              <TableHead>Permissão</TableHead>
              <TableHead>Status</TableHead>
              <TableHead className="w-[100px]">Ações</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredScreens.map((screen) => (
              <TableRow key={screen.id}>
                <TableCell>
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10">
                      {getScreenIcon(screen.icon)}
                    </div>
                    <div>
                      <div className="font-medium">{screen.title}</div>
                      <div className="text-sm text-muted-foreground">{screen.name}</div>
                    </div>
                  </div>
                </TableCell>
                <TableCell>
                  <Badge variant="outline">
                    {screen.screen_type}
                  </Badge>
                </TableCell>
                <TableCell>
                  <div className="flex flex-wrap gap-1">
                    {getVisibilityBadges(screen).map((badge, i) => (
                      <Badge key={i} variant="secondary" className="text-xs">
                        {badge.label}
                      </Badge>
                    ))}
                  </div>
                </TableCell>
                <TableCell>
                  <div className="text-xs space-y-1">
                    <div>Mobile: {screen.columns_mobile}</div>
                    <div>LCD: {screen.columns_display_small}/{screen.columns_display_large}</div>
                    <div>Web: {screen.columns_web}</div>
                  </div>
                </TableCell>
                <TableCell>
                  {screen.required_permission ? (
                    <Badge variant="outline" className="gap-1">
                      <Lock className="h-3 w-3" />
                      {screen.required_permission}
                    </Badge>
                  ) : (
                    <span className="text-muted-foreground">Pública</span>
                  )}
                </TableCell>
                <TableCell>
                  <Badge variant={screen.is_visible ? 'default' : 'secondary'}>
                    {screen.is_visible ? (
                      <><Eye className="mr-1 h-3 w-3" /> Visível</>
                    ) : (
                      <><EyeOff className="mr-1 h-3 w-3" /> Oculta</>
                    )}
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
                      <DropdownMenuItem onClick={() => openEditDialog(screen)}>
                        <Edit className="mr-2 h-4 w-4" />
                        Editar
                      </DropdownMenuItem>
                      <DropdownMenuItem onClick={() => {
                        setScreenForItems(screen)
                        setIsItemsManagerOpen(true)
                      }}>
                        <Layers className="mr-2 h-4 w-4" />
                        Gerenciar Itens
                      </DropdownMenuItem>
                      <DropdownMenuSeparator />
                      <DropdownMenuItem 
                        onClick={() => handleDeleteScreen(screen)}
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
      </Card>

      {/* Edit/Add Dialog */}
      <Dialog open={isEditDialogOpen || isAddDialogOpen} onOpenChange={(open) => {
        if (!open) {
          setIsEditDialogOpen(false)
          setIsAddDialogOpen(false)
          resetForm()
        }
      }}>
        <DialogContent className="sm:max-w-[600px]">
          <DialogHeader>
            <DialogTitle>{selectedScreen ? 'Editar Tela' : 'Nova Tela'}</DialogTitle>
            <DialogDescription>
              Configure as propriedades da tela para diferentes dispositivos
            </DialogDescription>
          </DialogHeader>
          
          <form onSubmit={handleSaveScreen} className="space-y-4">
            <Tabs defaultValue="basic" className="w-full">
              <TabsList className="grid w-full grid-cols-3">
                <TabsTrigger value="basic">Básico</TabsTrigger>
                <TabsTrigger value="layout">Layout</TabsTrigger>
                <TabsTrigger value="visibility">Visibilidade</TabsTrigger>
              </TabsList>
              
              <TabsContent value="basic" className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="name">Nome (ID)</Label>
                    <Input
                      id="name"
                      value={formData.name}
                      onChange={(e) => setFormData({...formData, name: e.target.value})}
                      placeholder="home"
                      required
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="title">Título</Label>
                    <Input
                      id="title"
                      value={formData.title}
                      onChange={(e) => setFormData({...formData, title: e.target.value})}
                      placeholder="Início"
                      required
                    />
                  </div>
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
                      {availableIcons.map((icon) => (
                        <option key={icon.value} value={icon.value}>
                          {icon.label}
                        </option>
                      ))}
                    </select>
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="screen_type">Tipo de Tela</Label>
                    <select
                      id="screen_type"
                      value={formData.screen_type}
                      onChange={(e) => setFormData({...formData, screen_type: e.target.value})}
                      className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
                    >
                      {screenTypes.map((type) => (
                        <option key={type.value} value={type.value}>
                          {type.label}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
                
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="position">Posição</Label>
                    <Input
                      id="position"
                      type="number"
                      value={formData.position}
                      onChange={(e) => setFormData({...formData, position: parseInt(e.target.value)})}
                      min="1"
                      max="99"
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="required_permission">Permissão</Label>
                    <select
                      id="required_permission"
                      value={formData.required_permission || ''}
                      onChange={(e) => setFormData({...formData, required_permission: e.target.value || null})}
                      className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
                    >
                      {permissions.map((perm) => (
                        <option key={perm.value || 'none'} value={perm.value || ''}>
                          {perm.label}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
              </TabsContent>
              
              <TabsContent value="layout" className="space-y-4">
                <div className="space-y-4">
                  <div className="space-y-2">
                    <Label>Colunas - Mobile</Label>
                    <Input
                      type="number"
                      value={formData.columns_mobile}
                      onChange={(e) => setFormData({...formData, columns_mobile: parseInt(e.target.value)})}
                      min="1"
                      max="6"
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label>Colunas - Display Pequeno</Label>
                    <Input
                      type="number"
                      value={formData.columns_display_small}
                      onChange={(e) => setFormData({...formData, columns_display_small: parseInt(e.target.value)})}
                      min="1"
                      max="6"
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label>Colunas - Display Grande</Label>
                    <Input
                      type="number"
                      value={formData.columns_display_large}
                      onChange={(e) => setFormData({...formData, columns_display_large: parseInt(e.target.value)})}
                      min="1"
                      max="8"
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label>Colunas - Web</Label>
                    <Input
                      type="number"
                      value={formData.columns_web}
                      onChange={(e) => setFormData({...formData, columns_web: parseInt(e.target.value)})}
                      min="1"
                      max="12"
                    />
                  </div>
                </div>
              </TabsContent>
              
              <TabsContent value="visibility" className="space-y-4">
                <div className="space-y-4">
                  <div className="flex items-center justify-between">
                    <Label htmlFor="is_visible">Tela Visível</Label>
                    <Switch
                      id="is_visible"
                      checked={formData.is_visible}
                      onCheckedChange={(checked) => setFormData({...formData, is_visible: checked})}
                    />
                  </div>
                  
                  <div className="flex items-center justify-between">
                    <Label htmlFor="show_on_mobile">Mostrar no Mobile</Label>
                    <Switch
                      id="show_on_mobile"
                      checked={formData.show_on_mobile}
                      onCheckedChange={(checked) => setFormData({...formData, show_on_mobile: checked})}
                    />
                  </div>
                  
                  <div className="flex items-center justify-between">
                    <Label htmlFor="show_on_display_small">Mostrar em Display Pequeno</Label>
                    <Switch
                      id="show_on_display_small"
                      checked={formData.show_on_display_small}
                      onCheckedChange={(checked) => setFormData({...formData, show_on_display_small: checked})}
                    />
                  </div>
                  
                  <div className="flex items-center justify-between">
                    <Label htmlFor="show_on_display_large">Mostrar em Display Grande</Label>
                    <Switch
                      id="show_on_display_large"
                      checked={formData.show_on_display_large}
                      onCheckedChange={(checked) => setFormData({...formData, show_on_display_large: checked})}
                    />
                  </div>
                  
                  <div className="flex items-center justify-between">
                    <Label htmlFor="show_on_web">Mostrar na Web</Label>
                    <Switch
                      id="show_on_web"
                      checked={formData.show_on_web}
                      onCheckedChange={(checked) => setFormData({...formData, show_on_web: checked})}
                    />
                  </div>
                  
                  <div className="flex items-center justify-between">
                    <Label htmlFor="show_on_controls">Mostrar em Controles</Label>
                    <Switch
                      id="show_on_controls"
                      checked={formData.show_on_controls}
                      onCheckedChange={(checked) => setFormData({...formData, show_on_controls: checked})}
                    />
                  </div>
                </div>
              </TabsContent>
            </Tabs>
            
            <DialogFooter>
              <Button type="button" variant="outline" onClick={() => {
                setIsEditDialogOpen(false)
                setIsAddDialogOpen(false)
                resetForm()
              }}>
                Cancelar
              </Button>
              <Button type="submit">
                {selectedScreen ? 'Salvar Alterações' : 'Criar Tela'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Screen Items Manager */}
      <ScreenItemsManager
        screen={screenForItems}
        isOpen={isItemsManagerOpen}
        onClose={() => {
          setIsItemsManagerOpen(false)
          setScreenForItems(null)
        }}
        onUpdate={loadData}
      />

      {/* Screen Preview */}
      <ScreenPreview
        isOpen={isPreviewOpen}
        onClose={() => setIsPreviewOpen(false)}
      />
    </div>
  )
}

export default ScreensPageV2