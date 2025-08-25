import React, { useState, useEffect, useRef } from 'react'
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
import api from '@/lib/api'
import { 
  adaptConfigToPreview, 
  getColorForValue,
  shouldShowItem,
  getItemSize,
  getScreenColumns
} from '@/utils/previewAdapter'
import { 
  normalizeItemType, 
  normalizeActionType, 
  compareItemTypes,
  compareActionTypes 
} from '@/utils/normalizers'

const ScreenPreview = ({ isOpen, onClose }) => {
  const [fullConfig, setFullConfig] = useState(null)
  const [screens, setScreens] = useState([])
  const [currentScreen, setCurrentScreen] = useState(null)
  const [screenItems, setScreenItems] = useState([])
  const [loading, setLoading] = useState(false)
  const [isReady, setIsReady] = useState(false)
  const loadingRef = useRef(false)
  const [deviceType, setDeviceType] = useState('display_small') // Padrão Display P
  const [itemStates, setItemStates] = useState({})
  const [navigationHistory, setNavigationHistory] = useState([])
  const [telemetry, setTelemetry] = useState({})

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

  // Carregar configuração completa
  const loadFullConfig = async () => {
    // Evitar múltiplas chamadas simultâneas
    if (loadingRef.current) {
      console.log('⚠️ Já está carregando, ignorando chamada duplicada')
      return
    }
    
    try {
      console.log('🔄 Iniciando carregamento da configuração...')
      loadingRef.current = true
      setLoading(true)
      
      // Usar novo endpoint config/full
      console.log('📡 Chamando API config/full...')
      const configData = await api.getPreviewConfig()
      console.log('✅ Dados recebidos:', configData)
      
      // Adaptar dados para o formato do preview
      const adaptedConfig = adaptConfigToPreview(configData)
      console.log('✅ Config adaptada:', adaptedConfig)
      setFullConfig(adaptedConfig)
      setScreens(adaptedConfig.screens || [])
      setTelemetry(adaptedConfig.telemetry || {})
      
      // Selecionar primeira tela visível para o dispositivo atual
      const deviceConfig = deviceTypes.find(d => d.id === deviceType)
      console.log('📱 Device config:', deviceConfig)
      const firstVisible = adaptedConfig.screens.find(s => 
        s.is_visible && s[deviceConfig.show]
      )
      console.log('🖥️ Primeira tela visível:', firstVisible)
      
      if (firstVisible) {
        // Passar a config adaptada diretamente
        await navigateToScreen(firstVisible, adaptedConfig)
      }
      
      // Marcar como pronto
      console.log('✅ Marcando como pronto (isReady = true)')
      setIsReady(true)
    } catch (error) {
      console.error('❌ Erro carregando configuração:', error)
      console.error('Stack trace:', error.stack)
      // Fallback: tentar carregar telas individualmente
      try {
        const screensData = await api.getScreens()
        setScreens(screensData || [])
        const firstVisible = screensData.find(s => s.is_visible)
        if (firstVisible) {
          await navigateToScreen(firstVisible)
        }
      } catch (fallbackError) {
        console.error('❌ Erro no fallback:', fallbackError)
        // Se tudo falhar, marcar como pronto mesmo assim para não travar
        setIsReady(true)
      }
    } finally {
      console.log('🏁 Finally: setLoading(false) e loadingRef.current = false')
      setLoading(false)
      loadingRef.current = false
    }
  }

  // Navegar para tela
  const navigateToScreen = async (screen, configOverride = null) => {
    if (!screen) {
      console.log('❌ navigateToScreen: screen é null')
      return
    }
    
    console.log('🔄 navigateToScreen chamada para:', screen.name)
    const device = deviceTypes.find(d => d.id === deviceType)
    console.log('📱 Device atual:', device)
    
    // Verificar se a tela é visível no dispositivo atual
    if (!screen[device.show]) {
      console.log(`❌ Tela não visível para ${device.name}. Campo ${device.show}:`, screen[device.show])
      alert(`Esta tela não está configurada para ${device.name}`)
      return
    }
    
    try {
      setLoading(true)
      
      // Usar config passada ou a do state
      const configToUse = configOverride || fullConfig
      console.log('📦 Config usada:', configToUse ? 'disponível' : 'null')
      
      // Se temos dados do config/full, usar os itens já carregados
      let items = []
      if (configToUse && configToUse.screens) {
        const fullScreen = configToUse.screens.find(s => s.id === screen.id)
        console.log('🖥️ Screen encontrada no config:', fullScreen ? 'sim' : 'não')
        items = fullScreen?.items || []
        console.log(`📋 Items carregados do config: ${items.length}`)
      } else {
        console.log('⚠️ Usando fallback para carregar items')
        // Fallback: carregar itens individualmente
        items = await api.getScreenItems(screen.id)
      }
      
      console.log('🔍 Items antes do filtro:', items.length)
      console.log('Items completos:', items)
      console.log('Items resumo:', items.map(i => ({
        name: i.name,
        is_active: i.is_active,
        size_display_small: i.size_display_small,
        item_type: i.item_type
      })))
      
      // Filtrar itens ativos e visíveis no dispositivo atual
      const visibleItems = items.filter(item => 
        shouldShowItem(item, deviceType)
      )
      
      console.log(`✅ Items visíveis após filtro: ${visibleItems.length}`)
      setScreenItems(visibleItems)
      
      // Atualizar navegação
      setCurrentScreen(screen)
      setNavigationHistory(prev => [...prev, screen.id])
      
      // Inicializar estados dos itens baseados nos dados reais
      const states = {}
      visibleItems.forEach(item => {
        if (compareItemTypes(item.item_type, 'SWITCH') || compareItemTypes(item.item_type, 'BUTTON')) {
          states[item.id] = false
        } else if (compareItemTypes(item.item_type, 'GAUGE') || compareItemTypes(item.item_type, 'DISPLAY')) {
          // Usar valor atual da telemetria se disponível
          states[item.id] = item.currentValue || item.formattedValue || 0
        }
      })
      setItemStates(states)
      
    } catch (error) {
      console.error('❌ Erro carregando itens:', error)
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

  // Inicializar - usar useEffect corretamente
  useEffect(() => {
    if (isOpen) {
      if (!fullConfig && !loadingRef.current) {
        loadFullConfig()
      }
    } else {
      // Resetar quando fechar
      setIsReady(false)
      setFullConfig(null)
      setScreens([])
      setCurrentScreen(null)
      setScreenItems([])
    }
  }, [isOpen])
  

  // Recarregar quando mudar tipo de dispositivo
  useEffect(() => {
    if (isOpen && fullConfig) {
      // Reselecionar primeira tela visível para o novo dispositivo
      const deviceConfig = deviceTypes.find(d => d.id === deviceType)
      const firstVisible = fullConfig.screens.find(s => 
        s.is_visible && s[deviceConfig.show]
      )
      
      if (firstVisible && currentScreen?.id !== firstVisible.id) {
        setNavigationHistory([]) // Reset histórico
        navigateToScreen(firstVisible)
      } else if (currentScreen) {
        // Recarregar tela atual com novo dispositivo
        navigateToScreen(currentScreen)
      }
    }
  }, [deviceType])

  // Executar ação do item
  const handleItemAction = (item) => {
    
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
    if (compareActionTypes(item.action_type, 'RELAY_CONTROL')) {
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
    } else if (compareItemTypes(item.item_type, 'SWITCH') || compareItemTypes(item.item_type, 'BUTTON')) {
      // Toggle padrão
      setItemStates(prev => ({
        ...prev,
        [item.id]: !prev[item.id]
      }))
    }
    
    // Navegar para tela se a ação for navigation
    if (compareActionTypes(item.action_type, 'NAVIGATION') && item.action_target) {
      const targetScreen = screens.find(s => s.name === item.action_target)
      if (targetScreen) {
        navigateToScreen(targetScreen)
      }
    }
    
    // TODO: Implementar outras ações quando MQTT estiver pronto
  }

  // Renderizar item
  const renderItem = (item) => {
    console.log('🔧 renderItem chamada para:', item.name, 'tipo:', item.item_type)
    const device = deviceTypes.find(d => d.id === deviceType)
    const itemSize = getItemSize(item, deviceType)
    const IconComponent = iconMap[item.icon] || Circle
    const isActive = itemStates[item.id] || false
    console.log('📏 Item size:', itemSize, 'isActive:', isActive)
    
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
    
    switch (normalizeItemType(item.item_type)) {
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
        const gaugeValue = item.currentValue || itemStates[item.id] || 0
        const minValue = item.min_value || 0
        const maxValue = item.max_value || 100
        const percentage = Math.min(100, Math.max(0, ((gaugeValue - minValue) / (maxValue - minValue)) * 100))
        const gaugeColor = getColorForValue(gaugeValue, item.color_ranges)
        
        return (
          <Card key={item.id} className={`${sizeClass} p-4 hover:shadow-lg transition-shadow`}>
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <span className="text-sm font-medium">{item.label}</span>
                <IconComponent className="h-4 w-4 text-muted-foreground" />
              </div>
              <div className="space-y-1">
                <Progress 
                  value={percentage} 
                  className="h-3"
                  style={{ 
                    '--progress-background': gaugeColor 
                  }}
                />
                <div className="flex justify-between text-xs text-muted-foreground">
                  <span>{minValue}</span>
                  <span className="font-medium text-foreground">
                    {item.formattedValue || `${gaugeValue}${item.unit || ''}`}
                  </span>
                  <span>{maxValue}</span>
                </div>
              </div>
              {item.color_ranges && item.color_ranges.length > 0 && (
                <div className="flex gap-1 mt-2">
                  {item.color_ranges.map((range, idx) => (
                    <div 
                      key={idx}
                      className="h-1 flex-1 rounded"
                      style={{ backgroundColor: range.color }}
                      title={`${range.min} - ${range.max}`}
                    />
                  ))}
                </div>
              )}
            </div>
          </Card>
        )
        
      case 'display':
        const displayValue = item.currentValue !== undefined ? item.currentValue : itemStates[item.id] || 0
        const formattedValue = item.formattedValue || `${displayValue}${item.unit || ''}`
        const fontSize = itemSize === 'large' ? 'text-3xl' : itemSize === 'small' ? 'text-xl' : 'text-2xl'
        const iconSize = itemSize === 'large' ? 'h-10 w-10' : itemSize === 'small' ? 'h-6 w-6' : 'h-8 w-8'
        const padding = itemSize === 'large' ? 'p-6' : itemSize === 'small' ? 'p-3' : 'p-4'
        
        // Cores baseadas no valor e ranges definidos
        let valueColor = getColorForValue(displayValue, item.color_ranges)
        if (valueColor === '#3B82F6') { // Se é cor padrão, aplicar lógica de cores por tipo
          if (item.name === 'temp' && displayValue > 90) valueColor = '#EF4444'
          else if (item.name === 'fuel' && displayValue < 20) valueColor = '#F97316'
          else if (item.name === 'rpm' && displayValue > 4000) valueColor = '#EAB308'
          else valueColor = 'currentColor'
        }
        
        return (
          <Card key={item.id} className={`${sizeClass} ${padding} hover:shadow-lg transition-shadow`}>
            <div className="flex items-center justify-between">
              <div className="flex-1">
                <div className="text-xs text-muted-foreground uppercase tracking-wider">
                  {item.label}
                </div>
                <div 
                  className={`${fontSize} font-bold tabular-nums`}
                  style={{ color: valueColor }}
                >
                  {formattedValue}
                </div>
                {item.relay_board && item.relay_channel && (
                  <div className="text-[10px] text-muted-foreground mt-1">
                    {item.deviceName} - {item.channelName}
                  </div>
                )}
              </div>
              <IconComponent className={`${iconSize} text-muted-foreground`} />
            </div>
          </Card>
        )
        
      default:
        console.log('⚠️ Tipo de item não reconhecido:', item.item_type, normalizeItemType(item.item_type))
        return null
    }
  }

  // Obter configurações do dispositivo atual
  const getCurrentDevice = () => deviceTypes.find(d => d.id === deviceType)

  // Fallback: Se está aberto mas não carregou, forçar carregamento
  if (isOpen && !fullConfig && !loadingRef.current) {
    loadFullConfig()
  }

  
  if (!isOpen) return null

  // Se não está pronto, mostrar loading
  if (!isReady) {
    return (
      <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
        <div className="bg-white dark:bg-gray-900 p-8 rounded-lg">
          <div className="flex items-center gap-4">
            <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent" />
            <span>Carregando preview...</span>
          </div>
        </div>
      </div>
    )
  }

  // Modal completo com conteúdo
  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      {/* Overlay */}
      <div 
        className="fixed inset-0 bg-black bg-opacity-50 transition-opacity"
        onClick={onClose}
      />
      
      {/* Modal Content */}
      <div className="fixed inset-0 flex items-center justify-center p-4">
        <div 
          className="relative bg-white dark:bg-gray-900 rounded-lg shadow-xl max-w-[95vw] h-[90vh] w-full overflow-hidden"
          onClick={(e) => e.stopPropagation()}
        >
          {/* Header com botão fechar */}
          <div className="absolute top-4 right-4 z-10">
            <button
              onClick={onClose}
              className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
            >
              <X className="h-5 w-5" />
            </button>
          </div>
          
          <div className="flex h-full">
            {/* Sidebar com controles */}
            <div className="w-64 border-r bg-gray-50 dark:bg-gray-800 p-4 space-y-4 overflow-y-auto">
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
                <div className="space-y-2 text-xs text-gray-600 dark:text-gray-400">
                  <div>
                    <span className="font-medium">Tela:</span> {currentScreen?.title || 'Nenhuma'}
                  </div>
                  <div>
                    <span className="font-medium">Colunas:</span> {getScreenColumns(currentScreen, deviceType)}
                  </div>
                  <div>
                    <span className="font-medium">Itens:</span> {screenItems.length}
                  </div>
                  <div>
                    <span className="font-medium">Dimensões:</span> {getCurrentDevice().width} x {getCurrentDevice().height}
                  </div>
                  {fullConfig && (
                    <>
                      <div className="border-t pt-2 mt-2">
                        <span className="font-medium text-green-600">✅ Config/Full:</span> {fullConfig.preview_mode ? 'Preview' : 'Real'}
                      </div>
                      <div>
                        <span className="font-medium">Telemetria:</span> {Object.keys(telemetry).length} valores
                      </div>
                    </>
                  )}
                </div>
              </div>
            </div>

            {/* Área de preview */}
            <div className="flex-1 p-6 bg-gray-50 dark:bg-gray-950 overflow-auto">
              <div className="flex flex-col items-center justify-center h-full">
                {/* Container do dispositivo */}
                <div 
                  className="bg-white dark:bg-gray-900 border-2 border-gray-200 dark:border-gray-700 rounded-lg shadow-xl overflow-hidden"
                  style={{
                    width: getCurrentDevice().width,
                    maxWidth: '100%',
                    height: getCurrentDevice().height,
                    maxHeight: '100%'
                  }}
                >
                  {/* Header do dispositivo */}
                  <div className="bg-gray-100 dark:bg-gray-800 border-b px-4 py-2 flex items-center justify-between">
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
                      <div className="flex flex-col items-center justify-center h-full text-gray-500">
                        <Monitor className="h-12 w-12 mb-2" />
                        <p className="text-sm">Nenhum item nesta tela</p>
                      </div>
                    ) : (
                      <div 
                        className="grid gap-3"
                        style={{
                          gridTemplateColumns: `repeat(${getScreenColumns(currentScreen, deviceType)}, 1fr)`
                        }}
                      >
                        {console.log('🎨 Renderizando items:', screenItems.length, screenItems)}
                        {screenItems
                          .sort((a, b) => (a.position || 0) - (b.position || 0))
                          .map(item => {
                            console.log('🎯 Renderizando item:', item.name, item.item_type)
                            const rendered = renderItem(item)
                            console.log('📦 Item renderizado:', rendered)
                            return rendered
                          })}
                      </div>
                    )}
                  </div>
                </div>

                {/* Controles de simulação */}
                <div className="mt-4 flex items-center gap-4 flex-wrap">
                  <Badge variant="secondary">
                    {fullConfig ? '✅ Config/Full Preview' : '⚠️ Modo Fallback'} - Ações não são enviadas aos dispositivos
                  </Badge>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => {
                      setItemStates({})
                      if (currentScreen) {
                        navigateToScreen(currentScreen)
                      }
                    }}
                  >
                    Resetar Estados
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => {
                      setFullConfig(null)
                      setTelemetry({})
                      loadFullConfig()
                    }}
                  >
                    Recarregar Config
                  </Button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default ScreenPreview