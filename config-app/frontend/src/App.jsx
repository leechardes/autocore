import React, { useState, useEffect } from 'react'
import { Car, Gauge, Cpu, ToggleLeft, Monitor, Radio, Palette, Settings, Menu, Sun, Moon, RefreshCw, Plus, FileJson, Activity, Play, Zap } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Toaster } from 'sonner'
import DevicesPage from './pages/DevicesPage'
import RelaysPage from './pages/RelaysPage'
import ScreensPageV2 from './pages/ScreensPageV2'
import ConfigGeneratorPage from './pages/ConfigGeneratorPage'
import ConfigSettingsPage from './pages/ConfigSettingsPage.jsx'
import DeviceThemesPage from './pages/DeviceThemesPage.jsx'
import CANBusPage from './pages/CANBusPage.jsx'
import CANParametersPage from './pages/CANParametersPage.jsx'
import MQTTMonitorPage from './pages/MQTTMonitorPage.jsx'
import MacrosPage from './pages/MacrosPage.jsx'
import ThemeSelector from './components/ThemeSelector'
import api from '@/lib/api'

function App() {
  const [loading, setLoading] = useState(true)
  const [isDark, setIsDark] = useState(false)
  const [currentPage, setCurrentPage] = useState('dashboard')
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)
  const [refreshing, setRefreshing] = useState(false)
  
  // Data state
  const [status, setStatus] = useState({
    lastUpdate: '',
    systemHealth: 'online'
  })
  
  const [stats, setStats] = useState([
    {
      title: 'Total de Dispositivos',
      value: '0',
      icon: Cpu,
      description: 'Cadastrados'
    },
    {
      title: 'Canais de Relé',
      value: '0',
      icon: ToggleLeft,
      description: 'Configurados'
    },
    {
      title: 'Telas Configuradas',
      value: '0',
      icon: Monitor,
      description: 'Ativas'
    },
    {
      title: 'Sinais CAN',
      value: '0',
      icon: Radio,
      description: 'Mapeados'
    }
  ])

  // Navigation items
  const navigation = [
    {
      id: 'dashboard',
      name: 'Dashboard',
      icon: Gauge,
      title: 'Dashboard',
      description: 'Visão geral do sistema'
    },
    {
      id: 'devices',
      name: 'Dispositivos',
      icon: Cpu,
      title: 'Dispositivos',
      description: 'Gerenciar dispositivos ESP32'
    },
    {
      id: 'relays',
      name: 'Relés',
      icon: Zap,
      title: 'Configuração de Relés',
      description: 'Configurar canais e placas de relé'
    },
    {
      id: 'macros',
      name: 'Macros',
      icon: Play,
      title: 'Macros e Automações',
      description: 'Gerenciar sequências de ações programáveis'
    },
    {
      id: 'screens',
      name: 'Telas',
      icon: Monitor,
      title: 'Editor de Telas',
      description: 'Configurar layouts visuais'
    },
    {
      id: 'can',
      name: 'CAN Bus',
      icon: Radio,
      title: 'Sinais CAN',
      description: 'Configurar telemetria CAN'
    },
    {
      id: 'mqtt',
      name: 'Monitor MQTT',
      icon: Activity,
      title: 'Monitor MQTT',
      description: 'Monitor em tempo real das mensagens MQTT'
    },
    {
      id: 'config',
      name: 'Gerador Config',
      icon: FileJson,
      title: 'Gerador de Configuração',
      description: 'Gerar arquivos JSON, C++ e YAML para ESP32'
    },
    {
      id: 'themes',
      name: 'Temas',
      icon: Palette,
      title: 'Temas e Aparência',
      description: 'Personalizar visual'
    },
    {
      id: 'settings',
      name: 'Configurações',
      icon: Settings,
      title: 'Configurações',
      description: 'Configurações do sistema'
    }
  ]

  // Initialize app
  useEffect(() => {
    const initApp = async () => {
      console.log('🚀 AutoCore Config App iniciando...')
      
      // Initialize theme
      const savedTheme = localStorage.getItem('theme')
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
      const darkMode = savedTheme === 'dark' || (!savedTheme && prefersDark)
      
      setIsDark(darkMode)
      document.documentElement.classList.toggle('dark', darkMode)
      
      // Load initial data
      await loadInitialData()
      
      setLoading(false)
      console.log('✅ AutoCore Config App carregado')
    }

    initApp()

    // Set up navigation listener
    const handleNavigate = (event) => {
      setCurrentPage(event.detail)
    }
    window.addEventListener('navigate', handleNavigate)

    // Set up periodic updates
    const interval = setInterval(loadInitialData, 30000)
    return () => {
      clearInterval(interval)
      window.removeEventListener('navigate', handleNavigate)
    }
  }, [])

  // Load data from API
  const loadInitialData = async () => {
    try {
      const [statusData, devices, channels, screens, canSignals] = await Promise.all([
        api.getStatus(),
        api.getDevices(),
        api.getRelayChannels(),
        api.getScreens(),
        api.getCANSignals()
      ])

      // Update status
      setStatus({
        lastUpdate: new Date().toLocaleTimeString(),
        systemHealth: statusData.status || 'offline'
      })

      // Update stats
      setStats(prev => [
        {
          ...prev[0],
          value: devices.length.toString()  // Total de dispositivos cadastrados
        },
        {
          ...prev[1],
          value: channels.length.toString()  // Total de canais configurados
        },
        {
          ...prev[2],
          value: screens.filter(s => s.is_visible === true).length.toString()
        },
        {
          ...prev[3],
          value: canSignals.length.toString()  // Total de sinais CAN mapeados
        }
      ])

    } catch (error) {
      console.error('Erro carregando dados:', error)
    }
  }

  // Theme toggle
  const toggleTheme = () => {
    const newIsDark = !isDark
    setIsDark(newIsDark)
    document.documentElement.classList.toggle('dark', newIsDark)
    localStorage.setItem('theme', newIsDark ? 'dark' : 'light')
  }

  // Manual refresh
  const refreshData = async () => {
    if (refreshing) return
    
    setRefreshing(true)
    try {
      await loadInitialData()
    } catch (error) {
      console.error('Erro atualizando dados:', error)
    } finally {
      setRefreshing(false)
    }
  }

  const currentPageData = navigation.find(p => p.id === currentPage) || navigation[0]

  if (loading) {
    return (
      <div className="fixed inset-0 z-50 flex items-center justify-center bg-background">
        <div className="flex items-center space-x-2">
          <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent"></div>
          <span className="text-sm text-muted-foreground">Carregando AutoCore...</span>
        </div>
      </div>
    )
  }

  return (
    <div className="flex h-screen bg-background">
      {/* Sidebar */}
      <nav className={`${mobileMenuOpen ? 'translate-x-0' : '-translate-x-full'} fixed inset-y-0 left-0 z-50 w-64 bg-card border-r transition-transform duration-300 ease-in-out md:relative md:translate-x-0`}>
        {/* Logo */}
        <div className="flex h-16 items-center justify-between border-b px-6">
          <div className="flex items-center space-x-2">
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary">
              <Car className="h-5 w-5 text-primary-foreground" />
            </div>
            <div>
              <h1 className="text-lg font-semibold">AutoCore</h1>
              <p className="text-xs text-muted-foreground">Config App</p>
            </div>
          </div>
          <Button
            variant="ghost"
            size="icon"
            className="md:hidden"
            onClick={() => setMobileMenuOpen(false)}
          >
            <Menu className="h-5 w-5" />
          </Button>
        </div>

        {/* Navigation */}
        <div className="flex-1 space-y-1 p-4">
          {navigation.map((item) => {
            const Icon = item.icon
            return (
              <Button
                key={item.id}
                variant={currentPage === item.id ? "default" : "ghost"}
                className="w-full justify-start"
                onClick={() => {
                  setCurrentPage(item.id)
                  setMobileMenuOpen(false)
                }}
              >
                <Icon className="mr-2 h-4 w-4" />
                {item.name}
              </Button>
            )
          })}
        </div>

        {/* Footer */}
        <div className="border-t p-4">
          <div className="flex items-center space-x-2">
            <div className="h-2 w-2 rounded-full bg-green-500"></div>
            <div className="text-sm">
              <p className="font-medium">Sistema Online</p>
              <p className="text-xs text-muted-foreground">{status.lastUpdate}</p>
            </div>
          </div>
        </div>
      </nav>

      {/* Mobile backdrop */}
      {mobileMenuOpen && (
        <div 
          className="fixed inset-0 z-40 bg-black/50 md:hidden"
          onClick={() => setMobileMenuOpen(false)}
        />
      )}

      {/* Main Content */}
      <main className="flex flex-1 flex-col overflow-hidden">
        {/* Header */}
        <header className="flex h-16 items-center justify-between border-b bg-background px-6">
          <div className="flex items-center space-x-4">
            <Button
              variant="ghost"
              size="icon"
              className="md:hidden"
              onClick={() => setMobileMenuOpen(true)}
            >
              <Menu className="h-5 w-5" />
            </Button>
            <div>
              <h2 className="text-lg font-semibold">{currentPageData.title}</h2>
              <p className="text-sm text-muted-foreground">{currentPageData.description}</p>
            </div>
          </div>
          
          <div className="flex items-center space-x-4">
            {/* Theme Selector */}
            <ThemeSelector />
            
            {/* Refresh */}
            <Button variant="ghost" size="icon" onClick={refreshData} disabled={refreshing}>
              <RefreshCw className={`h-4 w-4 ${refreshing ? 'animate-spin' : ''}`} />
            </Button>
          </div>
        </header>

        {/* Page Content */}
        <div className="flex-1 overflow-auto p-6">
          {currentPage === 'dashboard' && (
            <div className="space-y-6">
              {/* Stats Cards */}
              <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                {stats.map((stat, index) => {
                  const Icon = stat.icon
                  return (
                    <Card key={index}>
                      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium text-muted-foreground">
                          {stat.title}
                        </CardTitle>
                        <Icon className="h-4 w-4 text-muted-foreground" />
                      </CardHeader>
                      <CardContent>
                        <div className="text-2xl font-bold">{stat.value}</div>
                        <p className="text-xs text-muted-foreground">{stat.description}</p>
                      </CardContent>
                    </Card>
                  )
                })}
              </div>

              {/* Quick Actions */}
              <Card>
                <CardHeader>
                  <CardTitle>Ações Rápidas</CardTitle>
                  <CardDescription>
                    Acesso rápido às funcionalidades principais
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
                    {[
                      { icon: Plus, title: 'Adicionar Device', desc: 'Descobrir novo ESP32', page: 'devices' },
                      { icon: Settings, title: 'Configurar Relés', desc: 'Mapear canais', page: 'relays' },
                      { icon: Monitor, title: 'Editar Telas', desc: 'Layout visual', page: 'screens' },
                      { icon: FileJson, title: 'Gerar Config', desc: 'Download JSON', page: 'config' }
                    ].map((action, index) => {
                      const Icon = action.icon
                      return (
                        <Button
                          key={index}
                          variant="outline"
                          className="h-auto flex-col items-start space-y-2 p-4"
                          onClick={() => setCurrentPage(action.page)}
                        >
                          <Icon className="h-5 w-5 text-primary" />
                          <div className="text-left">
                            <p className="font-medium">{action.title}</p>
                            <p className="text-sm text-muted-foreground">{action.desc}</p>
                          </div>
                        </Button>
                      )
                    })}
                  </div>
                </CardContent>
              </Card>
            </div>
          )}

          {currentPage === 'devices' && (
            <DevicesPage />
          )}

          {currentPage === 'relays' && (
            <RelaysPage />
          )}
          
          {currentPage === 'macros' && (
            <MacrosPage />
          )}

          {currentPage === 'screens' && (
            <ScreensPageV2 />
          )}

          {currentPage === 'config' && (
            <ConfigGeneratorPage />
          )}

          {currentPage === 'settings' && (
            <ConfigSettingsPage />
          )}

          {currentPage === 'themes' && (
            <DeviceThemesPage />
          )}

          {currentPage === 'can' && (
            <CANBusPage />
          )}

          {currentPage === 'can-parameters' && (
            <CANParametersPage />
          )}

          {currentPage === 'mqtt' && (
            <MQTTMonitorPage />
          )}

          {currentPage !== 'dashboard' && currentPage !== 'devices' && currentPage !== 'relays' && currentPage !== 'screens' && currentPage !== 'config' && currentPage !== 'settings' && currentPage !== 'themes' && currentPage !== 'can' && currentPage !== 'can-parameters' && currentPage !== 'mqtt' && (
            <div className="flex flex-col items-center justify-center py-12">
              <Monitor className="h-12 w-12 text-muted-foreground mb-4" />
              <h3 className="text-lg font-semibold mb-2">Em Desenvolvimento</h3>
              <p className="text-muted-foreground">Página {currentPageData.title} em implementação</p>
            </div>
          )}
        </div>
      </main>
      
      {/* Toast Notifications */}
      <Toaster position="bottom-right" />
    </div>
  )
}

export default App