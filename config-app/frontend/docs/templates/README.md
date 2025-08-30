# 📄 Templates - Frontend AutoCore

## 🎯 Visão Geral
Templates e modelos para desenvolvimento consistente no frontend React do AutoCore Config App.

## 📁 Templates Disponíveis

### React Component Template
```typescript
// ComponentName.tsx
import React from 'react';
import { cn } from '@/lib/utils';

interface ComponentNameProps {
  className?: string;
  children?: React.ReactNode;
}

export function ComponentName({
  className,
  children,
  ...props
}: ComponentNameProps) {
  return (
    <div 
      className={cn("base-styles", className)} 
      {...props}
    >
      {children}
    </div>
  );
}

ComponentName.displayName = "ComponentName";
```

### Custom Hook Template
```typescript
// useHookName.ts
import { useState, useEffect, useCallback } from 'react';

interface HookOptions {
  initialValue?: any;
  onSuccess?: (data: any) => void;
  onError?: (error: Error) => void;
}

export function useHookName(options: HookOptions = {}) {
  const [data, setData] = useState(options.initialValue);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const execute = useCallback(async () => {
    setLoading(true);
    setError(null);
    
    try {
      // Hook logic here
      const result = await performOperation();
      setData(result);
      options.onSuccess?.(result);
    } catch (err) {
      const error = err as Error;
      setError(error);
      options.onError?.(error);
    } finally {
      setLoading(false);
    }
  }, [options]);

  return {
    data,
    loading,
    error,
    execute
  };
}
```

### Test Template
```typescript
// ComponentName.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { ComponentName } from './ComponentName';

describe('ComponentName', () => {
  it('renders correctly', () => {
    render(<ComponentName />);
    expect(screen.getByRole('element')).toBeInTheDocument();
  });

  it('handles user interactions', async () => {
    render(<ComponentName />);
    
    const button = screen.getByRole('button');
    fireEvent.click(button);
    
    await waitFor(() => {
      expect(screen.getByText('Expected text')).toBeInTheDocument();
    });
  });

  it('handles error states', () => {
    // Test error scenarios
  });
});
```

### Page Template
```typescript
// PageName.tsx
import React from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';

export function PageName() {
  return (
    <div className="container mx-auto py-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold">Page Title</h1>
        <Button>Action Button</Button>
      </div>
      
      <Card>
        <CardHeader>
          <CardTitle>Section Title</CardTitle>
        </CardHeader>
        <CardContent>
          {/* Page content */}
        </CardContent>
      </Card>
    </div>
  );
}
```

### API Service Template
```typescript
// serviceName.ts
import { api } from '@/lib/api';

export interface ServiceData {
  id: string;
  name: string;
  // Define interface
}

class ServiceNameService {
  private baseUrl = '/api/service-name';

  async getAll(): Promise<ServiceData[]> {
    const response = await api.get(this.baseUrl);
    return response.data;
  }

  async getById(id: string): Promise<ServiceData> {
    const response = await api.get(`${this.baseUrl}/${id}`);
    return response.data;
  }

  async create(data: Omit<ServiceData, 'id'>): Promise<ServiceData> {
    const response = await api.post(this.baseUrl, data);
    return response.data;
  }

  async update(id: string, data: Partial<ServiceData>): Promise<ServiceData> {
    const response = await api.put(`${this.baseUrl}/${id}`, data);
    return response.data;
  }

  async delete(id: string): Promise<void> {
    await api.delete(`${this.baseUrl}/${id}`);
  }
}

export const serviceNameService = new ServiceNameService();
```

## 🎨 UI Templates

### Form Template
```typescript
// FormComponent.tsx
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form';

const formSchema = z.object({
  name: z.string().min(2, 'Nome deve ter pelo menos 2 caracteres'),
  email: z.string().email('Email inválido'),
});

type FormData = z.infer<typeof formSchema>;

interface FormComponentProps {
  onSubmit: (data: FormData) => void;
  initialData?: Partial<FormData>;
}

export function FormComponent({ onSubmit, initialData }: FormComponentProps) {
  const form = useForm<FormData>({
    resolver: zodResolver(formSchema),
    defaultValues: initialData || {
      name: '',
      email: '',
    },
  });

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Nome</FormLabel>
              <FormControl>
                <Input placeholder="Digite o nome" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input type="email" placeholder="Digite o email" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        
        <Button type="submit" disabled={form.formState.isSubmitting}>
          {form.formState.isSubmitting ? 'Salvando...' : 'Salvar'}
        </Button>
      </form>
    </Form>
  );
}
```

### Modal Template
```typescript
// ModalComponent.tsx
import React from 'react';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';

interface ModalComponentProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  title: string;
  description?: string;
  children: React.ReactNode;
  onConfirm?: () => void;
  onCancel?: () => void;
  confirmText?: string;
  cancelText?: string;
  confirmVariant?: 'default' | 'destructive';
}

export function ModalComponent({
  open,
  onOpenChange,
  title,
  description,
  children,
  onConfirm,
  onCancel,
  confirmText = 'Confirmar',
  cancelText = 'Cancelar',
  confirmVariant = 'default',
}: ModalComponentProps) {
  const handleCancel = () => {
    onCancel?.();
    onOpenChange(false);
  };

  const handleConfirm = () => {
    onConfirm?.();
    onOpenChange(false);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{title}</DialogTitle>
          {description && (
            <DialogDescription>{description}</DialogDescription>
          )}
        </DialogHeader>
        
        <div className="py-4">
          {children}
        </div>
        
        {(onConfirm || onCancel) && (
          <DialogFooter>
            {onCancel && (
              <Button variant="outline" onClick={handleCancel}>
                {cancelText}
              </Button>
            )}
            {onConfirm && (
              <Button variant={confirmVariant} onClick={handleConfirm}>
                {confirmText}
              </Button>
            )}
          </DialogFooter>
        )}
      </DialogContent>
    </Dialog>
  );
}
```

## 🎯 Code Generation

### Component Generator Script
```bash
#!/bin/bash
# scripts/generate-component.sh

COMPONENT_NAME=$1
if [ -z "$COMPONENT_NAME" ]; then
  echo "Usage: ./generate-component.sh ComponentName"
  exit 1
fi

COMPONENT_DIR="src/components/$COMPONENT_NAME"
mkdir -p "$COMPONENT_DIR"

# Create component file
cat > "$COMPONENT_DIR/$COMPONENT_NAME.tsx" << EOF
import React from 'react';
import { cn } from '@/lib/utils';

interface ${COMPONENT_NAME}Props {
  className?: string;
}

export function $COMPONENT_NAME({ className }: ${COMPONENT_NAME}Props) {
  return (
    <div className={cn("", className)}>
      $COMPONENT_NAME Component
    </div>
  );
}
EOF

# Create index file
echo "export { $COMPONENT_NAME } from './$COMPONENT_NAME';" > "$COMPONENT_DIR/index.ts"

# Create test file
cat > "$COMPONENT_DIR/$COMPONENT_NAME.test.tsx" << EOF
import { render, screen } from '@testing-library/react';
import { $COMPONENT_NAME } from './$COMPONENT_NAME';

describe('$COMPONENT_NAME', () => {
  it('renders correctly', () => {
    render(<$COMPONENT_NAME />);
    expect(screen.getByText('$COMPONENT_NAME Component')).toBeInTheDocument();
  });
});
EOF

echo "Component $COMPONENT_NAME created successfully!"
```

## 📋 Checklists

### Component Checklist
- [ ] Props interface definida com TypeScript
- [ ] className prop para customização
- [ ] displayName definido
- [ ] Testes básicos criados
- [ ] Documentação/comentários adicionados
- [ ] Acessibilidade considerada
- [ ] Responsividade implementada

### Hook Checklist
- [ ] TypeScript interfaces/types definidos
- [ ] Estados de loading/error tratados
- [ ] Cleanup no useEffect quando necessário
- [ ] Memoização com useCallback/useMemo quando apropriado
- [ ] Testes unitários criados
- [ ] Documentação JSDoc adicionada

### Page Checklist
- [ ] Layout responsivo implementado
- [ ] Loading states considerados
- [ ] Error boundaries implementados
- [ ] SEO meta tags configurados (se necessário)
- [ ] Breadcrumbs/navegação adicionados
- [ ] Testes de integração criados

---

**Status**: Templates configurados ✅  
**Última atualização**: 2025-01-28  
**Responsável**: Equipe Frontend