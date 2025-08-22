# Power Management - ESP32 Display

## ⚡ Especificações de Energia

### Consumo de Corrente
| Modo | Consumo | Descrição |
|------|---------|-----------|
| Ativo | ~240mA | CPU + WiFi + Display + Backlight |
| WiFi Sleep | ~180mA | CPU ativo, WiFi em sleep |
| Light Sleep | ~0.8mA | CPU sleep, RTC ativo |
| Deep Sleep | ~10μA | Apenas RTC timer |
| Hibernation | ~2.5μA | Apenas wake-up externo |

### Componentes por Consumo
- **ESP32 Core**: 20-80mA (dependendo da frequência)
- **WiFi Ativo**: 80-120mA
- **Display ILI9341**: 15-20mA
- **Backlight LED**: 50-100mA (controlável)
- **Touch XPT2046**: 1-2mA

## 🔋 Modos de Sleep

### Light Sleep
```cpp
#include "esp_sleep.h"
#include "driver/rtc_io.h"

void enterLightSleep(uint64_t sleep_time_us) {
    // Configurar timer de wake-up
    esp_sleep_enable_timer_wakeup(sleep_time_us);
    
    // Configurar GPIO wake-up (opcional)
    esp_sleep_enable_ext0_wakeup(GPIO_NUM_0, 0); // Wake no GPIO 0
    
    // Desligar backlight
    ledcWrite(BACKLIGHT_PWM_CHANNEL, 0);
    
    // Entrar em light sleep
    esp_light_sleep_start();
    
    // Religar backlight após wake-up
    ledcWrite(BACKLIGHT_PWM_CHANNEL, 255);
}
```

### Deep Sleep
```cpp
void enterDeepSleep(uint64_t sleep_time_us) {
    // Salvar dados importantes no RTC memory
    RTC_DATA_ATTR static int wake_count = 0;
    wake_count++;
    
    // Configurar timer de wake-up
    esp_sleep_enable_timer_wakeup(sleep_time_us);
    
    // Configurar GPIO wake-up
    esp_sleep_enable_ext0_wakeup(GPIO_NUM_0, 0);
    
    // Desligar componentes
    WiFi.disconnect(true);
    WiFi.mode(WIFI_OFF);
    
    // Display sleep
    tft.writecommand(0x10);  // Sleep command
    
    // Entrar em deep sleep
    esp_deep_sleep_start();
}
```

### RTC Memory
```cpp
// Dados que persistem durante deep sleep
RTC_DATA_ATTR struct {
    uint32_t crc32;
    uint8_t wifi_ssid[32];
    uint8_t wifi_password[64];
    uint32_t boot_count;
    int32_t calibration_x1, calibration_x2;
    int32_t calibration_y1, calibration_y2;
} rtc_data;

bool saveToRTC() {
    // Calcular CRC para validação
    rtc_data.crc32 = calculateCRC32((uint8_t*)&rtc_data + 4, sizeof(rtc_data) - 4);
    return true;
}

bool loadFromRTC() {
    uint32_t crc = calculateCRC32((uint8_t*)&rtc_data + 4, sizeof(rtc_data) - 4);
    return (crc == rtc_data.crc32);
}
```

## 💡 Controle de Backlight

### PWM Control
```cpp
#define BACKLIGHT_PWM_CHANNEL 0
#define BACKLIGHT_PWM_FREQ 5000
#define BACKLIGHT_PWM_RESOLUTION 8

class BacklightController {
private:
    uint8_t current_brightness = 255;
    uint8_t target_brightness = 255;
    unsigned long last_update = 0;
    static const unsigned long FADE_STEP_TIME = 10; // ms
    
public:
    void init() {
        ledcSetup(BACKLIGHT_PWM_CHANNEL, BACKLIGHT_PWM_FREQ, BACKLIGHT_PWM_RESOLUTION);
        ledcAttachPin(TFT_BL, BACKLIGHT_PWM_CHANNEL);
        ledcWrite(BACKLIGHT_PWM_CHANNEL, current_brightness);
    }
    
    void setBrightness(uint8_t brightness) {
        target_brightness = brightness;
    }
    
    void update() {
        if (millis() - last_update > FADE_STEP_TIME) {
            if (current_brightness < target_brightness) {
                current_brightness = min(current_brightness + 5, target_brightness);
            } else if (current_brightness > target_brightness) {
                current_brightness = max(current_brightness - 5, target_brightness);
            }
            
            ledcWrite(BACKLIGHT_PWM_CHANNEL, current_brightness);
            last_update = millis();
        }
    }
    
    // Dimming automático baseado em tempo
    void handleAutoDim() {
        static unsigned long last_interaction = millis();
        unsigned long idle_time = millis() - last_interaction;
        
        if (idle_time > 30000) {      // 30s - dim para 50%
            setBrightness(128);
        } else if (idle_time > 60000) { // 60s - dim para 10%
            setBrightness(25);
        } else if (idle_time > 120000) { // 2min - desligar
            setBrightness(0);
        }
    }
    
    void userInteraction() {
        last_interaction = millis();
        setBrightness(255);  // Voltar ao máximo
    }
};
```

## 🔌 Gerenciamento de Energia WiFi

### WiFi Power Save
```cpp
void setupWiFiPowerSave() {
    // Configurar power save mode
    WiFi.setSleep(WIFI_PS_MIN_MODEM);  // Modo economia
    
    // Ou para máxima economia:
    // WiFi.setSleep(WIFI_PS_MAX_MODEM);
    
    // Configurar DTIM (Data Traffic Indication Message)
    esp_wifi_set_ps(WIFI_PS_MIN_MODEM);
}

void optimizeWiFiPower() {
    // Reduzir potência de transmissão se próximo ao AP
    WiFi.setTxPower(WIFI_POWER_11dBm);  // Menor potência
    
    // Configurar timeout de conexão
    WiFi.setAutoReconnect(true);
    WiFi.setAutoConnect(true);
}
```

### Disconnection Strategy
```cpp
class WiFiPowerManager {
private:
    unsigned long last_activity = 0;
    bool wifi_connected = true;
    static const unsigned long WIFI_TIMEOUT = 300000; // 5 min sem atividade
    
public:
    void handleWiFiPower() {
        unsigned long idle_time = millis() - last_activity;
        
        if (idle_time > WIFI_TIMEOUT && wifi_connected) {
            WiFi.disconnect(true);
            WiFi.mode(WIFI_OFF);
            wifi_connected = false;
            Serial.println("WiFi desligado por inatividade");
        }
    }
    
    void wakeupWiFi() {
        if (!wifi_connected) {
            WiFi.mode(WIFI_STA);
            WiFi.begin(saved_ssid, saved_password);
            wifi_connected = true;
        }
        last_activity = millis();
    }
};
```

## ⚙️ CPU Frequency Scaling

### Dynamic Frequency
```cpp
#include "esp_pm.h"

void configureCPUPowerManagement() {
    esp_pm_config_esp32_t pm_config = {
        .max_freq_mhz = 240,      // Frequência máxima
        .min_freq_mhz = 80,       // Frequência mínima (para WiFi)
        .light_sleep_enable = true // Habilitar light sleep automático
    };
    
    esp_pm_configure(&pm_config);
}

void setCPUFrequency(uint32_t freq_mhz) {
    // Frequências válidas: 240, 160, 80, 40, 20, 10 MHz
    setCpuFrequencyMhz(freq_mhz);
    
    // Reconfigurar SPI se necessário
    if (freq_mhz < 80) {
        // Reduzir frequência SPI para estabilidade
        tft.writecommand(0x00); // NOP para testar comunicação
    }
}
```

## 🔋 Battery Management (Se Aplicável)

### ADC Battery Monitoring
```cpp
#define BATTERY_ADC_PIN 35
#define BATTERY_VOLTAGE_DIVIDER 2.0  // Divisor de tensão

class BatteryMonitor {
private:
    float voltage_samples[10];
    int sample_index = 0;
    
public:
    float readBatteryVoltage() {
        int adc_reading = analogRead(BATTERY_ADC_PIN);
        float voltage = (adc_reading / 4095.0) * 3.3 * BATTERY_VOLTAGE_DIVIDER;
        
        // Adicionar à média móvel
        voltage_samples[sample_index] = voltage;
        sample_index = (sample_index + 1) % 10;
        
        // Calcular média
        float avg_voltage = 0;
        for (int i = 0; i < 10; i++) {
            avg_voltage += voltage_samples[i];
        }
        return avg_voltage / 10.0;
    }
    
    uint8_t getBatteryPercentage() {
        float voltage = readBatteryVoltage();
        
        // Curva típica para Li-Ion 3.7V
        if (voltage >= 4.1) return 100;
        if (voltage >= 3.9) return 80;
        if (voltage >= 3.7) return 60;
        if (voltage >= 3.5) return 40;
        if (voltage >= 3.3) return 20;
        if (voltage >= 3.0) return 5;
        return 0;
    }
    
    bool isLowBattery() {
        return getBatteryPercentage() < 15;
    }
};
```

## 🚨 Power Failure Detection

### Brown-out Detection
```cpp
#include "esp_brownout.h"

void setupBrownoutDetection() {
    // Configurar nível de brown-out
    esp_brownout_init();
    
    // Callback para brown-out
    esp_register_shutdown_handler(powerFailureHandler);
}

void powerFailureHandler() {
    // Salvar dados críticos rapidamente
    saveConfigToNVS();
    
    // Desligar periféricos
    ledcWrite(BACKLIGHT_PWM_CHANNEL, 0);
    
    // Preparar para shutdown
    esp_deep_sleep_start();
}
```

## 📊 Monitoramento de Energia

### Power Profiling
```cpp
class PowerProfiler {
private:
    struct PowerState {
        unsigned long timestamp;
        uint32_t cpu_freq;
        bool wifi_active;
        uint8_t backlight_level;
        float estimated_current;
    };
    
    PowerState states[100];
    int state_index = 0;
    
public:
    void logCurrentState() {
        PowerState current;
        current.timestamp = millis();
        current.cpu_freq = getCpuFrequencyMhz();
        current.wifi_active = WiFi.isConnected();
        current.backlight_level = getCurrentBrightness();
        current.estimated_current = calculateEstimatedCurrent();
        
        states[state_index] = current;
        state_index = (state_index + 1) % 100;
    }
    
    float calculateEstimatedCurrent() {
        float total = 30.0;  // Base ESP32 current
        
        if (WiFi.isConnected()) total += 80.0;
        total += (getCurrentBrightness() / 255.0) * 100.0;  // Backlight
        total += 20.0;  // Display
        
        // Fator de frequência CPU
        total *= (getCpuFrequencyMhz() / 240.0);
        
        return total;
    }
};
```