/**
 * AutoCore Display - Interface JavaScript
 * Sistema de configuração moderno e responsivo
 */

class AutoCoreConfigUI {
    constructor() {
        this.deviceUUID = '';
        this.currentConfig = {};
        this.statusUpdateInterval = null;
        this.isLoading = false;
        
        // Bind methods
        this.init = this.init.bind(this);
        this.loadStatus = this.loadStatus.bind(this);
        this.loadConfiguration = this.loadConfiguration.bind(this);
        this.saveConfiguration = this.saveConfiguration.bind(this);
        this.scanNetworks = this.scanNetworks.bind(this);
    }

    // Inicialização
    async init() {
        console.log('🚀 Inicializando interface AutoCore Display');
        
        try {
            await this.loadStatus();
            await this.loadConfiguration();
            await this.scanNetworks();
            
            // Configurar updates automáticos de status
            this.startStatusUpdates();
            
            // Configurar event listeners
            this.setupEventListeners();
            
            this.hideLoading();
            this.showStatus('✅ Interface carregada com sucesso', 'success');
            
        } catch (error) {
            console.error('❌ Erro na inicialização:', error);
            this.hideLoading();
            this.showStatus('❌ Erro ao carregar interface: ' + error.message, 'error');
        }
    }

    // Status do sistema
    async loadStatus() {
        console.log('📊 Carregando status do sistema');
        
        try {
            const response = await fetch('/api/status');
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            
            const data = await response.json();
            console.log('Status recebido:', data);
            
            // Atualizar UUID
            this.deviceUUID = data.device_uuid || 'N/A';
            this.updateElement('deviceUUID', this.deviceUUID);
            this.updateElement('deviceUUIDBrief', this.deviceUUID);
            
            // Atualizar status geral
            this.updateElement('systemStatus', data.configured ? '✅ Configurado' : '⚙️ Configuração necessária');
            
            // Atualizar status detalhado na aba Status
            this.updateStatusTab(data);
            
        } catch (error) {
            console.error('❌ Erro ao carregar status:', error);
            throw error;
        }
    }

    // Configuração
    async loadConfiguration() {
        console.log('⚙️ Carregando configuração');
        
        try {
            const response = await fetch('/api/config');
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            
            const data = await response.json();
            console.log('Configuração recebida:', data);
            
            this.currentConfig = data;
            this.populateForm(data);
            
        } catch (error) {
            console.error('❌ Erro ao carregar configuração:', error);
            // Continuar com configuração vazia em caso de erro
            this.populateForm({});
        }
    }

    // Salvar configuração
    async saveConfiguration() {
        if (this.isLoading) return;
        
        console.log('💾 Salvando configuração');
        this.setLoading(true);
        
        try {
            // Validar formulário
            if (!this.validateForm()) {
                throw new Error('Por favor, preencha todos os campos obrigatórios');
            }
            
            // Coletar dados do formulário
            const config = this.collectFormData();
            console.log('Dados a serem salvos:', config);
            
            // Enviar para o servidor
            const response = await fetch('/api/config', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(config)
            });
            
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.error || `HTTP ${response.status}`);
            }
            
            const result = await response.json();
            console.log('Configuração salva:', result);
            
            this.showStatus('✅ Configuração salva com sucesso! Reiniciando dispositivo...', 'success');
            
            // Aguardar um pouco e reiniciar o dispositivo
            setTimeout(async () => {
                try {
                    await fetch('/api/restart', { method: 'POST' });
                } catch (e) {
                    // Erro esperado - dispositivo vai reiniciar
                    console.log('🔄 Dispositivo reiniciando...');
                }
                
                // Mostrar mensagem de reinicialização
                this.showStatus('🔄 Dispositivo reiniciando... Aguarde 30 segundos e recarregue a página.', 'info');
            }, 2000);
            
        } catch (error) {
            console.error('❌ Erro ao salvar:', error);
            this.showStatus('❌ Erro ao salvar: ' + error.message, 'error');
        } finally {
            this.setLoading(false);
        }
    }

    // Scan de redes WiFi
    async scanNetworks() {
        console.log('📶 Escaneando redes WiFi');
        
        const select = document.getElementById('wifiNetwork');
        const originalHTML = select.innerHTML;
        
        try {
            // Mostrar loading
            select.innerHTML = '<option value="">🔄 Escaneando...</option>';
            
            const response = await fetch('/api/networks');
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            
            const data = await response.json();
            console.log(`📡 ${data.count} redes encontradas`);
            
            // Limpar select
            select.innerHTML = '<option value="">Selecione uma rede</option>';
            
            // Adicionar redes encontradas
            if (data.networks && data.networks.length > 0) {
                data.networks.forEach(network => {
                    const option = document.createElement('option');
                    option.value = network.ssid;
                    option.textContent = `📶 ${network.ssid} (${network.signal}) ${network.security !== 'Aberta' ? '🔒' : '🔓'}`;
                    select.appendChild(option);
                });
            }
            
            // Adicionar opção personalizada
            const customOption = document.createElement('option');
            customOption.value = 'custom';
            customOption.textContent = '✏️ Rede personalizada...';
            select.appendChild(customOption);
            
            // Restaurar seleção se existir configuração
            if (this.currentConfig.wifi && this.currentConfig.wifi.ssid) {
                select.value = this.currentConfig.wifi.ssid;
                if (select.value !== this.currentConfig.wifi.ssid) {
                    // SSID não encontrado no scan, usar modo personalizado
                    select.value = 'custom';
                    document.getElementById('customSSID').value = this.currentConfig.wifi.ssid;
                    this.toggleCustomSSID();
                }
            }
            
        } catch (error) {
            console.error('❌ Erro no scan de redes:', error);
            select.innerHTML = originalHTML;
            this.showStatus('⚠️ Erro ao escanear redes: ' + error.message, 'warning');
        }
    }

    // Testar conexão com backend
    async testBackendConnection() {
        const host = document.getElementById('backendHost').value;
        const port = document.getElementById('backendPort').value;
        
        if (!host || !port) {
            this.showStatus('⚠️ Preencha o host e porta do backend', 'warning');
            return;
        }
        
        const testDiv = document.getElementById('backendTest');
        const testResult = testDiv.querySelector('.test-result');
        const testIcon = testResult.querySelector('.test-icon');
        const testMessage = testResult.querySelector('.test-message');
        
        // Mostrar teste em andamento
        testDiv.style.display = 'block';
        testIcon.textContent = '⏳';
        testMessage.textContent = 'Testando conexão...';
        
        try {
            const response = await fetch('/api/test-connection', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    host: host,
                    port: parseInt(port)
                })
            });
            
            if (response.ok) {
                testIcon.textContent = '✅';
                testMessage.textContent = 'Conexão com backend OK!';
                testResult.style.color = 'var(--secondary)';
            } else {
                throw new Error('Backend não respondeu');
            }
            
        } catch (error) {
            console.error('❌ Erro no teste de conexão:', error);
            testIcon.textContent = '❌';
            testMessage.textContent = 'Falha na conexão: ' + error.message;
            testResult.style.color = 'var(--danger)';
        }
        
        // Ocultar teste após 5 segundos
        setTimeout(() => {
            testDiv.style.display = 'none';
        }, 5000);
    }

    // Reset de fábrica
    async factoryReset() {
        if (!confirm('⚠️ ATENÇÃO: Esta ação irá apagar todas as configurações e reiniciar o dispositivo.\n\nTem certeza que deseja continuar?')) {
            return;
        }
        
        if (!confirm('🚨 ÚLTIMA CHANCE: Todas as configurações serão perdidas permanentemente!\n\nConfirma o reset de fábrica?')) {
            return;
        }
        
        console.log('🔄 Executando reset de fábrica');
        this.showStatus('🔄 Executando reset de fábrica...', 'warning');
        
        try {
            const response = await fetch('/api/factory-reset', { method: 'POST' });
            
            if (response.ok) {
                this.showStatus('✅ Reset executado! Dispositivo reiniciando...', 'success');
                
                setTimeout(() => {
                    this.showStatus('🔄 Dispositivo reiniciado. Recarregue a página em 30 segundos.', 'info');
                }, 2000);
            } else {
                throw new Error('Falha no reset de fábrica');
            }
            
        } catch (error) {
            console.error('❌ Erro no reset:', error);
            this.showStatus('❌ Erro no reset: ' + error.message, 'error');
        }
    }

    // Reiniciar dispositivo
    async restartDevice() {
        if (!confirm('🔄 Reiniciar o dispositivo agora?\n\nTodas as configurações salvas serão mantidas.')) {
            return;
        }
        
        console.log('⚡ Reiniciando dispositivo');
        this.showStatus('⚡ Reiniciando dispositivo...', 'info');
        
        try {
            await fetch('/api/restart', { method: 'POST' });
        } catch (error) {
            // Erro esperado - dispositivo vai reiniciar
            console.log('🔄 Dispositivo reiniciando...');
        }
        
        this.showStatus('🔄 Dispositivo reiniciando... Recarregue a página em 30 segundos.', 'info');
    }

    // Utilitários de formulário
    populateForm(config) {
        console.log('📝 Preenchendo formulário com configuração');
        
        // Básico
        this.updateElement('deviceName', config.device?.name || 'AutoCore Display');
        
        // Rede (será preenchida pelo scan)
        this.updateElement('wifiPassword', ''); // Por segurança, não preencher senha
        
        // Backend
        this.updateElement('backendHost', config.backend?.host || '');
        this.updateElement('backendPort', config.backend?.port || 8000);
        
        // Avançado
        this.updateElement('screenTimeout', config.screen_timeout || 30);
        this.updateElement('brightness', config.brightness || 80);
        this.updateElement('debugMode', config.debug_enabled || false, 'checked');
        this.updateElement('ntpServer', config.ntp_server || 'pool.ntp.org');
        
        // Atualizar valor do slider de brilho
        this.updateBrightnessValue(config.brightness || 80);
    }

    collectFormData() {
        return {
            device: {
                name: document.getElementById('deviceName').value || 'AutoCore Display',
                uuid: this.deviceUUID
            },
            wifi: {
                ssid: document.getElementById('wifiNetwork').value === 'custom' 
                      ? document.getElementById('customSSID').value 
                      : document.getElementById('wifiNetwork').value,
                password: document.getElementById('wifiPassword').value
            },
            backend: {
                host: document.getElementById('backendHost').value,
                port: parseInt(document.getElementById('backendPort').value) || 8000,
                api_key: document.getElementById('apiKey').value
            },
            system: {
                screen_timeout: parseInt(document.getElementById('screenTimeout').value) || 30,
                brightness: parseInt(document.getElementById('brightness').value) || 80,
                debug_enabled: document.getElementById('debugMode').checked,
                ntp_server: document.getElementById('ntpServer').value || 'pool.ntp.org'
            }
        };
    }

    validateForm() {
        const required = [
            { id: 'deviceName', name: 'Nome do dispositivo' },
            { id: 'backendHost', name: 'Host do backend' },
            { id: 'backendPort', name: 'Porta do backend' }
        ];
        
        // Validar WiFi
        const wifiNetwork = document.getElementById('wifiNetwork').value;
        if (!wifiNetwork) {
            this.showStatus('⚠️ Selecione uma rede WiFi', 'warning');
            return false;
        }
        
        if (wifiNetwork === 'custom') {
            const customSSID = document.getElementById('customSSID').value;
            if (!customSSID) {
                this.showStatus('⚠️ Digite o nome da rede personalizada', 'warning');
                return false;
            }
        }
        
        // Validar campos obrigatórios
        for (const field of required) {
            const element = document.getElementById(field.id);
            if (!element.value || element.value.trim() === '') {
                this.showStatus(`⚠️ ${field.name} é obrigatório`, 'warning');
                element.focus();
                return false;
            }
        }
        
        // Validar formato IP
        const hostInput = document.getElementById('backendHost');
        const ipPattern = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
        if (!ipPattern.test(hostInput.value)) {
            this.showStatus('⚠️ Endereço IP inválido', 'warning');
            hostInput.focus();
            return false;
        }
        
        return true;
    }

    // Utilitários de interface
    updateElement(id, value, property = 'value') {
        const element = document.getElementById(id);
        if (element) {
            if (property === 'checked') {
                element.checked = value;
            } else {
                element[property] = value;
            }
        }
    }

    updateStatusTab(data) {
        // Sistema
        this.updateElement('currentState', data.state || 'Desconhecido', 'textContent');
        this.updateElement('uptime', this.formatUptime(data.uptime) || '0s', 'textContent');
        this.updateElement('freeMemory', this.formatBytes(data.free_memory) || '0 B', 'textContent');
        this.updateElement('cpuFreq', (data.cpu_freq || 240) + ' MHz', 'textContent');
        
        // Rede
        this.updateElement('wifiStatus', data.wifi_connected ? '✅ Conectado' : '❌ Desconectado', 'textContent');
        this.updateElement('localIP', data.wifi_ip || 'N/A', 'textContent');
        this.updateElement('signalStrength', data.wifi_signal ? data.wifi_signal + ' dBm' : 'N/A', 'textContent');
        this.updateElement('mqttStatus', data.mqtt_connected ? '✅ Conectado' : '❌ Desconectado', 'textContent');
    }

    // Status updates automáticos
    startStatusUpdates() {
        if (this.statusUpdateInterval) {
            clearInterval(this.statusUpdateInterval);
        }
        
        this.statusUpdateInterval = setInterval(async () => {
            try {
                await this.loadStatus();
            } catch (error) {
                console.warn('⚠️ Erro na atualização automática de status:', error);
            }
        }, 10000); // A cada 10 segundos
    }

    stopStatusUpdates() {
        if (this.statusUpdateInterval) {
            clearInterval(this.statusUpdateInterval);
            this.statusUpdateInterval = null;
        }
    }

    // Interface helpers
    showStatus(message, type = 'info') {
        const statusEl = document.getElementById('statusMessage');
        statusEl.textContent = message;
        statusEl.className = `status-message ${type}`;
        statusEl.style.display = 'block';
        
        // Auto-hide success e info messages após 5 segundos
        if (type === 'success' || type === 'info') {
            setTimeout(() => {
                statusEl.style.display = 'none';
            }, 5000);
        }
        
        console.log(`📢 Status [${type}]: ${message}`);
    }

    hideLoading() {
        const overlay = document.getElementById('loadingOverlay');
        if (overlay) {
            overlay.style.display = 'none';
        }
    }

    setLoading(loading) {
        this.isLoading = loading;
        const saveButton = document.querySelector('.btn-primary');
        if (saveButton) {
            saveButton.disabled = loading;
            saveButton.textContent = loading ? '⏳ Salvando...' : '💾 Salvar Configuração';
        }
    }

    // Event listeners
    setupEventListeners() {
        console.log('🔗 Configurando event listeners');
        
        // Prevent form submission
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' && e.target.tagName !== 'BUTTON') {
                e.preventDefault();
            }
        });
        
        // Auto-save on significant changes (debounced)
        let saveTimeout;
        const autoSaveElements = ['deviceName', 'backendHost', 'backendPort'];
        autoSaveElements.forEach(id => {
            const element = document.getElementById(id);
            if (element) {
                element.addEventListener('input', () => {
                    clearTimeout(saveTimeout);
                    saveTimeout = setTimeout(() => {
                        console.log('💾 Auto-save triggered for', id);
                        // Aqui poderia implementar auto-save se desejado
                    }, 2000);
                });
            }
        });
    }

    // Formatters
    formatUptime(seconds) {
        if (!seconds) return '0s';
        
        const days = Math.floor(seconds / (24 * 3600));
        const hours = Math.floor((seconds % (24 * 3600)) / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        const secs = seconds % 60;
        
        if (days > 0) {
            return `${days}d ${hours}h ${minutes}m`;
        } else if (hours > 0) {
            return `${hours}h ${minutes}m ${secs}s`;
        } else if (minutes > 0) {
            return `${minutes}m ${secs}s`;
        } else {
            return `${secs}s`;
        }
    }

    formatBytes(bytes) {
        if (!bytes) return '0 B';
        
        const sizes = ['B', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(1024));
        return Math.round(bytes / Math.pow(1024, i) * 100) / 100 + ' ' + sizes[i];
    }
}

// Instância global da interface
const ui = new AutoCoreConfigUI();

// Funções globais para eventos HTML
function showTab(tabId) {
    // Ocultar todos os painéis
    document.querySelectorAll('.tab-panel').forEach(panel => {
        panel.classList.remove('active');
    });
    
    // Desativar todos os botões
    document.querySelectorAll('.tab-button').forEach(button => {
        button.classList.remove('active');
    });
    
    // Ativar o painel e botão selecionados
    const panel = document.getElementById(tabId);
    const button = document.querySelector(`[onclick="showTab('${tabId}')"]`);
    
    if (panel) panel.classList.add('active');
    if (button) button.classList.add('active');
}

function toggleCustomSSID() {
    const select = document.getElementById('wifiNetwork');
    const customGroup = document.getElementById('customSSIDGroup');
    
    if (customGroup) {
        customGroup.style.display = select.value === 'custom' ? 'block' : 'none';
    }
}

function togglePassword(inputId) {
    const input = document.getElementById(inputId);
    const button = input.nextElementSibling;
    
    if (input.type === 'password') {
        input.type = 'text';
        button.textContent = '🙈';
    } else {
        input.type = 'password';
        button.textContent = '👁️';
    }
}

function updateBrightnessValue(value) {
    const valueEl = document.getElementById('brightnessValue');
    if (valueEl) {
        valueEl.textContent = value + '%';
    }
}

// Funções de interface (chamadas pelos botões HTML)
function loadConfiguration() {
    ui.loadConfiguration();
}

function saveConfiguration() {
    ui.saveConfiguration();
}

function scanNetworks() {
    ui.scanNetworks();
}

function testBackendConnection() {
    ui.testBackendConnection();
}

function factoryReset() {
    ui.factoryReset();
}

function restartDevice() {
    ui.restartDevice();
}

// Inicializar quando o DOM estiver pronto
document.addEventListener('DOMContentLoaded', () => {
    console.log('🌟 DOM carregado, inicializando interface');
    ui.init();
});

// Cleanup ao sair da página
window.addEventListener('beforeunload', () => {
    ui.stopStatusUpdates();
});