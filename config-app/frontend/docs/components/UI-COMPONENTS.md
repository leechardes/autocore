# Componentes UI - shadcn/ui

Documentação completa dos componentes shadcn/ui utilizados no projeto.

## Componentes Implementados

### Button (button.jsx)

**Localização**: `src/components/ui/button.jsx`

**Propósito**: Botão reutilizável com variantes de estilo

**Variantes**:
- `default` - Botão primário azul
- `destructive` - Botão vermelho para ações perigosas
- `outline` - Botão com borda
- `secondary` - Botão secundário
- `ghost` - Botão sem fundo
- `link` - Botão estilo link

**Tamanhos**:
- `default` - Tamanho padrão
- `sm` - Pequeno
- `lg` - Grande
- `icon` - Quadrado para ícones

**Uso**:
```jsx
import { Button } from '@/components/ui/button'

<Button variant="default" size="lg" onClick={handleClick}>
  Clique aqui
</Button>

<Button variant="outline" size="icon">
  <IconName className="h-4 w-4" />
</Button>
```

---

### Card (card.jsx)

**Localização**: `src/components/ui/card.jsx`

**Propósito**: Container de conteúdo com estilo consistente

**Componentes**:
- `Card` - Container principal
- `CardHeader` - Cabeçalho do card
- `CardTitle` - Título do card
- `CardDescription` - Descrição/subtítulo
- `CardContent` - Conteúdo principal
- `CardFooter` - Rodapé do card

**Uso**:
```jsx
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'

<Card>
  <CardHeader>
    <CardTitle>Título do Card</CardTitle>
    <CardDescription>Descrição opcional</CardDescription>
  </CardHeader>
  <CardContent>
    <p>Conteúdo do card aqui...</p>
  </CardContent>
</Card>
```

---

### Dialog (dialog.jsx)

**Localização**: `src/components/ui/dialog.jsx`

**Propósito**: Modais e dialogs acessíveis

**Componentes**:
- `Dialog` - Container principal
- `DialogTrigger` - Elemento que abre o dialog
- `DialogContent` - Conteúdo do modal
- `DialogHeader` - Cabeçalho
- `DialogTitle` - Título do modal
- `DialogDescription` - Descrição
- `DialogFooter` - Rodapé com ações
- `DialogClose` - Botão para fechar

**Uso**:
```jsx
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog'

<Dialog>
  <DialogTrigger asChild>
    <Button variant="outline">Abrir Modal</Button>
  </DialogTrigger>
  <DialogContent>
    <DialogHeader>
      <DialogTitle>Título do Modal</DialogTitle>
      <DialogDescription>
        Descrição do modal aqui...
      </DialogDescription>
    </DialogHeader>
    {/* Conteúdo do modal */}
  </DialogContent>
</Dialog>
```

---

### Input (input.jsx)

**Localização**: `src/components/ui/input.jsx`

**Propósito**: Campo de entrada de texto estilizado

**Props**:
- Todas as props padrão do `<input>`
- `className` - Classes CSS adicionais

**Uso**:
```jsx
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

<div>
  <Label htmlFor="email">Email</Label>
  <Input 
    id="email" 
    type="email" 
    placeholder="Digite seu email"
    value={email}
    onChange={(e) => setEmail(e.target.value)}
  />
</div>
```

---

### Select (select.jsx)

**Localização**: `src/components/ui/select.jsx`

**Propósito**: Dropdown select acessível

**Componentes**:
- `Select` - Container principal
- `SelectTrigger` - Botão que abre o dropdown
- `SelectValue` - Valor selecionado exibido
- `SelectContent` - Container das opções
- `SelectItem` - Item individual
- `SelectGroup` - Agrupamento de itens
- `SelectLabel` - Label de grupo

**Uso**:
```jsx
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'

<Select onValueChange={setValue} value={value}>
  <SelectTrigger>
    <SelectValue placeholder="Selecione uma opção" />
  </SelectTrigger>
  <SelectContent>
    <SelectItem value="opcao1">Opção 1</SelectItem>
    <SelectItem value="opcao2">Opção 2</SelectItem>
    <SelectItem value="opcao3">Opção 3</SelectItem>
  </SelectContent>
</Select>
```

---

### Switch (switch.jsx)

**Localização**: `src/components/ui/switch.jsx`

**Propósito**: Toggle switch para valores boolean

**Props**:
- `checked` - Estado do switch
- `onCheckedChange` - Callback de mudança
- `disabled` - Desabilitar switch

**Uso**:
```jsx
import { Switch } from '@/components/ui/switch'
import { Label } from '@/components/ui/label'

<div className="flex items-center space-x-2">
  <Switch 
    id="notifications" 
    checked={notifications}
    onCheckedChange={setNotifications}
  />
  <Label htmlFor="notifications">Receber notificações</Label>
</div>
```

---

### Tabs (tabs.jsx)

**Localização**: `src/components/ui/tabs.jsx`

**Propósito**: Sistema de abas para navegação de conteúdo

**Componentes**:
- `Tabs` - Container principal
- `TabsList` - Lista de abas
- `TabsTrigger` - Botão de aba individual
- `TabsContent` - Conteúdo da aba

**Uso**:
```jsx
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'

<Tabs defaultValue="tab1">
  <TabsList>
    <TabsTrigger value="tab1">Aba 1</TabsTrigger>
    <TabsTrigger value="tab2">Aba 2</TabsTrigger>
  </TabsList>
  <TabsContent value="tab1">
    <p>Conteúdo da Aba 1</p>
  </TabsContent>
  <TabsContent value="tab2">
    <p>Conteúdo da Aba 2</p>
  </TabsContent>
</Tabs>
```

---

### Table (table.jsx)

**Localização**: `src/components/ui/table.jsx`

**Propósito**: Tabelas estilizadas e responsivas

**Componentes**:
- `Table` - Container da tabela
- `TableHeader` - Cabeçalho
- `TableBody` - Corpo da tabela
- `TableFooter` - Rodapé
- `TableRow` - Linha da tabela
- `TableHead` - Célula de cabeçalho
- `TableCell` - Célula de dados
- `TableCaption` - Legenda da tabela

**Uso**:
```jsx
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'

<Table>
  <TableHeader>
    <TableRow>
      <TableHead>Nome</TableHead>
      <TableHead>Status</TableHead>
      <TableHead>Ações</TableHead>
    </TableRow>
  </TableHeader>
  <TableBody>
    {data.map((item) => (
      <TableRow key={item.id}>
        <TableCell>{item.name}</TableCell>
        <TableCell>{item.status}</TableCell>
        <TableCell>
          <Button variant="outline" size="sm">Editar</Button>
        </TableCell>
      </TableRow>
    ))}
  </TableBody>
</Table>
```

---

### Toast (toast.jsx)

**Localização**: `src/components/ui/toast.jsx` e `toaster.jsx`

**Propósito**: Sistema de notificações usando Sonner

**Tipos**:
- Success (verde)
- Error (vermelho) 
- Warning (amarelo)
- Info (azul)
- Loading (com spinner)

**Setup**:
```jsx
// No App.jsx
import { Toaster } from 'sonner'

function App() {
  return (
    <>
      {/* Sua aplicação */}
      <Toaster position="bottom-right" />
    </>
  )
}
```

**Uso**:
```jsx
import { toast } from 'sonner'

// Tipos de toast
toast.success('Sucesso!', { description: 'Operação realizada' })
toast.error('Erro!', { description: 'Algo deu errado' })
toast.warning('Atenção!', { description: 'Verifique os dados' })
toast.info('Informação', { description: 'Nova atualização' })
toast.loading('Carregando...', { id: 'loading-id' })

// Customização
toast('Mensagem custom', {
  duration: 5000,
  action: {
    label: 'Desfazer',
    onClick: () => console.log('Desfazer clicado')
  }
})
```

---

## Outros Componentes UI

### Alert Dialog (alert-dialog.jsx)
**Propósito**: Dialogs para confirmações e alertas

### Badge (badge.jsx)
**Propósito**: Badges de status e labels

### Checkbox (checkbox.jsx)
**Propósito**: Caixas de seleção

### Label (label.jsx)
**Propósito**: Labels para elementos de formulário

### Progress (progress.jsx)
**Propósito**: Barras de progresso

### Scroll Area (scroll-area.jsx)
**Propósito**: Áreas de scroll customizadas

### Separator (separator.jsx)
**Propósito**: Separadores visuais

### Textarea (textarea.jsx)
**Propósito**: Campo de texto multilinhas

### Dropdown Menu (dropdown-menu.jsx)
**Propósito**: Menus dropdown complexos

## Padrões de Uso

### Composição de Componentes

```jsx
// Exemplo complexo combinando múltiplos componentes
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'

const DeviceCard = ({ device }) => (
  <Card>
    <CardHeader>
      <div className="flex justify-between items-start">
        <CardTitle>{device.name}</CardTitle>
        <Badge variant={device.online ? 'success' : 'destructive'}>
          {device.online ? 'Online' : 'Offline'}
        </Badge>
      </div>
    </CardHeader>
    <Separator />
    <CardContent className="pt-4">
      <p className="text-sm text-muted-foreground mb-4">
        IP: {device.ip} | Uptime: {device.uptime}
      </p>
      <div className="flex gap-2">
        <Button variant="outline" size="sm">Configurar</Button>
        <Button variant="outline" size="sm">Logs</Button>
      </div>
    </CardContent>
  </Card>
)
```

### Temas e Customização

Todos os componentes suportam o sistema de temas via CSS variables:

```css
:root {
  --background: 0 0% 100%;
  --foreground: 240 10% 3.9%;
  --primary: 240 5.9% 10%;
  --primary-foreground: 0 0% 98%;
  /* ... outras variáveis */
}

.dark {
  --background: 240 10% 3.9%;
  --foreground: 0 0% 98%;
  --primary: 0 0% 98%;
  --primary-foreground: 240 5.9% 10%;
  /* ... outras variáveis */
}
```

## Performance e Otimização

### Code Splitting
Componentes UI são bundle separadamente para otimização:

```javascript
// vite.config.js
export default {
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          ui: ['@radix-ui/react-slot', 'class-variance-authority', 'clsx', 'tailwind-merge']
        }
      }
    }
  }
}
```

### Tree Shaking
Importe apenas os componentes necessários:

```jsx
// ✅ Bom - imports específicos
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'

// ❌ Evitar - import genérico
import * as UI from '@/components/ui'
```

## Links Relacionados

- [shadcn/ui Documentation](https://ui.shadcn.com/)
- [Radix UI Primitives](https://www.radix-ui.com/primitives)
- [Componentes de Layout](layout-components.md)
- [Componentes de Formulário](form-components.md)