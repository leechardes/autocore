// AutoCore Config App - API Client
// Handles all communication with FastAPI backend

class AutoCoreAPI {
    constructor(baseURL = 'http://localhost:8000/api') {
        this.baseURL = baseURL;
        this.timeout = 10000; // 10 seconds
    }

    // Generic request method
    async request(endpoint, options = {}) {
        const url = `${this.baseURL}${endpoint}`;
        
        const config = {
            timeout: this.timeout,
            headers: {
                'Content-Type': 'application/json',
                ...options.headers
            },
            ...options
        };

        try {
            console.log(`🌐 API Request: ${config.method || 'GET'} ${url}`);
            
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), this.timeout);
            
            const response = await fetch(url, {
                ...config,
                signal: controller.signal
            });
            
            clearTimeout(timeoutId);
            
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            
            const data = await response.json();
            console.log(`✅ API Response: ${url}`, data);
            
            return data;
            
        } catch (error) {
            console.error(`❌ API Error: ${url}`, error);
            
            if (error.name === 'AbortError') {
                throw new Error('Request timeout - verifique a conexão com o servidor');
            }
            
            if (error.message.includes('Failed to fetch')) {
                throw new Error('Servidor indisponível - verifique se a API está rodando');
            }
            
            throw error;
        }
    }

    // HTTP Methods
    async get(endpoint, params = {}) {
        const queryString = new URLSearchParams(params).toString();
        const url = queryString ? `${endpoint}?${queryString}` : endpoint;
        
        return this.request(url, {
            method: 'GET'
        });
    }

    async post(endpoint, data = {}) {
        return this.request(endpoint, {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async patch(endpoint, data = {}) {
        return this.request(endpoint, {
            method: 'PATCH',
            body: JSON.stringify(data)
        });
    }

    async put(endpoint, data = {}) {
        return this.request(endpoint, {
            method: 'PUT',
            body: JSON.stringify(data)
        });
    }

    async delete(endpoint) {
        return this.request(endpoint, {
            method: 'DELETE'
        });
    }

    // System endpoints
    async getStatus() {
        return this.get('/status');
    }

    async getHealth() {
        return this.get('/');
    }

    // Device endpoints
    async getDevices() {
        return this.get('/devices');
    }

    async getDevice(id) {
        return this.get(`/devices/${id}`);
    }

    async createDevice(deviceData) {
        return this.post('/devices', deviceData);
    }

    async updateDevice(id, deviceData) {
        return this.patch(`/devices/${id}`, deviceData);
    }

    async deleteDevice(id) {
        return this.delete(`/devices/${id}`);
    }

    // Relay endpoints
    async getRelayBoards() {
        return this.get('/relays/boards');
    }

    async getRelayChannels(boardId = null) {
        const params = boardId ? { board_id: boardId } : {};
        return this.get('/relays/channels', params);
    }

    async toggleRelay(channelId) {
        return this.post(`/relays/channels/${channelId}/toggle`);
    }

    async setRelayState(channelId, state) {
        return this.patch(`/relays/channels/${channelId}/state`, { state });
    }

    async updateRelayChannel(channelId, channelData) {
        return this.patch(`/relays/channels/${channelId}`, channelData);
    }

    // Screen endpoints
    async getScreens() {
        return this.get('/screens');
    }

    async getScreen(id) {
        return this.get(`/screens/${id}`);
    }

    async createScreen(screenData) {
        return this.post('/screens', screenData);
    }

    async updateScreen(id, screenData) {
        return this.patch(`/screens/${id}`, screenData);
    }

    async deleteScreen(id) {
        return this.delete(`/screens/${id}`);
    }

    async getScreenItems(screenId) {
        return this.get(`/screens/${screenId}/items`);
    }

    async createScreenItem(screenId, itemData) {
        return this.post(`/screens/${screenId}/items`, itemData);
    }

    async updateScreenItem(screenId, itemId, itemData) {
        return this.patch(`/screens/${screenId}/items/${itemId}`, itemData);
    }

    async deleteScreenItem(screenId, itemId) {
        return this.delete(`/screens/${screenId}/items/${itemId}`);
    }

    // Theme endpoints
    async getThemes() {
        return this.get('/themes');
    }

    async getDefaultTheme() {
        return this.get('/themes/default');
    }

    async createTheme(themeData) {
        return this.post('/themes', themeData);
    }

    async updateTheme(id, themeData) {
        return this.patch(`/themes/${id}`, themeData);
    }

    // Config generation
    async generateDeviceConfig(deviceUuid) {
        return this.get(`/config/generate/${deviceUuid}`);
    }

    // Telemetry endpoints (future)
    async getTelemetry(deviceId, limit = 100) {
        return this.get(`/telemetry/${deviceId}`, { limit });
    }

    async getLatestTelemetry(deviceId) {
        return this.get(`/telemetry/${deviceId}/latest`);
    }

    // Batch operations
    async batchUpdateRelays(updates) {
        return this.post('/relays/batch-update', { updates });
    }

    async batchToggleRelays(channelIds) {
        return this.post('/relays/batch-toggle', { channel_ids: channelIds });
    }

    // File operations
    async exportConfig(format = 'json') {
        return this.get(`/export/config`, { format });
    }

    async importConfig(configData) {
        return this.post('/import/config', configData);
    }

    // Utility methods
    isOnline() {
        return navigator.onLine;
    }

    async testConnection() {
        try {
            await this.getHealth();
            return true;
        } catch {
            return false;
        }
    }

    // Error handling utilities
    getErrorMessage(error) {
        if (error.message) {
            return error.message;
        }
        
        if (typeof error === 'string') {
            return error;
        }
        
        return 'Erro desconhecido na API';
    }

    // Request retry logic
    async retryRequest(requestFn, maxRetries = 3, delay = 1000) {
        let lastError;
        
        for (let attempt = 1; attempt <= maxRetries; attempt++) {
            try {
                return await requestFn();
            } catch (error) {
                lastError = error;
                
                if (attempt === maxRetries) {
                    break;
                }
                
                console.warn(`Tentativa ${attempt} falhou, tentando novamente em ${delay}ms...`);
                await new Promise(resolve => setTimeout(resolve, delay));
                
                // Exponential backoff
                delay *= 2;
            }
        }
        
        throw lastError;
    }

    // Environment detection
    get baseURL() {
        // Auto-detect API URL based on environment
        if (typeof window !== 'undefined') {
            const hostname = window.location.hostname;
            
            if (hostname === 'localhost' || hostname === '127.0.0.1') {
                return 'http://localhost:8000/api';
            } else {
                // Production - same host different port or nginx proxy
                return `http://${hostname}:8000/api`;
            }
        }
        
        return this._baseURL || 'http://localhost:8000/api';
    }

    set baseURL(url) {
        this._baseURL = url;
    }
}

// Create global API instance
const api = new AutoCoreAPI();

// Export for module systems if needed
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { AutoCoreAPI, api };
}

// Make available globally
window.api = api;
window.AutoCoreAPI = AutoCoreAPI;

// Connection monitoring
window.addEventListener('online', () => {
    console.log('🌐 Conexão restaurada');
    document.dispatchEvent(new CustomEvent('api:online'));
});

window.addEventListener('offline', () => {
    console.log('📴 Conexão perdida');
    document.dispatchEvent(new CustomEvent('api:offline'));
});

// API ready event
document.addEventListener('DOMContentLoaded', () => {
    console.log('🔌 API Client inicializado');
    document.dispatchEvent(new CustomEvent('api:ready'));
});