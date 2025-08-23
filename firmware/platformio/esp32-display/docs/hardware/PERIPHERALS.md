# Periféricos Externos - ESP32 Display

## 🔌 Interfaces Disponíveis

### GPIO Digitais Livres
| GPIO | Tipo | Restrições | Uso Recomendado |
|------|------|------------|-----------------|
| 4    | I/O  | -          | Relays/LEDs |
| 5    | I/O  | Strapping  | Relays (com cuidado) |
| 16   | I/O  | -          | UART2_RX |
| 17   | I/O  | -          | UART2_TX |
| 18   | I/O  | -          | SPI_CLK adicional |
| 19   | I/O  | -          | SPI_MISO adicional |
| 22   | I/O  | -          | I2C_SCL |
| 23   | I/O  | -          | I2C_SDA |
| 25   | I/O  | DAC1       | PWM/Analog Out |
| 26   | I/O  | DAC2       | PWM/Analog Out |
| 27   | I/O  | -          | General I/O |
| 32   | I/O  | ADC1       | Sensor Analog |

### ADC Inputs (Apenas Entrada)
| GPIO | Canal ADC | Uso Recomendado |
|------|-----------|-----------------|
| 34   | ADC1_CH6  | Sensor temperatura |
| 35   | ADC1_CH7  | Monitoramento bateria |
| 36   | ADC1_CH0  | Sensor luz ambiente |
| 39   | ADC1_CH3  | Potenciômetro |

## 🔧 Configurações de Expansão

### I2C Bus Principal
```cpp
#include <Wire.h>

#define I2C_SDA 22
#define I2C_SCL 23
#define I2C_FREQ 400000  // 400kHz

void setupI2C() {
    Wire.begin(I2C_SDA, I2C_SCL, I2C_FREQ);
    
    // Scan para dispositivos conectados
    scanI2CDevices();
}

void scanI2CDevices() {
    Serial.println("Scanning I2C devices...");
    
    for (byte address = 1; address < 127; address++) {
        Wire.beginTransmission(address);
        byte error = Wire.endTransmission();
        
        if (error == 0) {
            Serial.printf("I2C device found at 0x%02X\n", address);
        }
    }
}
```

### UART Adicional
```cpp
#define UART2_RX 16
#define UART2_TX 17
#define UART2_BAUD 9600

HardwareSerial Serial2(2);

void setupUART2() {
    Serial2.begin(UART2_BAUD, SERIAL_8N1, UART2_RX, UART2_TX);
    Serial.println("UART2 initialized");
}

// Exemplo: comunicação com módulo RS485
void sendRS485Command(String command) {
    Serial2.println(command);
    
    // Aguardar resposta
    String response = "";
    unsigned long timeout = millis() + 1000;
    
    while (millis() < timeout && Serial2.available()) {
        response += Serial2.readString();
    }
    
    Serial.println("Response: " + response);
}
```

## 🎛️ Módulos de Expansão Comuns

### Módulo Relay 4 Canais
```cpp
#define RELAY1_PIN 25
#define RELAY2_PIN 26
#define RELAY3_PIN 27
#define RELAY4_PIN 32

class RelayController {
private:
    const int relay_pins[4] = {RELAY1_PIN, RELAY2_PIN, RELAY3_PIN, RELAY4_PIN};
    bool relay_states[4] = {false, false, false, false};
    
public:
    void init() {
        for (int i = 0; i < 4; i++) {
            pinMode(relay_pins[i], OUTPUT);
            digitalWrite(relay_pins[i], LOW);  // Relays desligados
        }
    }
    
    void setRelay(int relay, bool state) {
        if (relay >= 0 && relay < 4) {
            relay_states[relay] = state;
            digitalWrite(relay_pins[relay], state ? HIGH : LOW);
            
            Serial.printf("Relay %d: %s\n", relay + 1, state ? "ON" : "OFF");
        }
    }
    
    bool getRelayState(int relay) {
        return (relay >= 0 && relay < 4) ? relay_states[relay] : false;
    }
    
    void toggleRelay(int relay) {
        setRelay(relay, !getRelayState(relay));
    }
    
    void allOff() {
        for (int i = 0; i < 4; i++) {
            setRelay(i, false);
        }
    }
};
```

### Sensor de Temperatura DS18B20
```cpp
#include <OneWire.h>
#include <DallasTemperature.h>

#define TEMP_SENSOR_PIN 4

OneWire oneWire(TEMP_SENSOR_PIN);
DallasTemperature tempSensor(&oneWire);

class TemperatureSensor {
private:
    float last_temperature = 0.0;
    unsigned long last_reading = 0;
    static const unsigned long READ_INTERVAL = 2000;  // 2 segundos
    
public:
    void init() {
        tempSensor.begin();
        Serial.printf("Found %d temperature sensors\n", tempSensor.getDeviceCount());
    }
    
    float readTemperature() {
        if (millis() - last_reading > READ_INTERVAL) {
            tempSensor.requestTemperatures();
            last_temperature = tempSensor.getTempCByIndex(0);
            last_reading = millis();
            
            if (last_temperature == DEVICE_DISCONNECTED_C) {
                Serial.println("Temperature sensor disconnected!");
                return -999.0;
            }
        }
        
        return last_temperature;
    }
    
    bool isConnected() {
        return (last_temperature > -999.0);
    }
};
```

### Sensor de Luz Ambiente (LDR)
```cpp
#define LDR_PIN 36
#define LDR_SAMPLES 10

class LightSensor {
private:
    int readings[LDR_SAMPLES];
    int read_index = 0;
    unsigned long last_reading = 0;
    
public:
    void init() {
        // Configurar ADC para leitura analógica
        analogSetAttenuation(ADC_11db);  // Para leitura até 3.3V
        
        // Inicializar array com leituras
        for (int i = 0; i < LDR_SAMPLES; i++) {
            readings[i] = analogRead(LDR_PIN);
            delay(10);
        }
    }
    
    int readLightLevel() {
        // Ler novo valor
        readings[read_index] = analogRead(LDR_PIN);
        read_index = (read_index + 1) % LDR_SAMPLES;
        
        // Calcular média
        long total = 0;
        for (int i = 0; i < LDR_SAMPLES; i++) {
            total += readings[i];
        }
        
        return total / LDR_SAMPLES;
    }
    
    uint8_t getLightPercentage() {
        int level = readLightLevel();
        return map(level, 0, 4095, 0, 100);
    }
    
    // Auto-ajuste de brilho baseado na luz ambiente
    uint8_t getAutoBacklightLevel() {
        uint8_t light_percent = getLightPercentage();
        
        // Curva de resposta não-linear
        if (light_percent < 10) return 50;   // Ambiente escuro
        if (light_percent < 30) return 128;  // Ambiente médio
        if (light_percent < 70) return 200;  // Ambiente claro
        return 255;  // Luz solar direta
    }
};
```

### Buzzer/Beeper
```cpp
#define BUZZER_PIN 4

class Buzzer {
private:
    const int buzzer_channel = 1;  // Canal PWM diferente do backlight
    bool is_playing = false;
    
public:
    void init() {
        ledcSetup(buzzer_channel, 2000, 8);  // 2kHz, 8-bit resolution
        ledcAttachPin(BUZZER_PIN, buzzer_channel);
    }
    
    void playTone(int frequency, int duration_ms) {
        ledcWriteTone(buzzer_channel, frequency);
        delay(duration_ms);
        ledcWriteTone(buzzer_channel, 0);  // Parar som
    }
    
    void playBeep() {
        playTone(1000, 100);  // 1kHz por 100ms
    }
    
    void playDoubleBeep() {
        playTone(1000, 100);
        delay(50);
        playTone(1000, 100);
    }
    
    void playErrorSound() {
        playTone(500, 200);   // Som grave para erro
        delay(100);
        playTone(500, 200);
    }
    
    void playStartupSound() {
        playTone(800, 150);
        delay(50);
        playTone(1000, 150);
        delay(50);
        playTone(1200, 200);
    }
};
```

## 📡 Comunicação Wireless Adicional

### Módulo nRF24L01+ (2.4GHz)
```cpp
#include <RF24.h>

#define CE_PIN 4
#define CSN_PIN 5

RF24 radio(CE_PIN, CSN_PIN);

class WirelessComm {
private:
    const byte address[6] = "00001";
    
public:
    void init() {
        radio.begin();
        radio.openWritingPipe(address);
        radio.openReadingPipe(1, address);
        radio.setPALevel(RF24_PA_LOW);  // Baixa potência
        radio.setDataRate(RF24_250KBPS);  // Taxa baixa para maior alcance
        radio.startListening();
    }
    
    bool sendData(const void* data, size_t size) {
        radio.stopListening();
        bool result = radio.write(data, size);
        radio.startListening();
        return result;
    }
    
    bool receiveData(void* buffer, size_t size) {
        if (radio.available()) {
            radio.read(buffer, size);
            return true;
        }
        return false;
    }
};
```

### Módulo LoRa SX1276
```cpp
#include <LoRa.h>

#define LORA_SS    5
#define LORA_RST   4
#define LORA_DIO0  2

class LoRaComm {
public:
    void init() {
        LoRa.setPins(LORA_SS, LORA_RST, LORA_DIO0);
        
        if (!LoRa.begin(915E6)) {  // 915 MHz para Brasil
            Serial.println("LoRa init failed!");
            return;
        }
        
        LoRa.setSpreadingFactor(12);  // Máximo alcance
        LoRa.setSignalBandwidth(125E3);
        LoRa.setCodingRate4(8);
        LoRa.setTxPower(20);  // Máxima potência
        
        Serial.println("LoRa initialized");
    }
    
    void sendMessage(String message) {
        LoRa.beginPacket();
        LoRa.print(message);
        LoRa.endPacket();
    }
    
    String receiveMessage() {
        String message = "";
        int packetSize = LoRa.parsePacket();
        
        if (packetSize) {
            while (LoRa.available()) {
                message += (char)LoRa.read();
            }
            
            int rssi = LoRa.packetRssi();
            Serial.printf("Received: %s (RSSI: %d)\n", message.c_str(), rssi);
        }
        
        return message;
    }
};
```

## 🔧 Expansão via PCF8574 (I2C)

### Expansor de 8 GPIOs
```cpp
#include <PCF8574.h>

#define PCF8574_ADDRESS 0x20

PCF8574 gpio_expander(PCF8574_ADDRESS);

class GPIOExpander {
private:
    uint8_t output_state = 0;
    
public:
    void init() {
        gpio_expander.begin();
        
        // Configurar todos como saída inicialmente
        gpio_expander.write8(0x00);  // Todos LOW
    }
    
    void setPin(int pin, bool state) {
        if (pin >= 0 && pin < 8) {
            if (state) {
                output_state |= (1 << pin);
            } else {
                output_state &= ~(1 << pin);
            }
            gpio_expander.write8(output_state);
        }
    }
    
    bool readPin(int pin) {
        if (pin >= 0 && pin < 8) {
            uint8_t input = gpio_expander.read8();
            return (input & (1 << pin)) != 0;
        }
        return false;
    }
    
    void writeAll(uint8_t value) {
        output_state = value;
        gpio_expander.write8(value);
    }
    
    uint8_t readAll() {
        return gpio_expander.read8();
    }
};
```

## 🚨 Considerações de Integração

### Conflitos de Pinos
- **GPIO 12**: Compartilhado RST/MISO - cuidado com pull-ups
- **GPIO 2**: Strapping pin - evitar cargas externas durante boot
- **GPIO 5**: Strapping pin - pode afetar boot se carregado

### Isolação e Proteção
```cpp
// Proteção contra sobretensão
void setupPinProtection() {
    // Pull-ups internos onde necessário
    pinMode(GPIO_NUM_0, INPUT_PULLUP);   // Boot pin
    pinMode(GPIO_NUM_2, INPUT_PULLUP);   // Strapping pin
    
    // Configurar pinos como entrada durante inicialização
    for (int pin : {4, 5, 16, 17, 18, 19, 22, 23, 25, 26, 27, 32}) {
        pinMode(pin, INPUT);
        delay(1);  // Pequeno delay para estabilização
    }
}
```

### Gerenciamento de Energia
```cpp
void powerDownPeripherals() {
    // Desligar relays
    for (int pin : {25, 26, 27, 32}) {
        digitalWrite(pin, LOW);
    }
    
    // Colocar sensores em sleep
    tempSensor.requestTemperatures();  // Última leitura
    
    // Desabilitar interfaces
    Wire.end();
    Serial2.end();
}

void powerUpPeripherals() {
    // Reativar interfaces
    setupI2C();
    setupUART2();
    
    // Reconfigurar pinos
    setupPinProtection();
    
    // Reinicializar sensores
    tempSensor.begin();
}
```