import { useContext } from 'react'

// Import do contexto do ThemeProvider
export { useTheme } from '@/providers/theme-provider'

// Hook alternativo que pode ser usado
export function useThemeContext() {
  const { useTheme } = require('@/providers/theme-provider')
  return useTheme()
}

// Export padrão
export default function useTheme() {
  const { useTheme: useThemeHook } = require('@/providers/theme-provider')
  return useThemeHook()
}