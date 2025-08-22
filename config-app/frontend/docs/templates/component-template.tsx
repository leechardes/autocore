import React, { useState, useEffect, useCallback } from 'react'
import { ComponentIcon } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { toast } from 'sonner'
import api from '@/lib/api'

/**
 * Template para componentes AutoCore
 * 
 * @param {Object} props - Propriedades do componente
 * @param {string} props.title - Título do componente
 * @param {boolean} props.isVisible - Visibilidade do componente
 * @param {Function} props.onAction - Callback de ação
 * @param {string} props.className - Classes CSS adicionais
 */
interface ComponentTemplateProps {
  title?: string
  isVisible?: boolean
  onAction?: () => void
  className?: string
}

const ComponentTemplate: React.FC<ComponentTemplateProps> = ({
  title = 'Componente',
  isVisible = true,
  onAction,
  className = ''
}) => {
  // Estado local
  const [data, setData] = useState<any>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  
  // Efeito de inicialização
  useEffect(() => {
    if (isVisible) {
      loadData()
    }
  }, [isVisible])
  
  // Carregar dados da API
  const loadData = useCallback(async () => {
    setLoading(true)
    setError(null)
    
    try {
      const result = await api.getSomeData() // Substituir pelo endpoint correto
      setData(result)
    } catch (err) {
      const errorMessage = api.getErrorMessage(err)
      setError(errorMessage)
      toast.error('Erro ao carregar dados', {
        description: errorMessage
      })
    } finally {
      setLoading(false)
    }
  }, [])
  
  // Handler de ação
  const handleAction = useCallback(async () => {
    if (!data) return
    
    setLoading(true)
    
    try {
      await api.performAction(data.id) // Substituir pelo endpoint correto
      
      toast.success('Ação realizada com sucesso!')
      onAction?.()
      
      // Recarregar dados
      await loadData()
      
    } catch (err) {
      const errorMessage = api.getErrorMessage(err)
      toast.error('Erro ao realizar ação', {
        description: errorMessage
      })
    } finally {
      setLoading(false)
    }
  }, [data, onAction, loadData])
  
  // Não renderizar se não visível
  if (!isVisible) {
    return null
  }
  
  // Estado de loading
  if (loading && !data) {
    return (
      <Card className={className}>
        <CardContent className="p-6">
          <div className="flex items-center justify-center">
            <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent"></div>
            <span className="ml-2 text-sm text-muted-foreground">Carregando...</span>
          </div>
        </CardContent>
      </Card>
    )
  }
  
  // Estado de erro
  if (error && !data) {
    return (
      <Card className={className}>
        <CardContent className="p-6">
          <div className="text-center">
            <p className="text-sm text-destructive mb-2">Erro ao carregar componente</p>
            <p className="text-xs text-muted-foreground mb-4">{error}</p>
            <Button variant="outline" size="sm" onClick={loadData}>
              Tentar novamente
            </Button>
          </div>
        </CardContent>
      </Card>
    )
  }
  
  return (
    <Card className={className}>
      <CardHeader>
        <div className="flex items-center justify-between">
          <div>
            <CardTitle className="flex items-center gap-2">
              <ComponentIcon className="h-5 w-5" />
              {title}
            </CardTitle>
            <CardDescription>
              Descrição do componente
            </CardDescription>
          </div>
          <Button 
            variant="outline" 
            size="sm" 
            onClick={loadData}
            disabled={loading}
          >
            Atualizar
          </Button>
        </div>
      </CardHeader>
      
      <CardContent>
        {/* Conteúdo principal do componente */}
        <div className="space-y-4">
          {data ? (
            <div>
              <h3 className="text-sm font-medium mb-2">Dados carregados:</h3>
              <pre className="text-xs bg-muted p-2 rounded">
                {JSON.stringify(data, null, 2)}
              </pre>
            </div>
          ) : (
            <p className="text-sm text-muted-foreground">
              Nenhum dado disponível
            </p>
          )}
          
          {/* Ações do componente */}
          <div className="flex gap-2">
            <Button 
              onClick={handleAction} 
              disabled={loading || !data}
              size="sm"
            >
              {loading ? 'Processando...' : 'Executar Ação'}
            </Button>
            
            <Button 
              variant="outline" 
              size="sm" 
              onClick={loadData}
              disabled={loading}
            >
              Recarregar
            </Button>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

export default ComponentTemplate

/**
 * Uso do componente:
 * 
 * ```jsx
 * import ComponentTemplate from './ComponentTemplate'
 * 
 * const MyPage = () => {
 *   const handleAction = () => {
 *     console.log('Ação executada!')
 *   }
 *   
 *   return (
 *     <div>
 *       <ComponentTemplate 
 *         title="Meu Componente"
 *         isVisible={true}
 *         onAction={handleAction}
 *         className="mb-4"
 *       />
 *     </div>
 *   )
 * }
 * ```
 * 
 * Customizações necessárias:
 * 1. Substituir `api.getSomeData()` pelo endpoint correto
 * 2. Substituir `api.performAction()` pela ação correta
 * 3. Ajustar a interface `ComponentTemplateProps` conforme necessário
 * 4. Personalizar o conteúdo do CardContent
 * 5. Adicionar validações específicas
 * 6. Implementar estados customizados se necessário
 */
