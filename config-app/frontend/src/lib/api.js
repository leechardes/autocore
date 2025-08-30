// AutoCore Config App - API Client Centralizado
// Todas as chamadas de API em um local

class AutoCoreAPI {
  constructor() {
    this.baseURL = import.meta.env.VITE_API_URL || 'http://localhost:8081/api'
    this.timeout = 10000 // 10 seconds
  }

  // Generic request method
  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`
    
    const config = {
      timeout: this.timeout,
      headers: {
        'Content-Type': 'application/json',
        ...options.headers
      },
      ...options
    }

    try {
      
      const controller = new AbortController()
      const timeoutId = setTimeout(() => controller.abort(), this.timeout)
      
      const response = await fetch(url, {
        ...config,
        signal: controller.signal
      })
      
      clearTimeout(timeoutId)
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`)
      }
      
      const data = await response.json()
      
      return data
      
    } catch (error) {
      console.error(`❌ API Error: ${url}`, error)
      
      if (error.name === 'AbortError') {
        throw new Error('Request timeout - verifique a conexão com o servidor')
      }
      
      if (error.message.includes('Failed to fetch')) {
        throw new Error('Servidor indisponível - verifique se a API está rodando')
      }
      
      throw error
    }
  }

  // HTTP Methods
  async get(endpoint, params = {}) {
    const queryString = new URLSearchParams(params).toString()
    const url = queryString ? `${endpoint}?${queryString}` : endpoint
    
    return this.request(url, {
      method: 'GET'
    })
  }

  async post(endpoint, data = {}) {
    return this.request(endpoint, {
      method: 'POST',
      body: JSON.stringify(data)
    })
  }

  async patch(endpoint, data = {}) {
    return this.request(endpoint, {
      method: 'PATCH',
      body: JSON.stringify(data)
    })
  }

  async put(endpoint, data = {}) {
    return this.request(endpoint, {
      method: 'PUT',
      body: JSON.stringify(data)
    })
  }

  async delete(endpoint) {
    return this.request(endpoint, {
      method: 'DELETE'
    })
  }

  // ===================================
  // SYSTEM ENDPOINTS
  // ===================================

  async getStatus() {
    return this.get('/status')
  }

  async getHealth() {
    return this.get('/')
  }

  // ===================================
  // DEVICE ENDPOINTS  
  // ===================================

  async getDevices() {
    return this.get('/devices')
  }

  async getDevice(id) {
    return this.get(`/devices/${id}`)
  }

  async getAvailableRelayDevices() {
    return this.get('/devices/available-for-relays')
  }

  async createDevice(deviceData) {
    return this.post('/devices', deviceData)
  }

  async updateDevice(id, deviceData) {
    return this.patch(`/devices/${id}`, deviceData)
  }

  async deleteDevice(id) {
    return this.delete(`/devices/${id}`)
  }

  // ===================================
  // RELAY ENDPOINTS
  // ===================================

  async getRelayBoards() {
    return this.get('/relays/boards')
  }

  async getRelayBoard(id) {
    return this.get(`/relays/boards/${id}`)
  }

  async getRelayChannels(boardId = null) {
    const params = boardId ? { board_id: boardId } : {}
    return this.get('/relays/channels', params)
  }

  async getRelayChannel(id) {
    return this.get(`/relays/channels/${id}`)
  }

  async toggleRelay(channelId) {
    return this.post(`/relays/channels/${channelId}/toggle`)
  }

  async setRelayState(channelId, state) {
    return this.patch(`/relays/channels/${channelId}/state`, { state })
  }

  async updateRelayChannel(channelId, channelData) {
    return this.patch(`/relays/channels/${channelId}`, channelData)
  }

  async createRelayBoard(boardData) {
    return this.post('/relays/boards', boardData)
  }

  async updateRelayBoard(boardId, boardData) {
    return this.patch(`/relays/boards/${boardId}`, boardData)
  }

  async deleteRelayBoard(boardId) {
    return this.delete(`/relays/boards/${boardId}`)
  }

  async createRelayChannel(channelData) {
    return this.post('/relays/channels', channelData)
  }

  async deleteRelayChannel(channelId) {
    return this.delete(`/relays/channels/${channelId}`)
  }

  async resetRelayChannel(channelId) {
    return this.post(`/relays/channels/${channelId}/reset`)
  }

  async activateRelayChannel(channelId) {
    return this.post(`/relays/channels/${channelId}/activate`)
  }

  async updateRelayBoard(boardId, boardData) {
    return this.patch(`/relays/boards/${boardId}`, boardData)
  }

  async deleteRelayBoard(boardId) {
    return this.delete(`/relays/boards/${boardId}`)
  }

  // Batch operations
  async batchUpdateRelays(updates) {
    return this.post('/relays/batch-update', { updates })
  }

  async batchToggleRelays(channelIds) {
    return this.post('/relays/batch-toggle', { channel_ids: channelIds })
  }

  // ===================================
  // SCREEN ENDPOINTS
  // ===================================

  async getScreens() {
    return this.get('/screens')
  }

  async getScreen(id) {
    return this.get(`/screens/${id}`)
  }

  async createScreen(screenData) {
    return this.post('/screens', screenData)
  }

  async updateScreen(id, screenData) {
    return this.patch(`/screens/${id}`, screenData)
  }

  async deleteScreen(id) {
    return this.delete(`/screens/${id}`)
  }

  async getScreenItems(screenId) {
    return this.get(`/screens/${screenId}/items`)
  }

  async createScreenItem(screenId, itemData) {
    return this.post(`/screens/${screenId}/items`, itemData)
  }

  async updateScreenItem(screenId, itemId, itemData) {
    return this.patch(`/screens/${screenId}/items/${itemId}`, itemData)
  }

  async deleteScreenItem(screenId, itemId) {
    return this.delete(`/screens/${screenId}/items/${itemId}`)
  }

  // ===================================
  // THEME ENDPOINTS
  // ===================================

  async getThemes() {
    return this.get('/themes')
  }

  async getDefaultTheme() {
    return this.get('/themes/default')
  }

  async createTheme(themeData) {
    return this.post('/themes', themeData)
  }

  async updateTheme(id, themeData) {
    return this.patch(`/themes/${id}`, themeData)
  }

  async deleteTheme(id) {
    return this.delete(`/themes/${id}`)
  }

  // ===================================
  // CONFIG GENERATION
  // ===================================

  async generateDeviceConfig(deviceUuid) {
    return this.get(`/config/generate/${deviceUuid}`)
  }

  async exportConfig(format = 'json') {
    return this.get(`/export/config`, { format })
  }

  async importConfig(configData) {
    return this.post('/import/config', configData)
  }

  // Novo endpoint config/full para preview
  async getFullConfig(deviceUuid = null, preview = true) {
    if (deviceUuid) {
      return this.get(`/config/full/${deviceUuid}`, { preview })
    } else {
      return this.get('/config/full', { preview })
    }
  }

  async getPreviewConfig() {
    try {
      const result = await this.get('/config/full')
      return result
    } catch (error) {
      console.error('❌ Erro em getPreviewConfig:', error)
      throw error
    }
  }

  // ===================================
  // VEHICLE ENDPOINT (Singular - Single Vehicle System)
  // ===================================

  async getVehicle() {
    return this.get('/vehicle')
  }

  async createOrUpdateVehicle(vehicleData) {
    return this.post('/vehicle', vehicleData)
  }

  async deleteVehicle() {
    return this.delete('/vehicle')
  }

  async resetVehicle() {
    return this.delete('/vehicle/reset')
  }

  async updateVehicleOdometer(odometer) {
    return this.patch('/vehicle/odometer', { current_mileage: odometer })
  }

  async updateVehicleLocation(lat, lng) {
    return this.patch('/vehicle/location', { latitude: lat, longitude: lng })
  }

  async updateVehicleStatus(status) {
    return this.patch('/vehicle/status', { status })
  }

  async getVehicleMaintenanceHistory() {
    return this.get('/vehicle/maintenance')
  }

  async scheduleVehicleMaintenance(maintenanceData) {
    return this.post('/vehicle/maintenance', maintenanceData)
  }

  // ===================================
  // CAN SIGNALS ENDPOINTS
  // ===================================

  async getCANSignals(category = null) {
    const params = category ? `?category=${category}` : ''
    return this.get(`/can-signals${params}`)
  }

  async getCANSignal(id) {
    return this.get(`/can-signals/${id}`)
  }

  async createCANSignal(signalData) {
    return this.post('/can-signals', signalData)
  }

  async updateCANSignal(id, signalData) {
    return this.put(`/can-signals/${id}`, signalData)
  }

  async deleteCANSignal(id) {
    return this.delete(`/can-signals/${id}`)
  }

  async seedCANSignals() {
    return this.post('/can-signals/seed')
  }

  // ===================================
  // TELEMETRY ENDPOINTS (Future)
  // ===================================

  async getTelemetry(deviceId, limit = 100) {
    return this.get(`/telemetry/${deviceId}`, { limit })
  }

  async getLatestTelemetry(deviceId) {
    return this.get(`/telemetry/${deviceId}/latest`)
  }

  // ===================================
  // CAN BUS ENDPOINTS (Future)
  // ===================================

  async getCanSignals() {
    return this.get('/can/signals')
  }

  async getCanTelemetry(limit = 100) {
    return this.get('/can/telemetry', { limit })
  }

  async createCanSignal(signalData) {
    return this.post('/can/signals', signalData)
  }

  async updateCanSignal(signalId, signalData) {
    return this.patch(`/can/signals/${signalId}`, signalData)
  }

  async deleteCanSignal(signalId) {
    return this.delete(`/can/signals/${signalId}`)
  }

  // ===================================
  // UTILITY METHODS
  // ===================================

  isOnline() {
    return navigator.onLine
  }

  async testConnection() {
    try {
      await this.getHealth()
      return true
    } catch {
      return false
    }
  }

  getErrorMessage(error) {
    if (error.message) {
      return error.message
    }
    
    if (typeof error === 'string') {
      return error
    }
    
    return 'Erro desconhecido na API'
  }

  // Request retry logic
  async retryRequest(requestFn, maxRetries = 3, delay = 1000) {
    let lastError
    
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await requestFn()
      } catch (error) {
        lastError = error
        
        if (attempt === maxRetries) {
          break
        }
        
        await new Promise(resolve => setTimeout(resolve, delay))
        
        // Exponential backoff
        delay *= 2
      }
    }
    
    throw lastError
  }

  // ===================================
  // MACROS ENDPOINTS
  // ===================================
  
  async getMacros(activeOnly = true) {
    return this.get('/macros/', { active_only: activeOnly })
  }
  
  async getMacro(id) {
    return this.get(`/macros/${id}`)
  }
  
  async createMacro(macroData) {
    return this.post('/macros/', macroData)
  }
  
  async updateMacro(id, macroData) {
    return this.put(`/macros/${id}`, macroData)
  }
  
  async deleteMacro(id) {
    return this.delete(`/macros/${id}`)
  }
  
  async executeMacro(id, context = null, testMode = false) {
    return this.post(`/macros/${id}/execute`, {
      context: context || { source: 'web_interface' },
      test_mode: testMode
    })
  }
  
  async stopMacro(id) {
    return this.post(`/macros/${id}/stop`)
  }
  
  async getMacroStatus(id) {
    return this.get(`/macros/${id}/status`)
  }
  
  async getMacroTemplates() {
    return this.get('/macros/templates/list')
  }
  
  async createMacroFromTemplate(templateId, name = null) {
    const params = name ? { name } : {}
    return this.post(`/macros/templates/${templateId}/create`, null, params)
  }
  
  async emergencyStop() {
    return this.post('/macros/emergency-stop')
  }
  
  // ===================================
  // SIMULATOR ENDPOINTS
  // ===================================
  
  async getSimulatorBoards() {
    return this.get('/simulators/relay/boards')
  }
  
  async listRelaySimulators() {
    return this.get('/simulators/relay/list')
  }
  
  async createRelaySimulator(boardId) {
    return this.post(`/simulators/relay/create/${boardId}`)
  }
  
  async removeRelaySimulator(boardId) {
    return this.delete(`/simulators/relay/${boardId}`)
  }
  
  async getRelaySimulatorStatus(boardId) {
    return this.get(`/simulators/relay/${boardId}/status`)
  }
  
  async toggleRelayChannel(boardId, channel) {
    return this.post(`/simulators/relay/${boardId}/channel/${channel}/toggle`)
  }
  
  async setRelayChannelState(boardId, channel, state) {
    return this.post(`/simulators/relay/${boardId}/channel/${channel}/set`, { state })
  }
  
  async resetRelaySimulator(boardId) {
    return this.post(`/simulators/relay/${boardId}/reset`)
  }
  
  async getBoardChannelsWithState(boardId) {
    return this.get(`/simulators/relay/boards/${boardId}/channels`)
  }
  
  // Debug info
  getDebugInfo() {
    return {
      baseURL: this.baseURL,
      timeout: this.timeout,
      online: this.isOnline(),
      timestamp: new Date().toISOString()
    }
  }
}

// Create and export global API instance
const api = new AutoCoreAPI()

// Export for different module systems
export { AutoCoreAPI, api }
export default api

// Make available globally for debugging
if (typeof window !== 'undefined') {
  window.api = api
  window.AutoCoreAPI = AutoCoreAPI
}