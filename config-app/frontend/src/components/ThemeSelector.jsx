import React, { useState, useEffect } from 'react'
import { 
  Palette, 
  Check,
  ChevronDown 
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'

const ThemeSelector = () => {
  const [currentTheme, setCurrentTheme] = useState('default')
  const [currentColor, setCurrentColor] = useState('teal')
  
  // Configurações de temas
  const themes = [
    { value: 'default', label: 'Default', description: 'Tema padrão do sistema' },
    { value: 'scaled', label: 'Scaled', description: 'Espaçamento e tamanhos aumentados' },
    { value: 'mono', label: 'Mono', description: 'Minimalista e monocromático' }
  ]
  
  // Configurações de cores
  const colors = [
    { value: 'blue', label: 'Blue', class: 'bg-blue-500', hsl: '221.2 83.2% 53.3%' },
    { value: 'green', label: 'Green', class: 'bg-green-500', hsl: '142.1 76.2% 36.3%' },
    { value: 'amber', label: 'Amber', class: 'bg-amber-500', hsl: '37.7 92.1% 50.2%' },
    { value: 'rose', label: 'Rose', class: 'bg-rose-500', hsl: '346.8 77.2% 49.8%' },
    { value: 'purple', label: 'Purple', class: 'bg-purple-500', hsl: '271.5 81.3% 55.9%' },
    { value: 'orange', label: 'Orange', class: 'bg-orange-500', hsl: '24.6 95% 53.1%' },
    { value: 'teal', label: 'Teal', class: 'bg-teal-500', hsl: '172.5 66% 50.7%' }
  ]
  
  // Carregar tema salvo
  useEffect(() => {
    const savedTheme = localStorage.getItem('config-app-theme') || 'default'
    const savedColor = localStorage.getItem('config-app-color') || 'teal'
    
    setCurrentTheme(savedTheme)
    setCurrentColor(savedColor)
    applyTheme(savedTheme, savedColor)
  }, [])
  
  // Aplicar tema e cor
  const applyTheme = (theme, color) => {
    const root = document.documentElement
    
    // Remover classes anteriores
    root.classList.remove('theme-default', 'theme-scaled', 'theme-mono')
    
    // Adicionar classe do tema
    root.classList.add(`theme-${theme}`)
    
    // Aplicar cor primária
    const colorConfig = colors.find(c => c.value === color)
    if (colorConfig) {
      // Converter HSL para CSS variables
      const [h, s, l] = colorConfig.hsl.split(' ')
      root.style.setProperty('--primary', colorConfig.hsl)
      root.style.setProperty('--primary-foreground', '0 0% 100%') // Branco para contraste
      
      // Variações da cor primária
      root.style.setProperty('--primary-light', `${h} ${s} 95%`)
      root.style.setProperty('--primary-dark', `${h} ${s} 25%`)
    }
    
    // Aplicar estilos específicos do tema
    if (theme === 'scaled') {
      root.style.setProperty('--radius', '0.75rem')
      root.style.setProperty('--spacing-scale', '1.25')
    } else if (theme === 'mono') {
      root.style.setProperty('--radius', '0.25rem')
      root.style.setProperty('--spacing-scale', '0.9')
    } else {
      root.style.setProperty('--radius', '0.5rem')
      root.style.setProperty('--spacing-scale', '1')
    }
  }
  
  // Mudar tema
  const handleThemeChange = (value) => {
    setCurrentTheme(value)
    localStorage.setItem('config-app-theme', value)
    applyTheme(value, currentColor)
  }
  
  // Mudar cor
  const handleColorChange = (value) => {
    setCurrentColor(value)
    localStorage.setItem('config-app-color', value)
    applyTheme(currentTheme, value)
  }
  
  // Label do botão
  const getButtonLabel = () => {
    const theme = themes.find(t => t.value === currentTheme)
    const color = colors.find(c => c.value === currentColor)
    return `${theme?.label} · ${color?.label}`
  }
  
  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button 
          variant="outline" 
          size="sm"
          className="h-8 px-3"
        >
          <Palette className="mr-2 h-4 w-4" />
          <span className="hidden sm:inline-block">{getButtonLabel()}</span>
          <span className="sm:hidden">Tema</span>
          <ChevronDown className="ml-2 h-3 w-3" />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-56">
        {/* Seção de Temas */}
        <DropdownMenuLabel className="flex items-center gap-2">
          Tema
        </DropdownMenuLabel>
        {themes.map((theme) => (
          <DropdownMenuItem
            key={theme.value}
            onClick={() => handleThemeChange(theme.value)}
            className="flex items-center justify-between"
          >
            <div>
              <div className="font-medium">{theme.label}</div>
              <div className="text-xs text-muted-foreground">{theme.description}</div>
            </div>
            {currentTheme === theme.value && (
              <Check className="h-4 w-4 text-primary" />
            )}
          </DropdownMenuItem>
        ))}
        
        <DropdownMenuSeparator />
        
        {/* Seção de Cores */}
        <DropdownMenuLabel className="flex items-center gap-2">
          Cores
        </DropdownMenuLabel>
        {colors.map((color) => (
          <DropdownMenuItem
            key={color.value}
            onClick={() => handleColorChange(color.value)}
            className="flex items-center justify-between"
          >
            <div className="flex items-center gap-2">
              <div className={`h-4 w-4 rounded-full ${color.class}`} />
              <span className="font-medium">{color.label}</span>
            </div>
            {currentColor === color.value && (
              <Check className="h-4 w-4 text-primary" />
            )}
          </DropdownMenuItem>
        ))}
      </DropdownMenuContent>
    </DropdownMenu>
  )
}

export default ThemeSelector