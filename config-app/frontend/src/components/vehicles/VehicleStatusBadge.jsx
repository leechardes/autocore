import React from 'react'
import { Badge } from '@/components/ui/badge'
import { 
  CheckCircle, 
  AlertTriangle, 
  XCircle, 
  Circle, 
  ShoppingCart,
  Car 
} from 'lucide-react'

export default function VehicleStatusBadge({ status, size = 'default', showIcon = true }) {
  const getStatusConfig = (status) => {
    switch (status) {
      case 'active':
        return {
          label: 'Ativo',
          variant: 'default',
          className: 'bg-green-500 text-white hover:bg-green-600',
          icon: CheckCircle
        }
      case 'maintenance':
        return {
          label: 'Manutenção',
          variant: 'secondary',
          className: 'bg-yellow-500 text-white hover:bg-yellow-600',
          icon: AlertTriangle
        }
      case 'inactive':
        return {
          label: 'Inativo',
          variant: 'secondary',
          className: 'bg-gray-500 text-white hover:bg-gray-600',
          icon: XCircle
        }
      case 'sold':
        return {
          label: 'Vendido',
          variant: 'secondary',
          className: 'bg-blue-500 text-white hover:bg-blue-600',
          icon: ShoppingCart
        }
      case 'accident':
        return {
          label: 'Acidente',
          variant: 'destructive',
          className: 'bg-red-500 text-white hover:bg-red-600',
          icon: XCircle
        }
      default:
        return {
          label: 'Desconhecido',
          variant: 'outline',
          className: 'bg-gray-100 text-gray-600',
          icon: Circle
        }
    }
  }

  const config = getStatusConfig(status)
  const Icon = config.icon

  const sizeClasses = {
    sm: 'h-5 text-xs',
    default: 'h-6 text-sm',
    lg: 'h-8 text-base'
  }

  const iconSizes = {
    sm: 'h-3 w-3',
    default: 'h-4 w-4',
    lg: 'h-5 w-5'
  }

  return (
    <Badge 
      variant={config.variant}
      className={`
        ${config.className} 
        ${sizeClasses[size]}
        inline-flex items-center gap-1 font-medium
      `}
    >
      {showIcon && <Icon className={iconSizes[size]} />}
      {config.label}
    </Badge>
  )
}

// Componente auxiliar para indicador circular de status
export function VehicleStatusIndicator({ status, size = 'default' }) {
  const getStatusColor = (status) => {
    switch (status) {
      case 'active': return 'bg-green-500'
      case 'maintenance': return 'bg-yellow-500'
      case 'inactive': return 'bg-gray-500'
      case 'sold': return 'bg-blue-500'
      case 'accident': return 'bg-red-500'
      default: return 'bg-gray-400'
    }
  }

  const sizeClasses = {
    sm: 'w-2 h-2',
    default: 'w-3 h-3',
    lg: 'w-4 h-4'
  }

  return (
    <div 
      className={`
        ${sizeClasses[size]} 
        ${getStatusColor(status)}
        rounded-full flex-shrink-0
      `}
      title={getStatusConfig(status).label}
    />
  )
}

// Hook para obter opções de status
export function useStatusOptions() {
  return [
    { value: 'active', label: 'Ativo', color: 'green' },
    { value: 'maintenance', label: 'Manutenção', color: 'yellow' },
    { value: 'inactive', label: 'Inativo', color: 'gray' },
    { value: 'sold', label: 'Vendido', color: 'blue' },
    { value: 'accident', label: 'Acidente', color: 'red' }
  ]
}

function getStatusConfig(status) {
  switch (status) {
    case 'active':
      return { label: 'Ativo' }
    case 'maintenance':
      return { label: 'Manutenção' }
    case 'inactive':
      return { label: 'Inativo' }
    case 'sold':
      return { label: 'Vendido' }
    case 'accident':
      return { label: 'Acidente' }
    default:
      return { label: 'Desconhecido' }
  }
}