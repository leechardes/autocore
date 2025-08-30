# 🔍 A12-VEHICLE-FRONTEND-DEBUGGER - Debugger de Tela de Veículo

## 📋 Objetivo

Agente autônomo para investigar e corrigir o problema de tela preta ao clicar em "criar" veículo no frontend, verificando integração com API, estrutura de dados e componentes React.

## 🎯 Missão

Identificar e corrigir a causa da tela preta quando o usuário tenta criar um veículo, garantindo que o frontend está preparado para trabalhar com a API de registro único.

## ⚙️ Configuração

```yaml
tipo: debug
prioridade: crítica
autônomo: true
projeto: config-app/frontend
api_base: http://localhost:8081
problema: Tela preta ao clicar em criar veículo
output: docs/agents/executed/A12-FRONTEND-DEBUG-[DATA].md
```

## 🚨 CONTEXTO CRÍTICO DA API

### Estrutura Atual do Backend (IMPORTANTE!)

A API foi refatorada para trabalhar com **REGISTRO ÚNICO** de veículo:

#### Endpoints Disponíveis:
- **GET** `/api/vehicle` - Retorna o único veículo ou `null`
- **POST** `/api/vehicle` - Cria ou atualiza o único veículo
- **PUT** `/api/vehicle` - Atualização parcial
- **DELETE** `/api/vehicle` - Remove (soft delete)
- **GET** `/api/config/full` - Configuração completa com veículo

#### Mudanças Importantes:
- ❌ **NÃO EXISTE MAIS**: `/api/vehicles` (plural)
- ❌ **NÃO EXISTE MAIS**: `/api/vehicles/{id}` 
- ✅ **AGORA É**: `/api/vehicle` (singular, sem ID)
- ✅ **RETORNO**: Objeto único ou `null`, nunca array

### Estrutura de Dados Real do /config/full

```json
{
  "devices": [...],
  "relays": [...],
  "screens": [...],
  "vehicle": {  // SINGULAR, não "vehicles"!
    "configured": true,
    "data": {
      "id": 1,  // Sempre 1 (registro único)
      "uuid": "preview-vehicle",
      "plate": "ABC1D23",
      "brand": "Toyota",
      "model": "Corolla",
      "version": "XEi 2.0",
      "year_model": 2023,
      "fuel_type": "flex",
      "status": "active",
      "odometer": 15420,
      "full_name": "Toyota Corolla XEi 2.0 2023",
      "is_online": true,
      "chassis": "9BWZZZ377VT004321",
      "renavam": "12345678901",
      "year_manufacture": 2023,
      "color": "Prata",
      "engine_capacity": 2.0,
      "engine_power": 177,
      "transmission": "automatic",
      "category": "passenger",
      "notes": "Veículo principal"
    },
    "maintenance_alert": false,
    "documents_alert": false,
    "next_maintenance_date": "2025-03-15",
    "next_maintenance_km": 20000
  }
}
```

### Quando NÃO há veículo:
```json
{
  "vehicle": {
    "configured": false,
    "data": null,
    "message": "Nenhum veículo cadastrado"
  }
}
```

## 🔄 Fluxo de Execução

### Fase 1: Diagnóstico do Problema (15%)
1. Localizar componente de veículo no frontend
2. Verificar console do navegador para erros
3. Identificar onde ocorre o clique "criar"
4. Verificar se há modal, dialog ou navegação

### Fase 2: Verificar Integração com API (30%)
1. Procurar chamadas para `/api/vehicles` (PLURAL - ERRADO!)
2. Verificar se está tentando acessar array em vez de objeto
3. Verificar se está esperando ID na URL
4. Confirmar URLs das chamadas API

### Fase 3: Analisar Estrutura de Dados (45%)
1. Verificar como o frontend processa `/config/full`
2. Procurar por `config.vehicles` (plural - ERRADO!)
3. Verificar se espera array: `vehicles.map()` (ERRADO!)
4. Confirmar se trata `vehicle` como objeto único

### Fase 4: Corrigir Componentes React (70%)
1. Ajustar para usar `/api/vehicle` (singular)
2. Tratar retorno como objeto ou null
3. Remover loops/maps desnecessários
4. Ajustar formulário para registro único

### Fase 5: Corrigir Estado e Hooks (85%)
1. Verificar useState inicial (deve ser objeto ou null)
2. Ajustar useEffect para buscar único veículo
3. Corrigir handlers de submit
4. Verificar navegação após criar

### Fase 6: Testes e Validação (100%)
1. Testar botão criar
2. Verificar se formulário aparece
3. Confirmar submit funciona
4. Validar que tela não fica preta

## 🐛 Problemas Comuns a Procurar

### 1. URLs Incorretas
```javascript
// ❌ ERRADO - API antiga
fetch('/api/vehicles')
fetch('/api/vehicles/1')
axios.get('/api/vehicles')

// ✅ CORRETO - API nova
fetch('/api/vehicle')
axios.get('/api/vehicle')
```

### 2. Tratamento de Arrays
```javascript
// ❌ ERRADO - Esperando array
const vehicles = data.vehicles || [];
vehicles.map(v => ...)
{vehicles.length > 0 && ...}

// ✅ CORRETO - Objeto único
const vehicle = data.vehicle?.data || null;
{vehicle && ...}
```

### 3. Estado Inicial Incorreto
```javascript
// ❌ ERRADO
const [vehicles, setVehicles] = useState([]);
const [vehicle, setVehicle] = useState({});

// ✅ CORRETO
const [vehicle, setVehicle] = useState(null);
```

### 4. Criação com ID
```javascript
// ❌ ERRADO - Tentando gerar ID
const newVehicle = {
  id: Date.now(),
  ...formData
};

// ✅ CORRETO - Sem ID (backend gerencia)
const newVehicle = {
  plate: formData.plate,
  chassis: formData.chassis,
  // ... outros campos
};
```

## 🔧 Correções Específicas

### Para Buscar Veículo
```javascript
// Função correta para buscar único veículo
async function fetchVehicle() {
  try {
    const response = await fetch('http://localhost:8081/api/vehicle');
    if (response.ok) {
      const data = await response.json();
      setVehicle(data); // Pode ser null
    }
  } catch (error) {
    console.error('Erro ao buscar veículo:', error);
    setVehicle(null);
  }
}
```

### Para Criar/Atualizar Veículo
```javascript
// POST para criar ou atualizar
async function saveVehicle(formData) {
  try {
    const response = await fetch('http://localhost:8081/api/vehicle', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        plate: formData.plate,
        chassis: formData.chassis,
        renavam: formData.renavam,
        brand: formData.brand,
        model: formData.model,
        year_manufacture: formData.yearManufacture,
        year_model: formData.yearModel,
        fuel_type: formData.fuelType || 'flex',
        // NÃO incluir user_id ou category obrigatórios
      })
    });
    
    if (response.ok) {
      const vehicle = await response.json();
      setVehicle(vehicle);
      // Fechar modal ou navegar
    }
  } catch (error) {
    console.error('Erro ao salvar veículo:', error);
  }
}
```

### Para Processar config/full
```javascript
// Processar configuração completa
async function loadConfig() {
  const response = await fetch('http://localhost:8081/api/config/full');
  const config = await response.json();
  
  // ✅ CORRETO - vehicle no singular
  if (config.vehicle?.configured) {
    setVehicle(config.vehicle.data);
    setMaintenanceAlert(config.vehicle.maintenance_alert);
  } else {
    setVehicle(null);
  }
  
  // ❌ NÃO fazer isso:
  // setVehicles(config.vehicles || []);
}
```

## ✅ Checklist de Verificação

### Arquivos a Verificar
- [ ] `src/pages/Vehicle*.jsx` ou `Vehicle*.tsx`
- [ ] `src/components/Vehicle*.jsx` ou similares
- [ ] `src/services/api.js` ou `vehicleService.js`
- [ ] `src/hooks/useVehicle.js` se existir
- [ ] `src/store/` se usar Redux/Zustand

### Pontos Críticos
- [ ] URLs usando `/api/vehicle` (singular)
- [ ] Sem tentativas de acessar arrays
- [ ] Estado inicial como null ou objeto
- [ ] Formulário sem campos user_id/category obrigatórios
- [ ] Tratamento de retorno null do GET

### Console Errors a Procurar
- [ ] "Cannot read property 'map' of undefined"
- [ ] "vehicles is not iterable"
- [ ] "404 Not Found" em /api/vehicles
- [ ] "Cannot read property 'id' of null"

## 📊 Dados de Teste

### POST Mínimo Funcional
```json
{
  "plate": "ABC1D23",
  "chassis": "9BWZZZ377VT004321",
  "renavam": "12345678901",
  "brand": "Volkswagen",
  "model": "Gol",
  "year_manufacture": 2023,
  "year_model": 2024,
  "fuel_type": "flex"
}
```

### Resposta Esperada
```json
{
  "id": 1,
  "uuid": "generated-uuid",
  "plate": "ABC1D23",
  "brand": "Volkswagen",
  "model": "Gol",
  "status": "active",
  "odometer": 0,
  "is_active": true,
  // ... outros campos
}
```

## 🚀 Solução Rápida

Se a tela fica preta, provavelmente é porque:
1. **JavaScript quebrou** - Verificar console (F12)
2. **Modal sem conteúdo** - CSS com problema ou componente não renderizando
3. **Navegação quebrada** - Tentando ir para rota que não existe
4. **Estado corrompido** - Tentando acessar propriedade de null/undefined

## 📋 Output Esperado

Gerar relatório em `docs/agents/executed/A12-FRONTEND-DEBUG-[DATA].md` com:
1. Causa exata da tela preta
2. Arquivos que precisam correção
3. Linhas de código problemáticas
4. Correções aplicadas
5. Teste confirmando funcionamento

---

**Versão**: 1.0.0  
**Autor**: Sistema AutoCore  
**Data**: 28/01/2025  
**API Base**: http://localhost:8081  
**Contexto**: Frontend React/shadcn com API de registro único