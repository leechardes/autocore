import React, { useState, useEffect } from 'react'
import {
  Monitor,
  Smartphone,
  Tablet,
  Tv,
  ChevronLeft,
  ChevronRight,
  Home,
  Lightbulb,
  Power,
  Gauge,
  ToggleLeft,
  Circle,
  Square,
  Activity,
  Thermometer,
  Droplets,
  Wind,
  Battery,
  Wifi,
  Settings,
  X
} from 'lucide-react'

import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import { Switch } from '@/components/ui/switch'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import api from '@/lib/api'

const ScreenPreview = ({ isOpen, onClose }) => {
  const [screens, setScreens] = useState([])
  const [currentScreen, setCurrentScreen] = useState(null)
  const [screenItems, setScreenItems] = useState([])
  const [loading, setLoading] = useState(false)
  const [deviceType, setDeviceType] = useState('web')
  const [itemStates, setItemStates] = useState({})
  const [navigationHistory, setNavigationHistory] = useState([])

  // Tipos de dispositivo
  const deviceTypes = [
    { 
      id: 'mobile', 
      name: 'Mobile', 
      icon: Smartphone,
      width: '375px',
      height: '667px',
      columns: 'columns_mobile',
      size: 'size_mobile',
      show: 'show_on_mobile'
    },
    { 
      id: 'display_small', 
      name: 'Display P', 
      icon: Tablet,
      width: '480px',
      height: '320px',
      columns: 'columns_display_small',
      size: 'size_display_small',
      show: 'show_on_display_small'
    },
    { 
      id: 'display_large', 
      name: 'Display G', 
      icon: Tv,
      width: '800px',
      height: '480px',
      columns: 'columns_display_large',
      size: 'size_display_large',
      show: 'show_on_display_large'
    },
    { 
      id: 'web', 
      name: 'Web', 
      icon: Monitor,
      width: '100%',
      height: '600px',
      columns: 'columns_web',
      size: 'size_web',
      show: 'show_on_web'
    }
  ]

  // Ícones disponíveis
  const iconMap = {
    'home': Home,
    'lightbulb': Lightbulb,
    'power': Power,
    'gauge': Gauge,
    'toggle': ToggleLeft,
    'circle': Circle,
    'square': Square,
    'activity': Activity,
    'thermometer': Thermometer,
    'droplets': Droplets,
    'wind': Wind,
    'battery': Battery,
    'wifi': Wifi,
    'settings': Settings,
    // Ícones específicos do projeto
    'speedometer': Gauge,
    'tachometer': Activity,
    'fuel': Droplets,
    'light-high': Lightbulb,
    'light-low': Lightbulb,
    'light-fog': Lightbulb,
    'light-emergency': Lightbulb,
    'winch': Settings,
    'air-compressor': Wind,
    'power-inverter': Power,
    'radio': Wifi
  }

  // Carregar telas
  const loadScreens = async () => {
    try {
      setLoading(true)
      const screensData = await api.getScreens()
      setScreens(screensData || [])
      
      // Selecionar primeira tela visível
      const firstVisible = screensData.find(s => s.is_visible)
      if (firstVisible) {
        await navigateToScreen(firstVisible)
      }
    } catch (error) {
      console.error('Erro carregando telas:', error)
    } finally {
      setLoading(false)
    }
  }

  // Navegar para tela
  const navigateToScreen = async (screen) => {
    if (!screen) return
    
    const device = deviceTypes.find(d => d.id === deviceType)
    
    // Verificar se a tela é visível no dispositivo atual
    if (!screen[device.show]) {
      alert(`Esta tela não está configurada para ${device.name}`)
      return
    }
    
    try {
      setLoading(true)
      
      // Carregar itens da tela
      const items = await api.get(`/screens/${screen.id}/items`)
      setScreenItems(items || [])
      
      // Atualizar navegação
      setCurrentScreen(screen)
      setNavigationHistory(prev => [...prev, screen.id])
      
      // Inicializar estados dos itens
      const states = {}
      items.forEach(item => {
        if (item.item_type === 'switch' || item.item_type === 'button') {
          states[item.id] = false
        } else if (item.item_type === 'gauge' || item.item_type === 'display') {
          states[item.id] = Math.floor(Math.random() * 100) // Valor demo
        }
      })
      setItemStates(states)
      
    } catch (error) {
      console.error('Erro carregando itens:', error)
    } finally {
      setLoading(false)
    }
  }

  // Voltar navegação
  const goBack = () => {
    if (navigationHistory.length > 1) {
      const newHistory = [...navigationHistory]
      newHistory.pop() // Remove atual
      const previousScreenId = newHistory[newHistory.length - 1]
      const previousScreen = screens.find(s => s.id === previousScreenId)
      
      if (previousScreen) {
        setNavigationHistory(newHistory.slice(0, -1)) // Remove o último também
        navigateToScreen(previousScreen)
      }
    }
  }

  // Inicializar
  useEffect(() => {
    if (isOpen) {
      loadScreens()
    }
  }, [isOpen])

  // Executar ação do item
  const handleItemAction = (item) => {
    console.log('Ação executada:', item)
    
    // Parse do payload se existir
    let payload = {}
    if (item.action_payload) {
      try {
        payload = JSON.parse(item.action_payload)
      } catch (e) {
        console.error('Erro parsing payload:', e)
      }
    }
    
    // Ação baseada no tipo
    if (item.action_type === 'relay') {
      // Para relés, verificar se é toggle ou momentary
      if (payload.momentary) {
        // Momentary - ativa temporariamente
        setItemStates(prev => ({ ...prev, [item.id]: true }))
        setTimeout(() => {
          setItemStates(prev => ({ ...prev, [item.id]: false }))
        }, 500) // Desativa após 500ms
      } else {
        // Toggle normal
        setItemStates(prev => ({
          ...prev,
          [item.id]: !prev[item.id]
        }))
      }
    } else if (item.item_type === 'switch' || item.item_type === 'button') {
      // Toggle padrão
      setItemStates(prev => ({
        ...prev,
        [item.id]: !prev[item.id]
      }))
    }
    
    // Navegar para tela se a ação for screen_navigate
    if (item.action_type === 'screen_navigate' && item.action_target) {
      const targetScreen = screens.find(s => s.name === item.action_target)
      if (targetScreen) {
        navigateToScreen(targetScreen)
      }
    }
    
    // TODO: Implementar outras ações quando MQTT estiver pronto
  }

  // Renderizar item
  const renderItem = (item) => {
    const device = deviceTypes.find(d => d.id === deviceType)
    const itemSize = item[device.size] || 'normal'
    const IconComponent = iconMap[item.icon] || Circle
    const isActive = itemStates[item.id] || false
    
    // Classes de tamanho
    const sizeClasses = {
      'small': 'col-span-1',
      'normal': 'col-span-1',
      'large': 'col-span-2',
      'full': 'col-span-full'
    }
    
    const sizeClass = sizeClasses[itemSize] || 'col-span-1'
    
    // Parse do payload para determinar tipo de botão
    let buttonType = 'toggle' // padrão
    let buttonVariant = 'default'
    if (item.action_payload) {
      try {
        const payload = JSON.parse(item.action_payload)
        if (payload.momentary) buttonType = 'momentary'
        if (payload.pulse) buttonType = 'pulse'
      } catch (e) {}
    }
    
    // Determinar variante visual baseada no estado e tipo
    if (buttonType === 'momentary') {
      buttonVariant = isActive ? 'destructive' : 'secondary'
    } else {
      buttonVariant = isActive ? 'default' : 'outline'
    }
    
    // Altura do botão baseada no tamanho
    const heightClass = itemSize === 'large' ? 'h-24' : itemSize === 'small' ? 'h-16' : 'h-20'
    
    switch (item.item_type) {
      case 'button':
        return (
          <Button
            key={item.id}
            variant={buttonVariant}
            className={`${sizeClass} ${heightClass} flex flex-col gap-2 transition-all hover:scale-105`}
            onClick={() => handleItemAction(item)}
          >
            <IconComponent className={itemSize === 'large' ? 'h-8 w-8' : 'h-6 w-6'} />
            <span className={itemSize === 'large' ? 'text-sm font-medium' : 'text-xs'}>
              {item.label}
            </span>
            {buttonType === 'momentary' && (
              <Badge variant="outline" className="text-[10px] px-1 py-0">
                HOLD
              </Badge>
            )}
          </Button>
        )
        
      case 'switch':
        return (
          <Card key={item.id} className={`${sizeClass} p-4`}>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <IconComponent className="h-5 w-5" />
                <span className="text-sm font-medium">{item.label}</span>
              </div>
              <Switch
                checked={isActive}
                onCheckedChange={() => handleItemAction(item)}
              />
            </div>
          </Card>
        )
        
      case 'gauge':
        const value = itemStates[item.id] || 0
        return (
          <Card key={item.id} className={`${sizeClass} p-4`}>
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <span className="text-sm font-medium">{item.label}</span>
                <IconComponent className="h-4 w-4 text-muted-foreground" />
              </div>
              <div className="space-y-1">
                <Progress value={value} className="h-2" />
                <div className="flex justify-between text-xs text-muted-foreground">
                  <span>0</span>
                  <span className="font-medium text-foreground">
                    {value}{item.data_unit || '%'}
                  </span>
                  <span>100</span>
                </div>
              </div>
            </div>
          </Card>
        )
        
      case 'display':
        const displayValue = itemStates[item.id] || 0
        const fontSize = itemSize === 'large' ? 'text-3xl' : itemSize === 'small' ? 'text-xl' : 'text-2xl'
        const iconSize = itemSize === 'large' ? 'h-10 w-10' : itemSize === 'small' ? 'h-6 w-6' : 'h-8 w-8'
        const padding = itemSize === 'large' ? 'p-6' : itemSize === 'small' ? 'p-3' : 'p-4'
        
        // Cores baseadas no tipo de dado
        let valueColor = ''
        if (item.name === 'temp' && displayValue > 90) valueColor = 'text-red-500'
        else if (item.name === 'fuel' && displayValue < 20) valueColor = 'text-orange-500'
        else if (item.name === 'rpm' && displayValue > 4000) valueColor = 'text-yellow-500'
        
        return (
          <Card key={item.id} className={`${sizeClass} ${padding} hover:shadow-lg transition-shadow`}>
            <div className="flex items-center justify-between">
              <div className="flex-1">
                <div className="text-xs text-muted-foreground uppercase tracking-wider">
                  {item.label}
                </div>
                <div className={`${fontSize} font-bold ${valueColor} tabular-nums`}>
                  {item.data_format === 'percentage' ? 
                    `${displayValue}${item.data_unit || '%'}` :
                    `${displayValue.toLocaleString()} ${item.data_unit || ''}`
                  }
                </div>
              </div>
              <IconComponent className={`${iconSize} text-muted-foreground`} />
            </div>
          </Card>
        )
        
      default:
        return null
    }
  }

  // Obter configurações do dispositivo atual
  const getCurrentDevice = () => deviceTypes.find(d => d.id === deviceType)

  if (!isOpen) return null

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-[95vw] h-[90vh] p-0">
        <div className="flex h-full">
          {/* Sidebar com controles */}
          <div className="w-64 border-r bg-muted/10 p-4 space-y-4">
            <div>
              <h3 className="text-sm font-medium mb-2">Tipo de Dispositivo</h3>
              <div className="space-y-2">
                {deviceTypes.map(type => {
                  const Icon = type.icon
                  return (
                    <Button
                      key={type.id}
                      variant={deviceType === type.id ? 'default' : 'outline'}
                      className="w-full justify-start"
                      onClick={() => setDeviceType(type.id)}
                    >
                      <Icon className="mr-2 h-4 w-4" />
                      {type.name}
                    </Button>
                  )
                })}
              </div>
            </div>

            <div className="border-t pt-4">
              <h3 className="text-sm font-medium mb-2">Telas Disponíveis</h3>
              <div className="space-y-1 max-h-[300px] overflow-y-auto">
                {screens
                  .filter(s => s.is_visible && s[getCurrentDevice().show])
                  .map(screen => (
                    <Button
                      key={screen.id}
                      variant={currentScreen?.id === screen.id ? 'secondary' : 'ghost'}
                      className="w-full justify-start text-xs"
                      onClick={() => navigateToScreen(screen)}
                    >
                      {screen.title}
                    </Button>
                  ))}
              </div>
            </div>

            <div className="border-t pt-4">
              <h3 className="text-sm font-medium mb-2">Informações</h3>
              <div className="space-y-2 text-xs text-muted-foreground">
                <div>
                  <span className="font-medium">Tela:</span> {currentScreen?.title || 'Nenhuma'}
                </div>
                <div>
                  <span className="font-medium">Colunas:</span> {currentScreen?.[getCurrentDevice().columns] || 0}
                </div>
                <div>
                  <span className="font-medium">Itens:</span> {screenItems.length}
                </div>
                <div>
                  <span className="font-medium">Dimensões:</span> {getCurrentDevice().width} x {getCurrentDevice().height}
                </div>
              </div>
            </div>
          </div>

          {/* Área de preview */}
          <div className="flex-1 p-6 bg-muted/5 overflow-auto">
            <div className="flex flex-col items-center justify-center h-full">
              {/* Container do dispositivo */}
              <div 
                className="bg-background border-2 border-border rounded-lg shadow-xl overflow-hidden"
                style={{
                  width: getCurrentDevice().width,
                  maxWidth: '100%',
                  height: getCurrentDevice().height,
                  maxHeight: '100%'
                }}
              >
                {/* Header do dispositivo */}
                <div className="bg-card border-b px-4 py-2 flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    {navigationHistory.length > 1 && (
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={goBack}
                      >
                        <ChevronLeft className="h-4 w-4" />
                      </Button>
                    )}
                    <h2 className="font-semibold text-sm">
                      {currentScreen?.title || 'Selecione uma tela'}
                    </h2>
                  </div>
                  <Badge variant="outline" className="text-xs">
                    {getCurrentDevice().name}
                  </Badge>
                </div>

                {/* Conteúdo da tela */}
                <div className="p-4 overflow-auto h-[calc(100%-48px)]">
                  {loading ? (
                    <div className="flex items-center justify-center h-full">
                      <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent" />
                    </div>
                  ) : screenItems.length === 0 ? (
                    <div className="flex flex-col items-center justify-center h-full text-muted-foreground">
                      <Monitor className="h-12 w-12 mb-2" />
                      <p className="text-sm">Nenhum item nesta tela</p>
                    </div>
                  ) : (
                    <div 
                      className={`grid gap-3`}
                      style={{
                        gridTemplateColumns: `repeat(${currentScreen?.[getCurrentDevice().columns] || 2}, 1fr)`
                      }}
                    >
                      {screenItems
                        .filter(item => item.is_active)
                        .sort((a, b) => a.position - b.position)
                        .map(item => renderItem(item))}
                    </div>
                  )}
                </div>
              </div>

              {/* Controles de simulação */}
              <div className="mt-4 flex items-center gap-4">
                <Badge variant="secondary">
                  Modo Preview - Ações não são enviadas aos dispositivos
                </Badge>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    setItemStates({})
                    navigateToScreen(currentScreen)
                  }}
                >
                  Resetar Estados
                </Button>
              </div>
            </div>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  )
}

export default ScreenPreview