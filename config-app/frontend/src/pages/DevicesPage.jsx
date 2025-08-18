import React, { useState, useEffect } from 'react'
import { 
  Plus, 
  Search, 
  Filter, 
  MoreHorizontal, 
  Wifi, 
  WifiOff, 
  Settings,
  Trash2,
  Edit,
  Power,
  Activity,
  Clock,
  MapPin
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
  DialogTrigger,
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
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Checkbox } from '@/components/ui/checkbox'
import { Separator } from '@/components/ui/separator'
import {
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from '@/components/ui/tabs'
import api from '@/lib/api'
import { DEVICE_TYPES, normalizeDeviceType } from '@/utils/normalizers'

const DevicesPage = () => {
  const [devices, setDevices] = useState([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedDevice, setSelectedDevice] = useState(null)
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false)
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false)
  const [isConfigDialogOpen, setIsConfigDialogOpen] = useState(false)
  const [formData, setFormData] = useState({
    name: '',
    type: 'ESP32_RELAY',
    ip_address: '',
    mac_address: '',
    location: '',
    is_active: true
  })
  
  // Estado para configurações avançadas
  const [advancedConfig, setAdvancedConfig] = useState({})
  
  // Estado para capacidades
  const [capabilities, setCapabilities] = useState({})

  // Carregar dispositivos
  const loadDevices = async () => {
    try {
      setLoading(true)
      const data = await api.getDevices()
      setDevices(data)
    } catch (error) {
      console.error('Erro carregando dispositivos:', error)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadDevices()
  }, [])

  // Filtrar dispositivos
  const filteredDevices = devices.filter(device =>
    device.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    device.type.toLowerCase().includes(searchTerm.toLowerCase()) ||
    device.ip_address?.includes(searchTerm) ||
    device.mac_address?.includes(searchTerm)
  )


  // Device type icon e label
  const getDeviceTypeInfo = (type) => {
    const normalizedType = normalizeDeviceType(type)
    const types = {
      ESP32_RELAY: { label: 'ESP32 Relé', icon: Power },
      ESP32_DISPLAY: { label: 'ESP32 Display', icon: Activity },
      ESP32_SENSOR: { label: 'ESP32 Sensor', icon: Activity },
      ESP32_CAN: { label: 'ESP32 CAN Interface', icon: Settings },
      ESP32_CONTROL: { label: 'ESP32 Controle', icon: Settings }
    }
    
    return types[normalizedType] || { label: normalizedType, icon: Settings }
  }

  // Localizações pré-definidas
  const vehicleLocations = [
    { value: 'painel', label: 'Painel' },
    { value: 'console_central', label: 'Console Central' },
    { value: 'porta_malas', label: 'Porta-Malas' },
    { value: 'motor', label: 'Compartimento do Motor' },
    { value: 'porta_esquerda', label: 'Porta Esquerda' },
    { value: 'porta_direita', label: 'Porta Direita' },
    { value: 'teto', label: 'Teto' },
    { value: 'assoalho', label: 'Assoalho' },
    { value: 'porta_luvas', label: 'Porta-Luvas' },
    { value: 'coluna_a', label: 'Coluna A' },
    { value: 'coluna_b', label: 'Coluna B' },
    { value: 'para_choque_dianteiro', label: 'Para-choque Dianteiro' },
    { value: 'para_choque_traseiro', label: 'Para-choque Traseiro' },
    { value: 'custom', label: 'Outro (especificar)' }
  ]

  // Configurações avançadas por tipo de dispositivo
  const getAdvancedFieldsByType = (type) => {
    const normalizedType = normalizeDeviceType(type)
    const fields = {
      ESP32_RELAY: [
        { key: 'relay_count', label: 'Número de Relés', type: 'number', placeholder: '16', required: true },
        { key: 'board_model', label: 'Modelo da Placa', type: 'select', options: [
          { value: '16ch_standard', label: '16 Canais Standard' },
          { value: '8ch_standard', label: '8 Canais Standard' },
          { value: '4ch_standard', label: '4 Canais Standard' },
          { value: 'custom', label: 'Personalizado' }
        ]},
        { key: 'voltage', label: 'Tensão de Operação', type: 'select', options: [
          { value: '12V', label: '12V' },
          { value: '24V', label: '24V' },
          { value: '5V', label: '5V' }
        ]},
        { key: 'max_current', label: 'Corrente Máxima (A)', type: 'number', placeholder: '10' }
      ],
      ESP32_DISPLAY: [
        { key: 'screen_size', label: 'Tamanho da Tela', type: 'select', options: [
          { value: '2.4inch', label: '2.4 polegadas' },
          { value: '2.8inch', label: '2.8 polegadas' },
          { value: '3.5inch', label: '3.5 polegadas' },
          { value: '5inch', label: '5 polegadas' },
          { value: '7inch', label: '7 polegadas' },
          { value: '10inch', label: '10 polegadas' }
        ]},
        { key: 'resolution', label: 'Resolução', type: 'select', options: [
          { value: '320x240', label: '320x240' },
          { value: '480x320', label: '480x320' },
          { value: '800x480', label: '800x480' },
          { value: '1024x600', label: '1024x600' }
        ]},
        { key: 'touch_enabled', label: 'Touch Screen', type: 'checkbox' },
        { key: 'brightness_control', label: 'Controle de Brilho', type: 'checkbox' }
      ],
      esp32_sensor: [
        { key: 'sensor_type', label: 'Tipo de Sensor', type: 'select', options: [
          { value: 'temperature', label: 'Temperatura' },
          { value: 'pressure', label: 'Pressão' },
          { value: 'flow', label: 'Fluxo' },
          { value: 'level', label: 'Nível' },
          { value: 'multi', label: 'Múltiplos Sensores' }
        ]},
        { key: 'measurement_unit', label: 'Unidade de Medida', type: 'text', placeholder: '°C, PSI, L/min' },
        { key: 'min_value', label: 'Valor Mínimo', type: 'number', placeholder: '0' },
        { key: 'max_value', label: 'Valor Máximo', type: 'number', placeholder: '100' },
        { key: 'sample_rate', label: 'Taxa de Amostragem (Hz)', type: 'number', placeholder: '10' }
      ],
      esp32_can: [
        { key: 'can_speed', label: 'Velocidade CAN', type: 'select', options: [
          { value: '250000', label: '250 kbps' },
          { value: '500000', label: '500 kbps' },
          { value: '1000000', label: '1 Mbps' }
        ]},
        { key: 'ecu_type', label: 'Tipo de ECU', type: 'select', options: [
          { value: 'fueltech', label: 'FuelTech' },
          { value: 'megasquirt', label: 'MegaSquirt' },
          { value: 'haltech', label: 'Haltech' },
          { value: 'aem', label: 'AEM' },
          { value: 'generic', label: 'Genérico' }
        ]},
        { key: 'termination_resistor', label: 'Resistor de Terminação', type: 'checkbox' },
        { key: 'filter_ids', label: 'IDs para Filtrar (hex)', type: 'text', placeholder: '0x200,0x201,0x202' }
      ],
      esp32_control: [
        { key: 'button_count', label: 'Número de Botões', type: 'number', placeholder: '12' },
        { key: 'led_count', label: 'Número de LEDs', type: 'number', placeholder: '12' },
        { key: 'button_type', label: 'Tipo de Botões', type: 'select', options: [
          { value: 'momentary', label: 'Momentâneo' },
          { value: 'toggle', label: 'Toggle' },
          { value: 'mixed', label: 'Misto' }
        ]},
        { key: 'backlight', label: 'Iluminação', type: 'select', options: [
          { value: 'none', label: 'Nenhuma' },
          { value: 'white', label: 'Branca' },
          { value: 'rgb', label: 'RGB' }
        ]},
        { key: 'encoder_count', label: 'Número de Encoders', type: 'number', placeholder: '0' }
      ]
    }
    
    return fields[normalizedType] || []
  }

  // Capacidades por tipo de dispositivo
  const getCapabilitiesByType = (type) => {
    const normalizedType = normalizeDeviceType(type)
    const capabilities = {
      ESP32_RELAY: [
        { key: 'relay_control', label: 'Controle de Relés', description: 'Permite controlar relés remotamente' },
        { key: 'status_report', label: 'Relatório de Status', description: 'Envia status dos relés periodicamente' },
        { key: 'ota_update', label: 'Atualização OTA', description: 'Permite atualização de firmware remota' },
        { key: 'timer_control', label: 'Controle por Timer', description: 'Programação de horários para relés' },
        { key: 'interlock', label: 'Intertravamento', description: 'Previne ativação simultânea de relés conflitantes' }
      ],
      ESP32_DISPLAY: [
        { key: 'touch_input', label: 'Entrada Touch', description: 'Aceita entrada por toque na tela' },
        { key: 'screen_render', label: 'Renderização de Tela', description: 'Renderiza interfaces gráficas' },
        { key: 'brightness_control', label: 'Controle de Brilho', description: 'Ajuste de brilho da tela' },
        { key: 'screen_rotation', label: 'Rotação de Tela', description: 'Suporta rotação da interface' },
        { key: 'multi_page', label: 'Múltiplas Páginas', description: 'Navegação entre diferentes telas' }
      ],
      ESP32_SENSOR: [
        { key: 'data_logging', label: 'Log de Dados', description: 'Armazena histórico de leituras' },
        { key: 'alert_threshold', label: 'Alertas por Limite', description: 'Envia alertas quando valores excedem limites' },
        { key: 'calibration', label: 'Calibração', description: 'Suporta calibração de sensores' },
        { key: 'multi_sensor', label: 'Múltiplos Sensores', description: 'Leitura de vários sensores simultaneamente' },
        { key: 'data_filtering', label: 'Filtragem de Dados', description: 'Aplica filtros para reduzir ruído' }
      ],
      ESP32_CAN: [
        { key: 'can_read', label: 'Leitura CAN', description: 'Lê mensagens do barramento CAN' },
        { key: 'can_write', label: 'Escrita CAN', description: 'Envia mensagens para o barramento CAN' },
        { key: 'obd2', label: 'Protocolo OBD2', description: 'Suporta diagnóstico OBD2' },
        { key: 'can_filter', label: 'Filtro CAN', description: 'Filtra mensagens por ID' },
        { key: 'can_bridge', label: 'Bridge CAN', description: 'Ponte entre CAN e MQTT' }
      ],
      ESP32_CONTROL: [
        { key: 'button_input', label: 'Entrada de Botões', description: 'Leitura de botões físicos' },
        { key: 'led_output', label: 'Controle de LEDs', description: 'Controla LEDs indicadores' },
        { key: 'encoder_input', label: 'Entrada de Encoder', description: 'Leitura de encoders rotativos' },
        { key: 'haptic_feedback', label: 'Feedback Háptico', description: 'Vibração para feedback tátil' },
        { key: 'backlight_control', label: 'Controle de Iluminação', description: 'Controla iluminação de fundo' }
      ]
    }
    
    return capabilities[normalizedType] || []
  }

  // Salvar dispositivo
  const handleSaveDevice = async (e) => {
    e.preventDefault()
    
    try {
      if (selectedDevice) {
        // Editar - salvar apenas dados básicos
        await api.updateDevice(selectedDevice.id, formData)
      } else {
        // Adicionar
        await api.createDevice({
          ...formData,
          uuid: `esp32-${Date.now()}`
        })
      }
      
      // Recarregar lista
      await loadDevices()
      
      // Fechar diálogos
      setIsAddDialogOpen(false)
      setIsEditDialogOpen(false)
      resetForm()
      
    } catch (error) {
      console.error('Erro salvando dispositivo:', error)
    }
  }

  // Deletar dispositivo
  const handleDeleteDevice = async (device) => {
    try {
      await api.deleteDevice(device.id)
      await loadDevices()
    } catch (error) {
      console.error('Erro deletando dispositivo:', error)
    }
  }

  // Reset form
  const resetForm = () => {
    setFormData({
      name: '',
      type: 'ESP32_RELAY',
      ip_address: '',
      mac_address: '',
      location: '',
      is_active: true
    })
    setAdvancedConfig({})
    setSelectedDevice(null)
  }

  // Open edit dialog
  const openEditDialog = (device) => {
    setSelectedDevice(device)
    setFormData({
      name: device.name || '',
      type: normalizeDeviceType(device.type) || 'ESP32_RELAY',
      ip_address: device.ip_address || '',
      mac_address: device.mac_address || '',
      location: device.location || '',
      is_active: device.is_active ?? true
    })
    setIsEditDialogOpen(true)
  }

  // Open config dialog
  const openConfigDialog = async (device) => {
    setSelectedDevice(device)
    setFormData({
      name: device.name || '',
      type: normalizeDeviceType(device.type) || 'ESP32_RELAY',
      ip_address: device.ip_address || '',
      mac_address: device.mac_address || '',
      location: device.location || '',
      is_active: device.is_active ?? true
    })
    
    // Carregar configurações existentes
    try {
      const response = await api.getDevice(device.id)
      
      // Carregar parâmetros do configuration_json
      if (response.configuration_json) {
        const config = JSON.parse(response.configuration_json)
        // Remover campos que não são parâmetros avançados
        const { location, device_type, mqtt_topic, ...params } = config
        setAdvancedConfig(params)
      } else {
        setAdvancedConfig({})
      }
      
      // Carregar capacidades do capabilities_json
      if (response.capabilities_json) {
        const caps = JSON.parse(response.capabilities_json)
        setCapabilities(caps)
      } else {
        setCapabilities({})
      }
    } catch (error) {
      console.error('Erro carregando configurações:', error)
      setAdvancedConfig({})
      setCapabilities({})
    }
    
    setIsConfigDialogOpen(true)
  }

  // Form dialog content - movido para fora para evitar re-render
  const renderDeviceFormDialog = (isOpen, onOpenChange, title, description) => (
    <Dialog open={isOpen} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>{title}</DialogTitle>
          <DialogDescription>{description}</DialogDescription>
        </DialogHeader>
        
        <form onSubmit={handleSaveDevice} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="name">Nome do Dispositivo</Label>
            <Input
              id="name"
              value={formData.name}
              onChange={(e) => setFormData({...formData, name: e.target.value})}
              placeholder="Ex: Central de Relés"
              required
            />
          </div>
          
          <div className="space-y-2">
            <Label htmlFor="type">Tipo</Label>
            <select
              id="type"
              value={formData.type}
              onChange={(e) => {
                setFormData({...formData, type: e.target.value})
                setAdvancedConfig({}) // Resetar configurações avançadas ao mudar tipo
              }}
              className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
            >
              {DEVICE_TYPES.map(deviceType => (
                <option key={deviceType.value} value={deviceType.value}>
                  {deviceType.label}
                </option>
              ))}
            </select>
          </div>
          
          <div className="space-y-2">
            <Label htmlFor="ip_address">Endereço IP</Label>
            <Input
              id="ip_address"
              value={formData.ip_address}
              onChange={(e) => setFormData({...formData, ip_address: e.target.value})}
              placeholder="192.168.1.100"
            />
          </div>
          
          <div className="space-y-2">
            <Label htmlFor="mac_address">Endereço MAC</Label>
            <Input
              id="mac_address"
              value={formData.mac_address}
              onChange={(e) => setFormData({...formData, mac_address: e.target.value})}
              placeholder="AA:BB:CC:DD:EE:FF"
            />
          </div>
          
          <div className="space-y-2">
            <Label htmlFor="location">Localização</Label>
            <Select
              value={formData.location}
              onValueChange={(value) => setFormData({...formData, location: value})}
            >
              <SelectTrigger id="location">
                <SelectValue placeholder="Selecione a localização" />
              </SelectTrigger>
              <SelectContent>
                {vehicleLocations.map(loc => (
                  <SelectItem key={loc.value} value={loc.value}>
                    {loc.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          
          <div className="flex items-center space-x-2">
            <Switch
              id="is_active"
              checked={formData.is_active}
              onCheckedChange={(checked) => setFormData({...formData, is_active: checked})}
            />
            <Label htmlFor="is_active">Dispositivo Ativo</Label>
          </div>
          
          <DialogFooter>
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              Cancelar
            </Button>
            <Button type="submit">
              {selectedDevice ? 'Salvar Alterações' : 'Adicionar Dispositivo'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )

  // Diálogo de Configurações Avançadas
  const renderConfigDialog = () => (
    <Dialog open={isConfigDialogOpen} onOpenChange={setIsConfigDialogOpen}>
      <DialogContent className="sm:max-w-[700px] max-h-[80vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Configurações - {selectedDevice?.name}</DialogTitle>
          <DialogDescription>
            Configure os parâmetros e capacidades do {selectedDevice && getDeviceTypeInfo(selectedDevice.type).label}
          </DialogDescription>
        </DialogHeader>
        
        <Tabs defaultValue="parameters" className="w-full">
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="parameters">Parâmetros</TabsTrigger>
            <TabsTrigger value="capabilities">Capacidades</TabsTrigger>
          </TabsList>
          
          <TabsContent value="parameters" className="space-y-4">
            <form onSubmit={async (e) => {
              e.preventDefault()
              try {
                // Salvar configurações avançadas
                await api.updateDevice(selectedDevice.id, {
                  configuration: advancedConfig
                })
                await loadDevices()
                setIsConfigDialogOpen(false)
                setAdvancedConfig({})
                setCapabilities({})
              } catch (error) {
                console.error('Erro salvando configurações:', error)
              }
            }} className="space-y-4">
          
          {selectedDevice && getAdvancedFieldsByType(selectedDevice.type).map((field) => (
            <div key={field.key} className="space-y-2">
              <Label htmlFor={field.key}>
                {field.label}
                {field.required && <span className="text-red-500 ml-1">*</span>}
              </Label>
              
              {field.type === 'text' && (
                <Input
                  id={field.key}
                  type="text"
                  placeholder={field.placeholder}
                  value={advancedConfig[field.key] || ''}
                  onChange={(e) => setAdvancedConfig({
                    ...advancedConfig,
                    [field.key]: e.target.value
                  })}
                  required={field.required}
                />
              )}
              
              {field.type === 'number' && (
                <Input
                  id={field.key}
                  type="number"
                  placeholder={field.placeholder}
                  value={advancedConfig[field.key] || ''}
                  onChange={(e) => setAdvancedConfig({
                    ...advancedConfig,
                    [field.key]: e.target.value
                  })}
                  required={field.required}
                />
              )}
              
              {field.type === 'select' && (
                <Select
                  value={advancedConfig[field.key] || ''}
                  onValueChange={(value) => setAdvancedConfig({
                    ...advancedConfig,
                    [field.key]: value
                  })}
                >
                  <SelectTrigger id={field.key}>
                    <SelectValue placeholder={`Selecione ${field.label.toLowerCase()}`} />
                  </SelectTrigger>
                  <SelectContent>
                    {field.options.map(option => (
                      <SelectItem key={option.value} value={option.value}>
                        {option.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              )}
              
              {field.type === 'checkbox' && (
                <div className="flex items-center space-x-2">
                  <Checkbox
                    id={field.key}
                    checked={advancedConfig[field.key] || false}
                    onCheckedChange={(checked) => setAdvancedConfig({
                      ...advancedConfig,
                      [field.key]: checked
                    })}
                  />
                  <Label htmlFor={field.key} className="text-sm font-normal cursor-pointer">
                    {field.label}
                  </Label>
                </div>
              )}
            </div>
          ))}
          
          {selectedDevice && getAdvancedFieldsByType(selectedDevice.type).length === 0 && (
            <div className="text-center py-8 text-muted-foreground">
              Não há configurações avançadas disponíveis para este tipo de dispositivo.
            </div>
          )}
          
              <DialogFooter>
                <Button type="button" variant="outline" onClick={() => setIsConfigDialogOpen(false)}>
                  Cancelar
                </Button>
                {selectedDevice && getAdvancedFieldsByType(selectedDevice.type).length > 0 && (
                  <Button type="submit">
                    Salvar Parâmetros
                  </Button>
                )}
              </DialogFooter>
            </form>
          </TabsContent>
          
          <TabsContent value="capabilities" className="space-y-4">
            <div className="space-y-3">
              <p className="text-sm text-muted-foreground">
                Selecione as capacidades que este dispositivo suporta
              </p>
              
              {selectedDevice && getCapabilitiesByType(selectedDevice.type).map((capability) => (
                <div key={capability.key} className="flex items-start space-x-3 p-3 rounded-lg border">
                  <Checkbox
                    id={capability.key}
                    checked={capabilities[capability.key] || false}
                    onCheckedChange={(checked) => setCapabilities({
                      ...capabilities,
                      [capability.key]: checked
                    })}
                    className="mt-1"
                  />
                  <div className="flex-1">
                    <Label htmlFor={capability.key} className="font-medium cursor-pointer">
                      {capability.label}
                    </Label>
                    <p className="text-sm text-muted-foreground mt-1">
                      {capability.description}
                    </p>
                  </div>
                </div>
              ))}
              
              {selectedDevice && getCapabilitiesByType(selectedDevice.type).length === 0 && (
                <div className="text-center py-8 text-muted-foreground">
                  Não há capacidades configuráveis para este tipo de dispositivo.
                </div>
              )}
            </div>
            
            <DialogFooter>
              <Button type="button" variant="outline" onClick={() => setIsConfigDialogOpen(false)}>
                Cancelar
              </Button>
              {selectedDevice && getCapabilitiesByType(selectedDevice.type).length > 0 && (
                <Button onClick={async () => {
                  try {
                    // Preparar objeto de capacidades com valores booleanos
                    const capabilitiesObj = {}
                    Object.keys(capabilities).forEach(key => {
                      capabilitiesObj[key] = capabilities[key] === true
                    })
                    
                    // Salvar capacidades no campo específico
                    await api.updateDevice(selectedDevice.id, {
                      capabilities: capabilitiesObj
                    })
                    
                    await loadDevices()
                    setIsConfigDialogOpen(false)
                    setCapabilities({})
                    setAdvancedConfig({})
                  } catch (error) {
                    console.error('Erro salvando capacidades:', error)
                  }
                }}>
                  Salvar Capacidades
                </Button>
              )}
            </DialogFooter>
          </TabsContent>
        </Tabs>
      </DialogContent>
    </Dialog>
  )

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent"></div>
        <span className="ml-2 text-muted-foreground">Carregando dispositivos...</span>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Dispositivos</h1>
          <p className="text-muted-foreground">
            Gerencie todos os dispositivos ESP32 conectados ao sistema
          </p>
        </div>
        <Button onClick={() => setIsAddDialogOpen(true)}>
          <Plus className="mr-2 h-4 w-4" />
          Adicionar Dispositivo
        </Button>
      </div>

      {/* Stats Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total</CardTitle>
            <Settings className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{devices.length}</div>
            <p className="text-xs text-muted-foreground">Dispositivos cadastrados</p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">ESP32 Relé</CardTitle>
            <Power className="h-4 w-4 text-blue-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-blue-600">
              {devices.filter(d => normalizeDeviceType(d.type) === 'ESP32_RELAY').length}
            </div>
            <p className="text-xs text-muted-foreground">Placas de relé</p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">ESP32 Display</CardTitle>
            <Activity className="h-4 w-4 text-green-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">
              {devices.filter(d => normalizeDeviceType(d.type) === 'ESP32_DISPLAY').length}
            </div>
            <p className="text-xs text-muted-foreground">Telas e displays</p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">ESP32 CAN</CardTitle>
            <Settings className="h-4 w-4 text-purple-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-purple-600">
              {devices.filter(d => normalizeDeviceType(d.type) === 'ESP32_CAN').length}
            </div>
            <p className="text-xs text-muted-foreground">Interfaces CAN</p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">ESP32 Sensor</CardTitle>
            <Activity className="h-4 w-4 text-orange-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-orange-600">
              {devices.filter(d => normalizeDeviceType(d.type) === 'ESP32_SENSOR').length}
            </div>
            <p className="text-xs text-muted-foreground">Módulos sensores</p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">ESP32 Control</CardTitle>
            <Settings className="h-4 w-4 text-teal-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-teal-600">
              {devices.filter(d => normalizeDeviceType(d.type) === 'ESP32_CONTROL').length}
            </div>
            <p className="text-xs text-muted-foreground">Painéis de controle</p>
          </CardContent>
        </Card>
      </div>

      {/* Search & Filter */}
      <div className="flex items-center space-x-2">
        <div className="relative flex-1 max-w-sm">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="Buscar dispositivos..."
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

      {/* Devices Table */}
      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Dispositivo</TableHead>
              <TableHead>Tipo</TableHead>
              <TableHead>IP</TableHead>
              <TableHead>Localização</TableHead>
              <TableHead className="w-[100px]">Ações</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredDevices.map((device) => {
              const TypeIcon = getDeviceTypeInfo(device.type).icon
              return (
                <TableRow key={device.id}>
                  <TableCell>
                    <div className="flex items-center space-x-3">
                      <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10">
                        <TypeIcon className="h-4 w-4 text-primary" />
                      </div>
                      <div>
                        <div className="font-medium">{device.name}</div>
                        <div className="text-sm text-muted-foreground">{device.uuid}</div>
                      </div>
                    </div>
                  </TableCell>
                  <TableCell>
                    {getDeviceTypeInfo(device.type).label}
                  </TableCell>
                  <TableCell>
                    <div className="font-mono text-sm">{device.ip_address || '-'}</div>
                  </TableCell>
                  <TableCell>
                    <div className="flex items-center">
                      {device.location && (
                        <>
                          <MapPin className="mr-1 h-3 w-3 text-muted-foreground" />
                          <span className="text-sm">{device.location}</span>
                        </>
                      )}
                    </div>
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
                        <DropdownMenuItem onClick={() => openEditDialog(device)}>
                          <Edit className="mr-2 h-4 w-4" />
                          Editar
                        </DropdownMenuItem>
                        <DropdownMenuItem onClick={() => openConfigDialog(device)}>
                          <Settings className="mr-2 h-4 w-4" />
                          Configurar
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
                              <AlertDialogTitle>Deletar Dispositivo</AlertDialogTitle>
                              <AlertDialogDescription>
                                Tem certeza que deseja deletar o dispositivo "{device.name}"? 
                                Esta ação não pode ser desfeita.
                              </AlertDialogDescription>
                            </AlertDialogHeader>
                            <AlertDialogFooter>
                              <AlertDialogCancel>Cancelar</AlertDialogCancel>
                              <AlertDialogAction 
                                onClick={() => handleDeleteDevice(device)}
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

      {/* Empty State */}
      {filteredDevices.length === 0 && !loading && (
        <div className="text-center py-12">
          <Settings className="mx-auto h-12 w-12 text-muted-foreground/50" />
          <h3 className="mt-2 text-sm font-semibold">Nenhum dispositivo encontrado</h3>
          <p className="mt-1 text-sm text-muted-foreground">
            {searchTerm ? 'Tente uma busca diferente.' : 'Adicione seu primeiro dispositivo ESP32.'}
          </p>
          {!searchTerm && (
            <Button className="mt-4" onClick={() => setIsAddDialogOpen(true)}>
              <Plus className="mr-2 h-4 w-4" />
              Adicionar Dispositivo
            </Button>
          )}
        </div>
      )}

      {/* Add Device Dialog */}
      {renderDeviceFormDialog(
        isAddDialogOpen,
        (open) => {
          setIsAddDialogOpen(open)
          if (!open) resetForm()
        },
        "Adicionar Dispositivo",
        "Adicione um novo dispositivo ESP32 ao sistema."
      )}

      {/* Edit Device Dialog */}
      {renderDeviceFormDialog(
        isEditDialogOpen,
        (open) => {
          setIsEditDialogOpen(open)
          if (!open) resetForm()
        },
        "Editar Dispositivo",
        "Modifique as configurações do dispositivo."
      )}

      {/* Config Dialog */}
      {renderConfigDialog()}
    </div>
  )
}

export default DevicesPage