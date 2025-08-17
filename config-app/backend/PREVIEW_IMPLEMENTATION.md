# Implementação do Modo Preview - Endpoint `/api/config/full`

## 📋 Resumo das Implementações

Este documento descreve as melhorias implementadas no endpoint `/api/config/full/{device_uuid}` para suportar o modo preview e as necessidades identificadas na documentação.

## 🔧 Modificações Realizadas

### 1. **Endpoint com UUID Opcional**

**Arquivo**: `config-app/backend/main.py`

- ✅ Adicionadas múltiplas rotas para o mesmo endpoint:
  - `GET /api/config/full/{device_uuid}` (rota existente)
  - `GET /api/config/full` (nova rota sem UUID)

- ✅ Parâmetros suportados:
  ```python
  async def get_full_configuration(
      device_uuid: Optional[str] = None, 
      preview: bool = Query(False, description="Modo preview para visualizador")
  )
  ```

- ✅ Lógica de detecção do modo preview:
  - `device_uuid == "preview"`
  - `preview=True` (query parameter)
  - `device_uuid is None` (rota sem UUID)

### 2. **Função `get_preview_configuration()`**

**Arquivo**: `config-app/backend/main.py` (linhas 1152-1373)

- ✅ Configuração completa para visualizador frontend
- ✅ Dados simulados de telemetria para 12 sinais diferentes
- ✅ Todas as screens ativas com todos os componentes
- ✅ Dados expandidos para relay_boards e relay_channels
- ✅ Tratamento de erros com configuração de fallback

**Telemetria simulada incluída**:
```python
preview_telemetry = {
    "speed": 45.5,           # Velocidade
    "rpm": 3200,             # Rotação do motor
    "engine_temp": 89.5,     # Temperatura do motor
    "oil_pressure": 4.2,     # Pressão do óleo
    "fuel_level": 75.8,      # Nível de combustível
    "battery_voltage": 13.8, # Tensão da bateria
    "intake_temp": 23.5,     # Temperatura do ar
    "boost_pressure": 0.8,   # Pressão do turbo
    "lambda": 0.95,          # Fator lambda
    "tps": 35.2,             # Posição do acelerador
    "ethanol": 27.5,         # Percentual de etanol
    "gear": 3                # Marcha atual
}
```

### 3. **Campos Adicionais para Display/Gauge**

**Adicionados nos screen_items** (tanto modo normal quanto preview):

```python
item_data = {
    # ... campos existentes ...
    
    # Novos campos para Display/Gauge
    "display_format": "gauge" | "text" | "number",
    "value_source": "telemetry.speed",
    "unit": "km/h",
    "min_value": 0,
    "max_value": 100,
    "color_ranges": [
        {"min": 0, "max": 30, "color": "#4CAF50"},
        {"min": 30, "max": 70, "color": "#FF9800"},
        {"min": 70, "max": 100, "color": "#F44336"}
    ],
    "size": "small" | "medium" | "large",
    "color_theme": "primary" | "success" | "warning",
    "custom_colors": {
        "background": "#FFFFFF",
        "text": "#000000",
        "border": "#CCCCCC"
    }
}
```

### 4. **Telemetria em Tempo Real**

**Arquivo**: `database/shared/repositories.py`

- ✅ Novo método `TelemetryRepository.get_latest_by_device()`:
  - Busca um valor por `data_key` (mais recente)
  - Query otimizada com subquery e JOIN
  - Retorna dados estruturados para o frontend

**Arquivo**: `config-app/backend/main.py`

- ✅ Integração da telemetria real para dispositivos normais:
  ```python
  latest_telemetry = telemetry.get_latest_by_device(device.id, limit=50)
  telemetry_data = {}
  for t in latest_telemetry:
      telemetry_data[t.data_key] = t.data_value
  config_data["telemetry"] = telemetry_data
  ```

### 5. **Melhorias no Repository**

**Arquivo**: `database/shared/repositories.py`

- ✅ `ConfigRepository.get_all_screens()`:
  - Lista todas as telas incluindo ocultas
  - Específico para modo preview
  - Parâmetro `include_hidden=True`

### 6. **Validações e Tratamento de Erros**

- ✅ **Validações de entrada**:
  - UUID máximo 100 caracteres
  - UUID obrigatório quando não é preview
  - Dispositivo deve estar ativo

- ✅ **Tratamento de erros específicos**:
  - Erro de banco: HTTP 503
  - Timeout: HTTP 504
  - Erro genérico: HTTP 500
  - Logs detalhados com tipo de erro

- ✅ **Configuração de fallback** para preview:
  - Em caso de erro, retorna configuração mínima
  - Evita quebra total do frontend

## 🔄 Compatibilidade

### ✅ **Totalmente Compatível**
- ESP32 continua usando `/api/config/full/{device_uuid}`
- Frontend pode usar qualquer das 3 formas:
  - `/api/config/full` (preview automático)
  - `/api/config/full/preview` (preview explícito)
  - `/api/config/full?preview=true` (preview via query)

### ✅ **Estrutura de Resposta**
- Campos existentes mantidos inalterados
- Novos campos adicionados sem quebrar compatibilidade
- Campo `preview_mode: true` identifica modo preview

## 🧪 Como Testar

### 1. **Teste Básico**
```bash
# Modo preview automático
curl http://localhost:8081/api/config/full

# Modo preview explícito
curl http://localhost:8081/api/config/full/preview

# Modo preview via query
curl http://localhost:8081/api/config/full?preview=true
```

### 2. **Teste com Script**
```bash
cd /Users/leechardes/Projetos/AutoCore/config-app/backend
python3 test_preview_endpoint.py
```

### 3. **Verificar Resposta**
- ✅ `preview_mode: true` presente
- ✅ `telemetry` com 12 sinais simulados
- ✅ `screens` com todas as telas configuradas
- ✅ Campos novos nos `screen_items`

## 📊 Benefícios Implementados

1. **Frontend Preview**:
   - Visualização completa sem dependência de dispositivos
   - Dados simulados realistas para gauges
   - Todos os tipos de componentes visíveis

2. **ESP32 Display**:
   - Campos adicionais para displays avançados
   - Telemetria em tempo real
   - Configuração de ranges de cor para gauges

3. **Manutenibilidade**:
   - Código bem estruturado com função dedicada
   - Tratamento robusto de erros
   - Logs detalhados para debug

4. **Performance**:
   - Query otimizada para telemetria
   - Fallback em caso de erro
   - Validações de entrada

## 🎯 Resultado Final

O endpoint `/api/config/full` agora suporta:

- ✅ **Modo Preview**: Configuração completa com dados simulados
- ✅ **UUID Opcional**: Múltiplas formas de acesso
- ✅ **Campos Expandidos**: Suporte completo para gauges/displays
- ✅ **Telemetria Real**: Dados atualizados para dispositivos
- ✅ **Compatibilidade 100%**: Não quebra código existente
- ✅ **Tratamento de Erros**: Robusto e informativo

O frontend pode agora criar um preview completo e o ESP32 recebe exatamente a mesma estrutura de dados.