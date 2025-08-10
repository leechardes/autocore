/**
 * AutoCore ESP32 Display - Logger Implementation
 */

#include "logger.h"
#include <WiFi.h>

// Variáveis estáticas
LogLevel Logger::currentLevel = LOG_LEVEL_INFO;
bool Logger::initialized = false;
bool Logger::serialEnabled = true;
bool Logger::bufferEnabled = false;
std::vector<LogEntry> Logger::logBuffer;
size_t Logger::maxBufferSize = 100;
size_t Logger::bufferIndex = 0;

bool Logger::begin(LogLevel level, bool enableSerial) {
    currentLevel = level;
    serialEnabled = enableSerial;
    
    if (serialEnabled) {
        Serial.begin(115200);
        delay(100);  // Aguardar inicialização
    }
    
    initialized = true;
    
    if (serialEnabled) {
        header("AutoCore Display Logger");
        info("Logger inicializado - Nível: %s", levelToString(level).c_str());
        info("Serial: %s, Buffer: %s", 
             serialEnabled ? "ON" : "OFF",
             bufferEnabled ? "ON" : "OFF");
        separator();
    }
    
    return true;
}

void Logger::end() {
    if (initialized) {
        info("Finalizando logger...");
        initialized = false;
    }
}

void Logger::setLevel(LogLevel level) {
    LogLevel oldLevel = currentLevel;
    currentLevel = level;
    
    if (initialized) {
        info("Nível de log alterado: %s -> %s", 
             levelToString(oldLevel).c_str(),
             levelToString(level).c_str());
    }
}

void Logger::enableSerial(bool enable) {
    serialEnabled = enable;
    if (initialized) {
        // Note: não podemos logar via serial se estamos desabilitando
        if (enable) {
            info("Serial logging habilitado");
        }
    }
}

void Logger::enableBuffer(bool enable, size_t maxSize) {
    bufferEnabled = enable;
    maxBufferSize = maxSize;
    
    if (enable) {
        logBuffer.reserve(maxBufferSize);
        if (initialized) {
            info("Buffer de log habilitado - Máximo: %d entradas", maxBufferSize);
        }
    } else {
        logBuffer.clear();
        if (initialized) {
            info("Buffer de log desabilitado");
        }
    }
}

void Logger::log(LogLevel level, const char* format, ...) {
    if (!initialized || level > currentLevel) {
        return;
    }
    
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    logWithContext(level, "", buffer);
}

void Logger::logWithContext(LogLevel level, const String& context, const char* format, ...) {
    if (!initialized || level > currentLevel) {
        return;
    }
    
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    String message = String(buffer);
    
    // Adicionar ao buffer se habilitado
    if (bufferEnabled) {
        addToBuffer(level, context, message);
    }
    
    // Enviar para Serial se habilitado
    if (serialEnabled) {
        LogEntry entry(level, context, message);
        Serial.println(formatEntry(entry));
    }
}

// Implementação das macros de logging
void Logger::error(const char* format, ...) {
    if (!initialized || LOG_LEVEL_ERROR > currentLevel) return;
    
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    logWithContext(LOG_LEVEL_ERROR, "", buffer);
}

void Logger::warn(const char* format, ...) {
    if (!initialized || LOG_LEVEL_WARN > currentLevel) return;
    
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    logWithContext(LOG_LEVEL_WARN, "", buffer);
}

void Logger::info(const char* format, ...) {
    if (!initialized || LOG_LEVEL_INFO > currentLevel) return;
    
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    logWithContext(LOG_LEVEL_INFO, "", buffer);
}

void Logger::debug(const char* format, ...) {
    if (!initialized || LOG_LEVEL_DEBUG > currentLevel) return;
    
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    logWithContext(LOG_LEVEL_DEBUG, "", buffer);
}

void Logger::verbose(const char* format, ...) {
    if (!initialized || LOG_LEVEL_VERBOSE > currentLevel) return;
    
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    logWithContext(LOG_LEVEL_VERBOSE, "", buffer);
}

// Implementação das macros contextualizadas
void Logger::errorCtx(const String& context, const char* format, ...) {
    if (!initialized || LOG_LEVEL_ERROR > currentLevel) return;
    
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    logWithContext(LOG_LEVEL_ERROR, context, buffer);
}

void Logger::warnCtx(const String& context, const char* format, ...) {
    if (!initialized || LOG_LEVEL_WARN > currentLevel) return;
    
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    logWithContext(LOG_LEVEL_WARN, context, buffer);
}

void Logger::infoCtx(const String& context, const char* format, ...) {
    if (!initialized || LOG_LEVEL_INFO > currentLevel) return;
    
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    logWithContext(LOG_LEVEL_INFO, context, buffer);
}

void Logger::debugCtx(const String& context, const char* format, ...) {
    if (!initialized || LOG_LEVEL_DEBUG > currentLevel) return;
    
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    logWithContext(LOG_LEVEL_DEBUG, context, buffer);
}

void Logger::verboseCtx(const String& context, const char* format, ...) {
    if (!initialized || LOG_LEVEL_VERBOSE > currentLevel) return;
    
    char buffer[512];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    logWithContext(LOG_LEVEL_VERBOSE, context, buffer);
}

void Logger::logMemory() {
    if (!initialized || LOG_LEVEL_DEBUG > currentLevel) return;
    
    size_t freeHeap = ESP.getFreeHeap();
    size_t totalHeap = ESP.getHeapSize();
    size_t usedHeap = totalHeap - freeHeap;
    float usagePercent = (float)usedHeap / totalHeap * 100.0f;
    
    debugCtx("Memory", "Heap: %s livre / %s total (%.1f%% usado)",
            formatBytes(freeHeap).c_str(),
            formatBytes(totalHeap).c_str(),
            usagePercent);
    
    // PSRAM se disponível
    if (ESP.getPsramSize() > 0) {
        size_t freePsram = ESP.getFreePsram();
        size_t totalPsram = ESP.getPsramSize();
        debugCtx("Memory", "PSRAM: %s livre / %s total",
                formatBytes(freePsram).c_str(),
                formatBytes(totalPsram).c_str());
    }
}

void Logger::logSystem() {
    if (!initialized || LOG_LEVEL_DEBUG > currentLevel) return;
    
    debugCtx("System", "Uptime: %s", formatUptime(millis()).c_str());
    debugCtx("System", "CPU: %d MHz", ESP.getCpuFreqMHz());
    debugCtx("System", "Flash: %s", formatBytes(ESP.getFlashChipSize()).c_str());
    debugCtx("System", "Chip: %s Rev %d", ESP.getChipModel(), ESP.getChipRevision());
    debugCtx("System", "SDK: %s", ESP.getSdkVersion());
}

void Logger::logNetwork() {
    if (!initialized || LOG_LEVEL_DEBUG > currentLevel) return;
    
    if (WiFi.isConnected()) {
        debugCtx("Network", "WiFi: %s (%s)", WiFi.SSID().c_str(), WiFi.localIP().toString().c_str());
        debugCtx("Network", "Signal: %d dBm", WiFi.RSSI());
        debugCtx("Network", "Gateway: %s", WiFi.gatewayIP().toString().c_str());
    } else {
        debugCtx("Network", "WiFi: Desconectado");
    }
    
    debugCtx("Network", "MAC: %s", WiFi.macAddress().c_str());
}

String Logger::formatTimestamp(unsigned long timestamp) {
    unsigned long seconds = timestamp / 1000;
    unsigned long milliseconds = timestamp % 1000;
    
    unsigned long hours = seconds / 3600;
    unsigned long minutes = (seconds % 3600) / 60;
    seconds = seconds % 60;
    
    char buffer[32];
    snprintf(buffer, sizeof(buffer), "%02lu:%02lu:%02lu.%03lu", 
             hours, minutes, seconds, milliseconds);
    
    return String(buffer);
}

String Logger::formatLevel(LogLevel level) {
    switch (level) {
        case LOG_LEVEL_ERROR: return "ERROR";
        case LOG_LEVEL_WARN:  return "WARN ";
        case LOG_LEVEL_INFO:  return "INFO ";
        case LOG_LEVEL_DEBUG: return "DEBUG";
        case LOG_LEVEL_VERBOSE: return "VERB ";
        default: return "UNKN ";
    }
}

String Logger::formatEntry(const LogEntry& entry) {
    String timestamp = formatTimestamp(entry.timestamp);
    String level = formatLevel(entry.level);
    
    if (entry.context.length() > 0) {
        return "[" + timestamp + "] [" + level + "] [" + entry.context + "] " + entry.message;
    } else {
        return "[" + timestamp + "] [" + level + "] " + entry.message;
    }
}

void Logger::addToBuffer(LogLevel level, const String& context, const String& message) {
    LogEntry entry(level, context, message);
    
    if (logBuffer.size() < maxBufferSize) {
        logBuffer.push_back(entry);
    } else {
        // Buffer circular - substituir entrada mais antiga
        logBuffer[bufferIndex] = entry;
        bufferIndex = (bufferIndex + 1) % maxBufferSize;
    }
}

std::vector<LogEntry> Logger::getLogBuffer() {
    return logBuffer;
}

String Logger::getLogBufferAsString() {
    String result = "";
    
    for (const LogEntry& entry : logBuffer) {
        result += formatEntry(entry) + "\n";
    }
    
    return result;
}

void Logger::clearBuffer() {
    logBuffer.clear();
    bufferIndex = 0;
    
    if (initialized) {
        debugCtx("Logger", "Buffer de log limpo");
    }
}

String Logger::levelToString(LogLevel level) {
    switch (level) {
        case LOG_LEVEL_NONE: return "NONE";
        case LOG_LEVEL_ERROR: return "ERROR";
        case LOG_LEVEL_WARN: return "WARN";
        case LOG_LEVEL_INFO: return "INFO";
        case LOG_LEVEL_DEBUG: return "DEBUG";
        case LOG_LEVEL_VERBOSE: return "VERBOSE";
        default: return "UNKNOWN";
    }
}

LogLevel Logger::stringToLevel(const String& levelStr) {
    String upper = levelStr;
    upper.toUpperCase();
    
    if (upper == "NONE") return LOG_LEVEL_NONE;
    if (upper == "ERROR") return LOG_LEVEL_ERROR;
    if (upper == "WARN") return LOG_LEVEL_WARN;
    if (upper == "INFO") return LOG_LEVEL_INFO;
    if (upper == "DEBUG") return LOG_LEVEL_DEBUG;
    if (upper == "VERBOSE") return LOG_LEVEL_VERBOSE;
    
    return LOG_LEVEL_INFO;  // Padrão
}

void Logger::hexDump(const uint8_t* data, size_t length, const String& context) {
    if (!initialized || LOG_LEVEL_VERBOSE > currentLevel) return;
    
    String ctx = context.length() > 0 ? context : "HexDump";
    
    verboseCtx(ctx, "Dump de %d bytes:", length);
    
    for (size_t i = 0; i < length; i += 16) {
        String line = "";
        
        // Offset
        char offset[16];
        snprintf(offset, sizeof(offset), "%04X: ", i);
        line += offset;
        
        // Bytes em hex
        for (size_t j = 0; j < 16; j++) {
            if (i + j < length) {
                char hex[8];
                snprintf(hex, sizeof(hex), "%02X ", data[i + j]);
                line += hex;
            } else {
                line += "   ";
            }
            
            if (j == 7) line += " ";  // Separador no meio
        }
        
        line += " |";
        
        // Caracteres ASCII
        for (size_t j = 0; j < 16 && i + j < length; j++) {
            char c = data[i + j];
            if (c >= 32 && c <= 126) {
                line += c;
            } else {
                line += ".";
            }
        }
        
        line += "|";
        
        verboseCtx(ctx, "%s", line.c_str());
    }
}

String Logger::formatBytes(size_t bytes) {
    if (bytes < 1024) {
        return String(bytes) + " B";
    } else if (bytes < 1024 * 1024) {
        return String(bytes / 1024.0, 1) + " KB";
    } else if (bytes < 1024 * 1024 * 1024) {
        return String(bytes / (1024.0 * 1024.0), 1) + " MB";
    } else {
        return String(bytes / (1024.0 * 1024.0 * 1024.0), 2) + " GB";
    }
}

String Logger::formatUptime(unsigned long milliseconds) {
    unsigned long seconds = milliseconds / 1000;
    
    unsigned long days = seconds / (24 * 3600);
    seconds %= (24 * 3600);
    unsigned long hours = seconds / 3600;
    seconds %= 3600;
    unsigned long minutes = seconds / 60;
    seconds %= 60;
    
    if (days > 0) {
        return String(days) + "d " + String(hours) + "h " + String(minutes) + "m";
    } else if (hours > 0) {
        return String(hours) + "h " + String(minutes) + "m " + String(seconds) + "s";
    } else if (minutes > 0) {
        return String(minutes) + "m " + String(seconds) + "s";
    } else {
        return String(seconds) + "." + String((milliseconds % 1000) / 100) + "s";
    }
}

void Logger::separator(const String& title) {
    if (!initialized || LOG_LEVEL_INFO > currentLevel) return;
    
    if (title.length() > 0) {
        String line = "=== " + title + " ===";
        while (line.length() < 50) {
            line = "=" + line + "=";
        }
        info("%s", line.c_str());
    } else {
        info("==================================================");
    }
}

void Logger::header(const String& title) {
    if (!initialized || LOG_LEVEL_INFO > currentLevel) return;
    
    separator();
    info("    %s", title.c_str());
    separator();
}