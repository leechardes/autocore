import React, { useState, useEffect } from 'react'
import { 
  Palette,
  Plus,
  Edit,
  Trash2,
  Save,
  X,
  Check,
  Copy,
  Eye,
  Download,
  Upload,
  Sparkles,
  Sun,
  Moon
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Label } from '@/components/ui/label'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
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
import { Alert, AlertDescription } from '@/components/ui/alert'
import api from '@/lib/api'

const DeviceThemesPage = () => {
  const [themes, setThemes] = useState([])
  const [loading, setLoading] = useState(true)
  const [isDialogOpen, setIsDialogOpen] = useState(false)
  const [selectedTheme, setSelectedTheme] = useState(null)
  const [isPreviewOpen, setIsPreviewOpen] = useState(false)
  const [previewTheme, setPreviewTheme] = useState(null)
  
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    primary_color: '#14b8a6',
    secondary_color: '#64748b',
    background_color: '#ffffff',
    text_color: '#1f2937',
    success_color: '#10b981',
    warning_color: '#f59e0b',
    error_color: '#ef4444',
    is_default: false,
    is_dark: false,
    custom_css: ''
  })
  
  // Temas predefinidos
  const presetThemes = [
    {
      name: 'Teal Modern',
      description: 'Tema moderno com tons de teal',
      primary_color: '#14b8a6',
      secondary_color: '#64748b',
      background_color: '#ffffff',
      text_color: '#1f2937',
      is_dark: false
    },
    {
      name: 'Dark Professional',
      description: 'Tema escuro profissional',
      primary_color: '#3b82f6',
      secondary_color: '#64748b',
      background_color: '#0f172a',
      text_color: '#f1f5f9',
      is_dark: true
    },
    {
      name: 'Green Nature',
      description: 'Tema verde inspirado na natureza',
      primary_color: '#10b981',
      secondary_color: '#84cc16',
      background_color: '#ffffff',
      text_color: '#1f2937',
      is_dark: false
    },
    {
      name: 'Purple Elegance',
      description: 'Tema elegante em roxo',
      primary_color: '#8b5cf6',
      secondary_color: '#ec4899',
      background_color: '#faf5ff',
      text_color: '#1f2937',
      is_dark: false
    },
    {
      name: 'Amber Warm',
      description: 'Tema quente em tons de âmbar',
      primary_color: '#f59e0b',
      secondary_color: '#ea580c',
      background_color: '#fffbeb',
      text_color: '#1f2937',
      is_dark: false
    },
    {
      name: 'Midnight Blue',
      description: 'Tema escuro azul meia-noite',
      primary_color: '#60a5fa',
      secondary_color: '#818cf8',
      background_color: '#0f172a',
      text_color: '#e2e8f0',
      is_dark: true
    }
  ]
  
  // Carregar temas
  const loadThemes = async () => {
    try {
      setLoading(true)
      const data = await api.getThemes()
      setThemes(data || [])
    } catch (error) {
      console.error('Erro carregando temas:', error)
      // Usar temas locais se API falhar
      setThemes([
        {
          id: 1,
          name: 'Tema Padrão',
          description: 'Tema padrão do sistema',
          primary_color: '#14b8a6',
          secondary_color: '#64748b',
          background_color: '#ffffff',
          text_color: '#1f2937',
          is_default: true,
          is_dark: false
        }
      ])
    } finally {
      setLoading(false)
    }
  }
  
  useEffect(() => {
    loadThemes()
  }, [])
  
  // Abrir dialog para criar/editar
  const openDialog = (theme = null) => {
    if (theme) {
      setSelectedTheme(theme)
      setFormData({
        name: theme.name,
        description: theme.description || '',
        primary_color: theme.primary_color,
        secondary_color: theme.secondary_color,
        background_color: theme.background_color,
        text_color: theme.text_color || '#1f2937',
        success_color: theme.success_color || '#10b981',
        warning_color: theme.warning_color || '#f59e0b',
        error_color: theme.error_color || '#ef4444',
        is_default: theme.is_default || false,
        is_dark: theme.is_dark || false,
        custom_css: theme.custom_css || ''
      })
    } else {
      setSelectedTheme(null)
      setFormData({
        name: '',
        description: '',
        primary_color: '#14b8a6',
        secondary_color: '#64748b',
        background_color: '#ffffff',
        text_color: '#1f2937',
        success_color: '#10b981',
        warning_color: '#f59e0b',
        error_color: '#ef4444',
        is_default: false,
        is_dark: false,
        custom_css: ''
      })
    }
    setIsDialogOpen(true)
  }
  
  // Salvar tema
  const handleSaveTheme = async () => {
    try {
      if (selectedTheme) {
        // Atualizar tema existente
        await api.updateTheme(selectedTheme.id, formData)
      } else {
        // Criar novo tema
        await api.createTheme(formData)
      }
      await loadThemes()
      setIsDialogOpen(false)
    } catch (error) {
      console.error('Erro salvando tema:', error)
      alert('Erro ao salvar tema')
    }
  }
  
  // Deletar tema
  const handleDeleteTheme = async (theme) => {
    if (theme.is_default) {
      alert('Não é possível excluir o tema padrão')
      return
    }
    
    if (confirm(`Tem certeza que deseja excluir o tema "${theme.name}"?`)) {
      try {
        await api.deleteTheme(theme.id)
        await loadThemes()
      } catch (error) {
        console.error('Erro deletando tema:', error)
      }
    }
  }
  
  // Definir como padrão
  const handleSetDefault = async (theme) => {
    try {
      // Remover padrão de todos
      for (const t of themes) {
        if (t.is_default && t.id !== theme.id) {
          await api.updateTheme(t.id, { ...t, is_default: false })
        }
      }
      // Definir novo padrão
      await api.updateTheme(theme.id, { ...theme, is_default: true })
      await loadThemes()
    } catch (error) {
      console.error('Erro definindo tema padrão:', error)
    }
  }
  
  // Duplicar tema
  const handleDuplicateTheme = (theme) => {
    const newTheme = { ...theme }
    delete newTheme.id
    newTheme.name = `${theme.name} (Cópia)`
    newTheme.is_default = false
    setFormData(newTheme)
    setSelectedTheme(null)
    setIsDialogOpen(true)
  }
  
  // Aplicar preset
  const applyPreset = (preset) => {
    setFormData(prev => ({
      ...prev,
      ...preset
    }))
  }
  
  // Preview tema
  const openPreview = (theme) => {
    setPreviewTheme(theme)
    setIsPreviewOpen(true)
  }
  
  // Exportar tema
  const exportTheme = (theme) => {
    const data = JSON.stringify(theme, null, 2)
    const blob = new Blob([data], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `theme_${theme.name.toLowerCase().replace(/\s+/g, '_')}.json`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  }
  
  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent"></div>
        <span className="ml-2 text-muted-foreground">Carregando temas...</span>
      </div>
    )
  }
  
  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Temas de Dispositivos</h1>
          <p className="text-muted-foreground">
            Configure temas visuais para os dispositivos ESP32
          </p>
        </div>
        
        <Button onClick={() => openDialog()}>
          <Plus className="mr-2 h-4 w-4" />
          Novo Tema
        </Button>
      </div>
      
      {/* Info Alert */}
      <Alert>
        <Sparkles className="h-4 w-4" />
        <AlertDescription>
          Os temas configurados aqui serão aplicados aos displays dos dispositivos ESP32. 
          Cada dispositivo pode usar um tema diferente baseado em sua função.
        </AlertDescription>
      </Alert>
      
      {/* Themes Grid */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {themes.map((theme) => (
          <Card key={theme.id} className="relative overflow-hidden">
            {theme.is_default && (
              <Badge className="absolute right-2 top-2 z-10" variant="default">
                Padrão
              </Badge>
            )}
            
            <CardHeader className="pb-3">
              <div className="flex items-start justify-between">
                <div>
                  <CardTitle className="text-lg">{theme.name}</CardTitle>
                  <CardDescription className="text-sm">
                    {theme.description || 'Sem descrição'}
                  </CardDescription>
                </div>
                {theme.is_dark ? (
                  <Moon className="h-4 w-4 text-muted-foreground" />
                ) : (
                  <Sun className="h-4 w-4 text-muted-foreground" />
                )}
              </div>
            </CardHeader>
            
            <CardContent className="space-y-3">
              {/* Color Preview */}
              <div className="flex space-x-2">
                <div className="space-y-1">
                  <Label className="text-xs">Cores</Label>
                  <div className="flex space-x-1">
                    <div 
                      className="h-8 w-8 rounded border"
                      style={{ backgroundColor: theme.primary_color }}
                      title="Primária"
                    />
                    <div 
                      className="h-8 w-8 rounded border"
                      style={{ backgroundColor: theme.secondary_color }}
                      title="Secundária"
                    />
                    <div 
                      className="h-8 w-8 rounded border"
                      style={{ backgroundColor: theme.background_color }}
                      title="Fundo"
                    />
                    <div 
                      className="h-8 w-8 rounded border"
                      style={{ backgroundColor: theme.text_color || '#1f2937' }}
                      title="Texto"
                    />
                  </div>
                </div>
              </div>
              
              {/* Actions */}
              <div className="flex flex-wrap gap-2">
                <Button 
                  size="sm" 
                  variant="outline"
                  onClick={() => openPreview(theme)}
                >
                  <Eye className="mr-1 h-3 w-3" />
                  Preview
                </Button>
                
                <Button 
                  size="sm" 
                  variant="outline"
                  onClick={() => openDialog(theme)}
                >
                  <Edit className="mr-1 h-3 w-3" />
                  Editar
                </Button>
                
                <Button 
                  size="sm" 
                  variant="outline"
                  onClick={() => handleDuplicateTheme(theme)}
                >
                  <Copy className="mr-1 h-3 w-3" />
                  Duplicar
                </Button>
                
                {!theme.is_default && (
                  <Button 
                    size="sm" 
                    variant="outline"
                    onClick={() => handleSetDefault(theme)}
                  >
                    <Check className="mr-1 h-3 w-3" />
                    Definir Padrão
                  </Button>
                )}
                
                <Button 
                  size="sm" 
                  variant="outline"
                  onClick={() => exportTheme(theme)}
                >
                  <Download className="mr-1 h-3 w-3" />
                  Exportar
                </Button>
                
                {!theme.is_default && (
                  <Button 
                    size="sm" 
                    variant="destructive"
                    onClick={() => handleDeleteTheme(theme)}
                  >
                    <Trash2 className="h-3 w-3" />
                  </Button>
                )}
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
      
      {/* Empty State */}
      {themes.length === 0 && (
        <Card className="p-8 text-center">
          <Palette className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
          <h3 className="text-lg font-semibold mb-2">Nenhum tema configurado</h3>
          <p className="text-muted-foreground mb-4">
            Crie seu primeiro tema para os dispositivos
          </p>
          <Button onClick={() => openDialog()}>
            <Plus className="mr-2 h-4 w-4" />
            Criar Primeiro Tema
          </Button>
        </Card>
      )}
      
      {/* Create/Edit Dialog */}
      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent className="max-w-2xl max-h-[80vh] overflow-auto">
          <DialogHeader>
            <DialogTitle>
              {selectedTheme ? 'Editar Tema' : 'Novo Tema'}
            </DialogTitle>
            <DialogDescription>
              Configure as cores e propriedades do tema
            </DialogDescription>
          </DialogHeader>
          
          <div className="space-y-4">
            {/* Presets */}
            {!selectedTheme && (
              <div className="space-y-2">
                <Label>Temas Predefinidos</Label>
                <div className="grid grid-cols-3 gap-2">
                  {presetThemes.map((preset, index) => (
                    <Button
                      key={index}
                      variant="outline"
                      size="sm"
                      onClick={() => applyPreset(preset)}
                      className="justify-start"
                    >
                      <div 
                        className="h-4 w-4 rounded mr-2"
                        style={{ backgroundColor: preset.primary_color }}
                      />
                      <span className="text-xs">{preset.name}</span>
                    </Button>
                  ))}
                </div>
              </div>
            )}
            
            {/* Basic Info */}
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="name">Nome do Tema</Label>
                <Input
                  id="name"
                  value={formData.name}
                  onChange={(e) => setFormData({...formData, name: e.target.value})}
                  placeholder="Ex: Tema Moderno"
                  required
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="description">Descrição</Label>
                <Input
                  id="description"
                  value={formData.description}
                  onChange={(e) => setFormData({...formData, description: e.target.value})}
                  placeholder="Descrição opcional"
                />
              </div>
            </div>
            
            {/* Colors */}
            <div className="space-y-2">
              <Label>Cores Principais</Label>
              <div className="grid grid-cols-4 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="primary_color" className="text-xs">Primária</Label>
                  <div className="flex items-center space-x-2">
                    <Input
                      id="primary_color"
                      type="color"
                      value={formData.primary_color}
                      onChange={(e) => setFormData({...formData, primary_color: e.target.value})}
                      className="h-10 w-16"
                    />
                    <Input
                      value={formData.primary_color}
                      onChange={(e) => setFormData({...formData, primary_color: e.target.value})}
                      className="flex-1"
                    />
                  </div>
                </div>
                
                <div className="space-y-2">
                  <Label htmlFor="secondary_color" className="text-xs">Secundária</Label>
                  <div className="flex items-center space-x-2">
                    <Input
                      id="secondary_color"
                      type="color"
                      value={formData.secondary_color}
                      onChange={(e) => setFormData({...formData, secondary_color: e.target.value})}
                      className="h-10 w-16"
                    />
                    <Input
                      value={formData.secondary_color}
                      onChange={(e) => setFormData({...formData, secondary_color: e.target.value})}
                      className="flex-1"
                    />
                  </div>
                </div>
                
                <div className="space-y-2">
                  <Label htmlFor="background_color" className="text-xs">Fundo</Label>
                  <div className="flex items-center space-x-2">
                    <Input
                      id="background_color"
                      type="color"
                      value={formData.background_color}
                      onChange={(e) => setFormData({...formData, background_color: e.target.value})}
                      className="h-10 w-16"
                    />
                    <Input
                      value={formData.background_color}
                      onChange={(e) => setFormData({...formData, background_color: e.target.value})}
                      className="flex-1"
                    />
                  </div>
                </div>
                
                <div className="space-y-2">
                  <Label htmlFor="text_color" className="text-xs">Texto</Label>
                  <div className="flex items-center space-x-2">
                    <Input
                      id="text_color"
                      type="color"
                      value={formData.text_color}
                      onChange={(e) => setFormData({...formData, text_color: e.target.value})}
                      className="h-10 w-16"
                    />
                    <Input
                      value={formData.text_color}
                      onChange={(e) => setFormData({...formData, text_color: e.target.value})}
                      className="flex-1"
                    />
                  </div>
                </div>
              </div>
            </div>
            
            {/* Status Colors */}
            <div className="space-y-2">
              <Label>Cores de Status</Label>
              <div className="grid grid-cols-3 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="success_color" className="text-xs">Sucesso</Label>
                  <div className="flex items-center space-x-2">
                    <Input
                      id="success_color"
                      type="color"
                      value={formData.success_color}
                      onChange={(e) => setFormData({...formData, success_color: e.target.value})}
                      className="h-10 w-16"
                    />
                    <Input
                      value={formData.success_color}
                      onChange={(e) => setFormData({...formData, success_color: e.target.value})}
                      className="flex-1"
                    />
                  </div>
                </div>
                
                <div className="space-y-2">
                  <Label htmlFor="warning_color" className="text-xs">Aviso</Label>
                  <div className="flex items-center space-x-2">
                    <Input
                      id="warning_color"
                      type="color"
                      value={formData.warning_color}
                      onChange={(e) => setFormData({...formData, warning_color: e.target.value})}
                      className="h-10 w-16"
                    />
                    <Input
                      value={formData.warning_color}
                      onChange={(e) => setFormData({...formData, warning_color: e.target.value})}
                      className="flex-1"
                    />
                  </div>
                </div>
                
                <div className="space-y-2">
                  <Label htmlFor="error_color" className="text-xs">Erro</Label>
                  <div className="flex items-center space-x-2">
                    <Input
                      id="error_color"
                      type="color"
                      value={formData.error_color}
                      onChange={(e) => setFormData({...formData, error_color: e.target.value})}
                      className="h-10 w-16"
                    />
                    <Input
                      value={formData.error_color}
                      onChange={(e) => setFormData({...formData, error_color: e.target.value})}
                      className="flex-1"
                    />
                  </div>
                </div>
              </div>
            </div>
            
            {/* Options */}
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <input
                  type="checkbox"
                  id="is_dark"
                  checked={formData.is_dark}
                  onChange={(e) => setFormData({...formData, is_dark: e.target.checked})}
                  className="rounded"
                />
                <Label htmlFor="is_dark">Tema Escuro</Label>
              </div>
              
              <div className="flex items-center space-x-2">
                <input
                  type="checkbox"
                  id="is_default"
                  checked={formData.is_default}
                  onChange={(e) => setFormData({...formData, is_default: e.target.checked})}
                  className="rounded"
                />
                <Label htmlFor="is_default">Definir como Padrão</Label>
              </div>
            </div>
            
            {/* Custom CSS */}
            <div className="space-y-2">
              <Label htmlFor="custom_css">CSS Customizado (Opcional)</Label>
              <Textarea
                id="custom_css"
                value={formData.custom_css}
                onChange={(e) => setFormData({...formData, custom_css: e.target.value})}
                placeholder="/* CSS adicional para o tema */"
                className="font-mono text-sm"
                rows={4}
              />
            </div>
          </div>
          
          <DialogFooter>
            <Button variant="outline" onClick={() => setIsDialogOpen(false)}>
              Cancelar
            </Button>
            <Button onClick={handleSaveTheme}>
              {selectedTheme ? 'Salvar Alterações' : 'Criar Tema'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
      
      {/* Preview Dialog */}
      <Dialog open={isPreviewOpen} onOpenChange={setIsPreviewOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Preview: {previewTheme?.name}</DialogTitle>
            <DialogDescription>
              Visualização do tema nos dispositivos
            </DialogDescription>
          </DialogHeader>
          
          {previewTheme && (
            <div 
              className="rounded-lg p-4 space-y-3"
              style={{ 
                backgroundColor: previewTheme.background_color,
                color: previewTheme.text_color || '#1f2937'
              }}
            >
              <div className="text-center space-y-2">
                <div 
                  className="text-2xl font-bold"
                  style={{ color: previewTheme.primary_color }}
                >
                  Título Principal
                </div>
                <div 
                  className="text-sm"
                  style={{ color: previewTheme.secondary_color }}
                >
                  Texto secundário de exemplo
                </div>
              </div>
              
              <div className="grid grid-cols-3 gap-2">
                <div 
                  className="p-2 rounded text-center text-white text-sm"
                  style={{ backgroundColor: previewTheme.success_color }}
                >
                  Sucesso
                </div>
                <div 
                  className="p-2 rounded text-center text-white text-sm"
                  style={{ backgroundColor: previewTheme.warning_color }}
                >
                  Aviso
                </div>
                <div 
                  className="p-2 rounded text-center text-white text-sm"
                  style={{ backgroundColor: previewTheme.error_color }}
                >
                  Erro
                </div>
              </div>
              
              <div className="space-y-2">
                <div 
                  className="p-3 rounded"
                  style={{ 
                    backgroundColor: previewTheme.primary_color,
                    color: '#ffffff'
                  }}
                >
                  Botão Primário
                </div>
                <div 
                  className="p-3 rounded border-2"
                  style={{ 
                    borderColor: previewTheme.secondary_color,
                    color: previewTheme.secondary_color
                  }}
                >
                  Botão Secundário
                </div>
              </div>
            </div>
          )}
          
          <DialogFooter>
            <Button variant="outline" onClick={() => setIsPreviewOpen(false)}>
              Fechar
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}

export default DeviceThemesPage