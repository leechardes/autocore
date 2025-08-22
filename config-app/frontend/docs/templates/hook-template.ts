import { useState, useEffect, useCallback, useRef } from 'react'
import { toast } from 'sonner'
import api from '@/lib/api'

/**
 * Template para custom hooks AutoCore
 * 
 * @param initialValue - Valor inicial dos dados
 * @param options - Opções de configuração do hook
 */

interface UseTemplateHookOptions {
  autoFetch?: boolean
  refreshInterval?: number
  onError?: (error: Error) => void
  onSuccess?: (data: any) => void
}

interface UseTemplateHookReturn<T> {
  // Estado dos dados
  data: T | null
  loading: boolean
  error: string | null
  
  // Ações
  fetch: () => Promise<T | null>
  refetch: () => Promise<T | null>
  reset: () => void
  
  // Utilitários
  isLoading: boolean
  hasData: boolean
  hasError: boolean
}

const useTemplateHook = <T = any>(
  initialValue: T | null = null,
  options: UseTemplateHookOptions = {}
): UseTemplateHookReturn<T> => {
  
  // Destructure options com defaults
  const {
    autoFetch = false,
    refreshInterval,
    onError,
    onSuccess
  } = options
  
  // Estado principal
  const [data, setData] = useState<T | null>(initialValue)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  
  // Ref para controlar intervals
  const intervalRef = useRef<NodeJS.Timeout | null>(null)
  const mountedRef = useRef(true)
  
  // Cleanup no unmount
  useEffect(() => {
    return () => {
      mountedRef.current = false
      if (intervalRef.current) {
        clearInterval(intervalRef.current)
      }
    }
  }, [])
  
  // Função principal de fetch
  const fetchData = useCallback(async (): Promise<T | null> => {
    if (!mountedRef.current) return null
    
    setLoading(true)
    setError(null)
    
    try {
      // Substituir pela chamada correta da API
      const result = await api.getSomeData() as T
      
      if (mountedRef.current) {
        setData(result)
        onSuccess?.(result)
      }
      
      return result
      
    } catch (err) {
      const errorMessage = api.getErrorMessage(err)
      
      if (mountedRef.current) {
        setError(errorMessage)
        onError?.(err as Error)
        
        // Toast opcional para erros
        toast.error('Erro ao carregar dados', {
          description: errorMessage
        })
      }
      
      return null
      
    } finally {
      if (mountedRef.current) {
        setLoading(false)
      }
    }
  }, [onError, onSuccess])
  
  // Função de refetch (limpa dados primeiro)
  const refetch = useCallback(async (): Promise<T | null> => {
    setData(null)
    return fetchData()
  }, [fetchData])
  
  // Função de reset
  const reset = useCallback(() => {
    setData(initialValue)
    setError(null)
    setLoading(false)
  }, [initialValue])
  
  // Auto fetch inicial
  useEffect(() => {
    if (autoFetch) {
      fetchData()
    }
  }, [autoFetch, fetchData])
  
  // Intervalo de refresh
  useEffect(() => {
    if (refreshInterval && refreshInterval > 0) {
      intervalRef.current = setInterval(() => {
        if (!loading && mountedRef.current) {
          fetchData()
        }
      }, refreshInterval)
      
      return () => {
        if (intervalRef.current) {
          clearInterval(intervalRef.current)
        }
      }
    }
  }, [refreshInterval, loading, fetchData])
  
  // Computed values
  const isLoading = loading
  const hasData = data !== null
  const hasError = error !== null
  
  return {
    // Estado
    data,
    loading,
    error,
    
    // Ações
    fetch: fetchData,
    refetch,
    reset,
    
    // Utilitários
    isLoading,
    hasData,
    hasError
  }
}

export default useTemplateHook

/**
 * Exemplo de uso:
 * 
 * ```typescript
 * import useTemplateHook from './useTemplateHook'
 * 
 * interface Device {
 *   id: number
 *   name: string
 *   online: boolean
 * }
 * 
 * const DevicesPage = () => {
 *   const { 
 *     data: devices, 
 *     loading, 
 *     error, 
 *     refetch 
 *   } = useTemplateHook<Device[]>([], {
 *     autoFetch: true,
 *     refreshInterval: 30000, // 30 segundos
 *     onSuccess: (data) => console.log('Dispositivos carregados:', data),
 *     onError: (error) => console.error('Erro:', error)
 *   })
 *   
 *   if (loading) return <div>Carregando...</div>
 *   if (error) return <div>Erro: {error}</div>
 *   
 *   return (
 *     <div>
 *       <button onClick={refetch}>Atualizar</button>
 *       {devices?.map(device => (
 *         <div key={device.id}>{device.name}</div>
 *       ))}
 *     </div>
 *   )
 * }
 * ```
 * 
 * Customizações necessárias:
 * 1. Substituir `api.getSomeData()` pela chamada correta
 * 2. Ajustar tipos TypeScript conforme necessário
 * 3. Implementar lógica específica do domínio
 * 4. Adicionar validações customizadas
 * 5. Implementar cache se necessário
 * 6. Adicionar métodos específicos (create, update, delete)
 */

/**
 * Variação para hooks com CRUD completo:
 */

interface UseCrudHookReturn<T> extends UseTemplateHookReturn<T[]> {
  create: (item: Omit<T, 'id'>) => Promise<T | null>
  update: (id: number | string, updates: Partial<T>) => Promise<T | null>
  remove: (id: number | string) => Promise<boolean>
  findById: (id: number | string) => T | undefined
}

export const useCrudHook = <T extends { id: number | string }>(
  endpoint: string,
  options: UseTemplateHookOptions = {}
): UseCrudHookReturn<T> => {
  
  const baseHook = useTemplateHook<T[]>([], options)
  
  const create = useCallback(async (item: Omit<T, 'id'>): Promise<T | null> => {
    try {
      const newItem = await api.post(endpoint, item) as T
      toast.success('Item criado com sucesso!')
      baseHook.refetch()
      return newItem
    } catch (err) {
      toast.error('Erro ao criar item')
      return null
    }
  }, [endpoint, baseHook])
  
  const update = useCallback(async (id: number | string, updates: Partial<T>): Promise<T | null> => {
    try {
      const updatedItem = await api.patch(`${endpoint}/${id}`, updates) as T
      toast.success('Item atualizado com sucesso!')
      baseHook.refetch()
      return updatedItem
    } catch (err) {
      toast.error('Erro ao atualizar item')
      return null
    }
  }, [endpoint, baseHook])
  
  const remove = useCallback(async (id: number | string): Promise<boolean> => {
    try {
      await api.delete(`${endpoint}/${id}`)
      toast.success('Item removido com sucesso!')
      baseHook.refetch()
      return true
    } catch (err) {
      toast.error('Erro ao remover item')
      return false
    }
  }, [endpoint, baseHook])
  
  const findById = useCallback((id: number | string): T | undefined => {
    return baseHook.data?.find(item => item.id === id)
  }, [baseHook.data])
  
  return {
    ...baseHook,
    create,
    update,
    remove,
    findById
  }
}
