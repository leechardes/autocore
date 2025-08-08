import React, { useState, useEffect } from 'react'
import { 
  Download, 
  FileJson, 
  Settings, 
  Cpu, 
  Monitor,
  ToggleLeft,
  Eye,
  RefreshCw,
  Copy,
  Check,
  AlertCircle,
  Info,
  Code,
  Zap,
  Wifi
} from 'lucide-react'

import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Label } from '@/components/ui/label'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Textarea } from '@/components/ui/textarea'
import { Switch } from '@/components/ui/switch'
import api from '@/lib/api'

const ConfigGeneratorPage = () => {
  const [devices, setDevices] = useState([])
  const [screens, setScreens] = useState([])
  const [relayBoards, setRelayBoards] = useState([])
  const [relayChannels, setRelayChannels] = useState([])
  const [loading, setLoading] = useState(true)
  const [generating, setGenerating] = useState(false)
  const [selectedDevice, setSelectedDevice] = useState(null)
  const [generatedConfig, setGeneratedConfig] = useState(null)
  const [isPreviewOpen, setIsPreviewOpen] = useState(false)
  const [copySuccess, setCopySuccess] = useState(false)
  const [error, setError] = useState(null)

  const [exportOptions, setExportOptions] = useState({
    includeScreens: true,
    includeRelays: true,
    includeWifi: true,
    includeMqtt: true,
    minify: false,
    addComments: true
  })

  // Carregar dados
  const loadData = async () => {
    try {
      setLoading(true)
      setError(null)
      
      console.log('Carregando dados...')
      const [devicesData, screensData, boardsData, channelsData] = await Promise.all([
        api.getDevices(),
        api.getScreens(),
        api.getRelayBoards(),
        api.getRelayChannels()
      ])
      
      console.log('Dados carregados:', {
        devices: devicesData?.length || 0,
        screens: screensData?.length || 0,
        boards: boardsData?.length || 0,
        channels: channelsData?.length || 0
      })
      
      setDevices(devicesData || [])
      setScreens(screensData || [])
      setRelayBoards(boardsData || [])
      setRelayChannels(channelsData || [])
    } catch (error) {
      console.error('Erro carregando dados:', error)
      setError(`Erro ao carregar dados: ${error.message}`)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadData()
  }, [])

  // Gerar configuração para dispositivo
  const generateConfig = async (device) => {
    try {
      console.log('Gerando config para device:', device)
      setGenerating(true)
      setSelectedDevice(device)

      // Buscar configuração da API
      let apiConfig = {}
      try {
        apiConfig = await api.generateDeviceConfig(device.uuid)
        console.log('API config recebida:', apiConfig)
      } catch (error) {
        console.log('API config não disponível, gerando localmente:', error)
      }
      
      // Filtrar dados baseado no dispositivo - verificar se screens existe
      const deviceScreens = screens ? screens.filter(s => s.device_id === device.id) : []
      console.log('Device screens:', deviceScreens)
      
      // Buscar placas e canais do dispositivo - verificar se arrays existem
      const deviceBoards = relayBoards ? relayBoards.filter(b => b.device_id === device.id) : []
      const deviceRelays = []
      for (const board of deviceBoards) {
        const boardChannels = relayChannels ? relayChannels.filter(c => c.board_id === board.id) : []
        deviceRelays.push(...boardChannels)
      }
      console.log('Device boards:', deviceBoards, 'Device relays:', deviceRelays)

      // Construir configuração personalizada
      const config = {
        device: {
          uuid: device.uuid,
          name: device.name,
          type: device.type,
          version: "1.0.0",
          firmware_version: device.firmware_version || "esp32-autocore-v1.2.3"
        },
        network: exportOptions.includeWifi ? {
          wifi: {
            ssid: "${WIFI_SSID}",
            password: "${WIFI_PASSWORD}",
            timeout: 30000,
            retry_attempts: 3
          },
          mqtt: exportOptions.includeMqtt ? {
            broker: "${MQTT_BROKER}",
            port: 1883,
            username: "${MQTT_USER}",
            password: "${MQTT_PASS}",
            client_id: device.uuid,
            topics: {
              status: `autocore/${device.uuid}/status`,
              commands: `autocore/${device.uuid}/commands`,
              telemetry: `autocore/${device.uuid}/telemetry`
            }
          } : undefined
        } : undefined,
        hardware: {
          pins: getDevicePinConfig(device.type),
          i2c: device.type.includes('display') ? {
            sda: 21,
            scl: 22,
            frequency: 400000
          } : undefined,
          spi: device.type.includes('relay') ? {
            miso: 19,
            mosi: 23,
            sclk: 18,
            cs: 5
          } : undefined
        },
        screens: exportOptions.includeScreens && deviceScreens.length > 0 ? 
          deviceScreens.map(screen => ({
            id: screen.id,
            name: screen.name,
            type: screen.screen_type,
            title: screen.title,
            visible: screen.is_visible
          })) : undefined,
        relays: exportOptions.includeRelays && deviceRelays.length > 0 ? 
          deviceRelays.map(relay => ({
            channel: relay.channel_number,
            name: relay.name,
            function_type: relay.function_type,
            icon: relay.icon,
            color: relay.color,
            protection_mode: relay.protection_mode,
            default_state: false,
            auto_off_delay: relay.function_type === 'pulse' ? 1000 : null
          })) : undefined,
        settings: {
          telemetry_interval: 5000,
          status_report_interval: 30000,
          deep_sleep_enabled: false,
          watchdog_timeout: 60000,
          debug_mode: false,
          log_level: "INFO"
        },
        generated: {
          timestamp: new Date().toISOString(),
          generator: "AutoCore Config App v1.0.0",
          config_version: "1.0"
        }
      }

      // Remover campos undefined se minify estiver ativado
      if (exportOptions.minify) {
        removeUndefinedFields(config)
      }

      setGeneratedConfig(config)
      setIsPreviewOpen(true)

    } catch (error) {
      console.error('Erro gerando configuração:', error)
      alert(`Erro ao gerar configuração: ${error.message}`)
      // Garantir que modal não abre se houve erro
      setIsPreviewOpen(false)
      setGeneratedConfig(null)
    } finally {
      setGenerating(false)
    }
  }

  // Configuração de pinos por tipo de dispositivo
  const getDevicePinConfig = (type) => {
    const pinConfigs = {
      'esp32_relay': {
        relay_pins: [2, 4, 16, 17, 18, 19, 21, 22, 23, 25, 26, 27, 32, 33],
        status_led: 2,
        button: 0
      },
      'esp32_display': {
        display_pins: {
          sda: 21,
          scl: 22,
          reset: 4
        },
        button: 0,
        status_led: 2
      },
      'esp32_sensor': {
        analog_pins: [32, 33, 34, 35, 36, 39],
        digital_pins: [2, 4, 16, 17],
        status_led: 2,
        button: 0
      }
    }
    
    return pinConfigs[type] || pinConfigs['esp32_relay']
  }

  // Remover campos undefined recursivamente
  const removeUndefinedFields = (obj) => {
    Object.keys(obj).forEach(key => {
      if (obj[key] === undefined) {
        delete obj[key]
      } else if (typeof obj[key] === 'object' && obj[key] !== null) {
        removeUndefinedFields(obj[key])
        if (Object.keys(obj[key]).length === 0) {
          delete obj[key]
        }
      }
    })
    return obj
  }

  // Exportar configuração
  const exportConfig = (format = 'json') => {
    if (!generatedConfig) return

    let content, filename, mimeType

    switch (format) {
      case 'json':
        content = exportOptions.minify 
          ? JSON.stringify(generatedConfig)
          : JSON.stringify(generatedConfig, null, 2)
        filename = `${selectedDevice.uuid}_config.json`
        mimeType = 'application/json'
        break
        
      case 'h':
        content = generateCppHeader(generatedConfig)
        filename = `${selectedDevice.uuid}_config.h`
        mimeType = 'text/plain'
        break
        
      case 'yaml':
        content = generateYamlConfig(generatedConfig)
        filename = `${selectedDevice.uuid}_config.yaml`
        mimeType = 'text/yaml'
        break
        
      default:
        return
    }

    // Download do arquivo
    const blob = new Blob([content], { type: mimeType })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = filename
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  }

  // Gerar header C++
  const generateCppHeader = (config) => {
    return `// AutoCore Device Configuration
// Generated: ${new Date().toISOString()}
// Device: ${config.device.name} (${config.device.uuid})

#ifndef AUTOCORE_CONFIG_H
#define AUTOCORE_CONFIG_H

#define DEVICE_UUID "${config.device.uuid}"
#define DEVICE_NAME "${config.device.name}"
#define DEVICE_TYPE "${config.device.type}"
#define FIRMWARE_VERSION "${config.device.firmware_version}"

// Hardware Configuration
${config.hardware.pins ? Object.entries(config.hardware.pins).map(([key, value]) => 
  Array.isArray(value) 
    ? `#define ${key.toUpperCase()}_PINS {${value.join(', ')}}`
    : `#define ${key.toUpperCase()} ${value}`
).join('\n') : ''}

// Network Configuration
${config.network?.mqtt ? `
#define MQTT_BROKER "${config.network.mqtt.broker}"
#define MQTT_PORT ${config.network.mqtt.port}
#define MQTT_CLIENT_ID "${config.network.mqtt.client_id}"
` : ''}

// Settings
#define TELEMETRY_INTERVAL ${config.settings.telemetry_interval}
#define STATUS_REPORT_INTERVAL ${config.settings.status_report_interval}
#define WATCHDOG_TIMEOUT ${config.settings.watchdog_timeout}

#endif // AUTOCORE_CONFIG_H`
  }

  // Gerar YAML (simplificado)
  const generateYamlConfig = (config) => {
    return `# AutoCore Device Configuration
# Generated: ${new Date().toISOString()}
# Device: ${config.device.name} (${config.device.uuid})

device:
  uuid: "${config.device.uuid}"
  name: "${config.device.name}"
  type: "${config.device.type}"
  firmware_version: "${config.device.firmware_version}"

network:
  wifi:
    ssid: "\${WIFI_SSID}"
    password: "\${WIFI_PASSWORD}"
  mqtt:
    broker: "\${MQTT_BROKER}"
    port: 1883

settings:
  telemetry_interval: ${config.settings.telemetry_interval}
  status_report_interval: ${config.settings.status_report_interval}
`
  }

  // Copiar para clipboard
  const copyToClipboard = async () => {
    if (!generatedConfig) return

    try {
      const text = exportOptions.minify 
        ? JSON.stringify(generatedConfig)
        : JSON.stringify(generatedConfig, null, 2)
      
      await navigator.clipboard.writeText(text)
      setCopySuccess(true)
      setTimeout(() => setCopySuccess(false), 2000)
    } catch (error) {
      console.error('Erro copiando:', error)
    }
  }

  // Exportar todas as configurações
  const exportAllConfigs = async () => {
    try {
      setGenerating(true)
      const allConfigs = {}
      
      for (const device of devices) {
        try {
          const config = await api.generateDeviceConfig(device.uuid)
          allConfigs[device.uuid] = config
        } catch (error) {
          console.log(`Erro gerando config para ${device.uuid}`)
        }
      }
      
      const content = JSON.stringify({
        generated: new Date().toISOString(),
        devices: allConfigs
      }, null, 2)
      
      const blob = new Blob([content], { type: 'application/json' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = 'autocore_all_configs.json'
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
      
    } catch (error) {
      console.error('Erro exportando todas as configurações:', error)
    } finally {
      setGenerating(false)
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent"></div>
        <span className="ml-2 text-muted-foreground">Carregando dados...</span>
      </div>
    )
  }

  if (error) {
    return (
      <div className="p-6">
        <Alert className="bg-red-50 border-red-200">
          <AlertCircle className="h-4 w-4 text-red-600" />
          <AlertDescription className="text-red-800">
            {error}
          </AlertDescription>
        </Alert>
        <Button onClick={() => loadData()} className="mt-4">
          <RefreshCw className="mr-2 h-4 w-4" />
          Tentar Novamente
        </Button>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Gerador de Configuração</h1>
          <p className="text-muted-foreground">
            Gere arquivos de configuração JSON, C++ e YAML para seus dispositivos ESP32
          </p>
        </div>
        
        <div className="flex items-center space-x-2">
          <Button variant="outline" onClick={exportAllConfigs} disabled={generating}>
            <Download className="mr-2 h-4 w-4" />
            Exportar Tudo
          </Button>
          <Button onClick={() => loadData()}>
            <RefreshCw className="mr-2 h-4 w-4" />
            Atualizar
          </Button>
        </div>
      </div>

      {/* Options */}
      <Card>
        <CardHeader>
          <CardTitle>Opções de Export</CardTitle>
          <CardDescription>Configure quais informações incluir na configuração</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            <div className="flex items-center space-x-2">
              <Switch
                id="includeScreens"
                checked={exportOptions.includeScreens}
                onCheckedChange={(checked) => 
                  setExportOptions({...exportOptions, includeScreens: checked})
                }
              />
              <Label htmlFor="includeScreens">Configurações de Telas</Label>
            </div>
            
            <div className="flex items-center space-x-2">
              <Switch
                id="includeRelays"
                checked={exportOptions.includeRelays}
                onCheckedChange={(checked) => 
                  setExportOptions({...exportOptions, includeRelays: checked})
                }
              />
              <Label htmlFor="includeRelays">Configurações de Relés</Label>
            </div>
            
            <div className="flex items-center space-x-2">
              <Switch
                id="includeWifi"
                checked={exportOptions.includeWifi}
                onCheckedChange={(checked) => 
                  setExportOptions({...exportOptions, includeWifi: checked})
                }
              />
              <Label htmlFor="includeWifi">Configurações WiFi</Label>
            </div>
            
            <div className="flex items-center space-x-2">
              <Switch
                id="includeMqtt"
                checked={exportOptions.includeMqtt}
                onCheckedChange={(checked) => 
                  setExportOptions({...exportOptions, includeMqtt: checked})
                }
              />
              <Label htmlFor="includeMqtt">Configurações MQTT</Label>
            </div>
            
            <div className="flex items-center space-x-2">
              <Switch
                id="minify"
                checked={exportOptions.minify}
                onCheckedChange={(checked) => 
                  setExportOptions({...exportOptions, minify: checked})
                }
              />
              <Label htmlFor="minify">JSON Minificado</Label>
            </div>
            
            <div className="flex items-center space-x-2">
              <Switch
                id="addComments"
                checked={exportOptions.addComments}
                onCheckedChange={(checked) => 
                  setExportOptions({...exportOptions, addComments: checked})
                }
              />
              <Label htmlFor="addComments">Incluir Comentários</Label>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Devices Grid */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {devices.map((device) => {
          const deviceScreens = screens.filter(s => s.device_id === device.id)
          const deviceBoards = relayBoards.filter(b => b.device_id === device.id)
          let deviceRelaysCount = 0
          for (const board of deviceBoards) {
            const boardChannels = relayChannels.filter(c => c.board_id === board.id)
            deviceRelaysCount += boardChannels.length
          }
          
          const getDeviceIcon = (type) => {
            switch (type) {
              case 'esp32_display': return Monitor
              case 'esp32_relay': return ToggleLeft
              case 'esp32_sensor': return Zap
              default: return Cpu
            }
          }
          
          const DeviceIcon = getDeviceIcon(device.type)
          
          return (
            <Card key={device.id} className="relative">
              <CardContent className="p-6">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
                      <DeviceIcon className="h-5 w-5 text-primary" />
                    </div>
                    <div>
                      <h3 className="font-semibold">{device.name}</h3>
                      <p className="text-sm text-muted-foreground">{device.uuid}</p>
                    </div>
                  </div>
                  <Badge 
                    variant={device.status === 'online' ? 'default' : 'secondary'}
                    className="flex items-center gap-1"
                  >
                    <Wifi className="h-3 w-3" />
                    {device.status}
                  </Badge>
                </div>
                
                <div className="space-y-2 text-sm text-muted-foreground">
                  <div className="flex items-center justify-between">
                    <span>Tipo:</span>
                    <span className="font-medium">
                      {device.type.replace('esp32_', '').toUpperCase()}
                    </span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span>IP:</span>
                    <span className="font-mono">{device.ip_address || 'N/A'}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span>Telas:</span>
                    <span className="flex items-center gap-1">
                      <Monitor className="h-3 w-3" />
                      {deviceScreens.length}
                    </span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span>Relés:</span>
                    <span className="flex items-center gap-1">
                      <ToggleLeft className="h-3 w-3" />
                      {deviceRelaysCount}
                    </span>
                  </div>
                </div>
                
                <Button 
                  className="w-full mt-4" 
                  onClick={() => generateConfig(device)}
                  disabled={generating}
                >
                  {generating && selectedDevice?.id === device.id ? (
                    <>
                      <RefreshCw className="mr-2 h-4 w-4 animate-spin" />
                      Gerando...
                    </>
                  ) : (
                    <>
                      <FileJson className="mr-2 h-4 w-4" />
                      Gerar Config
                    </>
                  )}
                </Button>
              </CardContent>
            </Card>
          )
        })}
      </div>

      {/* Empty State */}
      {devices.length === 0 && (
        <div className="text-center py-12">
          <Cpu className="mx-auto h-12 w-12 text-muted-foreground/50" />
          <h3 className="mt-2 text-sm font-semibold">Nenhum dispositivo encontrado</h3>
          <p className="mt-1 text-sm text-muted-foreground">
            Configure seus dispositivos ESP32 primeiro para gerar as configurações.
          </p>
        </div>
      )}

      {/* Config Preview Dialog */}
      {isPreviewOpen && generatedConfig && (
        <Dialog open={isPreviewOpen} onOpenChange={setIsPreviewOpen}>
          <DialogContent className="max-w-4xl max-h-[80vh] overflow-auto">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <FileJson className="h-5 w-5" />
              Configuração: {selectedDevice?.name}
            </DialogTitle>
            <DialogDescription>
              Preview e exportação da configuração gerada
            </DialogDescription>
          </DialogHeader>
          
          <Tabs defaultValue="json" className="flex-1">
            <div className="flex items-center justify-between mb-4">
              <TabsList>
                <TabsTrigger value="json">JSON</TabsTrigger>
                <TabsTrigger value="cpp">C++ Header</TabsTrigger>
                <TabsTrigger value="yaml">YAML</TabsTrigger>
              </TabsList>
              
              <div className="flex items-center space-x-2">
                <Button variant="outline" size="sm" onClick={copyToClipboard}>
                  {copySuccess ? (
                    <Check className="h-4 w-4 text-green-600" />
                  ) : (
                    <Copy className="h-4 w-4" />
                  )}
                </Button>
                <Button size="sm" onClick={() => exportConfig('json')}>
                  <Download className="mr-2 h-4 w-4" />
                  JSON
                </Button>
                <Button variant="outline" size="sm" onClick={() => exportConfig('h')}>
                  <Code className="mr-2 h-4 w-4" />
                  C++
                </Button>
                <Button variant="outline" size="sm" onClick={() => exportConfig('yaml')}>
                  <Settings className="mr-2 h-4 w-4" />
                  YAML
                </Button>
              </div>
            </div>
            
            <TabsContent value="json" className="space-y-0">
              <Textarea
                value={generatedConfig ? JSON.stringify(generatedConfig, null, 2) : ''}
                readOnly
                className="min-h-[400px] font-mono text-sm"
              />
            </TabsContent>
            
            <TabsContent value="cpp" className="space-y-0">
              <Textarea
                value={generatedConfig ? generateCppHeader(generatedConfig) : ''}
                readOnly
                className="min-h-[400px] font-mono text-sm"
              />
            </TabsContent>
            
            <TabsContent value="yaml" className="space-y-0">
              <Textarea
                value={generatedConfig ? generateYamlConfig(generatedConfig) : ''}
                readOnly
                className="min-h-[400px] font-mono text-sm"
              />
            </TabsContent>
          </Tabs>
          
          <Alert>
            <Info className="h-4 w-4" />
            <AlertDescription>
              Substitua as variáveis como ${WIFI_SSID}, ${MQTT_BROKER} pelos valores reais antes de usar no ESP32.
            </AlertDescription>
          </Alert>
          
          <DialogFooter>
            <Button variant="outline" onClick={() => setIsPreviewOpen(false)}>
              Fechar
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
      )}
    </div>
  )
}

export default ConfigGeneratorPage