#ifndef DEVICE_MODELS_H
#define DEVICE_MODELS_H

#include <Arduino.h>
#include <vector>
#include <map>

// Estrutura para armazenar informações do device
struct DeviceInfo {
    uint8_t id;
    String uuid;
    String type;
    String name;
    
    DeviceInfo() : id(0) {}
    DeviceInfo(uint8_t _id, const String& _uuid, const String& _type = "", const String& _name = "") 
        : id(_id), uuid(_uuid), type(_type), name(_name) {}
};

// Estrutura para armazenar informações do relay board
struct RelayBoardInfo {
    uint8_t id;
    uint8_t device_id;
    String name;
    uint8_t total_channels;
    
    RelayBoardInfo() : id(0), device_id(0), total_channels(0) {}
    RelayBoardInfo(uint8_t _id, uint8_t _device_id, const String& _name = "", uint8_t _channels = 16)
        : id(_id), device_id(_device_id), name(_name), total_channels(_channels) {}
};

// Classe para gerenciar mapeamento de devices e relay boards
class DeviceRegistry {
private:
    std::map<uint8_t, DeviceInfo> devices;           // device_id -> DeviceInfo
    std::map<uint8_t, RelayBoardInfo> relayBoards;   // relay_board_id -> RelayBoardInfo
    static DeviceRegistry* instance;
    
public:
    static DeviceRegistry* getInstance() {
        if (!instance) {
            instance = new DeviceRegistry();
        }
        return instance;
    }
    
    void clear() {
        devices.clear();
        relayBoards.clear();
    }
    
    void addDevice(const DeviceInfo& device) {
        devices[device.id] = device;
    }
    
    void addRelayBoard(const RelayBoardInfo& board) {
        relayBoards[board.id] = board;
    }
    
    // Resolve relay_board_id -> device uuid
    String resolveRelayBoardToUuid(uint8_t relay_board_id) {
        Serial.printf("[DeviceRegistry] Resolving relay_board_id: %d\n", relay_board_id);
        Serial.printf("[DeviceRegistry] Total relay boards: %d\n", relayBoards.size());
        
        auto boardIt = relayBoards.find(relay_board_id);
        if (boardIt == relayBoards.end()) {
            Serial.println("[DeviceRegistry] Relay board not found!");
            // Listar boards disponíveis
            Serial.println("[DeviceRegistry] Available relay boards:");
            for (auto& pair : relayBoards) {
                Serial.printf("  - Board ID: %d, Device ID: %d, Name: %s\n", 
                    pair.second.id, pair.second.device_id, pair.second.name.c_str());
            }
            return ""; // Relay board não encontrado
        }
        
        Serial.printf("[DeviceRegistry] Found relay board, device_id: %d\n", boardIt->second.device_id);
        
        auto deviceIt = devices.find(boardIt->second.device_id);
        if (deviceIt == devices.end()) {
            Serial.println("[DeviceRegistry] Device not found!");
            // Listar devices disponíveis
            Serial.println("[DeviceRegistry] Available devices:");
            for (auto& pair : devices) {
                Serial.printf("  - Device ID: %d, UUID: %s, Type: %s\n", 
                    pair.second.id, pair.second.uuid.c_str(), pair.second.type.c_str());
            }
            return ""; // Device não encontrado
        }
        
        Serial.printf("[DeviceRegistry] Resolved UUID: %s\n", deviceIt->second.uuid.c_str());
        return deviceIt->second.uuid;
    }
    
    bool hasRelayBoard(uint8_t relay_board_id) {
        return relayBoards.find(relay_board_id) != relayBoards.end();
    }
    
    size_t getDeviceCount() { return devices.size(); }
    size_t getRelayBoardCount() { return relayBoards.size(); }
};

#endif // DEVICE_MODELS_H