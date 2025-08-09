import React, { useState, useEffect } from 'react'
import { 
  Settings,
  Globe,
  Bell,
  Shield,
  Database,
  Wifi,
  Save,
  RefreshCw,
  Check,
  AlertCircle,
  Info
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Label } from '@/components/ui/label'
import { Input } from '@/components/ui/input'
import { Switch } from '@/components/ui/switch'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Alert, AlertDescription } from '@/components/ui/alert'
import ThemeSelector from '@/components/ThemeSelector'

const ConfigSettingsPage = () => {
  const [loading, setLoading] = useState(false)
  const [saving, setSaving] = useState(false)
  const [saveSuccess, setSaveSuccess] = useState(false)
  
  // Configurações
  const [settings, setSettings] = useState({
    // API
    apiUrl: import.meta.env.VITE_API_URL || 'http://localhost:5000',
    apiTimeout: 30000,
    
    // MQTT
    mqttBroker: '192.168.1.100',
    mqttPort: 1883,
    mqttUsername: '',
    mqttPassword: '',
    mqttEnabled: true,
    
    // Interface
    autoRefresh: true,
    refreshInterval: 30,
    notifications: true,
    soundEnabled: false,
    
    // Segurança
    sessionTimeout: 60,
    requirePassword: false,
    
    // Sistema
    logLevel: 'info',
    debugMode: false,
    telemetryEnabled: true,
    backupEnabled: true,
    backupInterval: 24
  })
  
  // Carregar configurações salvas
  useEffect(() => {
    loadSettings()
  }, [])
  
  const loadSettings = () => {
    // Carregar do localStorage
    const saved = localStorage.getItem('config-app-settings')
    if (saved) {
      try {
        const parsed = JSON.parse(saved)
        setSettings(prev => ({ ...prev, ...parsed }))
      } catch (error) {
        console.error('Erro carregando configurações:', error)
      }
    }
  }
  
  const handleSaveSettings = async () => {
    setSaving(true)
    try {
      // Salvar no localStorage
      localStorage.setItem('config-app-settings', JSON.stringify(settings))
      
      // Simular delay de salvamento
      await new Promise(resolve => setTimeout(resolve, 500))
      
      setSaveSuccess(true)
      setTimeout(() => setSaveSuccess(false), 3000)
    } catch (error) {
      console.error('Erro salvando configurações:', error)
    } finally {
      setSaving(false)
    }
  }
  
  const handleResetSettings = () => {
    if (confirm('Tem certeza que deseja restaurar as configurações padrão?')) {
      localStorage.removeItem('config-app-settings')
      loadSettings()
    }
  }
  
  const updateSetting = (key, value) => {
    setSettings(prev => ({ ...prev, [key]: value }))
  }
  
  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Configurações do Sistema</h1>
          <p className="text-muted-foreground">
            Configure o comportamento e aparência do Config App
          </p>
        </div>
        
        <div className="flex items-center space-x-2">
          <Button variant="outline" onClick={handleResetSettings}>
            <RefreshCw className="mr-2 h-4 w-4" />
            Restaurar Padrões
          </Button>
          <Button onClick={handleSaveSettings} disabled={saving}>
            {saving ? (
              <>
                <RefreshCw className="mr-2 h-4 w-4 animate-spin" />
                Salvando...
              </>
            ) : saveSuccess ? (
              <>
                <Check className="mr-2 h-4 w-4 text-green-600" />
                Salvo!
              </>
            ) : (
              <>
                <Save className="mr-2 h-4 w-4" />
                Salvar Alterações
              </>
            )}
          </Button>
        </div>
      </div>
      
      {/* Success Alert */}
      {saveSuccess && (
        <Alert className="bg-green-50 border-green-200">
          <Check className="h-4 w-4 text-green-600" />
          <AlertDescription className="text-green-800">
            Configurações salvas com sucesso!
          </AlertDescription>
        </Alert>
      )}
      
      {/* Settings Tabs */}
      <Tabs defaultValue="interface" className="space-y-4">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="interface">Interface</TabsTrigger>
          <TabsTrigger value="api">API & Rede</TabsTrigger>
          <TabsTrigger value="security">Segurança</TabsTrigger>
          <TabsTrigger value="system">Sistema</TabsTrigger>
        </TabsList>
        
        {/* Interface Tab */}
        <TabsContent value="interface" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Aparência</CardTitle>
              <CardDescription>
                Personalize o visual e comportamento da interface
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              {/* Theme Selector */}
              <div className="flex items-center justify-between">
                <div>
                  <Label>Tema e Cores</Label>
                  <p className="text-sm text-muted-foreground">
                    Escolha o tema e a cor principal da interface
                  </p>
                </div>
                <ThemeSelector />
              </div>
              
              {/* Auto Refresh */}
              <div className="flex items-center justify-between">
                <div>
                  <Label htmlFor="autoRefresh">Atualização Automática</Label>
                  <p className="text-sm text-muted-foreground">
                    Atualizar dados automaticamente
                  </p>
                </div>
                <Switch
                  id="autoRefresh"
                  checked={settings.autoRefresh}
                  onCheckedChange={(checked) => updateSetting('autoRefresh', checked)}
                />
              </div>
              
              {/* Refresh Interval */}
              {settings.autoRefresh && (
                <div className="space-y-2">
                  <Label htmlFor="refreshInterval">Intervalo de Atualização (segundos)</Label>
                  <Input
                    id="refreshInterval"
                    type="number"
                    value={settings.refreshInterval}
                    onChange={(e) => updateSetting('refreshInterval', parseInt(e.target.value))}
                    min="5"
                    max="300"
                  />
                </div>
              )}
              
              {/* Notifications */}
              <div className="flex items-center justify-between">
                <div>
                  <Label htmlFor="notifications">Notificações</Label>
                  <p className="text-sm text-muted-foreground">
                    Exibir notificações do sistema
                  </p>
                </div>
                <Switch
                  id="notifications"
                  checked={settings.notifications}
                  onCheckedChange={(checked) => updateSetting('notifications', checked)}
                />
              </div>
              
              {/* Sound */}
              <div className="flex items-center justify-between">
                <div>
                  <Label htmlFor="soundEnabled">Sons</Label>
                  <p className="text-sm text-muted-foreground">
                    Tocar sons para notificações
                  </p>
                </div>
                <Switch
                  id="soundEnabled"
                  checked={settings.soundEnabled}
                  onCheckedChange={(checked) => updateSetting('soundEnabled', checked)}
                />
              </div>
            </CardContent>
          </Card>
        </TabsContent>
        
        {/* API & Network Tab */}
        <TabsContent value="api" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Configurações de API</CardTitle>
              <CardDescription>
                Configure a conexão com o backend
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="apiUrl">URL da API</Label>
                <Input
                  id="apiUrl"
                  value={settings.apiUrl}
                  onChange={(e) => updateSetting('apiUrl', e.target.value)}
                  placeholder={import.meta.env.VITE_API_URL || "http://localhost:5000"}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="apiTimeout">Timeout (ms)</Label>
                <Input
                  id="apiTimeout"
                  type="number"
                  value={settings.apiTimeout}
                  onChange={(e) => updateSetting('apiTimeout', parseInt(e.target.value))}
                  min="1000"
                  max="60000"
                />
              </div>
            </CardContent>
          </Card>
          
          <Card>
            <CardHeader>
              <CardTitle>Configurações MQTT</CardTitle>
              <CardDescription>
                Configure a conexão com o broker MQTT
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <div>
                  <Label htmlFor="mqttEnabled">MQTT Habilitado</Label>
                  <p className="text-sm text-muted-foreground">
                    Conectar ao broker MQTT
                  </p>
                </div>
                <Switch
                  id="mqttEnabled"
                  checked={settings.mqttEnabled}
                  onCheckedChange={(checked) => updateSetting('mqttEnabled', checked)}
                />
              </div>
              
              {settings.mqttEnabled && (
                <>
                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="mqttBroker">Broker</Label>
                      <Input
                        id="mqttBroker"
                        value={settings.mqttBroker}
                        onChange={(e) => updateSetting('mqttBroker', e.target.value)}
                        placeholder="192.168.1.100"
                      />
                    </div>
                    
                    <div className="space-y-2">
                      <Label htmlFor="mqttPort">Porta</Label>
                      <Input
                        id="mqttPort"
                        type="number"
                        value={settings.mqttPort}
                        onChange={(e) => updateSetting('mqttPort', parseInt(e.target.value))}
                        placeholder="1883"
                      />
                    </div>
                  </div>
                  
                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="mqttUsername">Usuário</Label>
                      <Input
                        id="mqttUsername"
                        value={settings.mqttUsername}
                        onChange={(e) => updateSetting('mqttUsername', e.target.value)}
                        placeholder="Opcional"
                      />
                    </div>
                    
                    <div className="space-y-2">
                      <Label htmlFor="mqttPassword">Senha</Label>
                      <Input
                        id="mqttPassword"
                        type="password"
                        value={settings.mqttPassword}
                        onChange={(e) => updateSetting('mqttPassword', e.target.value)}
                        placeholder="Opcional"
                      />
                    </div>
                  </div>
                </>
              )}
            </CardContent>
          </Card>
        </TabsContent>
        
        {/* Security Tab */}
        <TabsContent value="security" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Segurança</CardTitle>
              <CardDescription>
                Configure opções de segurança e autenticação
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="sessionTimeout">Timeout de Sessão (minutos)</Label>
                <Input
                  id="sessionTimeout"
                  type="number"
                  value={settings.sessionTimeout}
                  onChange={(e) => updateSetting('sessionTimeout', parseInt(e.target.value))}
                  min="5"
                  max="1440"
                />
                <p className="text-sm text-muted-foreground">
                  Tempo de inatividade antes de desconectar
                </p>
              </div>
              
              <div className="flex items-center justify-between">
                <div>
                  <Label htmlFor="requirePassword">Exigir Senha</Label>
                  <p className="text-sm text-muted-foreground">
                    Solicitar senha para alterações críticas
                  </p>
                </div>
                <Switch
                  id="requirePassword"
                  checked={settings.requirePassword}
                  onCheckedChange={(checked) => updateSetting('requirePassword', checked)}
                />
              </div>
            </CardContent>
          </Card>
        </TabsContent>
        
        {/* System Tab */}
        <TabsContent value="system" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Sistema</CardTitle>
              <CardDescription>
                Configurações avançadas do sistema
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="logLevel">Nível de Log</Label>
                <select
                  id="logLevel"
                  value={settings.logLevel}
                  onChange={(e) => updateSetting('logLevel', e.target.value)}
                  className="w-full h-10 px-3 py-2 text-sm bg-background border border-input rounded-md"
                >
                  <option value="error">Apenas Erros</option>
                  <option value="warn">Avisos e Erros</option>
                  <option value="info">Informativo</option>
                  <option value="debug">Debug</option>
                </select>
              </div>
              
              <div className="flex items-center justify-between">
                <div>
                  <Label htmlFor="debugMode">Modo Debug</Label>
                  <p className="text-sm text-muted-foreground">
                    Exibir informações detalhadas no console
                  </p>
                </div>
                <Switch
                  id="debugMode"
                  checked={settings.debugMode}
                  onCheckedChange={(checked) => updateSetting('debugMode', checked)}
                />
              </div>
              
              <div className="flex items-center justify-between">
                <div>
                  <Label htmlFor="telemetryEnabled">Telemetria</Label>
                  <p className="text-sm text-muted-foreground">
                    Coletar dados de uso anônimos
                  </p>
                </div>
                <Switch
                  id="telemetryEnabled"
                  checked={settings.telemetryEnabled}
                  onCheckedChange={(checked) => updateSetting('telemetryEnabled', checked)}
                />
              </div>
              
              <div className="flex items-center justify-between">
                <div>
                  <Label htmlFor="backupEnabled">Backup Automático</Label>
                  <p className="text-sm text-muted-foreground">
                    Fazer backup das configurações automaticamente
                  </p>
                </div>
                <Switch
                  id="backupEnabled"
                  checked={settings.backupEnabled}
                  onCheckedChange={(checked) => updateSetting('backupEnabled', checked)}
                />
              </div>
              
              {settings.backupEnabled && (
                <div className="space-y-2">
                  <Label htmlFor="backupInterval">Intervalo de Backup (horas)</Label>
                  <Input
                    id="backupInterval"
                    type="number"
                    value={settings.backupInterval}
                    onChange={(e) => updateSetting('backupInterval', parseInt(e.target.value))}
                    min="1"
                    max="168"
                  />
                </div>
              )}
            </CardContent>
          </Card>
          
          <Alert>
            <Info className="h-4 w-4" />
            <AlertDescription>
              As configurações são salvas localmente no navegador. Para sincronizar entre dispositivos, 
              exporte e importe as configurações manualmente.
            </AlertDescription>
          </Alert>
        </TabsContent>
      </Tabs>
    </div>
  )
}

export default ConfigSettingsPage