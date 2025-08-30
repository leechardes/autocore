import React, { useEffect, useState } from 'react'
import { Card, CardHeader, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Car, Edit, Plus, Trash2 } from 'lucide-react'
import { default as useVehicleStore } from '@/stores/vehicleStore'
import VehicleForm from './VehicleForm'
import VehicleDisplay from '@/components/vehicle/VehicleDisplay'
import { toast } from 'sonner'
import { Skeleton } from '@/components/ui/skeleton'
import ErrorBoundary from '@/components/ErrorBoundary'
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog'

export default function VehicleManager() {
  const { 
    vehicle, 
    loading, 
    hasVehicle, 
    fetchVehicle, 
    deleteVehicle 
  } = useVehicleStore()
  
  const [isEditing, setIsEditing] = useState(false)
  const [showDeleteDialog, setShowDeleteDialog] = useState(false)
  
  // Debug logs
  console.log('[VehicleManager] Estado atual:', {
    isEditing,
    hasVehicle,
    vehicle,
    loading
  })
  
  useEffect(() => {
    console.log('[VehicleManager] useEffect - Buscando veículo...')
    fetchVehicle()
  }, [fetchVehicle])
  
  if (loading) {
    return (
      <div className="container mx-auto p-6 max-w-4xl">
        <Skeleton className="h-12 w-48 mb-6" />
        <Skeleton className="h-96 w-full" />
      </div>
    )
  }
  
  const handleDelete = async () => {
    try {
      await deleteVehicle()
      setShowDeleteDialog(false)
      toast.success('Veículo removido com sucesso!')
    } catch (error) {
      toast.error('Erro ao remover veículo: ' + error.message)
    }
  }
  
  const handleSave = () => {
    setIsEditing(false)
    fetchVehicle()
  }
  
  return (
    <div className="container mx-auto p-6 max-w-4xl">
      <div className="mb-6">
        <h1 className="text-3xl font-bold flex items-center gap-3">
          <Car className="h-8 w-8 text-primary" />
          Gerenciamento de Veículo
        </h1>
        <p className="text-muted-foreground mt-2">
          {hasVehicle 
            ? 'Visualize e gerencie os dados do veículo cadastrado'
            : 'Cadastre o veículo do sistema'}
        </p>
      </div>
      
      {(() => {
        console.log('[VehicleManager] Renderização condicional:', {
          hasVehicle,
          isEditing,
          condicao1: !hasVehicle && !isEditing,
          condicao2: isEditing,
          condicao3: hasVehicle && !isEditing
        })
        
        if (!hasVehicle && !isEditing) {
          console.log('[VehicleManager] Renderizando: Card vazio (cadastrar)')
          return (
            <Card className="border-dashed">
              <CardContent className="text-center py-12">
                <Car className="h-16 w-16 text-muted-foreground mx-auto mb-4" />
                <h3 className="text-xl font-semibold mb-2">
                  Nenhum veículo cadastrado
                </h3>
                <p className="text-muted-foreground mb-6">
                  Clique no botão abaixo para cadastrar o veículo do sistema
                </p>
                <Button 
                  onClick={() => {
                    console.log('[VehicleManager] Botão Cadastrar clicado!')
                    console.log('[VehicleManager] Mudando isEditing para true')
                    setIsEditing(true)
                  }} 
                  size="lg"
                >
                  <Plus className="mr-2 h-5 w-5" />
                  Cadastrar Veículo
                </Button>
              </CardContent>
            </Card>
          )
        } else if (isEditing) {
          console.log('[VehicleManager] Renderizando: VehicleForm')
          return (
            <ErrorBoundary>
              <VehicleForm 
                vehicle={vehicle}
                onSave={handleSave}
                onCancel={() => setIsEditing(false)}
              />
            </ErrorBoundary>
          )
        } else {
          console.log('[VehicleManager] Renderizando: Card com veículo')
          return (
            <Card>
              <CardHeader>
            <div className="flex justify-between items-start">
              <div>
                <h2 className="text-2xl font-bold">
                  {vehicle?.brand} {vehicle?.model}
                </h2>
                <p className="text-muted-foreground">Placa: {vehicle?.plate}</p>
              </div>
              <div className="flex gap-2">
                <Button 
                  variant="outline" 
                  onClick={() => setIsEditing(true)}
                >
                  <Edit className="mr-2 h-4 w-4" />
                  Editar
                </Button>
                <Button 
                  variant="destructive" 
                  onClick={() => setShowDeleteDialog(true)}
                >
                  <Trash2 className="mr-2 h-4 w-4" />
                  Remover
                </Button>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <VehicleDisplay vehicle={vehicle} />
          </CardContent>
            </Card>
          )
        }
      })()}

      {/* Dialog de confirmação de exclusão */}
      <AlertDialog open={showDeleteDialog} onOpenChange={setShowDeleteDialog}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Confirmar Remoção</AlertDialogTitle>
            <AlertDialogDescription>
              Tem certeza que deseja remover o veículo{' '}
              <strong>{vehicle?.brand} {vehicle?.model}</strong>{' '}
              (Placa: {vehicle?.plate})?
              <br /><br />
              Esta ação não pode ser desfeita e todos os dados do veículo serão perdidos.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancelar</AlertDialogCancel>
            <AlertDialogAction 
              onClick={handleDelete}
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              Remover Veículo
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}