/**
 * AutoCore ESP32 Relay - Frontend JavaScript
 * Interface moderna para configuração do sistema
 */

class AutoCoreRelay {
    constructor() {
        this.statusUpdateInterval = null;
        this.scanning = false;
        this.testing = false;
        this.saving = false;

        // Bind methods
        this.init = this.init.bind(this);
        this.loadStatus = this.loadStatus.bind(this);
        this.scanWiFi = this.scanWiFi.bind(this);
        this.testConnection = this.testConnection.bind(this);
        this.saveConfiguration = this.saveConfiguration.bind(this);
        
        // Initialize when DOM is ready
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', this.init);
        } else {
            this.init();
        }
    }

    init() {
        console.log('AutoCore ESP32 Relay - Inicializando interface...');
        
        // Setup event listeners
        this.setupEventListeners();
        
        // Load initial data
        this.loadStatus();
        this.loadCurrentConfig();
        
        // Start status updates
        this.startStatusUpdates();
        
        // Show success message
        this.showMessage('Interface carregada com sucesso!', 'success');
    }

    setupEventListeners() {
        // Form submission
        const configForm = document.getElementById('config-form');
        if (configForm) {
            configForm.addEventListener('submit', (e) => {
                e.preventDefault();
                this.saveConfiguration();
            });
        }

        // WiFi scan button
        const scanBtn = document.getElementById('scan-btn');
        if (scanBtn) {
            scanBtn.addEventListener('click', this.scanWiFi);
        }

        // Test connection button
        const testBtn = document.getElementById('test-connection-btn');
        if (testBtn) {
            testBtn.addEventListener('click', this.testConnection);
        }

        // Discover backend button
        const discoverBtn = document.getElementById('discover-backend-btn');
        if (discoverBtn) {
            discoverBtn.addEventListener('click', this.discoverBackend.bind(this));
        }

        // Load current config button
        const loadBtn = document.getElementById('load-current-btn');
        if (loadBtn) {
            loadBtn.addEventListener('click', this.loadCurrentConfig.bind(this));
        }

        // Advanced actions
        const viewLogsBtn = document.getElementById('view-logs-btn');
        if (viewLogsBtn) {
            viewLogsBtn.addEventListener('click', this.viewLogs.bind(this));
        }

        const restartBtn = document.getElementById('restart-btn');
        if (restartBtn) {
            restartBtn.addEventListener('click', () => this.confirmAction('restart'));
        }

        const factoryResetBtn = document.getElementById('factory-reset-btn');
        if (factoryResetBtn) {
            factoryResetBtn.addEventListener('click', () => this.confirmAction('factory-reset'));
        }

        // Modal controls
        this.setupModalControls();
    }

    setupModalControls() {
        // Close modals
        const closeButtons = document.querySelectorAll('.close-modal');
        closeButtons.forEach(btn => {
            btn.addEventListener('click', () => this.closeModal());
        });

        // Click outside to close
        window.addEventListener('click', (e) => {
            if (e.target.classList.contains('modal')) {
                this.closeModal();
            }
        });

        // Logs modal actions
        const refreshLogsBtn = document.getElementById('refresh-logs-btn');
        if (refreshLogsBtn) {
            refreshLogsBtn.addEventListener('click', this.loadLogs.bind(this));
        }

        // Confirmation modal
        const confirmOk = document.getElementById('confirm-ok');
        const confirmCancel = document.getElementById('confirm-cancel');
        
        if (confirmCancel) {
            confirmCancel.addEventListener('click', () => this.closeModal());
        }
        
        if (confirmOk) {
            confirmOk.addEventListener('click', this.executeConfirmedAction.bind(this));
        }
    }

    async loadStatus() {
        try {
            const response = await fetch('/api/status');
            const status = await response.json();

            // Update device info
            this.updateElement('device-uuid', status.uuid);
            this.updateElement('device-name', status.name);
            this.updateElement('wifi-status', status.wifi_connected ? 'Conectado' : 'Desconectado');
            this.updateElement('config-status', status.configured ? 'Configurado' : 'Pendente');
            
            // Update uptime
            const uptime = this.formatUptime(status.uptime);
            this.updateElement('uptime', uptime);

            // Update connection status
            this.updateConnectionStatus(status.wifi_connected);

        } catch (error) {
            console.error('Erro ao carregar status:', error);
            this.showMessage('Erro ao carregar status do dispositivo', 'error');
        }
    }

    async loadCurrentConfig() {
        try {
            const response = await fetch('/api/config');
            const config = await response.json();

            // Populate form fields
            this.updateElement('wifi-ssid', config.wifi_ssid, 'value');
            this.updateElement('backend-ip', config.backend_ip, 'value');
            this.updateElement('backend-port', config.backend_port, 'value');
            this.updateElement('mqtt-broker', config.mqtt_broker, 'value');
            this.updateElement('mqtt-port', config.mqtt_port, 'value');
            this.updateElement('mqtt-user', config.mqtt_user, 'value');

            console.log('Configuração atual carregada');

        } catch (error) {
            console.error('Erro ao carregar configuração atual:', error);
            this.showMessage('Erro ao carregar configuração atual', 'warning');
        }
    }

    async scanWiFi() {
        if (this.scanning) return;

        this.scanning = true;
        const scanBtn = document.getElementById('scan-btn');
        const wifiSelect = document.getElementById('wifi-ssid');
        
        // Update UI
        scanBtn.textContent = 'Escaneando...';
        scanBtn.disabled = true;
        
        try {
            const response = await fetch('/api/wifi/scan');
            const data = await response.json();

            // Clear existing options
            wifiSelect.innerHTML = '<option value="">Selecione uma rede...</option>';

            if (data.networks && data.networks.length > 0) {
                data.networks.forEach(network => {
                    const option = document.createElement('option');
                    option.value = network.ssid;
                    option.textContent = `${network.ssid} (${network.rssi}dBm) ${network.security}`;
                    wifiSelect.appendChild(option);
                });

                this.showMessage(`${data.networks.length} redes WiFi encontradas`, 'success');
            } else {
                this.showMessage('Nenhuma rede WiFi encontrada', 'warning');
            }

        } catch (error) {
            console.error('Erro no scan WiFi:', error);
            this.showMessage('Erro ao escanear redes WiFi', 'error');
        } finally {
            this.scanning = false;
            scanBtn.textContent = 'Escanear';
            scanBtn.disabled = false;
        }
    }

    async testConnection() {
        if (this.testing) return;

        const ip = document.getElementById('backend-ip').value;
        const port = document.getElementById('backend-port').value;

        if (!ip || !port) {
            this.showMessage('Informe o IP e porta do servidor', 'warning');
            return;
        }

        this.testing = true;
        const testBtn = document.getElementById('test-connection-btn');
        
        // Update UI
        testBtn.innerHTML = '<div class="loading-spinner"></div> Testando...';
        testBtn.disabled = true;

        try {
            const formData = new FormData();
            formData.append('ip', ip);
            formData.append('port', port);

            const response = await fetch('/api/test', {
                method: 'POST',
                body: formData
            });

            const result = await response.json();

            if (result.success) {
                this.showMessage(`Conexão bem-sucedida com ${ip}:${port}`, 'success');
            } else {
                this.showMessage(`Falha na conexão com ${ip}:${port}`, 'error');
            }

        } catch (error) {
            console.error('Erro no teste de conexão:', error);
            this.showMessage('Erro ao testar conexão', 'error');
        } finally {
            this.testing = false;
            testBtn.innerHTML = 'Testar Conexão';
            testBtn.disabled = false;
        }
    }

    async discoverBackend() {
        this.showMessage('Descoberta automática não implementada ainda', 'info');
        // TODO: Implementar descoberta automática do backend
    }

    async saveConfiguration() {
        if (this.saving) return;

        // Validate form
        const form = document.getElementById('config-form');
        if (!form.checkValidity()) {
            form.reportValidity();
            return;
        }

        this.saving = true;
        const saveBtn = document.getElementById('save-btn');
        const saveBtnText = document.getElementById('save-btn-text');
        const saveBtnLoading = document.getElementById('save-btn-loading');

        // Update UI
        saveBtnText.style.display = 'none';
        saveBtnLoading.style.display = 'block';
        saveBtn.disabled = true;

        try {
            // Collect form data
            const config = {
                wifi_ssid: document.getElementById('wifi-ssid').value,
                wifi_password: document.getElementById('wifi-password').value,
                backend_ip: document.getElementById('backend-ip').value,
                backend_port: parseInt(document.getElementById('backend-port').value),
                mqtt_broker: document.getElementById('mqtt-broker').value || '',
                mqtt_port: parseInt(document.getElementById('mqtt-port').value) || 1883,
                mqtt_user: document.getElementById('mqtt-user').value || '',
                mqtt_password: document.getElementById('mqtt-password').value || ''
            };

            const formData = new FormData();
            formData.append('config', JSON.stringify(config));

            const response = await fetch('/api/config', {
                method: 'POST',
                body: formData
            });

            const result = await response.json();

            if (result.success) {
                this.showMessage('Configuração salva com sucesso! Reiniciando...', 'success');
                
                // Device will restart, so stop status updates
                this.stopStatusUpdates();
                
                // Show countdown
                this.showRestartCountdown();
                
            } else {
                this.showMessage(`Erro ao salvar: ${result.error}`, 'error');
            }

        } catch (error) {
            console.error('Erro ao salvar configuração:', error);
            this.showMessage('Erro ao salvar configuração', 'error');
        } finally {
            this.saving = false;
            saveBtnText.style.display = 'block';
            saveBtnLoading.style.display = 'none';
            saveBtn.disabled = false;
        }
    }

    async viewLogs() {
        const modal = document.getElementById('logs-modal');
        const logsContainer = document.getElementById('logs-container');
        
        modal.classList.add('show');
        logsContainer.textContent = 'Carregando logs...';
        
        await this.loadLogs();
    }

    async loadLogs() {
        try {
            const response = await fetch('/api/logs');
            const data = await response.json();
            
            const logsContainer = document.getElementById('logs-container');
            
            if (data.logs && data.logs.length > 0) {
                logsContainer.textContent = data.logs.join('\n');
                logsContainer.scrollTop = logsContainer.scrollHeight;
            } else {
                logsContainer.textContent = 'Nenhum log disponível';
            }
            
        } catch (error) {
            console.error('Erro ao carregar logs:', error);
            const logsContainer = document.getElementById('logs-container');
            logsContainer.textContent = 'Erro ao carregar logs';
        }
    }

    confirmAction(action) {
        const modal = document.getElementById('confirm-modal');
        const title = document.getElementById('confirm-title');
        const message = document.getElementById('confirm-message');
        
        let titleText, messageText;
        
        switch (action) {
            case 'restart':
                titleText = 'Reiniciar Dispositivo';
                messageText = 'Tem certeza que deseja reiniciar o dispositivo? Isso pode levar alguns segundos.';
                break;
            case 'factory-reset':
                titleText = 'Factory Reset';
                messageText = 'ATENÇÃO: Isso irá apagar TODAS as configurações e reiniciar o dispositivo. Esta ação não pode ser desfeita!';
                break;
            default:
                return;
        }
        
        title.textContent = titleText;
        message.textContent = messageText;
        modal.classList.add('show');
        
        // Store action for later execution
        this.pendingAction = action;
    }

    async executeConfirmedAction() {
        const action = this.pendingAction;
        this.closeModal();
        
        if (action === 'restart') {
            await this.restartDevice();
        } else if (action === 'factory-reset') {
            await this.factoryReset();
        }
    }

    async restartDevice() {
        try {
            this.showMessage('Reiniciando dispositivo...', 'info');
            this.stopStatusUpdates();
            
            await fetch('/api/restart', { method: 'POST' });
            
            this.showRestartCountdown();
            
        } catch (error) {
            console.error('Erro ao reiniciar:', error);
            this.showMessage('Erro ao reiniciar dispositivo', 'error');
        }
    }

    async factoryReset() {
        try {
            this.showMessage('Executando factory reset...', 'warning');
            this.stopStatusUpdates();
            
            await fetch('/api/factory-reset', { method: 'POST' });
            
            this.showMessage('Factory reset concluído, reiniciando...', 'success');
            this.showRestartCountdown();
            
        } catch (error) {
            console.error('Erro no factory reset:', error);
            this.showMessage('Erro ao executar factory reset', 'error');
        }
    }

    showRestartCountdown() {
        let seconds = 10;
        const interval = setInterval(() => {
            this.updateConnectionStatus(false, `Reiniciando em ${seconds}s...`);
            seconds--;
            
            if (seconds < 0) {
                clearInterval(interval);
                this.updateConnectionStatus(false, 'Reconectando...');
                
                // Try to reconnect after restart
                setTimeout(() => {
                    this.startStatusUpdates();
                    window.location.reload();
                }, 5000);
            }
        }, 1000);
    }

    closeModal() {
        const modals = document.querySelectorAll('.modal');
        modals.forEach(modal => {
            modal.classList.remove('show');
        });
        this.pendingAction = null;
    }

    startStatusUpdates() {
        if (this.statusUpdateInterval) {
            clearInterval(this.statusUpdateInterval);
        }
        
        this.statusUpdateInterval = setInterval(() => {
            this.loadStatus();
        }, 5000); // Update every 5 seconds
    }

    stopStatusUpdates() {
        if (this.statusUpdateInterval) {
            clearInterval(this.statusUpdateInterval);
            this.statusUpdateInterval = null;
        }
    }

    updateConnectionStatus(connected, customText = null) {
        const statusElement = document.getElementById('connection-status');
        const statusDot = document.querySelector('.status-dot');
        
        if (customText) {
            statusElement.textContent = customText;
            statusDot.className = 'status-dot connecting';
        } else if (connected) {
            statusElement.textContent = 'Online';
            statusDot.className = 'status-dot online';
        } else {
            statusElement.textContent = 'Offline';
            statusDot.className = 'status-dot offline';
        }
    }

    updateElement(id, value, attribute = 'textContent') {
        const element = document.getElementById(id);
        if (element && value !== undefined) {
            element[attribute] = value;
        }
    }

    formatUptime(seconds) {
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        const secs = seconds % 60;
        
        if (hours > 0) {
            return `${hours}h ${minutes}m ${secs}s`;
        } else if (minutes > 0) {
            return `${minutes}m ${secs}s`;
        } else {
            return `${secs}s`;
        }
    }

    showMessage(text, type = 'info', duration = 5000) {
        const container = document.getElementById('status-messages');
        
        const message = document.createElement('div');
        message.className = `message ${type}`;
        message.innerHTML = `
            ${text}
            <button class="close">&times;</button>
        `;
        
        container.appendChild(message);
        
        // Auto remove after duration
        setTimeout(() => {
            if (message.parentNode) {
                message.parentNode.removeChild(message);
            }
        }, duration);
        
        // Manual close
        const closeBtn = message.querySelector('.close');
        closeBtn.addEventListener('click', () => {
            if (message.parentNode) {
                message.parentNode.removeChild(message);
            }
        });
        
        console.log(`[${type.toUpperCase()}] ${text}`);
    }
}

// Initialize the application
new AutoCoreRelay();