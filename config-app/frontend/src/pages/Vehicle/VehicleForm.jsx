import React, { useEffect, useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import * as z from 'zod'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
  FormDescription,
} from '@/components/ui/form'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Separator } from '@/components/ui/separator'
import { Badge } from '@/components/ui/badge'
import { 
  ArrowLeft, 
  Save, 
  Car, 
  FileText, 
  Settings, 
  MapPin,
  AlertCircle,
  CheckCircle,
  Loader2
} from 'lucide-react'
import { toast } from 'sonner'
import { default as useVehicleStore } from '@/stores/vehicleStore'
import { useStatusOptions } from '@/components/vehicles/VehicleStatusBadge'

// Schema de validação Zod
const vehicleSchema = z.object({
  plate: z
    .string()
    .min(7, 'Placa deve ter pelo menos 7 caracteres')
    .max(10, 'Placa deve ter no máximo 10 caracteres')
    .regex(
      /^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$/,
      'Formato inválido. Use ABC1D23 (Mercosul) ou ABC-1234 (antigo)'
    )
    .transform(val => val.toUpperCase().replace(/[^A-Z0-9]/g, '')),
  
  chassis: z
    .string()
    .length(17, 'Chassi deve ter exatos 17 caracteres')
    .regex(/^[A-HJ-NPR-Z0-9]{17}$/, 'Chassi contém caracteres inválidos')
    .transform(val => val.toUpperCase()),
  
  renavam: z
    .string()
    .length(11, 'RENAVAM deve ter 11 dígitos')
    .regex(/^[0-9]{11}$/, 'RENAVAM deve conter apenas números'),
  
  brand: z.string().min(1, 'Marca é obrigatória').max(50, 'Marca muito longa'),
  
  model: z.string().min(1, 'Modelo é obrigatório').max(50, 'Modelo muito longo'),
  
  year_manufacture: z
    .number({ required_error: 'Ano de fabricação é obrigatório' })
    .int('Deve ser um número inteiro')
    .min(1900, 'Ano muito antigo')
    .max(new Date().getFullYear(), 'Ano não pode ser futuro'),
  
  year_model: z
    .number({ required_error: 'Ano modelo é obrigatório' })
    .int('Deve ser um número inteiro')
    .min(1900, 'Ano muito antigo')
    .max(new Date().getFullYear() + 1, 'Ano modelo máximo permitido'),
  
  fuel_type: z.enum(['flex', 'gasoline', 'ethanol', 'diesel', 'electric', 'hybrid'], {
    required_error: 'Tipo de combustível é obrigatório'
  }),
  
  status: z.enum(['active', 'maintenance', 'inactive', 'sold', 'accident'], {
    required_error: 'Status é obrigatório'
  }),
  
  color: z.string().max(30, 'Cor muito longa').optional().or(z.literal('')),
  
  transmission: z
    .enum(['manual', 'automatic', 'cvt'])
    .optional()
    .or(z.literal('')),
  
  odometer: z
    .union([z.number().min(0, 'Quilometragem deve ser positiva'), z.literal('')])
    .optional(),
  
  notes: z.string().max(500, 'Observações muito longas').optional().or(z.literal('')),
  
  // Campos opcionais para localização
  latitude: z.union([z.number().min(-90).max(90), z.literal('')]).optional(),
  longitude: z.union([z.number().min(-180).max(180), z.literal('')]).optional()
})

export default function VehicleForm({ vehicle = null, onSave, onCancel }) {
  console.log('[VehicleForm] Componente renderizando...')
  console.log('[VehicleForm] Props recebidas:', { vehicle, onSave, onCancel })
  
  try {
    const { 
      loading, 
      createOrUpdateVehicle
    } = useVehicleStore()
    
    console.log('[VehicleForm] Estado do store:', { loading })
    
    const statusOptions = useStatusOptions()
    console.log('[VehicleForm] Status options:', statusOptions)
  
  const form = useForm({
    resolver: zodResolver(vehicleSchema),
    defaultValues: {
      plate: '',
      chassis: '',
      renavam: '',
      brand: '',
      model: '',
      year_manufacture: new Date().getFullYear(),
      year_model: new Date().getFullYear(),
      fuel_type: 'flex',
      status: 'active',
      color: '',
      transmission: 'manual',
      odometer: 0,
      notes: '',
      latitude: '',
      longitude: ''
    }
  })

  const { reset } = form

  // Carregar dados do veículo para edição
  useEffect(() => {
    if (vehicle) {
      reset({
        plate: vehicle.plate || '',
        chassis: vehicle.chassis || '',
        renavam: vehicle.renavam || '',
        brand: vehicle.brand || '',
        model: vehicle.model || '',
        year_manufacture: vehicle.year_manufacture || new Date().getFullYear(),
        year_model: vehicle.year_model || new Date().getFullYear(),
        fuel_type: vehicle.fuel_type || 'flex',
        status: vehicle.status || 'active',
        color: vehicle.color || '',
        transmission: vehicle.transmission || '',
        odometer: vehicle.odometer || 0,
        notes: vehicle.notes || '',
        latitude: vehicle.latitude || '',
        longitude: vehicle.longitude || ''
      })
    }
  }, [vehicle, reset])

  // Máscaras e formatadores
  const handlePlateChange = (value) => {
    // Remove caracteres especiais e converte para maiúsculas
    const cleaned = value.toUpperCase().replace(/[^A-Z0-9]/g, '')
    
    // Aplica formatação básica
    let formatted = cleaned
    if (cleaned.length > 3) {
      formatted = cleaned.slice(0, 3) + cleaned.slice(3)
    }
    
    return formatted.slice(0, 8) // Limita a 8 caracteres
  }

  const handleRenavamChange = (value) => {
    // Remove tudo que não é número
    return value.replace(/\D/g, '').slice(0, 11)
  }

  const handleChassisChange = (value) => {
    // Remove caracteres inválidos e converte para maiúsculas
    return value.toUpperCase().replace(/[^A-HJ-NPR-Z0-9]/g, '').slice(0, 17)
  }

  const onSubmit = async (data) => {
    try {
      // Converter strings vazias para null
      const processedData = Object.fromEntries(
        Object.entries(data).map(([key, value]) => [
          key, 
          value === '' ? null : value
        ])
      )

      await createOrUpdateVehicle(processedData)
      
      if (onSave) {
        onSave()
      }
    } catch (error) {
      // O erro já é tratado no store
    }
  }

  const fuelTypes = [
    { value: 'flex', label: 'Flex' },
    { value: 'gasoline', label: 'Gasolina' },
    { value: 'ethanol', label: 'Etanol' },
    { value: 'diesel', label: 'Diesel' },
    { value: 'electric', label: 'Elétrico' },
    { value: 'hybrid', label: 'Híbrido' }
  ]

  const transmissionTypes = [
    { value: 'not_informed', label: 'Não informado' },
    { value: 'manual', label: 'Manual' },
    { value: 'automatic', label: 'Automática' },
    { value: 'cvt', label: 'CVT' }
  ]

  const currentYear = new Date().getFullYear()
  const years = Array.from({ length: currentYear - 1950 + 1 }, (_, i) => currentYear - i)

  return (
    <div className="max-w-4xl">
      {/* Header */}
      <div className="mb-6">
        <h2 className="text-2xl font-bold">
          {vehicle ? 'Editar Veículo' : 'Cadastrar Veículo'}
        </h2>
        <p className="text-muted-foreground">
          {vehicle ? 'Atualize as informações do veículo' : 'Cadastre o veículo do sistema'}
        </p>
      </div>

      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
          {/* Identificação */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Car className="h-5 w-5" />
                Identificação do Veículo
              </CardTitle>
              <CardDescription>
                Informações básicas de identificação
              </CardDescription>
            </CardHeader>
            <CardContent className="grid gap-4 md:grid-cols-2">
              <FormField
                control={form.control}
                name="plate"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Placa *</FormLabel>
                    <FormControl>
                      <Input
                        placeholder="ABC1D23"
                        {...field}
                        onChange={(e) => {
                          const formatted = handlePlateChange(e.target.value)
                          field.onChange(formatted)
                        }}
                      />
                    </FormControl>
                    <FormDescription>
                      Formato Mercosul: ABC1D23 ou antigo: ABC-1234
                    </FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="chassis"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Chassi *</FormLabel>
                    <FormControl>
                      <Input
                        placeholder="9BWZZZ377VT004251"
                        {...field}
                        onChange={(e) => {
                          const formatted = handleChassisChange(e.target.value)
                          field.onChange(formatted)
                        }}
                      />
                    </FormControl>
                    <FormDescription>
                      17 caracteres alfanuméricos
                    </FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="renavam"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>RENAVAM *</FormLabel>
                    <FormControl>
                      <Input
                        placeholder="12345678901"
                        {...field}
                        onChange={(e) => {
                          const formatted = handleRenavamChange(e.target.value)
                          field.onChange(formatted)
                        }}
                      />
                    </FormControl>
                    <FormDescription>
                      11 dígitos numéricos
                    </FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="status"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Status *</FormLabel>
                    <Select onValueChange={field.onChange} defaultValue={field.value}>
                      <FormControl>
                        <SelectTrigger>
                          <SelectValue placeholder="Selecione o status" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {statusOptions.map((status) => (
                          <SelectItem key={status.value} value={status.value}>
                            {status.label}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </CardContent>
          </Card>

          {/* Especificações */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Settings className="h-5 w-5" />
                Especificações Técnicas
              </CardTitle>
              <CardDescription>
                Informações técnicas e características
              </CardDescription>
            </CardHeader>
            <CardContent className="grid gap-4 md:grid-cols-2">
              <FormField
                control={form.control}
                name="brand"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Marca *</FormLabel>
                    <FormControl>
                      <Input placeholder="Toyota" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="model"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Modelo *</FormLabel>
                    <FormControl>
                      <Input placeholder="Corolla" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="year_manufacture"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Ano de Fabricação *</FormLabel>
                    <Select 
                      onValueChange={(value) => field.onChange(parseInt(value))}
                      value={field.value?.toString()}
                    >
                      <FormControl>
                        <SelectTrigger>
                          <SelectValue placeholder="Selecione o ano" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {years.map((year) => (
                          <SelectItem key={year} value={year.toString()}>
                            {year}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="year_model"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Ano Modelo *</FormLabel>
                    <Select 
                      onValueChange={(value) => field.onChange(parseInt(value))}
                      value={field.value?.toString()}
                    >
                      <FormControl>
                        <SelectTrigger>
                          <SelectValue placeholder="Selecione o ano" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {years.slice(0, years.length + 1).map((year) => (
                          <SelectItem key={year} value={year.toString()}>
                            {year}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="fuel_type"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Combustível *</FormLabel>
                    <Select onValueChange={field.onChange} defaultValue={field.value}>
                      <FormControl>
                        <SelectTrigger>
                          <SelectValue placeholder="Selecione o combustível" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {fuelTypes.map((fuel) => (
                          <SelectItem key={fuel.value} value={fuel.value}>
                            {fuel.label}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="transmission"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Transmissão</FormLabel>
                    <Select onValueChange={field.onChange} value={field.value}>
                      <FormControl>
                        <SelectTrigger>
                          <SelectValue placeholder="Selecione a transmissão" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {transmissionTypes.map((transmission) => (
                          <SelectItem key={transmission.value} value={transmission.value}>
                            {transmission.label}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="color"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Cor</FormLabel>
                    <FormControl>
                      <Input placeholder="Branco" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="odometer"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Quilometragem Atual</FormLabel>
                    <FormControl>
                      <Input
                        type="number"
                        placeholder="50000"
                        {...field}
                        onChange={(e) => {
                          const value = e.target.value ? parseFloat(e.target.value) : ''
                          field.onChange(value)
                        }}
                      />
                    </FormControl>
                    <FormDescription>
                      Quilometragem atual do veículo
                    </FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </CardContent>
          </Card>

          {/* Localização (Opcional) */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <MapPin className="h-5 w-5" />
                Localização (Opcional)
              </CardTitle>
              <CardDescription>
                Coordenadas GPS do veículo
              </CardDescription>
            </CardHeader>
            <CardContent className="grid gap-4 md:grid-cols-2">
              <FormField
                control={form.control}
                name="latitude"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Latitude</FormLabel>
                    <FormControl>
                      <Input
                        type="number"
                        step="0.000001"
                        placeholder="-23.550520"
                        {...field}
                        onChange={(e) => {
                          const value = e.target.value ? parseFloat(e.target.value) : ''
                          field.onChange(value)
                        }}
                      />
                    </FormControl>
                    <FormDescription>
                      Coordenada de latitude (-90 a 90)
                    </FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="longitude"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Longitude</FormLabel>
                    <FormControl>
                      <Input
                        type="number"
                        step="0.000001"
                        placeholder="-46.633308"
                        {...field}
                        onChange={(e) => {
                          const value = e.target.value ? parseFloat(e.target.value) : ''
                          field.onChange(value)
                        }}
                      />
                    </FormControl>
                    <FormDescription>
                      Coordenada de longitude (-180 a 180)
                    </FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </CardContent>
          </Card>

          {/* Observações */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <FileText className="h-5 w-5" />
                Observações
              </CardTitle>
              <CardDescription>
                Informações adicionais sobre o veículo
              </CardDescription>
            </CardHeader>
            <CardContent>
              <FormField
                control={form.control}
                name="notes"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Notas</FormLabel>
                    <FormControl>
                      <Textarea
                        placeholder="Observações adicionais sobre o veículo..."
                        className="min-h-[100px]"
                        {...field}
                      />
                    </FormControl>
                    <FormDescription>
                      Máximo 500 caracteres
                    </FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </CardContent>
          </Card>

          {/* Ações */}
          <div className="flex justify-end gap-4">
            <Button
              type="button"
              variant="outline"
              onClick={onCancel}
              disabled={loading}
            >
              Cancelar
            </Button>
            <Button
              type="submit"
              disabled={loading}
              className="min-w-[120px]"
            >
              {loading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  {vehicle ? 'Atualizando...' : 'Salvando...'}
                </>
              ) : (
                <>
                  <Save className="mr-2 h-4 w-4" />
                  {vehicle ? 'Atualizar' : 'Salvar'} Veículo
                </>
              )}
            </Button>
          </div>
        </form>
      </Form>
    </div>
  )
  } catch (error) {
    console.error('[VehicleForm] ERRO ao renderizar:', error)
    console.error('[VehicleForm] Stack trace:', error.stack)
    return (
      <Card className="max-w-4xl">
        <CardContent className="p-6">
          <div className="text-center">
            <AlertCircle className="h-12 w-12 text-destructive mx-auto mb-4" />
            <h3 className="text-lg font-semibold mb-2">Erro ao carregar formulário</h3>
            <p className="text-muted-foreground mb-4">
              Ocorreu um erro ao carregar o formulário de veículo.
            </p>
            <p className="text-sm text-destructive mb-4">
              {error.message || 'Erro desconhecido'}
            </p>
            <Button onClick={onCancel} variant="outline">
              <ArrowLeft className="mr-2 h-4 w-4" />
              Voltar
            </Button>
          </div>
        </CardContent>
      </Card>
    )
  }
}