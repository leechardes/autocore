import React, { useState, useEffect, useRef } from 'react'
import { 
  Radio,
  Activity,
  Gauge,
  Thermometer,
  Zap,
  Droplets,
  Wind,
  AlertTriangle,
  TrendingUp,
  TrendingDown,
  Minus,
  Play,
  Pause,
  RefreshCw,
  Download,
  Settings,
  Filter,
  ChevronRight,
  Signal,
  Cog,
  Database,
  AlertCircle
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Progress } from '@/components/ui/progress'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Switch } from '@/components/ui/switch'
import { Label } from '@/components/ui/label'
import api from '@/lib/api'

const CANBusPage = () => {
  const [isSimulating, setIsSimulating] = useState(false)
  const [selectedFilter, setSelectedFilter] = useState('all')
  const [updateSpeed, setUpdateSpeed] = useState(1000) // ms
  const [showRawData, setShowRawData] = useState(false)
  const [configuredSignals, setConfiguredSignals] = useState([]) // Sinais do banco
  const [loadingSignals, setLoadingSignals] = useState(true)
  const [canSignals, setCanSignals] = useState({}) // Estado dos sinais dinamicamente
  const [signalHistory, setSignalHistory] = useState({}) // Histórico dinâmico
  const [rawMessages, setRawMessages] = useState([])
  const [messageCount, setMessageCount] = useState(0)
  const intervalRef = useRef(null)
  
  // Categorias de sinais
  const signalCategories = {
    motor: [],
    combustivel: [],
    eletrico: [],
    pressoes: [],
    velocidade: []
  }
  
  // Carregar sinais configurados do banco
  useEffect(() => {
    loadConfiguredSignals()
  }, [])
  
  const loadConfiguredSignals = async () => {
    setLoadingSignals(true)
    try {
      const signals = await api.getCANSignals()
      setConfiguredSignals(signals)
      
      // Se não houver sinais, oferece popular com padrão
      if (signals.length === 0) {
        const shouldSeed = confirm('Nenhum sinal CAN configurado. Deseja carregar os sinais padrão da FuelTech?')
        if (shouldSeed) {
          await api.seedCANSignals()
          const newSignals = await api.getCANSignals()
          setConfiguredSignals(newSignals)
          initializeSignalStates(newSignals)
        }
      } else {
        initializeSignalStates(signals)
      }
    } catch (error) {
      console.error('Erro ao carregar sinais:', error)
    } finally {
      setLoadingSignals(false)
    }
  }
  
  // Inicializar estados dos sinais baseado no banco
  const initializeSignalStates = (signals) => {
    const initialStates = {}
    const initialHistory = {}
    
    signals.forEach(signal => {
      const key = signal.signal_name.toLowerCase().replace(/[^a-z0-9]/g, '')
      
      // Estado inicial do sinal
      initialStates[key] = {
        ...signal,
        value: signal.min_value,
        trend: 'stable',
        key: key
      }
      
      // Histórico vazio
      initialHistory[key] = []
      
      // Organizar por categoria
      if (signalCategories[signal.category]) {
        signalCategories[signal.category].push(key)
      }
    })
    
    setCanSignals(initialStates)
    setSignalHistory(initialHistory)
  }
  
  // Simular mudanças nos valores baseado nas configurações do banco
  const simulateCANData = () => {
    if (Object.keys(canSignals).length === 0) return
    
    setCanSignals(prev => {
      const newSignals = { ...prev }
      
      // Para cada sinal configurado
      Object.keys(newSignals).forEach(key => {
        const signal = newSignals[key]
        const range = signal.max_value - signal.min_value
        
        // Simulação específica por tipo de sinal
        switch(key) {
          case 'rpm':
            // RPM segue TPS se existir
            const tps = newSignals.tps
            if (tps) {
              const targetRPM = 850 + (tps.value * 70)
              const newValue = prev[key].value + (targetRPM - prev[key].value) * 0.1
              newSignals[key].value = Math.round(Math.max(signal.min_value, Math.min(signal.max_value, newValue)))
              newSignals[key].trend = targetRPM > prev[key].value ? 'up' : targetRPM < prev[key].value ? 'down' : 'stable'
            } else {
              // Oscilação aleatória
              const change = (Math.random() - 0.5) * 200
              newSignals[key].value = Math.round(Math.max(signal.min_value, Math.min(signal.max_value, prev[key].value + change)))
            }
            break
            
          case 'tps':
            // Acelerador oscila aleatoriamente
            const tpsChange = (Math.random() - 0.5) * 10
            newSignals[key].value = parseFloat(Math.max(signal.min_value, Math.min(signal.max_value, prev[key].value + tpsChange)).toFixed(1))
            newSignals[key].trend = tpsChange > 1 ? 'up' : tpsChange < -1 ? 'down' : 'stable'
            break
            
          case 'map':
            // MAP segue TPS
            const currentTps = newSignals.tps
            if (currentTps) {
              newSignals[key].value = Math.round(35 + (currentTps.value * 2))
            }
            break
            
          case 'ect':
          case 'coolanttemp':
            // Temperatura aumenta gradualmente
            if (prev[key].value < 90) {
              newSignals[key].value = parseFloat(Math.min(90, prev[key].value + 0.5).toFixed(1))
              newSignals[key].trend = 'up'
            } else {
              newSignals[key].value = parseFloat((90 + (Math.random() - 0.5) * 2).toFixed(1))
              newSignals[key].trend = 'stable'
            }
            break
            
          case 'fuellevel':
            // Combustível diminui lentamente
            const currentTps2 = newSignals.tps
            if (currentTps2 && currentTps2.value > 20) {
              newSignals[key].value = parseFloat(Math.max(signal.min_value, prev[key].value - 0.1).toFixed(1))
              newSignals[key].trend = 'down'
            }
            break
            
          case 'battery':
            // Bateria oscila levemente
            newSignals[key].value = parseFloat((13.5 + Math.random() * 0.5).toFixed(1))
            break
            
          case 'lambda':
            // Lambda oscila em torno de 1.00
            newSignals[key].value = parseFloat((1.00 + (Math.random() - 0.5) * 0.1).toFixed(2))
            break
            
          case 'oilpressure':
            // Pressão de óleo segue RPM
            const currentRpm = newSignals.rpm
            if (currentRpm) {
              newSignals[key].value = parseFloat((1 + (currentRpm.value / 2000)).toFixed(1))
            }
            break
            
          case 'boostpressure':
            // Boost em alta carga
            const highLoad = newSignals.tps && newSignals.rpm
            if (highLoad && newSignals.tps.value > 80 && newSignals.rpm.value > 3000) {
              newSignals[key].value = Math.min(2, (newSignals.tps.value - 80) / 10)
              newSignals[key].trend = 'up'
            } else {
              newSignals[key].value = Math.max(0, prev[key].value - 0.1)
              newSignals[key].trend = prev[key].value > 0.1 ? 'down' : 'stable'
            }
            break
            
          case 'speed':
            // Velocidade baseada em RPM e marcha
            const rpm = newSignals.rpm
            const gear = newSignals.gear
            if (rpm && gear) {
              const gearRatios = [0, 35, 60, 90, 120, 150, 180]
              const ratio = gearRatios[Math.min(6, Math.max(0, gear.value))]
              newSignals[key].value = Math.round((rpm.value / 8000) * ratio)
            }
            break
            
          case 'gear':
            // Marcha baseada em RPM
            const currentRpm2 = newSignals.rpm
            if (currentRpm2) {
              newSignals[key].value = Math.min(6, Math.max(0, Math.floor(currentRpm2.value / 1300)))
            }
            break
            
          default:
            // Oscilação genérica para outros sinais
            const genericChange = (Math.random() - 0.5) * range * 0.05
            newSignals[key].value = parseFloat(
              Math.max(signal.min_value, Math.min(signal.max_value, prev[key].value + genericChange)).toFixed(2)
            )
            break
        }
      })
      
      return newSignals
    })
    
    // Atualizar histórico
    setSignalHistory(prev => {
      const newHistory = { ...prev }
      Object.keys(canSignals).forEach(key => {
        if (newHistory[key]) {
          newHistory[key] = [...newHistory[key].slice(-19), canSignals[key].value]
        }
      })
      return newHistory
    })
    
    // Gerar mensagens CAN raw baseadas nos sinais configurados
    generateRawMessages()
  }
  
  // Gerar mensagens CAN raw simuladas baseadas nas configurações
  const generateRawMessages = () => {
    // Agrupar sinais por CAN ID
    const signalsByCanId = {}
    configuredSignals.forEach(signal => {
      if (!signalsByCanId[signal.can_id]) {
        signalsByCanId[signal.can_id] = []
      }
      signalsByCanId[signal.can_id].push(signal)
    })
    
    // Gerar uma mensagem para cada CAN ID configurado
    Object.entries(signalsByCanId).forEach(([canId, signals]) => {
      // Criar array de 8 bytes
      const dataBytes = new Array(8).fill(0)
      
      // Preencher com valores dos sinais
      signals.forEach(signal => {
        const key = signal.signal_name.toLowerCase().replace(/[^a-z0-9]/g, '')
        const currentSignal = canSignals[key]
        
        if (currentSignal) {
          // Aplicar scale e offset inversos para obter valor raw
          let rawValue = currentSignal.value
          if (signal.offset) rawValue -= signal.offset
          if (signal.scale_factor && signal.scale_factor !== 1) {
            rawValue = rawValue / signal.scale_factor
          }
          
          // Converter para inteiro
          rawValue = Math.round(rawValue)
          
          // Calcular byte e bit positions
          const startByte = Math.floor(signal.start_bit / 8)
          const startBitInByte = signal.start_bit % 8
          
          // Simplificado: assumir que cabe em 1-2 bytes
          if (signal.length_bits <= 8) {
            dataBytes[startByte] = rawValue & 0xFF
          } else if (signal.length_bits <= 16) {
            if (signal.byte_order === 'big_endian') {
              dataBytes[startByte] = (rawValue >> 8) & 0xFF
              dataBytes[startByte + 1] = rawValue & 0xFF
            } else {
              dataBytes[startByte] = rawValue & 0xFF
              dataBytes[startByte + 1] = (rawValue >> 8) & 0xFF
            }
          }
        }
      })
      
      // Criar mensagem formatada
      const hexData = dataBytes.map(b => b.toString(16).toUpperCase().padStart(2, '0')).join(' ')
      const signalNames = signals.map(s => s.signal_name).join(', ')
      
      setRawMessages(prev => [{
        id: Date.now() + Math.random(),
        timestamp: new Date().toLocaleTimeString(),
        canId: canId,
        dlc: 8,
        data: hexData,
        decoded: signalNames
      }, ...prev.slice(0, 99)])
    })
    
    setMessageCount(prev => prev + Object.keys(signalsByCanId).length)
  }
  
  // Navegar para página de parâmetros
  const navigateToParameters = () => {
    const event = new CustomEvent('navigate', { detail: 'can-parameters' })
    window.dispatchEvent(event)
  }
  
  // Iniciar/parar simulação
  useEffect(() => {
    if (isSimulating && Object.keys(canSignals).length > 0) {
      intervalRef.current = setInterval(simulateCANData, updateSpeed)
    } else {
      if (intervalRef.current) {
        clearInterval(intervalRef.current)
      }
    }
    
    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current)
      }
    }
  }, [isSimulating, updateSpeed, canSignals])
  
  // Renderizar gauge para cada sinal
  const renderGauge = (key, signal) => {
    if (!signal) return null
    
    const percentage = ((signal.value - signal.min_value) / (signal.max_value - signal.min_value)) * 100
    const isWarning = 
      (key === 'ect' && signal.value > 100) ||
      (key === 'coolanttemp' && signal.value > 100) ||
      (key === 'oilpressure' && signal.value < 2) ||
      (key === 'battery' && signal.value < 12) ||
      (key === 'fuellevel' && signal.value < 20)
    
    const getIcon = () => {
      const category = signal.category
      switch(category) {
        case 'motor': return <Settings className="h-4 w-4" />
        case 'combustivel': return <Droplets className="h-4 w-4" />
        case 'eletrico': return <Zap className="h-4 w-4" />
        case 'pressoes': return <Gauge className="h-4 w-4" />
        case 'velocidade': return <TrendingUp className="h-4 w-4" />
        default: return <Activity className="h-4 w-4" />
      }
    }
    
    const getTrendIcon = () => {
      if (signal.trend === 'up') return <TrendingUp className="h-3 w-3 text-green-500" />
      if (signal.trend === 'down') return <TrendingDown className="h-3 w-3 text-red-500" />
      return <Minus className="h-3 w-3 text-gray-400" />
    }
    
    const getCategoryColor = (category) => {
      const colors = {
        motor: 'border-blue-500',
        combustivel: 'border-green-500',
        eletrico: 'border-yellow-500',
        pressoes: 'border-purple-500',
        velocidade: 'border-orange-500'
      }
      return colors[category] || 'border-gray-500'
    }
    
    return (
      <Card key={key} className={`relative ${isWarning ? 'border-orange-500' : getCategoryColor(signal.category)}`}>
        <CardContent className="p-4">
          <div className="flex items-center justify-between mb-2">
            <div className="flex items-center gap-2">
              {getIcon()}
              <div>
                <span className="text-sm font-medium">{signal.signal_name}</span>
                <Badge variant="outline" className="ml-2 text-xs">
                  {signal.can_id}
                </Badge>
              </div>
            </div>
            {getTrendIcon()}
          </div>
          
          <div className="space-y-2">
            <div className="flex items-baseline justify-between">
              <span className={`text-2xl font-bold ${isWarning ? 'text-orange-500' : ''}`}>
                {typeof signal.value === 'number' ? signal.value.toFixed(signal.decimal_places || 1) : signal.value}
              </span>
              <span className="text-sm text-muted-foreground">{signal.unit}</span>
            </div>
            
            {key !== 'gear' && (
              <Progress value={percentage} className="h-2" />
            )}
            
            <div className="flex justify-between text-xs text-muted-foreground">
              <span>{signal.min_value}</span>
              <span className="text-center truncate px-2">{signal.description}</span>
              <span>{signal.max_value}</span>
            </div>
          </div>
        </CardContent>
      </Card>
    )
  }
  
  // Filtrar sinais por categoria
  const getFilteredSignals = () => {
    if (selectedFilter === 'all') {
      return Object.entries(canSignals)
    }
    return Object.entries(canSignals).filter(([key, signal]) => 
      signal.category === selectedFilter
    )
  }
  
  // Categorias disponíveis baseadas nos sinais carregados
  const availableCategories = [...new Set(configuredSignals.map(s => s.category))]
  
  if (loadingSignals) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="text-center">
          <Database className="h-12 w-12 text-muted-foreground mx-auto mb-4 animate-pulse" />
          <p className="text-muted-foreground">Carregando sinais CAN configurados...</p>
        </div>
      </div>
    )
  }
  
  if (configuredSignals.length === 0) {
    return (
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold tracking-tight">Telemetria CAN Bus</h1>
            <p className="text-muted-foreground">
              Monitor de sinais CAN da ECU FuelTech
            </p>
          </div>
        </div>
        
        <Alert>
          <AlertCircle className="h-4 w-4" />
          <AlertDescription>
            <strong>Nenhum sinal CAN configurado.</strong> 
            <Button 
              variant="link" 
              onClick={navigateToParameters}
              className="ml-2"
            >
              Clique aqui para configurar os sinais
            </Button>
          </AlertDescription>
        </Alert>
      </div>
    )
  }
  
  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Telemetria CAN Bus</h1>
          <p className="text-muted-foreground">
            Monitor de sinais CAN da ECU FuelTech
          </p>
        </div>
        
        <div className="flex items-center space-x-2">
          <Badge variant={isSimulating ? "default" : "secondary"} className="flex items-center gap-1">
            <Signal className="h-3 w-3" />
            {messageCount} mensagens
          </Badge>
          
          <Button
            variant="outline"
            onClick={navigateToParameters}
          >
            <Cog className="mr-2 h-4 w-4" />
            Configurar Sinais
          </Button>
          
          <Button
            variant={isSimulating ? "destructive" : "default"}
            onClick={() => setIsSimulating(!isSimulating)}
          >
            {isSimulating ? (
              <>
                <Pause className="mr-2 h-4 w-4" />
                Parar
              </>
            ) : (
              <>
                <Play className="mr-2 h-4 w-4" />
                Iniciar Simulação
              </>
            )}
          </Button>
        </div>
      </div>
      
      {/* Alert Simulação */}
      <Alert>
        <Radio className="h-4 w-4" />
        <AlertDescription>
          <strong>Modo Simulação:</strong> Os dados exibidos são simulados baseados nas configurações do banco. 
          Quando conectado a uma ECU real via CAN Bus, os valores serão decodificados usando as configurações cadastradas.
          <span className="ml-2">
            • {configuredSignals.length} sinais configurados ({configuredSignals.filter(s => s.is_active).length} ativos)
          </span>
        </AlertDescription>
      </Alert>
      
      {/* Controles */}
      <Card>
        <CardHeader>
          <CardTitle>Configurações de Monitoramento</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div className="space-y-2">
              <Label>Categoria</Label>
              <Select value={selectedFilter} onValueChange={setSelectedFilter}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">Todos os Sinais</SelectItem>
                  {availableCategories.map(cat => (
                    <SelectItem key={cat} value={cat}>
                      {cat.charAt(0).toUpperCase() + cat.slice(1)}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            
            <div className="space-y-2">
              <Label>Velocidade de Atualização</Label>
              <Select value={updateSpeed.toString()} onValueChange={(v) => setUpdateSpeed(parseInt(v))}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="100">100ms (Rápido)</SelectItem>
                  <SelectItem value="500">500ms</SelectItem>
                  <SelectItem value="1000">1s (Normal)</SelectItem>
                  <SelectItem value="2000">2s</SelectItem>
                  <SelectItem value="5000">5s (Lento)</SelectItem>
                </SelectContent>
              </Select>
            </div>
            
            <div className="flex items-center space-x-2">
              <Switch
                id="showRaw"
                checked={showRawData}
                onCheckedChange={setShowRawData}
              />
              <Label htmlFor="showRaw">Mostrar Dados Raw</Label>
            </div>
            
            <div className="flex items-center gap-2">
              <Button variant="outline" className="flex-1">
                <Download className="mr-2 h-4 w-4" />
                Exportar
              </Button>
              <Button variant="outline" size="icon">
                <Settings className="h-4 w-4" />
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>
      
      {/* Tabs de Visualização */}
      <Tabs defaultValue="gauges" className="space-y-4">
        <TabsList>
          <TabsTrigger value="gauges">Medidores</TabsTrigger>
          <TabsTrigger value="graphs">Gráficos</TabsTrigger>
          {showRawData && <TabsTrigger value="raw">Dados Raw</TabsTrigger>}
        </TabsList>
        
        {/* Tab Medidores */}
        <TabsContent value="gauges" className="space-y-4">
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
            {getFilteredSignals().map(([key, signal]) => renderGauge(key, signal))}
          </div>
        </TabsContent>
        
        {/* Tab Gráficos */}
        <TabsContent value="graphs" className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Mini gráficos simplificados */}
            {Object.entries(signalHistory).filter(([key]) => {
              const signal = canSignals[key]
              return selectedFilter === 'all' || signal?.category === selectedFilter
            }).map(([key, history]) => {
              const signal = canSignals[key]
              if (!signal) return null
              
              return (
                <Card key={key}>
                  <CardHeader className="pb-3">
                    <CardTitle className="text-sm flex items-center justify-between">
                      <span>{signal.signal_name} - Últimos 20 valores</span>
                      <Badge variant="outline">{signal.can_id}</Badge>
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="h-24 flex items-end justify-between gap-1">
                      {history.map((value, index) => {
                        const height = ((value - signal.min_value) / (signal.max_value - signal.min_value)) * 100
                        return (
                          <div
                            key={index}
                            className="flex-1 bg-primary rounded-t"
                            style={{ height: `${Math.max(2, height)}%` }}
                          />
                        )
                      })}
                      {history.length === 0 && (
                        <div className="flex-1 text-center text-muted-foreground text-sm">
                          Aguardando dados...
                        </div>
                      )}
                    </div>
                    <div className="flex justify-between mt-2 text-xs text-muted-foreground">
                      <span>Min: {signal.min_value}</span>
                      <span>Atual: {signal.value?.toFixed(1)} {signal.unit}</span>
                      <span>Max: {signal.max_value}</span>
                    </div>
                  </CardContent>
                </Card>
              )
            })}
          </div>
        </TabsContent>
        
        {/* Tab Raw Data */}
        {showRawData && (
          <TabsContent value="raw" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>Mensagens CAN Raw</CardTitle>
                <CardDescription>
                  Últimas 100 mensagens recebidas do barramento CAN
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-2 max-h-96 overflow-auto font-mono text-xs">
                  {rawMessages.map(msg => (
                    <div key={msg.id} className="flex items-center gap-4 p-2 bg-muted rounded">
                      <span className="text-muted-foreground">{msg.timestamp}</span>
                      <Badge variant="outline">{msg.canId}</Badge>
                      <span>DLC: {msg.dlc}</span>
                      <span className="flex-1">{msg.data}</span>
                      <span className="text-primary">{msg.decoded}</span>
                    </div>
                  ))}
                  {rawMessages.length === 0 && (
                    <div className="text-center py-8 text-muted-foreground">
                      Inicie a simulação para ver as mensagens CAN
                    </div>
                  )}
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        )}
      </Tabs>
      
      {/* Status Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-sm">Taxa de Atualização</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{1000/updateSpeed} Hz</div>
            <p className="text-xs text-muted-foreground">
              {messageCount} mensagens processadas
            </p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-sm">Sinais Monitorados</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{getFilteredSignals().length}</div>
            <p className="text-xs text-muted-foreground">
              de {Object.keys(canSignals).length} ativos
            </p>
            <p className="text-xs text-blue-500 mt-1">
              {configuredSignals.length} configurados
            </p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-sm">Status da ECU</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-center gap-2">
              <div className={`h-3 w-3 rounded-full ${isSimulating ? 'bg-green-500 animate-pulse' : 'bg-gray-400'}`} />
              <span className="text-2xl font-bold">
                {isSimulating ? 'Simulando' : 'Desconectado'}
              </span>
            </div>
            <p className="text-xs text-muted-foreground">
              FuelTech FT600 (Configurado)
            </p>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}

export default CANBusPage