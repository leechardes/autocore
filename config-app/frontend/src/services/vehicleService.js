import api from '@/lib/api'

class VehicleService {
  constructor() {
    this.endpoint = '/vehicle'
  }

  /**
   * Busca o veículo único do sistema
   * @returns {Promise<Object|null>} Dados do veículo ou null se não existir
   */
  async getVehicle() {
    try {
      const response = await api.getVehicle()
      return response || null
    } catch (error) {
      if (error.message?.includes('404') || error.message?.includes('não encontrado')) {
        return null
      }
      console.error('Erro ao buscar veículo:', error)
      throw this.handleError(error)
    }
  }

  /**
   * Verifica se existe um veículo cadastrado
   * @returns {Promise<boolean>} True se existe veículo
   */
  async hasVehicle() {
    try {
      const vehicle = await this.getVehicle()
      return vehicle !== null
    } catch (error) {
      return false
    }
  }

  /**
   * Cria ou atualiza o veículo único do sistema
   * @param {Object} vehicleData - Dados do veículo
   * @returns {Promise<Object>} Veículo criado/atualizado
   */
  async createOrUpdateVehicle(vehicleData) {
    try {
      const response = await api.createOrUpdateVehicle(this.sanitizeVehicleData(vehicleData))
      return response
    } catch (error) {
      console.error('Erro ao salvar veículo:', error)
      throw this.handleError(error)
    }
  }

  /**
   * Remove o veículo do sistema
   * @returns {Promise<void>}
   */
  async deleteVehicle() {
    try {
      await api.deleteVehicle()
    } catch (error) {
      console.error('Erro ao remover veículo:', error)
      throw this.handleError(error)
    }
  }

  /**
   * Reseta o veículo para valores padrão
   * @returns {Promise<void>}
   */
  async resetVehicle() {
    try {
      await api.resetVehicle()
    } catch (error) {
      console.error('Erro ao resetar veículo:', error)
      throw this.handleError(error)
    }
  }

  /**
   * Atualiza odômetro do veículo
   * @param {number} odometer - Novo valor do odômetro
   * @returns {Promise<Object>} Veículo atualizado
   */
  async updateOdometer(odometer) {
    try {
      const response = await api.updateVehicleOdometer(parseFloat(odometer))
      return response
    } catch (error) {
      console.error('Erro ao atualizar odômetro do veículo:', error)
      throw this.handleError(error)
    }
  }

  /**
   * Atualiza localização do veículo
   * @param {number} lat - Latitude
   * @param {number} lng - Longitude
   * @returns {Promise<Object>} Veículo atualizado
   */
  async updateLocation(lat, lng) {
    try {
      const response = await api.updateVehicleLocation(parseFloat(lat), parseFloat(lng))
      return response
    } catch (error) {
      console.error('Erro ao atualizar localização do veículo:', error)
      throw this.handleError(error)
    }
  }

  /**
   * Atualiza status do veículo
   * @param {string} status - Novo status
   * @returns {Promise<Object>} Veículo atualizado
   */
  async updateStatus(status) {
    try {
      const response = await api.updateVehicleStatus(status)
      return response
    } catch (error) {
      console.error('Erro ao atualizar status do veículo:', error)
      throw this.handleError(error)
    }
  }

  /**
   * Busca histórico de manutenção do veículo
   * @returns {Promise<Array>} Histórico de manutenção
   */
  async getMaintenanceHistory() {
    try {
      const response = await api.getVehicleMaintenanceHistory()
      return response
    } catch (error) {
      console.error('Erro ao buscar histórico de manutenção:', error)
      throw this.handleError(error)
    }
  }

  /**
   * Agenda manutenção para o veículo
   * @param {Object} maintenanceData - Dados da manutenção
   * @returns {Promise<Object>} Manutenção agendada
   */
  async scheduleMaintenance(maintenanceData) {
    try {
      const response = await api.scheduleVehicleMaintenance(maintenanceData)
      return response
    } catch (error) {
      console.error('Erro ao agendar manutenção:', error)
      throw this.handleError(error)
    }
  }


  /**
   * Sanitiza dados do veículo antes do envio
   * @param {Object} data - Dados do veículo
   * @returns {Object} Dados sanitizados
   */
  sanitizeVehicleData(data) {
    const sanitized = { ...data }

    // Converte strings numéricas para números
    if (sanitized.year_manufacture) {
      sanitized.year_manufacture = parseInt(sanitized.year_manufacture)
    }
    if (sanitized.year_model) {
      sanitized.year_model = parseInt(sanitized.year_model)
    }
    if (sanitized.current_mileage) {
      sanitized.current_mileage = parseFloat(sanitized.current_mileage)
    }

    // Remove campos vazios
    Object.keys(sanitized).forEach(key => {
      if (sanitized[key] === '' || sanitized[key] === null) {
        delete sanitized[key]
      }
    })

    // Normaliza placa para maiúsculas
    if (sanitized.plate) {
      sanitized.plate = sanitized.plate.toUpperCase().replace(/[^A-Z0-9]/g, '')
    }

    // Normaliza chassi para maiúsculas
    if (sanitized.chassis) {
      sanitized.chassis = sanitized.chassis.toUpperCase().replace(/[^A-Z0-9]/g, '')
    }

    return sanitized
  }

  /**
   * Trata erros da API
   * @param {Error} error - Erro recebido
   * @returns {Error} Erro tratado
   */
  handleError(error) {
    let message = 'Erro desconhecido'

    if (error.message) {
      message = error.message
    } else if (typeof error === 'string') {
      message = error
    }

    // Mensagens específicas baseadas no status HTTP
    if (error.status) {
      switch (error.status) {
        case 400:
          message = 'Dados inválidos fornecidos'
          break
        case 401:
          message = 'Acesso não autorizado'
          break
        case 403:
          message = 'Operação não permitida'
          break
        case 404:
          message = 'Veículo não encontrado'
          break
        case 409:
          message = 'Conflito: Placa já existe'
          break
        case 422:
          message = 'Dados de entrada inválidos'
          break
        case 500:
          message = 'Erro interno do servidor'
          break
        case 503:
          message = 'Serviço temporariamente indisponível'
          break
      }
    }

    const customError = new Error(message)
    customError.status = error.status
    customError.originalError = error

    return customError
  }

  /**
   * Formata dados do veículo para exibição
   * @param {Object} vehicle - Dados do veículo
   * @returns {Object} Dados formatados
   */
  formatVehicleForDisplay(vehicle) {
    if (!vehicle) return null

    return {
      ...vehicle,
      displayName: `${vehicle.brand || ''} ${vehicle.model || ''} (${vehicle.plate || ''})`.trim(),
      yearRange: vehicle.year_manufacture && vehicle.year_model 
        ? `${vehicle.year_manufacture}/${vehicle.year_model}`
        : vehicle.year_manufacture || vehicle.year_model || '',
      statusLabel: this.getStatusLabel(vehicle.status),
      fuelTypeLabel: this.getFuelTypeLabel(vehicle.fuel_type),
      transmissionLabel: this.getTransmissionLabel(vehicle.transmission)
    }
  }

  /**
   * Obtém label do status
   */
  getStatusLabel(status) {
    const labels = {
      'active': 'Ativo',
      'maintenance': 'Manutenção',
      'inactive': 'Inativo',
      'sold': 'Vendido',
      'accident': 'Acidente'
    }
    return labels[status] || status || 'Desconhecido'
  }

  /**
   * Obtém label do tipo de combustível
   */
  getFuelTypeLabel(fuelType) {
    const labels = {
      'flex': 'Flex',
      'gasoline': 'Gasolina',
      'ethanol': 'Etanol',
      'diesel': 'Diesel',
      'electric': 'Elétrico',
      'hybrid': 'Híbrido'
    }
    return labels[fuelType] || fuelType || ''
  }

  /**
   * Obtém label do tipo de transmissão
   */
  getTransmissionLabel(transmission) {
    const labels = {
      'manual': 'Manual',
      'automatic': 'Automática',
      'cvt': 'CVT'
    }
    return labels[transmission] || transmission || ''
  }

  /**
   * Verifica se veículo precisa de manutenção
   * @param {Object} vehicle - Dados do veículo
   * @returns {boolean} True se precisa de manutenção
   */
  needsMaintenance(vehicle) {
    if (!vehicle) return false

    // Verificar se status é manutenção
    if (vehicle.status === 'maintenance') return true

    // Verificar quilometragem (exemplo: a cada 10.000 km)
    if (vehicle.current_mileage && vehicle.last_maintenance_mileage) {
      const kmSinceLastMaintenance = vehicle.current_mileage - vehicle.last_maintenance_mileage
      if (kmSinceLastMaintenance >= 10000) return true
    }

    // Verificar data da última manutenção (exemplo: mais de 6 meses)
    if (vehicle.last_maintenance_date) {
      const lastMaintenance = new Date(vehicle.last_maintenance_date)
      const sixMonthsAgo = new Date()
      sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6)
      
      if (lastMaintenance < sixMonthsAgo) return true
    }

    return false
  }
}

// Criar e exportar instância única
const vehicleService = new VehicleService()

export { VehicleService, vehicleService }
export default vehicleService