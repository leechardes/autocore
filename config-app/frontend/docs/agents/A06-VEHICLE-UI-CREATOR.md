# 🚗 A06-VEHICLE-UI-CREATOR - Criador de Interface de Veículos (Simplificado)

## 📋 Objetivo

Agente autônomo para implementar interface simples de cadastro independente de veículos no frontend React do AutoCore, sem relacionamentos com outras entidades.

## 🎯 Missão

Criar páginas React com TypeScript para CRUD básico de veículos, com formulários simples e listagem standalone.

## ⚙️ Configuração

```yaml
tipo: implementation
prioridade: alta
autônomo: true
projeto: config-app/frontend
dependência: backend/A05-VEHICLE-API-CREATOR
output: docs/agents/executed/A06-VEHICLE-UI-[DATA].md
```

## 🔄 Fluxo de Execução

### Fase 1: Análise (10%)
1. Verificar estrutura atual do frontend
2. Analisar componentes existentes (padrões)
3. Identificar sistema de rotas atual
4. Verificar gerenciamento de estado (Zustand)
5. Analisar integração API existente

### Fase 2: Estrutura de Páginas (25%)
1. Criar pasta `src/pages/Vehicles/`
2. Criar `VehicleList.tsx` - Listagem principal
3. Criar `VehicleForm.tsx` - Cadastro/Edição
4. Criar `VehicleDetail.tsx` - Visualização detalhada
5. Criar `index.ts` para exports

### Fase 3: Componentes (40%)
1. Criar `src/components/vehicles/VehicleCard.tsx`
2. Criar `src/components/vehicles/VehicleTable.tsx`
3. Criar `src/components/vehicles/VehicleFilters.tsx`
4. Criar `src/components/vehicles/VehicleStatusBadge.tsx`
5. Criar `src/components/vehicles/MaintenanceAlert.tsx`

### Fase 4: Formulários (55%)
1. Implementar formulário com react-hook-form
2. Adicionar validações (placa, chassi, renavam)
3. Criar máscaras de input
4. Implementar upload de fotos (opcional)
5. Adicionar feedback visual

### Fase 5: Integração API (70%)
1. Criar `src/services/vehicleService.ts`
2. Implementar chamadas CRUD
3. Adicionar interceptors Axios
4. Implementar tratamento de erros
5. Cache e otimização

### Fase 6: Estado e Rotas (85%)
1. Criar store Zustand para veículos
2. Integrar com rotas React Router
3. Adicionar ao menu de navegação
4. Implementar breadcrumbs
5. Configurar permissões

### Fase 7: Testes e Polish (100%)
1. Adicionar loading states
2. Implementar empty states
3. Adicionar animações suaves
4. Garantir responsividade
5. Gerar relatório de execução

## 📝 Estrutura de Componentes

### VehicleList.tsx
```tsx
import React, { useState, useEffect } from 'react';
import { Plus, Search, Filter } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card } from '@/components/ui/card';
import { useVehicleStore } from '@/stores/vehicleStore';
import VehicleTable from '@/components/vehicles/VehicleTable';
import VehicleFilters from '@/components/vehicles/VehicleFilters';

export default function VehicleList() {
  const { vehicles, loading, fetchVehicles } = useVehicleStore();
  const [searchTerm, setSearchTerm] = useState('');
  const [filters, setFilters] = useState({});
  
  useEffect(() => {
    fetchVehicles();
  }, []);
  
  return (
    <div className="container mx-auto p-6">
      {/* Header */}
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-3xl font-bold">Veículos</h1>
          <p className="text-gray-600">Gerencie sua frota de veículos</p>
        </div>
        <Button onClick={() => navigate('/vehicles/new')}>
          <Plus className="mr-2 h-4 w-4" />
          Novo Veículo
        </Button>
      </div>
      
      {/* Search and Filters */}
      <Card className="p-4 mb-6">
        <div className="flex gap-4">
          <div className="flex-1">
            <Input
              placeholder="Buscar por placa, modelo ou marca..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full"
              icon={<Search className="h-4 w-4" />}
            />
          </div>
          <VehicleFilters onFilterChange={setFilters} />
        </div>
      </Card>
      
      {/* Table/Grid */}
      <VehicleTable 
        vehicles={vehicles}
        loading={loading}
        searchTerm={searchTerm}
        filters={filters}
      />
    </div>
  );
}
```

### VehicleForm.tsx
```tsx
import React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select } from '@/components/ui/select';
import { Card, CardHeader, CardContent } from '@/components/ui/card';
import { useVehicleStore } from '@/stores/vehicleStore';
import { toast } from '@/components/ui/toast';

// Schema de validação
const vehicleSchema = z.object({
  plate: z.string()
    .min(7)
    .max(10)
    .regex(/^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$/, 'Formato inválido'),
  chassis: z.string().length(17, 'Chassi deve ter 17 caracteres'),
  renavam: z.string().length(11, 'RENAVAM deve ter 11 dígitos'),
  brand: z.string().min(1, 'Marca é obrigatória'),
  model: z.string().min(1, 'Modelo é obrigatório'),
  year_manufacture: z.number().min(1900).max(new Date().getFullYear()),
  year_model: z.number().min(1900).max(new Date().getFullYear() + 1),
  fuel_type: z.enum(['flex', 'gasoline', 'ethanol', 'diesel', 'electric', 'hybrid']),
  color: z.string().optional(),
  engine_capacity: z.number().optional(),
  transmission: z.enum(['manual', 'automatic', 'cvt']).optional(),
});

type VehicleFormData = z.infer<typeof vehicleSchema>;

export default function VehicleForm({ vehicleId }: { vehicleId?: number }) {
  const navigate = useNavigate();
  const { createVehicle, updateVehicle, loading } = useVehicleStore();
  
  const {
    register,
    handleSubmit,
    formState: { errors },
    setValue,
  } = useForm<VehicleFormData>({
    resolver: zodResolver(vehicleSchema),
  });
  
  const onSubmit = async (data: VehicleFormData) => {
    try {
      if (vehicleId) {
        await updateVehicle(vehicleId, data);
        toast.success('Veículo atualizado com sucesso!');
      } else {
        await createVehicle(data);
        toast.success('Veículo cadastrado com sucesso!');
      }
      navigate('/vehicles');
    } catch (error) {
      toast.error('Erro ao salvar veículo');
    }
  };
  
  return (
    <div className="container mx-auto p-6 max-w-4xl">
      <Card>
        <CardHeader>
          <h2 className="text-2xl font-bold">
            {vehicleId ? 'Editar' : 'Novo'} Veículo
          </h2>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
            {/* Identificação */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <Label htmlFor="plate">Placa *</Label>
                <Input
                  id="plate"
                  {...register('plate')}
                  placeholder="ABC1D23"
                  className="uppercase"
                  maxLength={7}
                />
                {errors.plate && (
                  <span className="text-red-500 text-sm">{errors.plate.message}</span>
                )}
              </div>
              
              <div>
                <Label htmlFor="chassis">Chassi *</Label>
                <Input
                  id="chassis"
                  {...register('chassis')}
                  placeholder="17 caracteres"
                  className="uppercase"
                  maxLength={17}
                />
                {errors.chassis && (
                  <span className="text-red-500 text-sm">{errors.chassis.message}</span>
                )}
              </div>
              
              <div>
                <Label htmlFor="renavam">RENAVAM *</Label>
                <Input
                  id="renavam"
                  {...register('renavam')}
                  placeholder="11 dígitos"
                  maxLength={11}
                />
                {errors.renavam && (
                  <span className="text-red-500 text-sm">{errors.renavam.message}</span>
                )}
              </div>
            </div>
            
            {/* Informações do Veículo */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="brand">Marca *</Label>
                <Select
                  id="brand"
                  {...register('brand')}
                  placeholder="Selecione a marca"
                >
                  <option value="volkswagen">Volkswagen</option>
                  <option value="ford">Ford</option>
                  <option value="chevrolet">Chevrolet</option>
                  <option value="fiat">Fiat</option>
                  <option value="toyota">Toyota</option>
                  <option value="honda">Honda</option>
                  {/* Adicionar mais marcas */}
                </Select>
              </div>
              
              <div>
                <Label htmlFor="model">Modelo *</Label>
                <Input
                  id="model"
                  {...register('model')}
                  placeholder="Ex: Gol, Civic, Corolla"
                />
              </div>
            </div>
            
            {/* Anos */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="year_manufacture">Ano Fabricação *</Label>
                <Input
                  id="year_manufacture"
                  type="number"
                  {...register('year_manufacture', { valueAsNumber: true })}
                  placeholder="2023"
                  min="1900"
                  max={new Date().getFullYear()}
                />
              </div>
              
              <div>
                <Label htmlFor="year_model">Ano Modelo *</Label>
                <Input
                  id="year_model"
                  type="number"
                  {...register('year_model', { valueAsNumber: true })}
                  placeholder="2024"
                  min="1900"
                  max={new Date().getFullYear() + 1}
                />
              </div>
            </div>
            
            {/* Características */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <Label htmlFor="fuel_type">Combustível *</Label>
                <Select id="fuel_type" {...register('fuel_type')}>
                  <option value="flex">Flex</option>
                  <option value="gasoline">Gasolina</option>
                  <option value="ethanol">Etanol</option>
                  <option value="diesel">Diesel</option>
                  <option value="electric">Elétrico</option>
                  <option value="hybrid">Híbrido</option>
                </Select>
              </div>
              
              <div>
                <Label htmlFor="color">Cor</Label>
                <Input
                  id="color"
                  {...register('color')}
                  placeholder="Ex: Preto, Branco, Prata"
                />
              </div>
              
              <div>
                <Label htmlFor="transmission">Transmissão</Label>
                <Select id="transmission" {...register('transmission')}>
                  <option value="">Selecione</option>
                  <option value="manual">Manual</option>
                  <option value="automatic">Automático</option>
                  <option value="cvt">CVT</option>
                </Select>
              </div>
            </div>
            
            {/* Botões */}
            <div className="flex justify-end gap-4">
              <Button
                type="button"
                variant="outline"
                onClick={() => navigate('/vehicles')}
              >
                Cancelar
              </Button>
              <Button type="submit" disabled={loading}>
                {loading ? 'Salvando...' : 'Salvar'}
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
```

### VehicleService.ts
```typescript
import axios from 'axios';
import { API_BASE_URL } from '@/config';

export interface Vehicle {
  id?: number;
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
    baseURL: `${API_BASE_URL}/api/vehicles`,
    headers: {
      'Content-Type': 'application/json',
    },
  });

  constructor() {
    // Interceptor simples - sem autenticação
    this.api.interceptors.request.use((config) => {
      // Pode adicionar headers comuns se necessário
      return config;
    });

    // Interceptor para erros
    this.api.interceptors.response.use(
      (response) => response,
      (error) => {
        if (error.response?.status === 401) {
          // Redirecionar para login
          window.location.href = '/login';
        }
        return Promise.reject(error);
      }
    );
  }

  // Listar veículos
  async getVehicles(params?: {
    skip?: number;
    limit?: number;
    status?: string;
  }): Promise<Vehicle[]> {
    const response = await this.api.get('/', { params });
    return response.data;
  }

  // Obter veículo por ID
  async getVehicle(id: number): Promise<Vehicle> {
    const response = await this.api.get(`/${id}`);
    return response.data;
  }

  // Buscar por placa
  async getVehicleByPlate(plate: string): Promise<Vehicle> {
    const response = await this.api.get(`/plate/${plate}`);
    return response.data;
  }

  // Criar veículo
  async createVehicle(vehicle: Omit<Vehicle, 'id' | 'uuid'>): Promise<Vehicle> {
    const response = await this.api.post('/', vehicle);
    return response.data;
  }

  // Atualizar veículo
  async updateVehicle(id: number, vehicle: Partial<Vehicle>): Promise<Vehicle> {
    const response = await this.api.put(`/${id}`, vehicle);
    return response.data;
  }

  // Deletar veículo
  async deleteVehicle(id: number): Promise<void> {
    await this.api.delete(`/${id}`);
  }

  // Atualizar quilometragem
  async updateOdometer(id: number, odometer: number): Promise<Vehicle> {
    const response = await this.api.put(`/${id}/odometer`, { odometer });
    return response.data;
  }

  // Atualizar localização
  async updateLocation(id: number, lat: number, lng: number): Promise<Vehicle> {
    const response = await this.api.put(`/${id}/location`, { lat, lng });
    return response.data;
  }

  // Buscar veículos
  async searchVehicles(query: string): Promise<Vehicle[]> {
    const response = await this.api.get('/search', { params: { q: query } });
    return response.data;
  }

  // Veículos por status
  async getVehiclesByStatus(status: string): Promise<Vehicle[]> {
    const response = await this.api.get(`/status/${status}`);
    return response.data;
  }

  // Veículos com manutenção pendente
  async getMaintenanceDue(): Promise<Vehicle[]> {
    const response = await this.api.get('/maintenance/due');
    return response.data;
  }

  // Documentos vencendo
  async getExpiringDocuments(days: number = 30): Promise<Vehicle[]> {
    const response = await this.api.get('/documents/expiring', {
      params: { days }
    });
    return response.data;
  }
}

export default new VehicleService();
```

### VehicleStore.ts (Zustand)
```typescript
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';
import vehicleService, { Vehicle } from '@/services/vehicleService';

interface VehicleState {
  vehicles: Vehicle[];
  selectedVehicle: Vehicle | null;
  loading: boolean;
  error: string | null;
  filters: {
    status?: string;
    brand?: string;
    search?: string;
  };
  
  // Actions
  fetchVehicles: () => Promise<void>;
  fetchVehicle: (id: number) => Promise<void>;
  createVehicle: (vehicle: Omit<Vehicle, 'id'>) => Promise<void>;
  updateVehicle: (id: number, vehicle: Partial<Vehicle>) => Promise<void>;
  deleteVehicle: (id: number) => Promise<void>;
  setFilters: (filters: any) => void;
  clearError: () => void;
}

export const useVehicleStore = create<VehicleState>()(
  devtools(
    (set, get) => ({
      vehicles: [],
      selectedVehicle: null,
      loading: false,
      error: null,
      filters: {},
      
      fetchVehicles: async () => {
        set({ loading: true, error: null });
        try {
          const vehicles = await vehicleService.getVehicles(get().filters);
          set({ vehicles, loading: false });
        } catch (error) {
          set({ error: error.message, loading: false });
        }
      },
      
      fetchVehicle: async (id: number) => {
        set({ loading: true, error: null });
        try {
          const vehicle = await vehicleService.getVehicle(id);
          set({ selectedVehicle: vehicle, loading: false });
        } catch (error) {
          set({ error: error.message, loading: false });
        }
      },
      
      createVehicle: async (vehicle: Omit<Vehicle, 'id'>) => {
        set({ loading: true, error: null });
        try {
          const newVehicle = await vehicleService.createVehicle(vehicle);
          set((state) => ({
            vehicles: [...state.vehicles, newVehicle],
            loading: false
          }));
        } catch (error) {
          set({ error: error.message, loading: false });
          throw error;
        }
      },
      
      updateVehicle: async (id: number, vehicle: Partial<Vehicle>) => {
        set({ loading: true, error: null });
        try {
          const updatedVehicle = await vehicleService.updateVehicle(id, vehicle);
          set((state) => ({
            vehicles: state.vehicles.map((v) =>
              v.id === id ? updatedVehicle : v
            ),
            selectedVehicle: updatedVehicle,
            loading: false
          }));
        } catch (error) {
          set({ error: error.message, loading: false });
          throw error;
        }
      },
      
      deleteVehicle: async (id: number) => {
        set({ loading: true, error: null });
        try {
          await vehicleService.deleteVehicle(id);
          set((state) => ({
            vehicles: state.vehicles.filter((v) => v.id !== id),
            loading: false
          }));
        } catch (error) {
          set({ error: error.message, loading: false });
          throw error;
        }
      },
      
      setFilters: (filters: any) => {
        set({ filters });
        get().fetchVehicles();
      },
      
      clearError: () => set({ error: null }),
    }),
    {
      name: 'vehicle-store',
    }
  )
);
```

## 🎨 Componentes UI

### VehicleCard.tsx
```tsx
import React from 'react';
import { Car, Fuel, Calendar, MapPin, Settings } from 'lucide-react';
import { Card, CardHeader, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Vehicle } from '@/services/vehicleService';

interface VehicleCardProps {
  vehicle: Vehicle;
  onEdit: () => void;
  onDelete: () => void;
  onViewDetails: () => void;
}

export default function VehicleCard({ 
  vehicle, 
  onEdit, 
  onDelete, 
  onViewDetails 
}: VehicleCardProps) {
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'bg-green-500';
      case 'inactive': return 'bg-gray-500';
      case 'maintenance': return 'bg-yellow-500';
      case 'retired': return 'bg-red-500';
      default: return 'bg-gray-500';
    }
  };
  
  return (
    <Card className="hover:shadow-lg transition-shadow">
      <CardHeader>
        <div className="flex justify-between items-start">
          <div className="flex items-center gap-3">
            <Car className="h-8 w-8 text-blue-600" />
            <div>
              <h3 className="font-bold text-lg">
                {vehicle.brand} {vehicle.model}
              </h3>
              <p className="text-gray-600">{vehicle.plate}</p>
            </div>
          </div>
          <Badge className={getStatusColor(vehicle.status || 'inactive')}>
            {vehicle.status}
          </Badge>
        </div>
      </CardHeader>
      
      <CardContent>
        <div className="grid grid-cols-2 gap-3 mb-4">
          <div className="flex items-center gap-2">
            <Calendar className="h-4 w-4 text-gray-500" />
            <span className="text-sm">{vehicle.year_model}</span>
          </div>
          
          <div className="flex items-center gap-2">
            <Fuel className="h-4 w-4 text-gray-500" />
            <span className="text-sm">{vehicle.fuel_type}</span>
          </div>
          
          <div className="flex items-center gap-2">
            <MapPin className="h-4 w-4 text-gray-500" />
            <span className="text-sm">{vehicle.odometer} km</span>
          </div>
          
          <div className="flex items-center gap-2">
            <Settings className="h-4 w-4 text-gray-500" />
            <span className="text-sm">{vehicle.transmission || 'Manual'}</span>
          </div>
        </div>
        
        <div className="flex gap-2">
          <Button 
            variant="outline" 
            size="sm" 
            onClick={onViewDetails}
            className="flex-1"
          >
            Detalhes
          </Button>
          <Button 
            variant="outline" 
            size="sm" 
            onClick={onEdit}
            className="flex-1"
          >
            Editar
          </Button>
          <Button 
            variant="outline" 
            size="sm" 
            onClick={onDelete}
            className="text-red-600"
          >
            Excluir
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}
```

## 🔧 Rotas

### App.tsx ou Routes.tsx
```tsx
import { Routes, Route } from 'react-router-dom';
import VehicleList from '@/pages/Vehicles/VehicleList';
import VehicleForm from '@/pages/Vehicles/VehicleForm';
import VehicleDetail from '@/pages/Vehicles/VehicleDetail';

// Adicionar às rotas existentes
<Route path="/vehicles" element={<VehicleList />} />
<Route path="/vehicles/new" element={<VehicleForm />} />
<Route path="/vehicles/:id" element={<VehicleDetail />} />
<Route path="/vehicles/:id/edit" element={<VehicleForm />} />
```

### Menu de Navegação
```tsx
// Em seu componente de menu/sidebar
import { Car } from 'lucide-react';

const menuItems = [
  // ... outros items
  {
    title: 'Veículos',
    icon: <Car className="h-5 w-5" />,
    path: '/vehicles',
    badge: vehicleCount, // opcional
  },
];
```

## ✅ Checklist de Implementação

- [ ] Estrutura de páginas criada
- [ ] Componentes base implementados
- [ ] Formulário com validação completa
- [ ] Integração com API funcional
- [ ] Store Zustand configurado
- [ ] Rotas adicionadas
- [ ] Menu atualizado
- [ ] Listagem com filtros
- [ ] Cards/tabela responsivos
- [ ] Loading e error states
- [ ] Empty states
- [ ] Confirmações de exclusão
- [ ] Toast notifications
- [ ] Responsividade mobile
- [ ] Testes básicos

## 🧪 Testes de Validação

### Teste de Renderização
```tsx
import { render, screen } from '@testing-library/react';
import VehicleList from '@/pages/Vehicles/VehicleList';

test('renders vehicle list', () => {
  render(<VehicleList />);
  const heading = screen.getByText(/Veículos/i);
  expect(heading).toBeInTheDocument();
});
```

### Teste de Formulário
```tsx
test('validates plate format', async () => {
  render(<VehicleForm />);
  const plateInput = screen.getByLabelText(/Placa/i);
  
  fireEvent.change(plateInput, { target: { value: 'INVALID' } });
  fireEvent.submit(form);
  
  await waitFor(() => {
    expect(screen.getByText(/Formato inválido/i)).toBeInTheDocument();
  });
});
```

## 📊 Output Esperado

Arquivo `A06-VEHICLE-UI-[DATA].md` contendo:
1. Status da implementação
2. Componentes criados
3. Rotas configuradas
4. Screenshots das telas
5. Testes realizados
6. Instruções de uso

## 🎨 Considerações de UX

1. **Feedback Visual**: Loading spinners, skeleton screens
2. **Validação em Tempo Real**: Mostrar erros conforme usuário digita
3. **Máscaras de Input**: Placa, RENAVAM formatados
4. **Confirmações**: Modal antes de deletar
5. **Breadcrumbs**: Navegação clara
6. **Filtros Salvos**: Persistir preferências do usuário
7. **Bulk Actions**: Selecionar múltiplos veículos
8. **Export**: Baixar lista em CSV/PDF

## 🚀 Próximos Passos

Após execução bem-sucedida:
1. Implementar dashboard de veículos
2. Adicionar gráficos e estatísticas
3. Integrar com mapa para localização
4. Implementar notificações de manutenção
5. Adicionar gestão de documentos/fotos

---

**Versão**: 1.0.0  
**Autor**: Sistema AutoCore  
**Data**: 28/08/2025  
**Dependência**: backend/A05-VEHICLE-API-CREATOR