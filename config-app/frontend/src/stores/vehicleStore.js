import { create } from 'zustand'
import { devtools, persist } from 'zustand/middleware'
import vehicleService from '@/services/vehicleService'
import { toast } from 'sonner'

const useVehicleStore = create(
  devtools(
    persist(
      (set, get) => ({
        // State - Objeto único em vez de array
        vehicle: null,
        loading: false,
        hasVehicle: false,
        error: null,

        // Actions
        setLoading: (loading) => set({ loading }),
        
        setError: (error) => set({ error }),

        clearError: () => set({ error: null }),

        // Fetch single vehicle
        fetchVehicle: async () => {
          set({ loading: true, error: null })

          try {
            const vehicle = await vehicleService.getVehicle()
            set({ 
              vehicle, 
              hasVehicle: vehicle !== null,
              loading: false 
            })
            return vehicle
          } catch (error) {
            console.error('Erro ao carregar veículo:', error)
            set({ 
              error: error.message,
              vehicle: null,
              hasVehicle: false,
              loading: false 
            })
            throw error
          }
        },

        // Create or update vehicle
        createOrUpdateVehicle: async (vehicleData) => {
          set({ loading: true, error: null })

          try {
            const vehicle = await vehicleService.createOrUpdateVehicle(vehicleData)
            
            set({ 
              vehicle, 
              hasVehicle: true,
              loading: false 
            })
            
            const isUpdate = get().vehicle !== null
            toast.success(isUpdate ? 'Veículo atualizado com sucesso!' : 'Veículo cadastrado com sucesso!')
            
            return vehicle
          } catch (error) {
            console.error('Erro ao salvar veículo:', error)
            set({ 
              error: error.message,
              loading: false 
            })
            toast.error('Erro ao salvar veículo: ' + error.message)
            throw error
          }
        },

        // Delete vehicle
        deleteVehicle: async () => {
          set({ loading: true, error: null })

          try {
            await vehicleService.deleteVehicle()
            
            set({ 
              vehicle: null,
              hasVehicle: false,
              loading: false 
            })
            
            toast.success('Veículo removido com sucesso!')
          } catch (error) {
            console.error('Erro ao remover veículo:', error)
            set({ 
              error: error.message,
              loading: false 
            })
            toast.error('Erro ao remover veículo: ' + error.message)
            throw error
          }
        },

        // Reset vehicle
        resetVehicle: async () => {
          set({ loading: true, error: null })

          try {
            await vehicleService.resetVehicle()
            
            set({ 
              vehicle: null,
              hasVehicle: false,
              loading: false 
            })
            
            toast.success('Veículo resetado com sucesso!')
          } catch (error) {
            console.error('Erro ao resetar veículo:', error)
            set({ 
              error: error.message,
              loading: false 
            })
            toast.error('Erro ao resetar veículo: ' + error.message)
            throw error
          }
        },

        // Update odometer
        updateOdometer: async (odometer) => {
          try {
            const updatedVehicle = await vehicleService.updateOdometer(odometer)
            
            const currentVehicle = get().vehicle
            if (currentVehicle) {
              set({ 
                vehicle: { 
                  ...currentVehicle, 
                  current_mileage: updatedVehicle.current_mileage 
                }
              })
            }
            
            toast.success('Odômetro atualizado com sucesso!')
            return updatedVehicle
          } catch (error) {
            console.error('Erro ao atualizar odômetro:', error)
            toast.error('Erro ao atualizar odômetro: ' + error.message)
            throw error
          }
        },

        // Update location
        updateLocation: async (lat, lng) => {
          try {
            const updatedVehicle = await vehicleService.updateLocation(lat, lng)
            
            const currentVehicle = get().vehicle
            if (currentVehicle) {
              set({ 
                vehicle: { 
                  ...currentVehicle, 
                  latitude: lat, 
                  longitude: lng 
                }
              })
            }
            
            toast.success('Localização atualizada com sucesso!')
            return updatedVehicle
          } catch (error) {
            console.error('Erro ao atualizar localização:', error)
            toast.error('Erro ao atualizar localização: ' + error.message)
            throw error
          }
        },

        // Update status
        updateStatus: async (status) => {
          try {
            const updatedVehicle = await vehicleService.updateStatus(status)
            
            const currentVehicle = get().vehicle
            if (currentVehicle) {
              set({ 
                vehicle: { 
                  ...currentVehicle, 
                  status: updatedVehicle.status 
                }
              })
            }
            
            toast.success('Status atualizado com sucesso!')
            return updatedVehicle
          } catch (error) {
            console.error('Erro ao atualizar status:', error)
            toast.error('Erro ao atualizar status: ' + error.message)
            throw error
          }
        },

        // Get maintenance history
        getMaintenanceHistory: async () => {
          try {
            const history = await vehicleService.getMaintenanceHistory()
            return history
          } catch (error) {
            console.error('Erro ao buscar histórico de manutenção:', error)
            toast.error('Erro ao buscar histórico: ' + error.message)
            throw error
          }
        },

        // Schedule maintenance
        scheduleMaintenance: async (maintenanceData) => {
          try {
            const maintenance = await vehicleService.scheduleMaintenance(maintenanceData)
            toast.success('Manutenção agendada com sucesso!')
            
            // Refresh vehicle data
            get().fetchVehicle()
            
            return maintenance
          } catch (error) {
            console.error('Erro ao agendar manutenção:', error)
            toast.error('Erro ao agendar manutenção: ' + error.message)
            throw error
          }
        },

        // Check if vehicle needs maintenance
        needsMaintenance: () => {
          const { vehicle } = get()
          if (!vehicle) return false
          
          return vehicleService.needsMaintenance(vehicle)
        },

        // Get formatted vehicle for display
        getFormattedVehicle: () => {
          const { vehicle } = get()
          if (!vehicle) return null
          
          return vehicleService.formatVehicleForDisplay(vehicle)
        },

        // Reset store
        reset: () => set({
          vehicle: null,
          loading: false,
          hasVehicle: false,
          error: null
        })
      }),
      {
        name: 'vehicle-store',
        partialize: (state) => ({
          // Only persist the vehicle data
          vehicle: state.vehicle,
          hasVehicle: state.hasVehicle
        })
      }
    ),
    {
      name: 'vehicle-store'
    }
  )
)

export default useVehicleStore