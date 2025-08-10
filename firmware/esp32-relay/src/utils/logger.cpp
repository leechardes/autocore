#include "logger.h"
#include <stdarg.h>
#include <WiFi.h>
#include <ArduinoJson.h>

// Variáveis estáticas
log_level_t Logger::current_level = LOG_LEVEL;
bool Logger::initialized = false;
unsigned long Logger::start_time = 0;
String Logger::log_buffer[Logger::LOG_BUFFER_SIZE];
int Logger::log_buffer_index = 0;
int Logger::log_buffer_count = 0;

bool Logger::begin(log_level_t level) {
    if (!initialized) {
        Serial.begin(SERIAL_BAUDRATE);
        while (!Serial && millis() < 3000) {
            delay(10);
        }
        
        start_time = millis();
        current_level = level;
        initialized = true;
        
        // Limpar buffer
        clearBuffer();
        
        Serial.println();
        Serial.println("===============================================");
        Serial.printf("AutoCore ESP32 Relay Firmware v%s\n", FIRMWARE_VERSION);
        Serial.println("===============================================");
        Serial.printf("Log Level: %s\n", levelToString(current_level).c_str());
        Serial.printf("Start Time: %s\n", getCurrentTimestamp().c_str());
        Serial.println("===============================================");
        
        return true;
    }
    return false;
}

void Logger::setLevel(log_level_t level) {
    current_level = level;
    LOG_INFO("Logger: Nível alterado para %s", levelToString(level).c_str());
}

log_level_t Logger::getLevel() {
    return current_level;
}

void Logger::print(log_level_t level, const char* file, int line, const char* format, ...) {
    if (!initialized || level > current_level) {
        return;
    }
    
    // Buffer para mensagem formatada
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    // Extrair nome do arquivo (apenas o nome, sem path)
    const char* filename = strrchr(file, '/');
    if (filename) {
        filename++;
    } else {
        filename = file;
    }
    
    // Montar mensagem completa
    String timestamp = getCurrentTimestamp();
    String levelStr = levelToString(level);
    String message = String(timestamp) + " [" + levelStr + "] " + 
                    String(filename) + ":" + String(line) + " - " + String(buffer);
    
    // Imprimir no Serial
    Serial.println(message);
    
    // Adicionar ao buffer circular
    addToBuffer(message);
}

void Logger::println(log_level_t level, const char* message) {
    if (!initialized || level > current_level) {
        return;
    }
    
    String timestamp = getCurrentTimestamp();
    String levelStr = levelToString(level);
    String fullMessage = String(timestamp) + " [" + levelStr + "] " + String(message);
    
    Serial.println(fullMessage);
    addToBuffer(fullMessage);
}

void Logger::error(const char* format, ...) {
    if (current_level < LOG_ERROR) return;
    
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    println(LOG_ERROR, buffer);
}

void Logger::warn(const char* format, ...) {
    if (current_level < LOG_WARN) return;
    
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    println(LOG_WARN, buffer);
}

void Logger::info(const char* format, ...) {
    if (current_level < LOG_INFO) return;
    
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    println(LOG_INFO, buffer);
}

void Logger::debug(const char* format, ...) {
    if (current_level < LOG_DEBUG) return;
    
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    println(LOG_DEBUG, buffer);
}

void Logger::errorWithContext(const char* context, const char* format, ...) {
    if (current_level < LOG_ERROR) return;
    
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    String message = String("[") + String(context) + "] " + String(buffer);
    println(LOG_ERROR, message.c_str());
}

void Logger::warnWithContext(const char* context, const char* format, ...) {
    if (current_level < LOG_WARN) return;
    
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    String message = String("[") + String(context) + "] " + String(buffer);
    println(LOG_WARN, message.c_str());
}

void Logger::infoWithContext(const char* context, const char* format, ...) {
    if (current_level < LOG_INFO) return;
    
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    String message = String("[") + String(context) + "] " + String(buffer);
    println(LOG_INFO, message.c_str());
}

void Logger::debugWithContext(const char* context, const char* format, ...) {
    if (current_level < LOG_DEBUG) return;
    
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    String message = String("[") + String(context) + "] " + String(buffer);
    println(LOG_DEBUG, message.c_str());
}

void Logger::addToBuffer(const String& message) {
    log_buffer[log_buffer_index] = message;
    log_buffer_index = (log_buffer_index + 1) % LOG_BUFFER_SIZE;
    
    if (log_buffer_count < LOG_BUFFER_SIZE) {
        log_buffer_count++;
    }
}

String Logger::getBufferAsJSON() {
    DynamicJsonDocument doc(8192);
    JsonArray logs = doc.createNestedArray("logs");
    
    int start_index = (log_buffer_count < LOG_BUFFER_SIZE) ? 0 : log_buffer_index;
    
    for (int i = 0; i < log_buffer_count; i++) {
        int index = (start_index + i) % LOG_BUFFER_SIZE;
        logs.add(log_buffer[index]);
    }
    
    doc["count"] = log_buffer_count;
    doc["max_size"] = LOG_BUFFER_SIZE;
    
    String json;
    serializeJson(doc, json);
    return json;
}

void Logger::clearBuffer() {
    for (int i = 0; i < LOG_BUFFER_SIZE; i++) {
        log_buffer[i] = "";
    }
    log_buffer_index = 0;
    log_buffer_count = 0;
}

String Logger::levelToString(log_level_t level) {
    switch (level) {
        case LOG_ERROR: return "ERROR";
        case LOG_WARN:  return "WARN ";
        case LOG_INFO:  return "INFO ";
        case LOG_DEBUG: return "DEBUG";
        default:        return "UNKN ";
    }
}

String Logger::getCurrentTimestamp() {
    unsigned long current = millis();
    unsigned long elapsed = current - start_time;
    
    unsigned long seconds = elapsed / 1000;
    unsigned long minutes = seconds / 60;
    unsigned long hours = minutes / 60;
    
    seconds = seconds % 60;
    minutes = minutes % 60;
    
    char timestamp[16];
    snprintf(timestamp, sizeof(timestamp), "%02lu:%02lu:%02lu.%03lu", 
             hours, minutes, seconds, elapsed % 1000);
    
    return String(timestamp);
}

void Logger::printSystemInfo() {
    LOG_INFO("=== INFORMAÇÕES DO SISTEMA ===");
    LOG_INFO("Firmware: %s", FIRMWARE_VERSION);
    LOG_INFO("Hardware: %s", HARDWARE_VERSION);
    LOG_INFO("Chip Model: %s", ESP.getChipModel());
    LOG_INFO("Chip Revision: %d", ESP.getChipRevision());
    LOG_INFO("CPU Frequency: %d MHz", ESP.getCpuFreqMHz());
    LOG_INFO("Flash Size: %d bytes", ESP.getFlashChipSize());
    LOG_INFO("Flash Speed: %d Hz", ESP.getFlashChipSpeed());
    LOG_INFO("Sketch Size: %d bytes", ESP.getSketchSize());
    LOG_INFO("Free Sketch Space: %d bytes", ESP.getFreeSketchSpace());
    
    if (WiFi.status() == WL_CONNECTED) {
        LOG_INFO("WiFi SSID: %s", WiFi.SSID().c_str());
        LOG_INFO("IP Address: %s", WiFi.localIP().toString().c_str());
        LOG_INFO("MAC Address: %s", WiFi.macAddress().c_str());
        LOG_INFO("RSSI: %d dBm", WiFi.RSSI());
    } else {
        LOG_INFO("WiFi: Desconectado");
    }
    LOG_INFO("==============================");
}

void Logger::printMemoryInfo() {
    LOG_DEBUG("=== INFORMAÇÕES DE MEMÓRIA ===");
    LOG_DEBUG("Free Heap: %d bytes", ESP.getFreeHeap());
    LOG_DEBUG("Min Free Heap: %d bytes", ESP.getMinFreeHeap());
    LOG_DEBUG("Max Alloc Heap: %d bytes", ESP.getMaxAllocHeap());
    LOG_DEBUG("Total Heap Size: %d bytes", ESP.getHeapSize());
    LOG_DEBUG("Used Heap: %d bytes", ESP.getHeapSize() - ESP.getFreeHeap());
    LOG_DEBUG("Heap Fragmentation: %.1f%%", 
              100.0 - (100.0 * ESP.getMaxAllocHeap() / ESP.getFreeHeap()));
    LOG_DEBUG("===============================");
}

void Logger::hexDump(const char* title, const uint8_t* data, size_t length) {
    if (current_level < LOG_DEBUG) return;
    
    LOG_DEBUG("=== HEX DUMP: %s ===", title);
    LOG_DEBUG("Length: %d bytes", length);
    
    for (size_t i = 0; i < length; i += 16) {
        String line = String();
        
        // Endereço
        line += String(i, HEX);
        line += ": ";
        
        // Dados em hex
        for (size_t j = 0; j < 16; j++) {
            if (i + j < length) {
                if (data[i + j] < 16) line += "0";
                line += String(data[i + j], HEX);
                line += " ";
            } else {
                line += "   ";
            }
            
            if (j == 7) line += " ";
        }
        
        line += " |";
        
        // Dados em ASCII
        for (size_t j = 0; j < 16 && i + j < length; j++) {
            char c = data[i + j];
            line += (c >= 32 && c < 127) ? c : '.';
        }
        
        line += "|";
        
        LOG_DEBUG("%s", line.c_str());
    }
    LOG_DEBUG("========================");
}

void Logger::printStackTrace() {
    // Implementação básica de stack trace para ESP32
    LOG_DEBUG("=== STACK TRACE ===");
    LOG_DEBUG("Free Stack: %d bytes", uxTaskGetStackHighWaterMark(NULL));
    LOG_DEBUG("Task Name: %s", pcTaskGetTaskName(NULL));
    LOG_DEBUG("===================");
}