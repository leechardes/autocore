import React from 'react'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { 
  AlertTriangle, 
  Calendar, 
  Gauge, 
  Settings, 
  Clock,
  CheckCircle
} from 'lucide-react'
import vehicleService from '@/services/vehicleService'

export default function MaintenanceAlert({ vehicle, onScheduleMaintenance, onUpdateStatus }) {
  if (!vehicle || !vehicleService.needsMaintenance(vehicle)) {
    return null
  }

  const getMaintenanceReasons = (vehicle) => {
    const reasons = []

    // Status de manutenção
    if (vehicle.status === 'maintenance') {
      reasons.push({
        icon: Settings,
        type: 'status',
        title: 'Em manutenção',
        description: 'Veículo marcado como em manutenção'
      })
    }

    // Quilometragem
    if (vehicle.current_mileage && vehicle.last_maintenance_mileage) {
      const kmSinceLastMaintenance = vehicle.current_mileage - vehicle.last_maintenance_mileage
      if (kmSinceLastMaintenance >= 10000) {
        reasons.push({
          icon: Gauge,
          type: 'mileage',
          title: 'Quilometragem',
          description: `${new Intl.NumberFormat('pt-BR').format(kmSinceLastMaintenance)} km desde última manutenção`
        })
      }
    }

    // Data da última manutenção
    if (vehicle.last_maintenance_date) {
      const lastMaintenance = new Date(vehicle.last_maintenance_date)
      const sixMonthsAgo = new Date()
      sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6)
      
      if (lastMaintenance < sixMonthsAgo) {
        const monthsAgo = Math.floor(
          (Date.now() - lastMaintenance.getTime()) / (1000 * 60 * 60 * 24 * 30)
        )
        reasons.push({
          icon: Calendar,
          type: 'date',
          title: 'Tempo',
          description: `${monthsAgo} meses desde última manutenção`
        })
      }
    }

    return reasons
  }

  const reasons = getMaintenanceReasons(vehicle)
  
  if (!reasons.length) return null

  const getAlertVariant = () => {
    if (vehicle.status === 'maintenance') return 'destructive'
    return 'default'
  }

  const formatPlate = (plate) => {
    return plate || 'Sem placa'
  }

  return (
    <Alert variant={getAlertVariant()} className="mb-4">
      <AlertTriangle className="h-4 w-4" />
      <AlertTitle className="flex items-center gap-2">
        Manutenção Necessária
        <Badge variant="outline" className="text-xs">
          {formatPlate(vehicle.plate)}
        </Badge>
      </AlertTitle>
      <AlertDescription className="space-y-3 mt-2">
        <div className="text-sm">
          <strong>{vehicle.brand} {vehicle.model}</strong> precisa de atenção:
        </div>
        
        <div className="space-y-2">
          {reasons.map((reason, index) => {
            const Icon = reason.icon
            return (
              <div key={index} className="flex items-center gap-2 text-sm">
                <Icon className="h-4 w-4 text-muted-foreground" />
                <span className="font-medium">{reason.title}:</span>
                <span>{reason.description}</span>
              </div>
            )
          })}
        </div>

        <div className="flex gap-2 mt-4">
          {vehicle.status !== 'maintenance' && (
            <Button
              size="sm"
              variant="outline"
              onClick={() => onScheduleMaintenance?.(vehicle)}
              className="text-xs"
            >
              <Calendar className="mr-1 h-3 w-3" />
              Agendar Manutenção
            </Button>
          )}
          
          <Button
            size="sm"
            variant="outline"
            onClick={() => onUpdateStatus?.(vehicle)}
            className="text-xs"
          >
            <Settings className="mr-1 h-3 w-3" />
            Alterar Status
          </Button>
        </div>
      </AlertDescription>
    </Alert>
  )
}

// Componente para listar todos os alertas de manutenção
export function MaintenanceAlerts({ vehicles = [], onScheduleMaintenance, onUpdateStatus }) {
  const vehiclesNeedingMaintenance = vehicles.filter(vehicle => 
    vehicleService.needsMaintenance(vehicle)
  )

  if (!vehiclesNeedingMaintenance.length) {
    return (
      <Alert className="border-green-200 bg-green-50">
        <CheckCircle className="h-4 w-4 text-green-600" />
        <AlertTitle className="text-green-800">Frota em dia</AlertTitle>
        <AlertDescription className="text-green-700">
          Todos os veículos estão com a manutenção em dia.
        </AlertDescription>
      </Alert>
    )
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2 mb-4">
        <AlertTriangle className="h-5 w-5 text-yellow-600" />
        <h3 className="text-lg font-semibold">
          Alertas de Manutenção ({vehiclesNeedingMaintenance.length})
        </h3>
      </div>
      
      {vehiclesNeedingMaintenance.map((vehicle) => (
        <MaintenanceAlert
          key={vehicle.id}
          vehicle={vehicle}
          onScheduleMaintenance={onScheduleMaintenance}
          onUpdateStatus={onUpdateStatus}
        />
      ))}
    </div>
  )
}

// Hook para obter estatísticas de manutenção
export function useMaintenanceStats(vehicles = []) {
  const stats = React.useMemo(() => {
    const total = vehicles.length
    const needingMaintenance = vehicles.filter(v => vehicleService.needsMaintenance(v)).length
    const inMaintenance = vehicles.filter(v => v.status === 'maintenance').length
    const upToDate = total - needingMaintenance

    return {
      total,
      needingMaintenance,
      inMaintenance,
      upToDate,
      maintenanceRate: total > 0 ? (upToDate / total) * 100 : 0
    }
  }, [vehicles])

  return stats
}