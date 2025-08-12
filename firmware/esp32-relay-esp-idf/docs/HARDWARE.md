# 💾 Especificações de Hardware - ESP32-Relay

Documentação completa das especificações e requisitos de hardware para o sistema ESP32-Relay.

## 📖 Índice

- [🔧 Especificações ESP32](#-especificações-esp32)
- [📌 Pinout e Conexões](#-pinout-e-conexões)  
- [🔌 Módulos de Relé](#-módulos-de-relé)
- [⚡ Requisitos de Alimentação](#-requisitos-de-alimentação)
- [🔒 Proteções e Segurança](#-proteções-e-segurança)
- [📐 Layout PCB](#-layout-pcb)
- [🛠️ Assembly Guide](#%EF%B8%8F-assembly-guide)

## 🔧 Especificações ESP32

### Chip Principal

**ESP32-WROOM-32 (Recomendado):**
- **CPU**: Dual-core Tensilica Xtensa 32-bit LX6 @ 240MHz
- **RAM**: 520KB SRAM (320KB disponível)
- **Flash**: 4MB (mínimo) / 8MB (recomendado)
- **WiFi**: 802.11 b/g/n 2.4GHz
- **Bluetooth**: v4.2 BR/EDR + BLE
- **Operating Voltage**: 3.0V - 3.6V
- **Operating Current**: 160mA - 240mA
- **Sleep Current**: < 5µA (deep sleep)

**Alternativas Compatíveis:**
- ESP32-WROVER (com PSRAM)
- ESP32-S3-WROOM-1 (USB nativo)
- ESP32-C3-WROOM-02 (RISC-V, single core)

### Periféricos Disponíveis

| Recurso | Quantidade | Uso no Projeto |
|---------|------------|----------------|
| **GPIO** | 34 pinos | 16 para relés + 4 reservados |
| **ADC** | 18 canais | Monitoramento analógico |
| **DAC** | 2 canais | Saída analógica |
| **PWM** | 16 canais | Controle de intensidade |
| **UART** | 3 interfaces | Debug + comunicação |
| **SPI** | 4 interfaces | Expansão futura |
| **I2C** | 2 interfaces | Sensores/displays |
| **Timers** | 4 x 64-bit | Sistema momentâneo |

## 📌 Pinout e Conexões

### Mapeamento de Relés (Padrão)

```
┌─────────────────────────────────────┐
│             ESP32-WROOM-32          │
├─────────────────────────────────────┤
│ GPIO | Relé | Função | Obs          │
├─────────────────────────────────────┤
│  2   │  1   │ Relé 1 │ Boot LED     │
│  4   │  2   │ Relé 2 │              │
│  5   │  3   │ Relé 3 │              │
│ 12   │  4   │ Relé 4 │ Boot pin     │
│ 13   │  5   │ Relé 5 │              │
│ 14   │  6   │ Relé 6 │              │
│ 15   │  7   │ Relé 7 │ Boot pin     │
│ 16   │  8   │ Relé 8 │              │
│ 17   │  9   │ Relé 9 │              │
│ 18   │ 10   │ Relé 10│              │
│ 19   │ 11   │ Relé 11│              │
│ 21   │ 12   │ Relé 12│ I2C SDA      │
│ 22   │ 13   │ Relé 13│ I2C SCL      │
│ 23   │ 14   │ Relé 14│              │
│ 25   │ 15   │ Relé 15│ DAC1         │
│ 26   │ 16   │ Relé 16│ DAC2         │
└─────────────────────────────────────┘
```

### Pinos Reservados/Evitar

| GPIO | Função | Motivo |
|------|--------|---------|
| 0 | Boot/Flash | Pull-up necessário no boot |
| 1 | UART0 TX | Console serial |
| 3 | UART0 RX | Console serial |
| 6-11 | Flash SPI | Conexão com memória Flash |

### Pinout Alternativo (Customizável)

Via `menuconfig` → `Hardware Settings` → `Custom GPIO Mapping`:

```c
// Exemplo de mapeamento customizado
const int custom_relay_pins[16] = {
    32, 33, 25, 26, 27, 14, 12, 13,  // Relés 1-8
    23, 22, 21, 19, 18, 5, 17, 16   // Relés 9-16
};
```

### Diagrama de Conexões

```
ESP32                    Relay Module
┌─────────────┐         ┌─────────────┐
│ GPIO2    3V3├─────────┤VCC          │
│             │         │             │
│ GPIO4      ├─────────┤IN1    OUT1  ├─── Load 1
│ GPIO5      ├─────────┤IN2    OUT2  ├─── Load 2
│ GPIO12     ├─────────┤IN3    OUT3  ├─── Load 3
│ ...        │         │...          │
│            │  ┌──────┤GND          │
│ GND        ├──┘      └─────────────┘
└─────────────┘
```

## 🔌 Módulos de Relé

### Especificações Recomendadas

**Módulo 16 Canais:**
- **Tensão Bobina**: 5V (com pull-up) ou 3.3V (nativo)
- **Corrente Bobina**: 15-20mA por canal
- **Tensão Contato**: 250V AC / 30V DC (máximo)
- **Corrente Contato**: 10A (máximo)
- **Tipo**: SPDT (Single Pole Double Throw)
- **Tempo Resposta**: < 10ms
- **Vida Útil**: > 100,000 operações

### Tipos de Módulos

#### 1. Módulo 5V com Optoacoplador
```
Vantagens:
✅ Isolação galvânica
✅ Proteção do ESP32
✅ Maior corrente de contato
✅ Compatível com níveis 3.3V

Desvantagens:
❌ Maior consumo energético
❌ Necessita fonte 5V separada
❌ Tamanho maior
```

#### 2. Módulo 3.3V Direto
```
Vantagens:
✅ Alimentação única 3.3V
✅ Menor consumo
✅ Design mais simples
✅ Menor tamanho

Desvantagens:  
❌ Menor corrente de contato
❌ Sem isolação galvânica
❌ Maior sensibilidade a ruído
```

#### 3. Relé Estado Sólido (SSR)
```
Vantagens:
✅ Sem ruído mecânico
✅ Maior velocidade
✅ Maior vida útil
✅ Controle direto 3.3V

Desvantagens:
❌ Maior custo
❌ Dissipação térmica
❌ Drop voltage
```

### Esquema de Conexão Detalhado

#### Módulo com Optoacoplador (5V)
```
ESP32-3.3V ──┐
             │
             ├─ 1kΩ ─── LED+ ──┐
             │                 │ Optoacoplador
ESP32-GPIO ──┤                 │
             │                 │
             ├─────────── LED- ──┘
             │
ESP32-GND ───┴─ Transistor ─── Relay+
                      │
              5V ─────┘
              
              Relay-GND ─── ESP32-GND
```

#### Módulo Direto (3.3V)
```
ESP32-GPIO ────────── Relay-IN
ESP32-3V3  ────────── Relay-VCC  
ESP32-GND  ────────── Relay-GND
```

## ⚡ Requisitos de Alimentação

### Cálculo de Consumo

**ESP32 Base:**
- Ativo (WiFi + CPU): 160-240mA @ 3.3V
- Idle (WiFi ligado): 20-30mA @ 3.3V
- Deep Sleep: < 5µA @ 3.3V

**Módulos de Relé:**
- Por canal (5V): 20mA @ 5V = 0.1W
- 16 canais (5V): 320mA @ 5V = 1.6W
- Por canal (3.3V): 15mA @ 3.3V = 0.05W
- 16 canais (3.3V): 240mA @ 3.3V = 0.8W

### Fonte de Alimentação

#### Opção 1: Fonte Única 5V
```
Entrada: 100-240V AC
Saída: 5V/3A (15W)

5V ─┬─ Módulos Relé (5V, 1.6W)
    │
    └─ Regulador LDO 3.3V ─ ESP32 (3.3V, 0.8W)
```

**Regulador 3.3V Recomendado:**
- AMS1117-3.3V (1A)
- LM2596-3.3V (switching, mais eficiente)

#### Opção 2: Fonte Dupla
```
Entrada: 100-240V AC
Saída 1: 5V/1A ─ Módulos Relé  
Saída 2: 3.3V/1A ─ ESP32
```

#### Opção 3: Fonte Única 3.3V
```
Entrada: 100-240V AC
Saída: 3.3V/2A (6.6W)

3.3V ─┬─ ESP32 (0.8W)
      └─ Módulos Relé 3.3V (0.8W)
```

### Proteção de Alimentação

```
AC Input ─ Fusível (1A) ─ Filtro EMI ─ Fonte Chaveada ─┬─ Capacitor (1000µF)
                                                        │
                                                        ├─ Varistor (surge protection)
                                                        │
                                                        └─ DC Output
```

## 🔒 Proteções e Segurança

### Proteção de Entrada

**Varistores:**
- MOV 275V (para entrada AC)
- MOV 14V (para linha DC 12V)

**Filtros EMI:**
```
L ──┬── Indutor (10µH) ──┬── Load
    │                    │
    │   ┌─ Capacitor ─┐  │
    └───┤   (100nF)   ├──┘
        └─────────────┘
        
N ──────────────────────── Load
```

### Proteção de Saída

**Diodos Flyback (Relés):**
```
         +5V
          │
          ├─ Diodo 1N4007
          │  (Cathodo para +5V)
Relay ────┤
Coil      │
          ├─ Transistor/GPIO
          │
         GND
```

**Fusíveis por Canal:**
- Fusível rápido 250mA por relé
- Porta-fusível PCB mount

### Isolação Galvânica

**Transformador de Isolação:**
- Entre AC mains e fontes DC
- Isolação > 4kV
- Certificação de segurança

**Optoacopladores:**
- 4N35 ou equivalente
- Isolação > 2.5kV
- CTR > 50%

## 📐 Layout PCB

### Dimensões Recomendadas

**PCB Principal:**
- Tamanho: 100mm x 80mm (4 camadas)
- Espessura: 1.6mm
- Máscara: Verde/Azul
- Serigrafia: Branca

**Zonas Funcionais:**
```
┌─────────────────────────────────┐
│ Power Supply    │ ESP32 Module  │
├─────────────────┼───────────────┤
│                 │               │
│ Relay Modules   │   Connectors  │
│ (16 channels)   │   & LEDs      │
│                 │               │
└─────────────────┴───────────────┘
```

### Layer Stack-up (4 camadas)

```
Layer 1 (Top): Components + Signal routing
Layer 2 (GND): Ground plane (GND)
Layer 3 (PWR): Power planes (3.3V, 5V)  
Layer 4 (Bottom): Signal routing + backup components
```

### Design Rules

**Trace Width:**
- Power (5V): 1.0mm (3A)
- Power (3.3V): 0.8mm (2A)  
- Signal: 0.2mm (0.1A)
- GPIO: 0.3mm (0.2A)

**Via Specifications:**
- Drill: 0.2mm
- Pad: 0.5mm
- Mask: 0.6mm

**Clearances:**
- Trace to trace: 0.15mm
- Trace to via: 0.1mm
- Via to via: 0.3mm

### Thermal Management

**Copper Pour:**
- Ground plane: 35µm (1oz)
- Power plane: 70µm (2oz) 
- Thermal vias: 0.3mm drill

**Component Placement:**
- ESP32: Centro do PCB
- Reguladores: Próximos às bordas
- Relés: Distribuídos uniformemente

## 🛠️ Assembly Guide

### Lista de Materiais (BOM)

#### Componentes Principais

| Item | Quantidade | Valor | Package | Descrição |
|------|------------|-------|---------|-----------|
| ESP32-WROOM-32 | 1 | - | Module | Microcontrolador principal |
| AMS1117-3.3V | 1 | - | SOT-223 | Regulador linear 3.3V |
| Relay Module | 16 | - | Module | Módulos de relé 5V/10A |

#### Componentes Passivos

| Item | Quantidade | Valor | Package | Descrição |
|------|------------|-------|---------|-----------|
| Capacitor | 4 | 1000µF | Eletrolítico | Filtro de alimentação |
| Capacitor | 8 | 100nF | 0805 | Desacoplamento |
| Capacitor | 2 | 22µF | 0805 | Filtro regulador |
| Resistor | 16 | 1kΩ | 0805 | Pull-up relés |
| Resistor | 4 | 10kΩ | 0805 | Pull-up boot |
| LED | 4 | - | 0805 | Indicadores status |
| Resistor | 4 | 330Ω | 0805 | Limitador LED |

#### Conectores e Mecânicos

| Item | Quantidade | Valor | Package | Descrição |
|------|------------|-------|---------|-----------|
| Terminal Block | 16 | 2-pos | 5.08mm | Saída relés |
| Header Pin | 1 | 2x19 | 2.54mm | ESP32 socket |
| Header Pin | 4 | 1x4 | 2.54mm | Programação |
| Fusível | 17 | 250mA | 5x20mm | Proteção |
| Porta-fusível | 17 | - | PCB | Holder fusível |

### Processo de Montagem

#### 1. Preparação PCB
```bash
1. Inspeção visual da PCB
2. Teste de continuidade (GND, PWR)
3. Verificação de dimensões
4. Limpeza com isopropanol
```

#### 2. Componentes SMD (Primeira)
```bash
1. Aplicar pasta de solda (stencil)
2. Posicionar componentes 0805
3. Solda por reflow (245°C)
4. Inspeção AOI (Automated Optical)
```

#### 3. Componentes Through-Hole
```bash
1. Inserir conectores e sockets
2. Solda manual ou wave solder
3. Cortar leads excessivos
4. Limpeza flux residual
```

#### 4. Módulos e Headers
```bash
1. Socket ESP32 (não soldar módulo ainda)
2. Conectores de programação
3. LEDs indicadores
4. Terminal blocks de saída
```

#### 5. Teste Elétrico
```bash
1. Teste continuidade
2. Teste isolação (500V)
3. Teste alimentação (sem ESP32)
4. Teste corrente quiescente
```

#### 6. Programação e Teste Final
```bash
1. Instalar ESP32 no socket
2. Conectar programador
3. Flash firmware de teste
4. Teste funcional completo
5. Etiqueta de identificação
```

### Ferramental Necessário

**Soldagem:**
- Estação de solda (temp. controlada)
- Ferro 15W (componentes SMD)  
- Ferro 25W (through-hole)
- Sugador de solda
- Fita de cobre (EMI shielding)

**Medição:**
- Multímetro
- Osciloscópio (debugging)
- Fonte de bancada (0-15V/3A)
- Gerador de função (opcional)

**Montagem:**
- Alicates bico
- Sugadores componentes SMD
- Morsa pequena PCB
- Lupa com LED
- ESD mat + pulseira

### Checklist Final

```
□ Continuidade elétrica OK
□ Isolação AC/DC > 2kV  
□ Consumo quiescente < 300mA
□ Boot ESP32 < 2 segundos
□ WiFi conecta < 15 segundos
□ Todos os relés funcionais
□ LEDs indicadores OK
□ Temperatura operação < 60°C
□ EMI compliance (se aplicável)
□ Etiqueta identificação colada
```

---

## 🔗 Links Relacionados

- [🏗️ Arquitetura](ARCHITECTURE.md) - Arquitetura técnica do sistema
- [⚙️ Configuração](CONFIGURATION.md) - Configuração detalhada
- [🚨 Troubleshooting](TROUBLESHOOTING.md) - Soluções para problemas de hardware
- [🔒 Security](SECURITY.md) - Considerações de segurança física
- [🚀 Deployment](DEPLOYMENT.md) - Deployment em produção

---

**Documento**: Especificações de Hardware ESP32-Relay  
**Versão**: 2.0.0  
**Última Atualização**: 11 de Agosto de 2025  
**Autor**: AutoCore Team