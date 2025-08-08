import React, { useState, useEffect } from 'react'
import { 
  Settings,
  Plus,
  Edit,
  Trash2,
  Save,
  X,
  Radio,
  ChevronRight,
  Hash,
  Binary,
  Calculator,
  Gauge,
  AlertCircle,
  Database,
  Upload,
  TrendingUp,
  Zap
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Switch } from '@/components/ui/switch'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import api from '@/lib/api'

const CANParametersPage = () => {
  const [signals, setSignals] = useState([])
  const [loading, setLoading] = useState(true)
  const [selectedCategory, setSelectedCategory] = useState('all')
  const [isDialogOpen, setIsDialogOpen] = useState(false)
  const [editingSignal, setEditingSignal] = useState(null)
  const [formData, setFormData] = useState({
    signal_name: '',
    can_id: '',
    start_bit: 0,
    length_bits: 8,
    byte_order: 'big_endian',
    data_type: 'unsigned',
    scale_factor: 1.0,
    offset: 0.0,
    unit: '',
    min_value: 0,
    max_value: 100,
    description: '',
    category: 'motor',
    is_active: true
  })

  const categories = [
    { value: 'all', label: 'Todos', icon: Radio },
    { value: 'motor', label: 'Motor', icon: Settings },
    { value: 'combustivel', label: 'Combustível', icon: Gauge },
    { value: 'eletrico', label: 'Elétrico', icon: Zap },
    { value: 'pressoes', label: 'Pressões', icon: Gauge },
    { value: 'velocidade', label: 'Velocidade', icon: TrendingUp }
  ]

  const byteOrders = [
    { value: 'big_endian', label: 'Big Endian (Motorola)' },
    { value: 'little_endian', label: 'Little Endian (Intel)' }
  ]

  const dataTypes = [
    { value: 'unsigned', label: 'Unsigned Integer' },
    { value: 'signed', label: 'Signed Integer' },
    { value: 'float', label: 'Float (IEEE 754)' },
    { value: 'boolean', label: 'Boolean' }
  ]

  useEffect(() => {
    loadSignals()
  }, [selectedCategory])

  const loadSignals = async () => {
    setLoading(true)
    try {
      const category = selectedCategory === 'all' ? null : selectedCategory
      const data = await api.getCANSignals(category)
      setSignals(data)
    } catch (error) {
      console.error('Erro ao carregar sinais CAN:', error)
    } finally {
      setLoading(false)
    }
  }

  const seedDefaultSignals = async () => {
    try {
      const response = await api.seedCANSignals()
      alert(response.message)
      loadSignals()
    } catch (error) {
      console.error('Erro ao popular sinais:', error)
      alert('Erro ao popular sinais padrão')
    }
  }

  const handleOpenDialog = (signal = null) => {
    if (signal) {
      setEditingSignal(signal)
      setFormData(signal)
    } else {
      setEditingSignal(null)
      setFormData({
        signal_name: '',
        can_id: '',
        start_bit: 0,
        length_bits: 8,
        byte_order: 'big_endian',
        data_type: 'unsigned',
        scale_factor: 1.0,
        offset: 0.0,
        unit: '',
        min_value: 0,
        max_value: 100,
        description: '',
        category: 'motor',
        is_active: true
      })
    }
    setIsDialogOpen(true)
  }

  const handleSave = async () => {
    try {
      if (editingSignal) {
        await api.updateCANSignal(editingSignal.id, formData)
      } else {
        await api.createCANSignal(formData)
      }
      setIsDialogOpen(false)
      loadSignals()
    } catch (error) {
      console.error('Erro ao salvar sinal:', error)
      alert(error.message || 'Erro ao salvar sinal')
    }
  }

  const handleDelete = async (id) => {
    if (confirm('Tem certeza que deseja remover este sinal?')) {
      try {
        await api.deleteCANSignal(id)
        loadSignals()
      } catch (error) {
        console.error('Erro ao deletar sinal:', error)
        alert('Erro ao deletar sinal')
      }
    }
  }

  const getCategoryIcon = (category) => {
    const cat = categories.find(c => c.value === category)
    return cat ? cat.icon : Radio
  }

  const getCategoryColor = (category) => {
    const colors = {
      motor: 'bg-blue-500',
      combustivel: 'bg-green-500',
      eletrico: 'bg-yellow-500',
      pressoes: 'bg-purple-500',
      velocidade: 'bg-orange-500'
    }
    return colors[category] || 'bg-gray-500'
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Parâmetros CAN Bus</h1>
          <p className="text-muted-foreground">
            Configure os sinais CAN para telemetria da ECU
          </p>
        </div>
        
        <div className="flex items-center space-x-2">
          {signals.length === 0 && (
            <Button variant="outline" onClick={seedDefaultSignals}>
              <Database className="mr-2 h-4 w-4" />
              Popular Padrão FuelTech
            </Button>
          )}
          <Button onClick={() => handleOpenDialog()}>
            <Plus className="mr-2 h-4 w-4" />
            Novo Sinal
          </Button>
        </div>
      </div>

      {/* Alert Info */}
      <Alert>
        <AlertCircle className="h-4 w-4" />
        <AlertDescription>
          Configure os sinais CAN que serão lidos da ECU FuelTech. 
          Cada sinal representa um parâmetro específico como RPM, temperatura, pressão, etc.
        </AlertDescription>
      </Alert>

      {/* Filtros */}
      <Card>
        <CardHeader>
          <CardTitle>Categorias</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex flex-wrap gap-2">
            {categories.map((cat) => {
              const Icon = cat.icon
              const count = cat.value === 'all' 
                ? signals.length 
                : signals.filter(s => s.category === cat.value).length
              
              return (
                <Button
                  key={cat.value}
                  variant={selectedCategory === cat.value ? "default" : "outline"}
                  size="sm"
                  onClick={() => setSelectedCategory(cat.value)}
                >
                  <Icon className="mr-2 h-4 w-4" />
                  {cat.label}
                  <Badge variant="secondary" className="ml-2">
                    {count}
                  </Badge>
                </Button>
              )
            })}
          </div>
        </CardContent>
      </Card>

      {/* Tabela de Sinais */}
      <Card>
        <CardHeader>
          <CardTitle>Sinais Configurados</CardTitle>
          <CardDescription>
            {signals.length} sinais CAN configurados no sistema
          </CardDescription>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="text-center py-8 text-muted-foreground">
              Carregando sinais...
            </div>
          ) : signals.length === 0 ? (
            <div className="text-center py-8">
              <Radio className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
              <p className="text-muted-foreground mb-4">
                Nenhum sinal CAN configurado
              </p>
              <Button onClick={seedDefaultSignals}>
                <Upload className="mr-2 h-4 w-4" />
                Carregar Sinais Padrão
              </Button>
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Nome</TableHead>
                  <TableHead>CAN ID</TableHead>
                  <TableHead>Bits</TableHead>
                  <TableHead>Unidade</TableHead>
                  <TableHead>Range</TableHead>
                  <TableHead>Categoria</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="text-right">Ações</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {signals.map((signal) => {
                  const Icon = getCategoryIcon(signal.category)
                  return (
                    <TableRow key={signal.id}>
                      <TableCell className="font-medium">
                        <div>
                          <div className="font-medium">{signal.signal_name}</div>
                          <div className="text-sm text-muted-foreground">
                            {signal.description}
                          </div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <Badge variant="outline">
                          {signal.can_id}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <div className="text-sm">
                          <div>Start: {signal.start_bit}</div>
                          <div>Len: {signal.length_bits}</div>
                        </div>
                      </TableCell>
                      <TableCell>{signal.unit || '-'}</TableCell>
                      <TableCell>
                        <div className="text-sm">
                          {signal.min_value} - {signal.max_value}
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          <div className={`h-2 w-2 rounded-full ${getCategoryColor(signal.category)}`} />
                          <span className="text-sm capitalize">{signal.category}</span>
                        </div>
                      </TableCell>
                      <TableCell>
                        <Badge variant={signal.is_active ? "default" : "secondary"}>
                          {signal.is_active ? 'Ativo' : 'Inativo'}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex items-center justify-end gap-2">
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleOpenDialog(signal)}
                          >
                            <Edit className="h-4 w-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleDelete(signal.id)}
                          >
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  )
                })}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      {/* Dialog de Edição/Criação */}
      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>
              {editingSignal ? 'Editar Sinal CAN' : 'Novo Sinal CAN'}
            </DialogTitle>
            <DialogDescription>
              Configure os parâmetros do sinal CAN
            </DialogDescription>
          </DialogHeader>

          <div className="grid gap-4 py-4">
            {/* Informações Básicas */}
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="signal_name">Nome do Sinal</Label>
                <Input
                  id="signal_name"
                  value={formData.signal_name}
                  onChange={(e) => setFormData({...formData, signal_name: e.target.value})}
                  placeholder="Ex: RPM, TPS, ECT"
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="category">Categoria</Label>
                <Select
                  value={formData.category}
                  onValueChange={(value) => setFormData({...formData, category: value})}
                >
                  <SelectTrigger id="category">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {categories.filter(c => c.value !== 'all').map(cat => (
                      <SelectItem key={cat.value} value={cat.value}>
                        {cat.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>

            {/* CAN Configuration */}
            <div className="grid grid-cols-3 gap-4">
              <div className="space-y-2">
                <Label htmlFor="can_id">CAN ID (Hex)</Label>
                <Input
                  id="can_id"
                  value={formData.can_id}
                  onChange={(e) => setFormData({...formData, can_id: e.target.value})}
                  placeholder="0x100"
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="start_bit">Start Bit</Label>
                <Input
                  id="start_bit"
                  type="number"
                  value={formData.start_bit}
                  onChange={(e) => setFormData({...formData, start_bit: parseInt(e.target.value)})}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="length_bits">Length (bits)</Label>
                <Input
                  id="length_bits"
                  type="number"
                  value={formData.length_bits}
                  onChange={(e) => setFormData({...formData, length_bits: parseInt(e.target.value)})}
                />
              </div>
            </div>

            {/* Data Format */}
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="byte_order">Byte Order</Label>
                <Select
                  value={formData.byte_order}
                  onValueChange={(value) => setFormData({...formData, byte_order: value})}
                >
                  <SelectTrigger id="byte_order">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {byteOrders.map(order => (
                      <SelectItem key={order.value} value={order.value}>
                        {order.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="data_type">Data Type</Label>
                <Select
                  value={formData.data_type}
                  onValueChange={(value) => setFormData({...formData, data_type: value})}
                >
                  <SelectTrigger id="data_type">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {dataTypes.map(type => (
                      <SelectItem key={type.value} value={type.value}>
                        {type.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>

            {/* Scaling */}
            <div className="grid grid-cols-3 gap-4">
              <div className="space-y-2">
                <Label htmlFor="scale_factor">Scale Factor</Label>
                <Input
                  id="scale_factor"
                  type="number"
                  step="0.001"
                  value={formData.scale_factor}
                  onChange={(e) => setFormData({...formData, scale_factor: parseFloat(e.target.value)})}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="offset">Offset</Label>
                <Input
                  id="offset"
                  type="number"
                  step="0.1"
                  value={formData.offset}
                  onChange={(e) => setFormData({...formData, offset: parseFloat(e.target.value)})}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="unit">Unidade</Label>
                <Input
                  id="unit"
                  value={formData.unit}
                  onChange={(e) => setFormData({...formData, unit: e.target.value})}
                  placeholder="RPM, °C, bar, %"
                />
              </div>
            </div>

            {/* Range */}
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="min_value">Valor Mínimo</Label>
                <Input
                  id="min_value"
                  type="number"
                  step="0.1"
                  value={formData.min_value}
                  onChange={(e) => setFormData({...formData, min_value: parseFloat(e.target.value)})}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="max_value">Valor Máximo</Label>
                <Input
                  id="max_value"
                  type="number"
                  step="0.1"
                  value={formData.max_value}
                  onChange={(e) => setFormData({...formData, max_value: parseFloat(e.target.value)})}
                />
              </div>
            </div>

            {/* Description */}
            <div className="space-y-2">
              <Label htmlFor="description">Descrição</Label>
              <Textarea
                id="description"
                value={formData.description}
                onChange={(e) => setFormData({...formData, description: e.target.value})}
                placeholder="Descrição detalhada do sinal..."
                rows={3}
              />
            </div>

            {/* Active */}
            <div className="flex items-center space-x-2">
              <Switch
                id="is_active"
                checked={formData.is_active}
                onCheckedChange={(checked) => setFormData({...formData, is_active: checked})}
              />
              <Label htmlFor="is_active">Sinal Ativo</Label>
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={() => setIsDialogOpen(false)}>
              <X className="mr-2 h-4 w-4" />
              Cancelar
            </Button>
            <Button onClick={handleSave}>
              <Save className="mr-2 h-4 w-4" />
              {editingSignal ? 'Salvar Alterações' : 'Criar Sinal'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}

export default CANParametersPage