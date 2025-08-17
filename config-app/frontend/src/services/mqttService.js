/**
 * Serviço MQTT com conformidade v2.2.0
 * Publicas mensagens seguindo o padrão correto de tópicos e payloads
 */

const MQTT_PROTOCOL_VERSION = '2.2.0';

class MQTTService {
    constructor() {
        this.heartbeatSequence = 1;
        this.sourceUuid = 'config-app-001';
    }

    /**
     * Publica comando de relé conforme v2.2.0
     */
    publishRelayCommand(deviceId, channel, state, functionType = 'toggle') {
        const topic = `autocore/devices/${deviceId}/relays/set`;
        const payload = {
            protocol_version: MQTT_PROTOCOL_VERSION,
            channel: channel,
            state: state,
            function_type: functionType,
            user: 'config_app',
            timestamp: new Date().toISOString()
        };
        
        return this.publish(topic, payload, { qos: 1 });
    }
    
    /**
     * Publica heartbeat de relé conforme v2.2.0
     */
    publishHeartbeat(deviceId, channel) {
        const topic = `autocore/devices/${deviceId}/relays/heartbeat`;
        const payload = {
            protocol_version: MQTT_PROTOCOL_VERSION,
            channel: channel,
            source_uuid: this.sourceUuid,
            target_uuid: deviceId,
            timestamp: new Date().toISOString(),
            sequence: this.heartbeatSequence++
        };
        
        return this.publish(topic, payload, { qos: 1 });
    }
    
    /**
     * Publica anúncio de dispositivo conforme v2.2.0
     */
    publishDeviceAnnounce(deviceId, deviceInfo) {
        const topic = `autocore/discovery/announce`;
        const payload = {
            protocol_version: MQTT_PROTOCOL_VERSION,
            uuid: deviceId,
            device_type: deviceInfo.device_type || "unknown",
            firmware_version: deviceInfo.firmware_version || "1.0.0",
            capabilities: deviceInfo.capabilities || [],
            ip_address: deviceInfo.ip_address,
            mac_address: deviceInfo.mac_address,
            timestamp: new Date().toISOString()
        };
        
        return this.publish(topic, payload, { qos: 1 });
    }
    
    /**
     * Publica telemetria conforme v2.2.0
     * Nota: UUID vai no payload, não no tópico
     */
    publishTelemetry(type, deviceId, data) {
        const topic = `autocore/telemetry/${type}/data`;
        const payload = {
            protocol_version: MQTT_PROTOCOL_VERSION,
            uuid: deviceId,
            timestamp: new Date().toISOString(),
            ...data
        };
        
        return this.publish(topic, payload, { qos: 0 });
    }
    
    /**
     * Publica comando gateway conforme v2.2.0
     */
    publishGatewayCommand(commandType, commandData) {
        const topic = `autocore/gateway/commands/${commandType}`;
        const payload = {
            protocol_version: MQTT_PROTOCOL_VERSION,
            command: commandType,
            source: this.sourceUuid,
            timestamp: new Date().toISOString(),
            ...commandData
        };
        
        return this.publish(topic, payload, { qos: 1 });
    }
    
    /**
     * Publica erro conforme v2.2.0
     */
    publishError(deviceId, errorType, errorDetails) {
        const topic = `autocore/errors/${deviceId}/${errorType}`;
        const payload = {
            protocol_version: MQTT_PROTOCOL_VERSION,
            uuid: deviceId,
            error_type: errorType,
            error_message: errorDetails.message,
            error_code: errorDetails.code,
            source: this.sourceUuid,
            timestamp: new Date().toISOString(),
            details: errorDetails
        };
        
        return this.publish(topic, payload, { qos: 1 });
    }
    
    /**
     * Método genérico de publicação
     */
    async publish(topic, payload, options = {}) {
        try {
            // Garantir que sempre tenha protocol_version
            if (typeof payload === 'object' && !payload.protocol_version) {
                payload.protocol_version = MQTT_PROTOCOL_VERSION;
            }
            
            // Garantir timestamp
            if (typeof payload === 'object' && !payload.timestamp) {
                payload.timestamp = new Date().toISOString();
            }
            
            const response = await fetch('/api/mqtt/publish', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    topic: topic,
                    payload: payload,
                    qos: options.qos || 1
                })
            });
            
            if (response.ok) {
                const result = await response.json();
                return { success: true, result };
            } else {
                const error = await response.text();
                console.error('❌ Erro ao publicar MQTT:', error);
                return { success: false, error };
            }
        } catch (error) {
            console.error('❌ Erro na requisição MQTT:', error);
            return { success: false, error: error.message };
        }
    }
    
    /**
     * Valida conformidade de mensagem
     */
    async validateMessage(topic, payload) {
        try {
            const response = await fetch('/api/protocol/validate', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    topic: topic,
                    payload: payload
                })
            });
            
            if (response.ok) {
                return await response.json();
            } else {
                throw new Error('Erro ao validar mensagem');
            }
        } catch (error) {
            console.error('❌ Erro ao validar mensagem:', error);
            return {
                valid: false,
                errors: ['Erro de comunicação com servidor'],
                warnings: []
            };
        }
    }
    
    /**
     * Obtém estatísticas de conformidade
     */
    async getProtocolStats() {
        try {
            const response = await fetch('/api/protocol/stats');
            if (response.ok) {
                return await response.json();
            } else {
                throw new Error('Erro ao obter estatísticas');
            }
        } catch (error) {
            console.error('❌ Erro ao obter estatísticas:', error);
            return {
                total_messages: 0,
                v2_2_0_compliant: 0,
                legacy_messages: 0,
                invalid_messages: 0,
                compliance_rate: 0
            };
        }
    }
    
    /**
     * Extrai UUID do payload para telemetria ou do tópico para dispositivos
     */
    extractDeviceUuid(topic, payload) {
        // Para telemetria, UUID vem do payload
        if (topic.startsWith('autocore/telemetry/')) {
            return payload?.uuid || 'unknown';
        }
        
        // Para dispositivos, UUID vem do tópico
        const match = topic.match(/autocore\/devices\/([\w-]+)\//);
        return match ? match[1] : 'unknown';
    }
    
    /**
     * Valida se tópico segue padrão v2.2.0
     */
    isValidTopicStructure(topic) {
        const validPatterns = [
            /^autocore\/devices\/[\w-]+\/(status|relays\/set|relays\/state|relays\/heartbeat)$/,
            /^autocore\/telemetry\/(relays|displays|sensors|can)\/data$/,
            /^autocore\/telemetry\/(sensors|can)\/[\w-]+$/,
            /^autocore\/gateway\/(status|commands\/\w+)$/,
            /^autocore\/discovery\/announce$/,
            /^autocore\/errors\/[\w-]+\/\w+$/
        ];
        
        return validPatterns.some(pattern => pattern.test(topic));
    }
    
    /**
     * Templates para testes
     */
    getTemplates() {
        return {
            relayCommand: {
                topic: 'autocore/devices/esp32-relay-001/relays/set',
                payload: {
                    protocol_version: MQTT_PROTOCOL_VERSION,
                    channel: 1,
                    state: true,
                    function_type: 'toggle',
                    user: 'config_app',
                    timestamp: new Date().toISOString()
                }
            },
            heartbeat: {
                topic: 'autocore/devices/esp32-relay-001/relays/heartbeat',
                payload: {
                    protocol_version: MQTT_PROTOCOL_VERSION,
                    channel: 1,
                    source_uuid: this.sourceUuid,
                    target_uuid: 'esp32-relay-001',
                    timestamp: new Date().toISOString(),
                    sequence: this.heartbeatSequence++
                }
            },
            telemetryRelays: {
                topic: 'autocore/telemetry/relays/data',
                payload: {
                    protocol_version: MQTT_PROTOCOL_VERSION,
                    uuid: 'esp32-relay-001',
                    event: 'relay_change',
                    channel: 1,
                    new_state: true,
                    timestamp: new Date().toISOString()
                }
            },
            deviceAnnounce: {
                topic: 'autocore/discovery/announce',
                payload: {
                    protocol_version: MQTT_PROTOCOL_VERSION,
                    uuid: 'esp32-relay-001',
                    device_type: 'esp32_relay',
                    firmware_version: '2.2.0',
                    capabilities: ['relay', 'telemetry'],
                    ip_address: '192.168.1.100',
                    mac_address: 'AA:BB:CC:DD:EE:FF',
                    timestamp: new Date().toISOString()
                }
            }
        };
    }
}

// Instância global
const mqttService = new MQTTService();

export default mqttService;