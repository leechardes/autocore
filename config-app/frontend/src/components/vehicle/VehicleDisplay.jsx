import React from 'react'
import { Badge } from '@/components/ui/badge'
import { 
  Calendar, Fuel, MapPin, Settings, FileText, AlertTriangle, Car
} from 'lucide-react'
import { Alert, AlertDescription } from '@/components/ui/alert'
import vehicleService from '@/services/vehicleService'

export default function VehicleDisplay({ vehicle }) {
  if (!vehicle) {
    return (
      <div className="text-center py-12">
        <Car className="h-16 w-16 text-muted-foreground mx-auto mb-4" />
        <p className="text-muted-foreground">
          Nenhum dado de veículo para exibir
        </p>
      </div>
    )
  }

  const formatted = vehicleService.formatVehicleForDisplay(vehicle)
  const needsMaintenance = vehicleService.needsMaintenance(vehicle)
  
  const maintenanceDue = vehicle.next_maintenance_km && vehicle.odometer &&
    (vehicle.next_maintenance_km - vehicle.odometer < 1000)
  
  return (
    <div className="space-y-6">
      {/* Alerta de manutenção */}
      {(needsMaintenance || maintenanceDue) && (
        <Alert>
          <AlertTriangle className="h-4 w-4" />
          <AlertDescription>
            {maintenanceDue 
              ? `Manutenção se aproximando! Faltam apenas ${vehicle.next_maintenance_km - vehicle.odometer} km`
              : 'Veículo precisa de manutenção!'
            }
          </AlertDescription>
        </Alert>
      )}
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Identificação */}
        <div>
          <h3 className="font-semibold mb-3 flex items-center">
            <Car className="h-4 w-4 mr-2" />
            Identificação
          </h3>
          <dl className="space-y-2 text-sm">
            <div className="flex justify-between">
              <dt className="text-muted-foreground">Marca/Modelo:</dt>
              <dd className="font-medium">{vehicle.brand} {vehicle.model}</dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-muted-foreground">Placa:</dt>
              <dd className="font-mono font-medium">{vehicle.plate || 'Não informada'}</dd>
            </div>
            {vehicle.chassis && (
              <div className="flex justify-between">
                <dt className="text-muted-foreground">Chassi:</dt>
                <dd className="font-mono text-xs">{vehicle.chassis}</dd>
              </div>
            )}
            {vehicle.renavam && (
              <div className="flex justify-between">
                <dt className="text-muted-foreground">RENAVAM:</dt>
                <dd className="font-mono">{vehicle.renavam}</dd>
              </div>
            )}
            <div className="flex justify-between">
              <dt className="text-muted-foreground">Ano:</dt>
              <dd>{formatted?.yearRange || 'Não informado'}</dd>
            </div>
            {vehicle.color && (
              <div className="flex justify-between">
                <dt className="text-muted-foreground">Cor:</dt>
                <dd className="capitalize">{vehicle.color}</dd>
              </div>
            )}
          </dl>
        </div>
        
        {/* Especificações */}
        <div>
          <h3 className="font-semibold mb-3 flex items-center">
            <Settings className="h-4 w-4 mr-2" />
            Especificações
          </h3>
          <dl className="space-y-2 text-sm">
            <div className="flex justify-between items-center">
              <dt className="text-muted-foreground flex items-center">
                <Fuel className="h-4 w-4 mr-1" />
                Combustível:
              </dt>
              <dd className="capitalize">{formatted?.fuelTypeLabel || 'Não informado'}</dd>
            </div>
            <div className="flex justify-between items-center">
              <dt className="text-muted-foreground flex items-center">
                <Settings className="h-4 w-4 mr-1" />
                Transmissão:
              </dt>
              <dd className="capitalize">
                {formatted?.transmissionLabel || 'Não informado'}
              </dd>
            </div>
            <div className="flex justify-between items-center">
              <dt className="text-muted-foreground flex items-center">
                <MapPin className="h-4 w-4 mr-1" />
                Quilometragem:
              </dt>
              <dd className="font-bold">
                {vehicle.odometer?.toLocaleString('pt-BR') || '0'} km
              </dd>
            </div>
            <div className="flex justify-between items-center">
              <dt className="text-muted-foreground">Status:</dt>
              <dd>
                <Badge variant={vehicle.status === 'active' ? 'default' : 'secondary'}>
                  {formatted?.statusLabel || 'Ativo'}
                </Badge>
              </dd>
            </div>
          </dl>
        </div>
      </div>
      
      {/* Manutenção e Documentos */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 pt-4 border-t">
        <div>
          <h3 className="font-semibold mb-3 flex items-center">
            <Settings className="h-4 w-4 mr-2" />
            Manutenção
          </h3>
          <dl className="space-y-2 text-sm">
            <div className="flex justify-between">
              <dt className="text-muted-foreground">Próxima em:</dt>
              <dd>
                {vehicle.next_maintenance_km 
                  ? `${vehicle.next_maintenance_km.toLocaleString('pt-BR')} km`
                  : 'Não definida'}
              </dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-muted-foreground">Data prevista:</dt>
              <dd>
                {vehicle.next_maintenance_date 
                  ? new Date(vehicle.next_maintenance_date).toLocaleDateString('pt-BR')
                  : 'Não definida'}
              </dd>
            </div>
            {vehicle.last_maintenance_date && (
              <div className="flex justify-between">
                <dt className="text-muted-foreground">Última manutenção:</dt>
                <dd>
                  {new Date(vehicle.last_maintenance_date).toLocaleDateString('pt-BR')}
                </dd>
              </div>
            )}
          </dl>
        </div>
        
        <div>
          <h3 className="font-semibold mb-3 flex items-center">
            <FileText className="h-4 w-4 mr-2" />
            Documentos
          </h3>
          <dl className="space-y-2 text-sm">
            <div className="flex justify-between">
              <dt className="text-muted-foreground">Licenciamento:</dt>
              <dd>
                {vehicle.license_expiry 
                  ? new Date(vehicle.license_expiry).toLocaleDateString('pt-BR')
                  : 'Não informado'}
              </dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-muted-foreground">Seguro:</dt>
              <dd>
                {vehicle.insurance_expiry 
                  ? new Date(vehicle.insurance_expiry).toLocaleDateString('pt-BR')
                  : 'Não informado'}
              </dd>
            </div>
            {vehicle.ipva_expiry && (
              <div className="flex justify-between">
                <dt className="text-muted-foreground">IPVA:</dt>
                <dd>
                  {new Date(vehicle.ipva_expiry).toLocaleDateString('pt-BR')}
                </dd>
              </div>
            )}
          </dl>
        </div>
      </div>
      
      {/* Localização */}
      {(vehicle.latitude || vehicle.longitude) && (
        <div className="pt-4 border-t">
          <h3 className="font-semibold mb-3 flex items-center">
            <MapPin className="h-4 w-4 mr-2" />
            Localização
          </h3>
          <dl className="space-y-2 text-sm">
            <div className="flex justify-between">
              <dt className="text-muted-foreground">Coordenadas:</dt>
              <dd className="font-mono">
                {vehicle.latitude?.toFixed(6)}, {vehicle.longitude?.toFixed(6)}
              </dd>
            </div>
            {vehicle.address && (
              <div className="flex justify-between">
                <dt className="text-muted-foreground">Endereço:</dt>
                <dd>{vehicle.address}</dd>
              </div>
            )}
          </dl>
        </div>
      )}
      
      {/* Observações */}
      {vehicle.notes && (
        <div className="pt-4 border-t">
          <h3 className="font-semibold mb-2">Observações</h3>
          <p className="text-muted-foreground text-sm whitespace-pre-wrap">
            {vehicle.notes}
          </p>
        </div>
      )}
      
      {/* Informações do sistema */}
      <div className="pt-4 border-t">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs text-muted-foreground">
          {vehicle.created_at && (
            <div>
              <span className="font-medium">Cadastrado em:</span>{' '}
              {new Date(vehicle.created_at).toLocaleString('pt-BR')}
            </div>
          )}
          {vehicle.updated_at && (
            <div>
              <span className="font-medium">Atualizado em:</span>{' '}
              {new Date(vehicle.updated_at).toLocaleString('pt-BR')}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}