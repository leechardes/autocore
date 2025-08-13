// ESP32 Relay Control Web Interface
// AutoCore System v2.0

const API_BASE = '';
let deviceInfo = {};
let relayStates = {};
let updateInterval = null;

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    console.log('ESP32 Relay Web Interface loaded');
    
    // Setup event listeners
    document.getElementById('refresh-btn').addEventListener('click', refreshAll);
    document.getElementById('all-on-btn').addEventListener('click', () => setAllRelays(true));
    document.getElementById('all-off-btn').addEventListener('click', () => setAllRelays(false));
    
    // Initial load
    refreshAll();
    
    // Auto-refresh every 5 seconds
    updateInterval = setInterval(updateStatus, 5000);
});

// Fetch device information
async function fetchDeviceInfo() {
    try {
        const response = await fetch(`${API_BASE}/api/info`);
        if (response.ok) {
            deviceInfo = await response.json();
            updateDeviceInfoUI();
        }
    } catch (error) {
        console.error('Error fetching device info:', error);
        updateConnectionStatus(false);
    }
}

// Fetch relay states
async function fetchRelayStates() {
    try {
        const response = await fetch(`${API_BASE}/api/relays`);
        if (response.ok) {
            const data = await response.json();
            relayStates = data.relays || {};
            updateRelayUI();
            updateConnectionStatus(true);
        }
    } catch (error) {
        console.error('Error fetching relay states:', error);
        updateConnectionStatus(false);
    }
}

// Update device information in UI
function updateDeviceInfoUI() {
    document.getElementById('device-id').textContent = deviceInfo.device_id || '-';
    document.getElementById('device-ip').textContent = deviceInfo.ip || '-';
    document.getElementById('uptime').textContent = formatUptime(deviceInfo.uptime || 0);
    document.getElementById('mqtt-status').textContent = deviceInfo.mqtt_connected ? 'Conectado' : 'Desconectado';
}

// Update relay UI
function updateRelayUI() {
    const relayGrid = document.getElementById('relay-grid');
    
    // Clear existing relays
    relayGrid.innerHTML = '';
    
    // Create relay cards
    for (let i = 1; i <= 8; i++) {
        const relayCard = createRelayCard(i, relayStates[i] || false);
        relayGrid.appendChild(relayCard);
    }
}

// Create relay card element
function createRelayCard(id, state) {
    const card = document.createElement('div');
    card.className = `relay-card ${state ? 'active' : ''}`;
    card.dataset.relayId = id;
    
    card.innerHTML = `
        <h3>Relé ${id}</h3>
        <div class="relay-status">${state ? 'LIGADO' : 'DESLIGADO'}</div>
    `;
    
    card.addEventListener('click', () => toggleRelay(id));
    
    return card;
}

// Toggle single relay
async function toggleRelay(id) {
    const currentState = relayStates[id] || false;
    const newState = !currentState;
    
    try {
        const response = await fetch(`${API_BASE}/api/relay/${id}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ state: newState ? 1 : 0 })
        });
        
        if (response.ok) {
            relayStates[id] = newState;
            updateRelayUI();
        }
    } catch (error) {
        console.error(`Error toggling relay ${id}:`, error);
    }
}

// Set all relays to same state
async function setAllRelays(state) {
    try {
        const response = await fetch(`${API_BASE}/api/relays/all`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ state: state ? 1 : 0 })
        });
        
        if (response.ok) {
            // Update all relay states
            for (let i = 1; i <= 8; i++) {
                relayStates[i] = state;
            }
            updateRelayUI();
        }
    } catch (error) {
        console.error('Error setting all relays:', error);
    }
}

// Update connection status indicator
function updateConnectionStatus(connected) {
    const indicator = document.getElementById('connection-status');
    const statusText = document.getElementById('status-text');
    
    if (connected) {
        indicator.classList.add('connected');
        statusText.textContent = 'Conectado';
    } else {
        indicator.classList.remove('connected');
        statusText.textContent = 'Desconectado';
    }
}

// Format uptime in seconds to readable format
function formatUptime(seconds) {
    const days = Math.floor(seconds / 86400);
    const hours = Math.floor((seconds % 86400) / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    
    if (days > 0) {
        return `${days}d ${hours}h ${minutes}m`;
    } else if (hours > 0) {
        return `${hours}h ${minutes}m`;
    } else {
        return `${minutes}m`;
    }
}

// Refresh all data
async function refreshAll() {
    await fetchDeviceInfo();
    await fetchRelayStates();
}

// Update only status (lighter request)
async function updateStatus() {
    await fetchRelayStates();
}

// Cleanup on page unload
window.addEventListener('beforeunload', () => {
    if (updateInterval) {
        clearInterval(updateInterval);
    }
});