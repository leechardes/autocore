import React from 'react'
import { AlertCircle } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props)
    this.state = { hasError: false, error: null, errorInfo: null }
  }

  static getDerivedStateFromError(error) {
    console.error('[ErrorBoundary] Erro capturado:', error)
    return { hasError: true }
  }

  componentDidCatch(error, errorInfo) {
    console.error('[ErrorBoundary] Detalhes do erro:', {
      error: error.toString(),
      stack: error.stack,
      componentStack: errorInfo.componentStack
    })
    
    this.setState({
      error,
      errorInfo
    })
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex items-center justify-center p-4">
          <Card className="max-w-md w-full">
            <CardContent className="p-6">
              <div className="text-center">
                <AlertCircle className="h-12 w-12 text-destructive mx-auto mb-4" />
                <h2 className="text-xl font-bold mb-2">Ops! Algo deu errado</h2>
                <p className="text-muted-foreground mb-4">
                  Ocorreu um erro inesperado na aplicação.
                </p>
                {this.state.error && (
                  <div className="text-left bg-muted p-3 rounded-md mb-4">
                    <p className="text-sm font-mono text-destructive">
                      {this.state.error.toString()}
                    </p>
                  </div>
                )}
                <Button 
                  onClick={() => window.location.reload()}
                  variant="outline"
                >
                  Recarregar Página
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      )
    }

    return this.props.children
  }
}

export default ErrorBoundary