// AutoCore Config App - Main Application
// Alpine.js components and stores

// Main App Data
document.addEventListener('alpine:init', () => {
    Alpine.data('app', () => ({
        // Loading state
        loading: true,
        
        // Theme management
        isDark: false,
        
        // Navigation state
        currentPage: 'dashboard',
        mobileMenuOpen: false,
        
        // Data refresh
        refreshing: false,
        
        // Navigation items
        navigation: [
            {
                id: 'dashboard',
                name: 'Dashboard',
                icon: 'gauge',
                title: 'Dashboard',
                description: 'Visão geral do sistema'
            },
            {
                id: 'devices',
                name: 'Dispositivos',
                icon: 'cpu',
                title: 'Dispositivos',
                description: 'Gerenciar dispositivos ESP32',
                badge: null
            },
            {
                id: 'relays',
                name: 'Relés',
                icon: 'toggle-left',
                title: 'Configuração de Relés',
                description: 'Configurar canais e placas de relé'
            },
            {
                id: 'screens',
                name: 'Telas',
                icon: 'monitor',
                title: 'Editor de Telas',
                description: 'Configurar layouts visuais'
            },
            {
                id: 'can',
                name: 'CAN Bus',
                icon: 'radio',
                title: 'Sinais CAN',
                description: 'Configurar telemetria CAN'
            },
            {
                id: 'themes',
                name: 'Temas',
                icon: 'palette',
                title: 'Temas e Aparência',
                description: 'Personalizar visual'
            },
            {
                id: 'settings',
                name: 'Configurações',
                icon: 'settings',
                title: 'Configurações',
                description: 'Configurações do sistema'
            }
        ],
        
        // System status
        status: {
            devicesOnline: 0,
            lastUpdate: '',
            systemHealth: 'online'
        },
        
        // Dashboard stats
        stats: [
            {
                title: 'Dispositivos Online',
                value: '0',
                icon: 'cpu',
                description: 'Conectados'
            },
            {
                title: 'Relés Ativos',
                value: '0',
                icon: 'toggle-left',
                description: 'Ligados'
            },
            {
                title: 'Telas Configuradas',
                value: '0',
                icon: 'monitor',
                description: 'Ativas'
            },
            {
                title: 'Telemetria CAN',
                value: '0',
                icon: 'radio',
                description: 'Sinais/min'
            }
        ],

        // Initialization
        async init() {
            console.log('🚀 AutoCore Config App iniciando...');
            
            // Initialize theme
            this.initTheme();
            
            // Initialize Lucide icons
            this.initIcons();
            
            // Load initial data
            await this.loadInitialData();
            
            // Start periodic updates
            this.startPeriodicUpdates();
            
            // App ready
            this.loading = false;
            
            console.log('✅ AutoCore Config App carregado');
        },

        // Theme management
        initTheme() {
            const savedTheme = localStorage.getItem('theme');
            const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
            
            this.isDark = savedTheme === 'dark' || (!savedTheme && prefersDark);
            this.applyTheme();
        },

        toggleTheme() {
            this.isDark = !this.isDark;
            this.applyTheme();
            localStorage.setItem('theme', this.isDark ? 'dark' : 'light');
        },

        applyTheme() {
            if (this.isDark) {
                document.documentElement.classList.add('dark');
            } else {
                document.documentElement.classList.remove('dark');
            }
        },

        // Navigation
        setCurrentPage(pageId) {
            this.currentPage = pageId;
            
            // Update browser history
            history.pushState({ page: pageId }, '', `#${pageId}`);
            
            // Update page title
            const page = this.navigation.find(p => p.id === pageId);
            if (page) {
                document.title = `${page.title} - AutoCore Config`;
            }
        },

        get currentPageTitle() {
            const page = this.navigation.find(p => p.id === this.currentPage);
            return page ? page.title : 'Dashboard';
        },

        get currentPageDescription() {
            const page = this.navigation.find(p => p.id === this.currentPage);
            return page ? page.description : '';
        },

        // Data loading
        async loadInitialData() {
            try {
                await Promise.all([
                    this.loadSystemStatus(),
                    this.loadDevices(),
                    this.loadRelays(),
                    this.loadScreens()
                ]);
                
                this.updateStats();
                
            } catch (error) {
                console.error('Erro carregando dados:', error);
                this.showToast('Erro ao carregar dados do sistema', 'error');
            }
        },

        async loadSystemStatus() {
            try {
                const response = await api.get('/status');
                this.status = {
                    devicesOnline: response.devices_online || 0,
                    lastUpdate: new Date().toLocaleTimeString(),
                    systemHealth: response.status || 'offline'
                };
            } catch (error) {
                console.error('Erro carregando status:', error);
            }
        },

        async loadDevices() {
            try {
                const devices = await api.get('/devices');
                
                // Update navigation badge
                const devicesNav = this.navigation.find(n => n.id === 'devices');
                if (devicesNav) {
                    devicesNav.badge = devices.length > 0 ? devices.length : null;
                }
                
                // Store for other components
                Alpine.store('devices', devices);
                
            } catch (error) {
                console.error('Erro carregando dispositivos:', error);
            }
        },

        async loadRelays() {
            try {
                const channels = await api.get('/relays/channels');
                Alpine.store('relayChannels', channels);
                
            } catch (error) {
                console.error('Erro carregando relés:', error);
            }
        },

        async loadScreens() {
            try {
                const screens = await api.get('/screens');
                Alpine.store('screens', screens);
                
            } catch (error) {
                console.error('Erro carregando telas:', error);
            }
        },

        updateStats() {
            const devices = Alpine.store('devices') || [];
            const channels = Alpine.store('relayChannels') || [];
            const screens = Alpine.store('screens') || [];

            // Update stats values
            this.stats[0].value = devices.filter(d => d.status === 'online').length.toString();
            this.stats[1].value = channels.filter(c => c.current_state === true).length.toString();
            this.stats[2].value = screens.filter(s => s.is_visible === true).length.toString();
            this.stats[3].value = '0'; // CAN telemetry - to be implemented
            
            this.status.devicesOnline = devices.filter(d => d.status === 'online').length;
        },

        // Periodic updates
        startPeriodicUpdates() {
            // Update every 30 seconds
            setInterval(async () => {
                if (!this.refreshing) {
                    await this.loadSystemStatus();
                }
            }, 30000);
            
            // Update stats every 10 seconds
            setInterval(() => {
                this.updateStats();
                this.status.lastUpdate = new Date().toLocaleTimeString();
            }, 10000);
        },

        // Manual refresh
        async refreshData() {
            if (this.refreshing) return;
            
            this.refreshing = true;
            
            try {
                await this.loadInitialData();
                this.showToast('Dados atualizados com sucesso', 'success');
                
            } catch (error) {
                console.error('Erro atualizando dados:', error);
                this.showToast('Erro ao atualizar dados', 'error');
                
            } finally {
                this.refreshing = false;
            }
        },

        // Icons initialization
        initIcons() {
            // Wait a bit for DOM to be ready
            setTimeout(() => {
                if (window.lucide) {
                    lucide.createIcons();
                }
            }, 100);
        },

        // Toast notifications
        showToast(message, type = 'info') {
            // Create toast element
            const toast = document.createElement('div');
            toast.className = `fixed top-4 right-4 z-50 toast toast-${type} px-4 py-2 rounded-lg shadow-lg transform transition-all duration-300 translate-x-full`;
            toast.textContent = message;
            
            document.body.appendChild(toast);
            
            // Animate in
            setTimeout(() => {
                toast.classList.remove('translate-x-full');
            }, 10);
            
            // Remove after 3 seconds
            setTimeout(() => {
                toast.classList.add('translate-x-full');
                setTimeout(() => {
                    document.body.removeChild(toast);
                }, 300);
            }, 3000);
        }
    }));

    // Global stores
    Alpine.store('devices', []);
    Alpine.store('relayChannels', []);
    Alpine.store('screens', []);
    Alpine.store('themes', []);
});

// Handle browser back/forward
window.addEventListener('popstate', (event) => {
    if (event.state && event.state.page) {
        Alpine.store('app').setCurrentPage(event.state.page);
    }
});

// Handle initial hash
window.addEventListener('load', () => {
    const hash = window.location.hash.substring(1);
    if (hash) {
        const app = document.querySelector('[x-data="app"]').__x_scope;
        if (app && app.setCurrentPage) {
            app.setCurrentPage(hash);
        }
    }
});