# 🚗 A10-VEHICLE-UI-SINGLE-RECORD-ADJUSTER - Ajustador de Interface para Registro Único

## 📋 Objetivo

Agente autônomo para ajustar a interface React de veículos para trabalhar com **apenas 1 registro único**, modificando componentes, services e estado já implementados pelo A06.

## 🎯 Missão

Refatorar páginas, componentes e serviços para gerenciar apenas 1 veículo, removendo listagens e trabalhando com objeto único em vez de arrays.

## ⚙️ Configuração

```yaml
tipo: adjustment
prioridade: urgente
autônomo: true
prerequisito: A06-VEHICLE-UI-CREATOR já executado
dependencia: backend/A09-VEHICLE-API-SINGLE-RECORD-ADJUSTER
output: docs/agents/executed/A10-UI-SINGLE-ADJUST-[DATA].md
```

## 🔄 Fluxo de Execução

### Fase 1: Análise do Estado Atual (10%)
1. Verificar páginas em `src/pages/Vehicles/`
2. Verificar componentes em `src/components/vehicles/`
3. Verificar service em `src/services/vehicleService.ts`
4. Verificar store Zustand

### Fase 2: Ajuste do Service (25%)
1. Modificar URLs para singular (`/api/vehicle`)
2. Ajustar métodos para registro único
3. Remover métodos de listagem
4. Simplificar tipos TypeScript

### Fase 3: Ajuste do Store (40%)
1. Mudar de array para objeto único
2. Remover métodos de listagem
3. Simplificar estado
4. Ajustar actions

### Fase 4: Refatoração de Páginas (60%)
1. Transformar listagem em visualização única
2. Unificar cadastro/edição
3. Simplificar navegação
4. Remover filtros e buscas

### Fase 5: Ajuste de Componentes (80%)
1. Converter tabela em card único
2. Remover componentes de múltiplos registros
3. Simplificar formulários
4. Ajustar validações

### Fase 6: Validação e Polish (100%)
1. Testar fluxo completo
2. Verificar responsividade
3. Garantir UX fluida
4. Gerar relatório

## 📝 Service Ajustado

### VehicleService.ts (Refatorado)
```typescript
import axios from 'axios';
import { API_BASE_URL } from '@/config';

export interface Vehicle {
  id?: number;  // Sempre 1
  uuid?: string;
  plate: string;
  chassis: string;
  renavam: string;
  brand: string;
  model: string;
  version?: string;
  year_manufacture: number;
  year_model: number;
  color?: string;
  fuel_type: string;
  engine_capacity?: number;
  engine_power?: number;
  transmission?: string;
  status?: string;
  odometer?: number;
  next_maintenance_date?: string;
  next_maintenance_km?: number;
  insurance_expiry?: string;
  license_expiry?: string;
  notes?: string;
  is_active?: boolean;
  created_at?: string;
  updated_at?: string;
}

class VehicleService {
  private api = axios.create({
    baseURL: `${API_BASE_URL}/api/vehicle`,  // Singular!
    headers: {
      'Content-Type': 'application/json',
    },
  });

  // Obter o único veículo
  async getVehicle(): Promise<Vehicle | null> {
    try {
      const response = await this.api.get('/');
      return response.data || null;
    } catch (error) {
      if (error.response?.status === 404) {
        return null;
      }
      throw error;
    }
  }

  // Criar ou atualizar o único veículo
  async createOrUpdateVehicle(vehicle: Omit<Vehicle, 'id' | 'uuid'>): Promise<Vehicle> {
    const response = await this.api.post('/', vehicle);
    return response.data;
  }

  // Atualizar parcialmente o único veículo
  async updateVehicle(vehicle: Partial<Vehicle>): Promise<Vehicle> {
    const response = await this.api.put('/', vehicle);
    return response.data;
  }

  // Deletar o único veículo (soft delete)
  async deleteVehicle(): Promise<void> {
    await this.api.delete('/');
  }

  // Reset completo (hard delete)
  async resetVehicle(): Promise<void> {
    await this.api.delete('/reset');
  }

  // Atualizar apenas quilometragem
  async updateOdometer(odometer: number): Promise<Vehicle> {
    const response = await this.api.put('/odometer', { odometer });
    return response.data;
  }

  // Verificar status
  async getVehicleStatus(): Promise<{
    exists: boolean;
    plate?: string;
    status?: string;
    maintenance_due?: boolean;
  }> {
    const response = await this.api.get('/status');
    return response.data;
  }

  // Verificar se existe veículo
  async hasVehicle(): Promise<boolean> {
    const vehicle = await this.getVehicle();
    return vehicle !== null;
  }
}

export default new VehicleService();
```

## 🗄️ Store Zustand Ajustado

### VehicleStore.ts (Refatorado)
```typescript
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';
import vehicleService, { Vehicle } from '@/services/vehicleService';

interface VehicleState {
  vehicle: Vehicle | null;  // Objeto único, não array!
  loading: boolean;
  error: string | null;
  hasVehicle: boolean;
  
  // Actions ajustadas
  fetchVehicle: () => Promise<void>;
  createOrUpdateVehicle: (vehicle: Omit<Vehicle, 'id'>) => Promise<void>;
  updateVehicle: (vehicle: Partial<Vehicle>) => Promise<void>;
  deleteVehicle: () => Promise<void>;
  resetVehicle: () => Promise<void>;
  updateOdometer: (odometer: number) => Promise<void>;
  clearError: () => void;
}

export const useVehicleStore = create<VehicleState>()(
  devtools(
    (set) => ({
      vehicle: null,
      loading: false,
      error: null,
      hasVehicle: false,
      
      fetchVehicle: async () => {
        set({ loading: true, error: null });
        try {
          const vehicle = await vehicleService.getVehicle();
          set({ 
            vehicle, 
            hasVehicle: vehicle !== null,
            loading: false 
          });
        } catch (error) {
          set({ 
            error: error.message, 
            loading: false,
            hasVehicle: false 
          });
        }
      },
      
      createOrUpdateVehicle: async (vehicleData: Omit<Vehicle, 'id'>) => {
        set({ loading: true, error: null });
        try {
          const vehicle = await vehicleService.createOrUpdateVehicle(vehicleData);
          set({ 
            vehicle, 
            hasVehicle: true,
            loading: false 
          });
        } catch (error) {
          set({ error: error.message, loading: false });
          throw error;
        }
      },
      
      updateVehicle: async (vehicleData: Partial<Vehicle>) => {
        set({ loading: true, error: null });
        try {
          const vehicle = await vehicleService.updateVehicle(vehicleData);
          set({ 
            vehicle, 
            loading: false 
          });
        } catch (error) {
          set({ error: error.message, loading: false });
          throw error;
        }
      },
      
      deleteVehicle: async () => {
        set({ loading: true, error: null });
        try {
          await vehicleService.deleteVehicle();
          set({ 
            vehicle: null, 
            hasVehicle: false,
            loading: false 
          });
        } catch (error) {
          set({ error: error.message, loading: false });
          throw error;
        }
      },
      
      resetVehicle: async () => {
        set({ loading: true, error: null });
        try {
          await vehicleService.resetVehicle();
          set({ 
            vehicle: null, 
            hasVehicle: false,
            loading: false 
          });
        } catch (error) {
          set({ error: error.message, loading: false });
          throw error;
        }
      },
      
      updateOdometer: async (odometer: number) => {
        set({ loading: true, error: null });
        try {
          const vehicle = await vehicleService.updateOdometer(odometer);
          set({ vehicle, loading: false });
        } catch (error) {
          set({ error: error.message, loading: false });
          throw error;
        }
      },
      
      clearError: () => set({ error: null }),
    }),
    {
      name: 'vehicle-store',  // Singular!
    }
  )
);
```

## 📱 Página Principal Ajustada

### VehicleManager.tsx (Nova página unificada)
```tsx
import React, { useEffect } from 'react';
import { Card, CardHeader, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Car, Edit, Plus, Trash2, RefreshCw } from 'lucide-react';
import { useVehicleStore } from '@/stores/vehicleStore';
import VehicleForm from './VehicleForm';
import VehicleDisplay from './VehicleDisplay';
import { toast } from '@/components/ui/toast';

export default function VehicleManager() {
  const { vehicle, loading, hasVehicle, fetchVehicle, deleteVehicle } = useVehicleStore();
  const [isEditing, setIsEditing] = React.useState(false);
  
  useEffect(() => {
    fetchVehicle();
  }, []);
  
  const handleDelete = async () => {
    if (confirm('Deseja remover o veículo cadastrado?')) {
      try {
        await deleteVehicle();
        toast.success('Veículo removido com sucesso');
      } catch (error) {
        toast.error('Erro ao remover veículo');
      }
    }
  };
  
  if (loading) {
    return (
      <div className="flex items-center justify-center h-96">
        <RefreshCw className="animate-spin h-8 w-8" />
      </div>
    );
  }
  
  return (
    <div className="container mx-auto p-6 max-w-4xl">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-3xl font-bold flex items-center gap-3">
          <Car className="h-8 w-8 text-blue-600" />
          Gerenciamento de Veículo
        </h1>
        <p className="text-gray-600 mt-2">
          {hasVehicle 
            ? 'Visualize e gerencie os dados do veículo cadastrado'
            : 'Cadastre o veículo do sistema'}
        </p>
      </div>
      
      {/* Content */}
      {!hasVehicle && !isEditing ? (
        // Estado vazio - Nenhum veículo
        <Card className="border-dashed">
          <CardContent className="text-center py-12">
            <Car className="h-16 w-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-xl font-semibold mb-2">
              Nenhum veículo cadastrado
            </h3>
            <p className="text-gray-600 mb-6">
              Clique no botão abaixo para cadastrar o veículo do sistema
            </p>
            <Button onClick={() => setIsEditing(true)} size="lg">
              <Plus className="mr-2 h-5 w-5" />
              Cadastrar Veículo
            </Button>
          </CardContent>
        </Card>
      ) : isEditing || (!hasVehicle && isEditing) ? (
        // Modo edição/cadastro
        <VehicleForm 
          vehicle={vehicle}
          onSave={() => {
            setIsEditing(false);
            fetchVehicle();
          }}
          onCancel={() => setIsEditing(false)}
        />
      ) : (
        // Visualização do veículo
        <Card>
          <CardHeader>
            <div className="flex justify-between items-start">
              <div>
                <h2 className="text-2xl font-bold">
                  {vehicle?.brand} {vehicle?.model}
                </h2>
                <p className="text-gray-600">Placa: {vehicle?.plate}</p>
              </div>
              <div className="flex gap-2">
                <Button 
                  variant="outline" 
                  onClick={() => setIsEditing(true)}
                >
                  <Edit className="mr-2 h-4 w-4" />
                  Editar
                </Button>
                <Button 
                  variant="outline" 
                  onClick={handleDelete}
                  className="text-red-600"
                >
                  <Trash2 className="mr-2 h-4 w-4" />
                  Remover
                </Button>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <VehicleDisplay vehicle={vehicle!} />
          </CardContent>
        </Card>
      )}
    </div>
  );
}
```

### VehicleDisplay.tsx (Componente de visualização)
```tsx
import React from 'react';
import { Vehicle } from '@/services/vehicleService';
import { Badge } from '@/components/ui/badge';
import { 
  Calendar, 
  Fuel, 
  MapPin, 
  Settings,
  FileText,
  AlertTriangle
} from 'lucide-react';

interface VehicleDisplayProps {
  vehicle: Vehicle;
}

export default function VehicleDisplay({ vehicle }: VehicleDisplayProps) {
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'bg-green-500';
      case 'inactive': return 'bg-gray-500';
      case 'maintenance': return 'bg-yellow-500';
      default: return 'bg-gray-500';
    }
  };
  
  const maintenanceDue = vehicle.next_maintenance_km && 
    (vehicle.next_maintenance_km - vehicle.odometer! < 1000);
  
  return (
    <div className="space-y-6">
      {/* Status e Alertas */}
      {maintenanceDue && (
        <div className="bg-yellow-50 border-l-4 border-yellow-400 p-4">
          <div className="flex items-center">
            <AlertTriangle className="h-5 w-5 text-yellow-400 mr-2" />
            <span className="font-medium">
              Manutenção se aproximando
            </span>
          </div>
        </div>
      )}
      
      {/* Informações Principais */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <h3 className="font-semibold text-gray-700 mb-3">
            Identificação
          </h3>
          <dl className="space-y-2">
            <div className="flex justify-between">
              <dt className="text-gray-600">Chassi:</dt>
              <dd className="font-mono">{vehicle.chassis}</dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-600">RENAVAM:</dt>
              <dd className="font-mono">{vehicle.renavam}</dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-600">Ano:</dt>
              <dd>{vehicle.year_manufacture}/{vehicle.year_model}</dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-600">Cor:</dt>
              <dd>{vehicle.color || 'Não informada'}</dd>
            </div>
          </dl>
        </div>
        
        <div>
          <h3 className="font-semibold text-gray-700 mb-3">
            Especificações
          </h3>
          <dl className="space-y-2">
            <div className="flex justify-between items-center">
              <dt className="text-gray-600 flex items-center">
                <Fuel className="h-4 w-4 mr-1" />
                Combustível:
              </dt>
              <dd className="capitalize">{vehicle.fuel_type}</dd>
            </div>
            <div className="flex justify-between items-center">
              <dt className="text-gray-600 flex items-center">
                <Settings className="h-4 w-4 mr-1" />
                Transmissão:
              </dt>
              <dd className="capitalize">
                {vehicle.transmission || 'Manual'}
              </dd>
            </div>
            <div className="flex justify-between items-center">
              <dt className="text-gray-600 flex items-center">
                <MapPin className="h-4 w-4 mr-1" />
                Quilometragem:
              </dt>
              <dd className="font-bold">
                {vehicle.odometer?.toLocaleString()} km
              </dd>
            </div>
            <div className="flex justify-between items-center">
              <dt className="text-gray-600">Status:</dt>
              <dd>
                <Badge className={getStatusColor(vehicle.status!)}>
                  {vehicle.status}
                </Badge>
              </dd>
            </div>
          </dl>
        </div>
      </div>
      
      {/* Manutenção e Documentos */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 pt-4 border-t">
        <div>
          <h3 className="font-semibold text-gray-700 mb-3 flex items-center">
            <Settings className="h-4 w-4 mr-2" />
            Manutenção
          </h3>
          <dl className="space-y-2">
            <div className="flex justify-between">
              <dt className="text-gray-600">Próxima em:</dt>
              <dd>
                {vehicle.next_maintenance_km 
                  ? `${vehicle.next_maintenance_km.toLocaleString()} km`
                  : 'Não definida'}
              </dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-600">Data prevista:</dt>
              <dd>
                {vehicle.next_maintenance_date 
                  ? new Date(vehicle.next_maintenance_date).toLocaleDateString()
                  : 'Não definida'}
              </dd>
            </div>
          </dl>
        </div>
        
        <div>
          <h3 className="font-semibold text-gray-700 mb-3 flex items-center">
            <FileText className="h-4 w-4 mr-2" />
            Documentos
          </h3>
          <dl className="space-y-2">
            <div className="flex justify-between">
              <dt className="text-gray-600">Licenciamento:</dt>
              <dd>
                {vehicle.license_expiry 
                  ? new Date(vehicle.license_expiry).toLocaleDateString()
                  : 'Não informado'}
              </dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-600">Seguro:</dt>
              <dd>
                {vehicle.insurance_expiry 
                  ? new Date(vehicle.insurance_expiry).toLocaleDateString()
                  : 'Não informado'}
              </dd>
            </div>
          </dl>
        </div>
      </div>
      
      {/* Observações */}
      {vehicle.notes && (
        <div className="pt-4 border-t">
          <h3 className="font-semibold text-gray-700 mb-2">Observações</h3>
          <p className="text-gray-600 whitespace-pre-wrap">{vehicle.notes}</p>
        </div>
      )}
    </div>
  );
}
```

## 🔧 Rotas Ajustadas

### Routes.tsx
```tsx
import { Routes, Route } from 'react-router-dom';
import VehicleManager from '@/pages/Vehicle/VehicleManager';

// Rota única para gerenciar o veículo
<Route path="/vehicle" element={<VehicleManager />} />
// Remover rotas antigas como /vehicles, /vehicles/new, etc.
```

### Menu Navigation
```tsx
// Ajustar menu para singular
const menuItems = [
  {
    title: 'Veículo',  // Singular!
    icon: <Car className="h-5 w-5" />,
    path: '/vehicle',
    badge: hasVehicle ? '1' : '0',  // Sempre 0 ou 1
  },
];
```

## ⚠️ Mudanças Importantes

### Componentes Removidos/Modificados
- ❌ `VehicleList.tsx` → ✅ `VehicleManager.tsx`
- ❌ `VehicleTable.tsx` → ✅ `VehicleDisplay.tsx`
- ❌ `VehicleFilters.tsx` → Removido
- ❌ `VehicleCard.tsx` → Integrado em `VehicleDisplay.tsx`
- ✅ `VehicleForm.tsx` → Mantido com ajustes

### Fluxo Simplificado
1. **Sem veículo**: Mostra botão para cadastrar
2. **Com veículo**: Mostra dados com opções de editar/remover
3. **Edição**: Usa mesmo formulário para criar/editar

## ✅ Checklist de Implementação

- [ ] Service ajustado para registro único
- [ ] Store Zustand refatorado
- [ ] Página VehicleManager criada
- [ ] Componente VehicleDisplay implementado
- [ ] Formulário ajustado para criar/editar
- [ ] Rotas atualizadas para singular
- [ ] Menu navegação ajustado
- [ ] Componentes desnecessários removidos
- [ ] Estados vazios tratados
- [ ] Feedback visual implementado

## 🧪 Testes de Validação

```tsx
// Teste 1: Renderização sem veículo
test('shows empty state when no vehicle', () => {
  render(<VehicleManager />);
  expect(screen.getByText(/Nenhum veículo cadastrado/i)).toBeInTheDocument();
});

// Teste 2: Cadastro de veículo
test('creates vehicle', async () => {
  render(<VehicleManager />);
  fireEvent.click(screen.getByText(/Cadastrar Veículo/i));
  // preencher form...
  fireEvent.click(screen.getByText(/Salvar/i));
  await waitFor(() => {
    expect(screen.getByText(/Volkswagen Gol/i)).toBeInTheDocument();
  });
});

// Teste 3: Edição do único veículo
test('edits existing vehicle', async () => {
  // com veículo mockado...
  render(<VehicleManager />);
  fireEvent.click(screen.getByText(/Editar/i));
  // alterar campos...
  fireEvent.click(screen.getByText(/Salvar/i));
});
```

## 📊 Output Esperado

Arquivo `A10-UI-SINGLE-ADJUST-[DATA].md` contendo:
1. Status dos ajustes realizados
2. Componentes modificados/removidos
3. Novo fluxo de navegação
4. Screenshots da interface
5. Testes executados
6. Métricas de performance

## 🚀 Resultado Final

- Interface para gerenciar **1 único veículo**
- Sem listagens ou tabelas
- Fluxo simplificado e intuitivo
- URL no singular (`/vehicle`)
- Estado claro: com ou sem veículo

---

**Versão**: 1.0.0  
**Autor**: Sistema AutoCore  
**Data**: 28/08/2025  
**Prerequisito**: A06 executado e A09 aplicado no backend