import React from 'react'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { vi, describe, it, expect, beforeEach, afterEach } from 'vitest'
import { toast } from 'sonner'
import ComponentTemplate from './ComponentTemplate'
import api from '@/lib/api'

// Mock dos módulos externos
vi.mock('sonner', () => ({
  toast: {
    success: vi.fn(),
    error: vi.fn()
  }
}))

vi.mock('@/lib/api', () => ({
  default: {
    getSomeData: vi.fn(),
    performAction: vi.fn(),
    getErrorMessage: vi.fn()
  }
}))

/**
 * Template de teste para componentes AutoCore
 * 
 * Cobre:
 * - Renderização básica
 * - Estados de loading e erro
 * - Interações do usuário
 * - Chamadas de API
 * - Acessibilidade
 */

describe('ComponentTemplate', () => {
  // Dados mock
  const mockData = {
    id: 1,
    name: 'Test Item',
    status: 'active'
  }
  
  const defaultProps = {
    title: 'Test Component',
    isVisible: true,
    onAction: vi.fn(),
    className: 'test-class'
  }
  
  beforeEach(() => {
    // Resetar todos os mocks antes de cada teste
    vi.clearAllMocks()
    
    // Setup padrão dos mocks
    vi.mocked(api.getSomeData).mockResolvedValue(mockData)
    vi.mocked(api.performAction).mockResolvedValue({ success: true })
    vi.mocked(api.getErrorMessage).mockReturnValue('Erro mock')
  })
  
  afterEach(() => {
    vi.clearAllMocks()
  })
  
  describe('Renderização Básica', () => {
    it('deve renderizar o componente com props padrão', async () => {
      render(<ComponentTemplate {...defaultProps} />)
      
      // Verificar se o título é exibido
      expect(screen.getByText('Test Component')).toBeInTheDocument()
      
      // Verificar se a descrição está presente
      expect(screen.getByText('Descrição do componente')).toBeInTheDocument()
      
      // Aguardar carregamento dos dados
      await waitFor(() => {
        expect(screen.getByText('Dados carregados:')).toBeInTheDocument()
      })
    })
    
    it('deve aplicar className customizada', () => {
      const { container } = render(<ComponentTemplate {...defaultProps} />)
      
      const cardElement = container.querySelector('.test-class')
      expect(cardElement).toBeInTheDocument()
    })
    
    it('não deve renderizar quando não visível', () => {
      render(<ComponentTemplate {...defaultProps} isVisible={false} />)
      
      expect(screen.queryByText('Test Component')).not.toBeInTheDocument()
    })
  })
  
  describe('Estados de Carregamento', () => {
    it('deve exibir estado de loading inicial', async () => {
      // Mock para simular loading
      vi.mocked(api.getSomeData).mockImplementation(
        () => new Promise(resolve => setTimeout(() => resolve(mockData), 100))
      )
      
      render(<ComponentTemplate {...defaultProps} />)
      
      // Verificar indicador de loading
      expect(screen.getByText('Carregando...')).toBeInTheDocument()
      
      // Aguardar conclusão do loading
      await waitFor(() => {
        expect(screen.queryByText('Carregando...')).not.toBeInTheDocument()
      })
    })
    
    it('deve exibir loading durante ações', async () => {
      render(<ComponentTemplate {...defaultProps} />)
      
      // Aguardar carregamento inicial
      await waitFor(() => {
        expect(screen.getByText('Executar Ação')).toBeInTheDocument()
      })
      
      // Mock para simular ação lenta
      vi.mocked(api.performAction).mockImplementation(
        () => new Promise(resolve => setTimeout(() => resolve({ success: true }), 100))
      )
      
      const actionButton = screen.getByText('Executar Ação')
      fireEvent.click(actionButton)
      
      // Verificar estado de loading da ação
      expect(screen.getByText('Processando...')).toBeInTheDocument()
      
      await waitFor(() => {
        expect(screen.queryByText('Processando...')).not.toBeInTheDocument()
      })
    })
  })
  
  describe('Estados de Erro', () => {
    it('deve exibir erro quando falha no carregamento inicial', async () => {
      const errorMessage = 'Erro ao carregar dados'
      vi.mocked(api.getSomeData).mockRejectedValue(new Error(errorMessage))
      vi.mocked(api.getErrorMessage).mockReturnValue(errorMessage)
      
      render(<ComponentTemplate {...defaultProps} />)
      
      await waitFor(() => {
        expect(screen.getByText('Erro ao carregar componente')).toBeInTheDocument()
        expect(screen.getByText(errorMessage)).toBeInTheDocument()
      })
      
      // Verificar botão de retry
      expect(screen.getByText('Tentar novamente')).toBeInTheDocument()
    })
    
    it('deve permitir retry após erro', async () => {
      // Primeiro: erro
      vi.mocked(api.getSomeData).mockRejectedValueOnce(new Error('Erro'))
      // Segundo: sucesso
      vi.mocked(api.getSomeData).mockResolvedValueOnce(mockData)
      
      render(<ComponentTemplate {...defaultProps} />)
      
      // Aguardar erro
      await waitFor(() => {
        expect(screen.getByText('Tentar novamente')).toBeInTheDocument()
      })
      
      // Clicar em retry
      const retryButton = screen.getByText('Tentar novamente')
      fireEvent.click(retryButton)
      
      // Aguardar sucesso
      await waitFor(() => {
        expect(screen.getByText('Dados carregados:')).toBeInTheDocument()
      })
    })
  })
  
  describe('Interações', () => {
    beforeEach(async () => {
      render(<ComponentTemplate {...defaultProps} />)
      
      // Aguardar carregamento inicial
      await waitFor(() => {
        expect(screen.getByText('Executar Ação')).toBeInTheDocument()
      })
    })
    
    it('deve executar ação com sucesso', async () => {
      const actionButton = screen.getByText('Executar Ação')
      fireEvent.click(actionButton)
      
      await waitFor(() => {
        expect(api.performAction).toHaveBeenCalledWith(mockData.id)
        expect(toast.success).toHaveBeenCalledWith('Ação realizada com sucesso!')
        expect(defaultProps.onAction).toHaveBeenCalled()
      })
    })
    
    it('deve tratar erro na ação', async () => {
      const errorMessage = 'Erro na ação'
      vi.mocked(api.performAction).mockRejectedValue(new Error(errorMessage))
      vi.mocked(api.getErrorMessage).mockReturnValue(errorMessage)
      
      const actionButton = screen.getByText('Executar Ação')
      fireEvent.click(actionButton)
      
      await waitFor(() => {
        expect(toast.error).toHaveBeenCalledWith('Erro ao realizar ação', {
          description: errorMessage
        })
      })
    })
    
    it('deve atualizar dados', async () => {
      const updateButton = screen.getByText('Atualizar')
      fireEvent.click(updateButton)
      
      await waitFor(() => {
        expect(api.getSomeData).toHaveBeenCalledTimes(2) // Initial + manual refresh
      })
    })
    
    it('deve recarregar dados', async () => {
      const reloadButton = screen.getByText('Recarregar')
      fireEvent.click(reloadButton)
      
      await waitFor(() => {
        expect(api.getSomeData).toHaveBeenCalledTimes(2) // Initial + reload
      })
    })
  })
  
  describe('Acessibilidade', () => {
    it('deve ter labels acessíveis', async () => {
      render(<ComponentTemplate {...defaultProps} />)
      
      await waitFor(() => {
        const actionButton = screen.getByRole('button', { name: /executar ação/i })
        expect(actionButton).toBeInTheDocument()
        
        const updateButton = screen.getByRole('button', { name: /atualizar/i })
        expect(updateButton).toBeInTheDocument()
      })
    })
    
    it('deve ter estrutura semântica correta', () => {
      render(<ComponentTemplate {...defaultProps} />)
      
      // Verificar se usa elementos semânticos adequados
      expect(screen.getByRole('heading', { name: 'Test Component' })).toBeInTheDocument()
    })
    
    it('deve gerenciar foco adequadamente', async () => {
      render(<ComponentTemplate {...defaultProps} />)
      
      await waitFor(() => {
        const actionButton = screen.getByText('Executar Ação')
        actionButton.focus()
        expect(document.activeElement).toBe(actionButton)
      })
    })
  })
  
  describe('Integração', () => {
    it('deve chamar API com parâmetros corretos', async () => {
      render(<ComponentTemplate {...defaultProps} />)
      
      await waitFor(() => {
        expect(api.getSomeData).toHaveBeenCalledTimes(1)
      })
    })
    
    it('deve tratar respostas da API corretamente', async () => {
      const customData = { id: 2, name: 'Custom Data', status: 'inactive' }
      vi.mocked(api.getSomeData).mockResolvedValue(customData)
      
      render(<ComponentTemplate {...defaultProps} />)
      
      await waitFor(() => {
        expect(screen.getByText('Dados carregados:')).toBeInTheDocument()
        expect(screen.getByText(JSON.stringify(customData, null, 2))).toBeInTheDocument()
      })
    })
  })
  
  describe('Props e Comportamentos', () => {
    it('deve usar título customizado', () => {
      const customTitle = 'Título Customizado'
      render(<ComponentTemplate {...defaultProps} title={customTitle} />)
      
      expect(screen.getByText(customTitle)).toBeInTheDocument()
    })
    
    it('deve desabilitar ações quando sem dados', () => {
      vi.mocked(api.getSomeData).mockResolvedValue(null)
      
      render(<ComponentTemplate {...defaultProps} />)
      
      waitFor(() => {
        const actionButton = screen.getByText('Executar Ação')
        expect(actionButton).toBeDisabled()
      })
    })
  })
})

/**
 * Testes de performance (opcional)
 */
describe('ComponentTemplate - Performance', () => {
  it('não deve re-renderizar desnecessariamente', async () => {
    const { rerender } = render(<ComponentTemplate {...defaultProps} />)
    
    await waitFor(() => {
      expect(screen.getByText('Dados carregados:')).toBeInTheDocument()
    })
    
    // Re-render com as mesmas props
    rerender(<ComponentTemplate {...defaultProps} />)
    
    // API não deve ser chamada novamente
    expect(api.getSomeData).toHaveBeenCalledTimes(1)
  })
})

/**
 * Snapshot testing
 */
describe('ComponentTemplate - Snapshots', () => {
  it('deve manter snapshot do estado inicial', async () => {
    const { container } = render(<ComponentTemplate {...defaultProps} />)
    
    await waitFor(() => {
      expect(screen.getByText('Dados carregados:')).toBeInTheDocument()
    })
    
    expect(container.firstChild).toMatchSnapshot()
  })
  
  it('deve manter snapshot do estado de erro', async () => {
    vi.mocked(api.getSomeData).mockRejectedValue(new Error('Erro de snapshot'))
    
    const { container } = render(<ComponentTemplate {...defaultProps} />)
    
    await waitFor(() => {
      expect(screen.getByText('Erro ao carregar componente')).toBeInTheDocument()
    })
    
    expect(container.firstChild).toMatchSnapshot()
  })
})

/**
 * Customizações necessárias para usar este template:
 * 
 * 1. Substituir 'ComponentTemplate' pelo nome do componente real
 * 2. Ajustar os imports para o componente correto
 * 3. Atualizar mockData com dados relevantes
 * 4. Modificar as chamadas de API mockadas
 * 5. Ajustar os seletores de texto/elementos
 * 6. Adicionar testes específicos do domínio
 * 7. Verificar acessibilidade específica
 * 8. Testar edge cases específicos
 * 
 * Exemplo de uso rápido:
 * 
 * ```bash
 * # Copiar template
 * cp docs/templates/test-template.spec.tsx src/components/__tests__/DeviceCard.test.tsx
 * 
 * # Editar arquivo copiado
 * # - Substituir 'ComponentTemplate' por 'DeviceCard'
 * # - Ajustar imports e dados mock
 * # - Adicionar testes específicos
 * 
 * # Executar testes
 * npm run test DeviceCard.test.tsx
 * ```
 */
