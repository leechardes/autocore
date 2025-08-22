// AutoCore Flutter Screen Template
// Gerado pelo sistema de agentes AutoCore
// Data: ${DateTime.now().toString().split(' ')[0]}

import 'package:autocore_app/core/extensions/context_extensions.dart';
import 'package:autocore_app/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// [SCREEN_DESCRIPTION]
/// 
/// Esta tela [SCREEN_PURPOSE] e fornece funcionalidades para:
/// - [FEATURE_1]
/// - [FEATURE_2] 
/// - [FEATURE_3]
class [SCREEN_NAME]Screen extends ConsumerStatefulWidget {
  const [SCREEN_NAME]Screen({super.key});

  @override
  ConsumerState<[SCREEN_NAME]Screen> createState() => _[SCREEN_NAME]ScreenState();
}

class _[SCREEN_NAME]ScreenState extends ConsumerState<[SCREEN_NAME]Screen> {
  // Controllers para TextFields (se necessário)
  // late TextEditingController _controller;
  
  // Estado local da tela
  bool _isLoading = false;
  String? _errorMessage;
  
  // Dados da tela
  // List<DataModel> _data = [];

  @override
  void initState() {
    super.initState();
    AppLogger.init('[SCREEN_NAME]Screen');
    
    // Inicializar controllers
    // _controller = TextEditingController();
    
    // Carregar dados iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    // Limpar recursos
    // _controller.dispose();
    AppLogger.dispose('[SCREEN_NAME]Screen');
    super.dispose();
  }

  /// Carrega dados da tela
  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.info('Loading [SCREEN_NAME] data');
      
      // TODO: Implementar carregamento de dados
      // final data = await ref.read([PROVIDER_NAME].notifier).loadData();
      // setState(() {
      //   _data = data;
      // });
      
      AppLogger.info('[SCREEN_NAME] data loaded successfully');
      
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load [SCREEN_NAME] data', 
          error: e, stackTrace: stackTrace);
      
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar dados: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Executa uma ação principal da tela
  Future<void> _executeAction() async {
    if (!mounted) return;

    try {
      AppLogger.userAction('[SCREEN_NAME] action executed');
      
      // TODO: Implementar ação
      // await ref.read([PROVIDER_NAME].notifier).executeAction();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ação executada com sucesso!'),
            backgroundColor: context.successColor,
          ),
        );
      }
      
    } catch (e) {
      AppLogger.error('Failed to execute [SCREEN_NAME] action', error: e);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers se necessário
    // final screenState = ref.watch([PROVIDER_NAME]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('[SCREEN_TITLE]'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Atualizar',
          ),
          // Adicionar mais ações se necessário
          // IconButton(
          //   icon: const Icon(Icons.settings),
          //   onPressed: () => context.go('/settings'),
          //   tooltip: 'Configurações',
          // ),
        ],
      ),
      body: _buildBody(),
      // Adicionar FAB se necessário
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _executeAction,
      //   tooltip: '[ACTION_TOOLTIP]',
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return _buildContent();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.errorColor,
            ),
            SizedBox(height: context.spacingMd),
            Text(
              'Ops! Algo deu errado',
              style: TextStyle(
                fontSize: context.fontSizeLarge,
                fontWeight: context.fontWeightBold,
                color: context.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacingSm),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: context.fontSizeMedium,
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacingLg),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: Implementar conteúdo da tela
          
          // Exemplo de seção
          _buildSection(
            title: 'Seção Exemplo',
            icon: Icons.widgets,
            child: Column(
              children: [
                Text(
                  'Conteúdo da seção aqui',
                  style: TextStyle(
                    fontSize: context.fontSizeMedium,
                    color: context.textPrimary,
                  ),
                ),
                SizedBox(height: context.spacingMd),
                
                // Exemplo de botão de ação
                ElevatedButton(
                  onPressed: _executeAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  child: const Text('Executar Ação'),
                ),
              ],
            ),
          ),
          
          // Adicionar mais seções conforme necessário
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: context.spacingMd),
      child: Padding(
        padding: EdgeInsets.all(context.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: context.primaryColor,
                ),
                SizedBox(width: context.spacingSm),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: context.fontSizeSmall,
                    fontWeight: context.fontWeightBold,
                    color: context.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spacingMd),
            child,
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares adicionais
  
  /// Mostra um diálogo de confirmação
  Future<bool> _showConfirmationDialog(String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmação'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Exibe um SnackBar de feedback
  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? context.errorColor : context.successColor,
        duration: Duration(seconds: isError ? 4 : 2),
        action: isError ? SnackBarAction(
          label: 'OK',
          onPressed: () {},
          textColor: Colors.white,
        ) : null,
      ),
    );
  }
}

// TODO: Implementar provider se necessário
// final [PROVIDER_NAME] = StateNotifierProvider<[NOTIFIER_NAME], [STATE_CLASS]>(
//   (ref) => [NOTIFIER_NAME](),
// );

// TODO: Implementar modelo de estado se necessário  
// @freezed
// class [STATE_CLASS] with _$[STATE_CLASS] {
//   const factory [STATE_CLASS]({
//     @Default(false) bool isLoading,
//     @Default([]) List<DataModel> data,
//     String? error,
//   }) = _[STATE_CLASS];
// }

// TODO: Implementar notifier se necessário
// class [NOTIFIER_NAME] extends StateNotifier<[STATE_CLASS]> {
//   [NOTIFIER_NAME]() : super(const [STATE_CLASS]());
//   
//   Future<void> loadData() async {
//     state = state.copyWith(isLoading: true, error: null);
//     
//     try {
//       // Implementar carregamento
//       final data = await _loadDataFromService();
//       state = state.copyWith(isLoading: false, data: data);
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//     }
//   }
//   
//   Future<void> executeAction() async {
//     // Implementar ação
//   }
// }

/*
INSTRUÇÕES PARA USO DESTE TEMPLATE:

1. SUBSTITUIÇÕES OBRIGATÓRIAS:
   - [SCREEN_NAME] → Nome da tela (ex: Dashboard, Settings, Device)
   - [SCREEN_TITLE] → Título exibido na AppBar (ex: "Painel Principal")  
   - [SCREEN_DESCRIPTION] → Descrição da funcionalidade da tela
   - [SCREEN_PURPOSE] → Propósito principal da tela
   - [FEATURE_1], [FEATURE_2], [FEATURE_3] → Funcionalidades principais
   - [PROVIDER_NAME] → Nome do provider (ex: dashboardProvider)
   - [NOTIFIER_NAME] → Nome da classe notifier
   - [STATE_CLASS] → Nome da classe de estado
   - [ACTION_TOOLTIP] → Tooltip da ação principal

2. CUSTOMIZAÇÕES OPCIONAIS:
   - Adicionar/remover campos de estado local conforme necessário
   - Implementar providers e state management se necessário
   - Customizar layout e componentes específicos
   - Adicionar validações de formulário se aplicável
   - Implementar navegação específica

3. BOAS PRÁTICAS INCLUÍDAS:
   - ✅ Logging completo com AppLogger
   - ✅ Gerenciamento de estado de loading/error
   - ✅ Dispose correto de recursos
   - ✅ Feedback visual consistente
   - ✅ Responsividade via context extensions
   - ✅ Tratamento de erros robusto
   - ✅ Accessibility (Semantics implícita via widgets padrão)
   - ✅ Performance (mounted checks, async safety)

4. INTEGRAÇÃO COM SISTEMA:
   - Este template segue os padrões do sistema AutoCore
   - Utiliza as extensions de context para temas/responsividade
   - Implementa logging padronizado
   - Segue convenções de nomenclatura do projeto

5. TESTES:
   - Criar testes de widget para a nova tela
   - Testar cenários de loading, success e error
   - Verificar navegação e interações do usuário
   - Validar acessibilidade e responsividade

EXEMPLO DE USO:
Para criar uma tela "DeviceControl":
- [SCREEN_NAME] → DeviceControl  
- [SCREEN_TITLE] → "Controle de Dispositivo"
- [PROVIDER_NAME] → deviceControlProvider
- etc.
*/