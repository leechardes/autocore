# A23 - Correção Completa da Integração com API e Remoção de Dados Mockados

## 📋 Objetivo
Corrigir todos os problemas de integração com API, centralizar endpoints, remover dados mockados e garantir que o app funcione 100% com dados reais do backend.

## 🎯 Tarefas

### 1. Centralizar Endpoints
- [ ] Criar arquivo `lib/core/constants/api_endpoints.dart`
- [ ] Mapear todos endpoints usados no app
- [ ] Migrar para usar `/api/config/full/{device_uuid}`
- [ ] Remover endpoints antigos e desatualizados

### 2. Revisar e Corrigir ApiService
- [ ] Atualizar todos métodos para usar endpoints centralizados
- [ ] Implementar método `getFullConfig(deviceUuid)`
- [ ] Remover todos dados mockados/fallback
- [ ] Adicionar tratamento de erro apropriado
- [ ] Garantir que falhas na API impeçam navegação

### 3. Corrigir Tela de Configurações
- [ ] Verificar endpoint de save (`PUT /api/devices/{uuid}`)
- [ ] Implementar feedback visual de sucesso/erro
- [ ] Recarregar dados após save bem-sucedido
- [ ] Validar campos antes de enviar

### 4. Atualizar Dashboard
- [ ] Remover todos dados hardcoded
- [ ] Usar configuração do `/api/config/full`
- [ ] Mostrar loading enquanto busca dados
- [ ] Mostrar erro se API falhar
- [ ] Não permitir navegação sem dados reais

### 5. Verificar ButtonItemWidget
- [ ] Confirmar que está sendo usado nas telas
- [ ] Verificar imports e factory
- [ ] Garantir que mudanças visuais sejam aplicadas

### 6. Implementar ConfigService Correto
- [ ] Usar endpoint `/api/config/full/{device_uuid}`
- [ ] Cache local apenas após sucesso da API
- [ ] Invalidar cache em intervalos apropriados
- [ ] Sincronizar com mudanças do backend

### 7. Quality Assurance
- [ ] Seguir FLUTTER_STANDARDS.md
- [ ] Zero warnings no flutter analyze
- [ ] Executar QA-FLUTTER-COMPREHENSIVE.md
- [ ] Compilar e testar APK

## 🔧 Implementação

### 1. Criar api_endpoints.dart

```dart
class ApiEndpoints {
  static const String baseUrl = 'http://10.0.10.119:8081';
  
  // Configuration
  static String configFull(String deviceUuid) => '/api/config/full/$deviceUuid';
  
  // Devices
  static String deviceDetails(String uuid) => '/api/devices/$uuid';
  static String deviceUpdate(String uuid) => '/api/devices/$uuid';
  static const String devicesList = '/api/devices';
  
  // System
  static const String systemStatus = '/api/status';
  static const String systemInfo = '/api/system/info';
  
  // Screens (deprecated - usar config/full)
  @Deprecated('Use configFull instead')
  static String screenItems(int screenId) => '/api/screens/$screenId/items';
  
  // Commands
  static const String executeCommand = '/api/commands/execute';
  static String relayCommand(String deviceUuid) => '/api/devices/$deviceUuid/relays';
}
```

### 2. Atualizar ApiService

```dart
Future<ConfigFullResponse?> getFullConfig(String deviceUuid) async {
  try {
    final response = await _dio.get(
      ApiEndpoints.configFull(deviceUuid),
    );
    
    if (response.statusCode == 200) {
      return ConfigFullResponse.fromJson(response.data);
    }
    
    // Não retorna dados mockados - falha apropriadamente
    throw ApiException('Failed to load configuration');
  } catch (e) {
    AppLogger.error('Failed to get full config', error: e);
    rethrow; // Propaga erro para UI tratar
  }
}
```

### 3. Remover Dados Mockados

Eliminar TODOS os lugares com dados hardcoded como:
- Listas de screens padrão
- Configurações default
- Itens de tela mockados
- Estados iniciais fixos

### 4. Tratamento de Erros

```dart
class ScreenDetailScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(configProvider);
    
    return configAsync.when(
      data: (config) => _buildScreen(config),
      loading: () => const LoadingScreen(),
      error: (error, stack) => ErrorScreen(
        message: 'Não foi possível carregar configuração',
        onRetry: () => ref.invalidate(configProvider),
      ),
    );
  }
}
```

## ✅ Checklist de Validação

- [ ] Nenhum dado mockado no código
- [ ] Todos endpoints centralizados
- [ ] API failures impedem navegação
- [ ] Save de configurações funciona
- [ ] Feedback visual apropriado
- [ ] Logs claros de sucesso/erro
- [ ] Flutter analyze sem warnings
- [ ] Segue FLUTTER_STANDARDS.md
- [ ] QA completo executado

## 📊 Resultado Esperado

1. App 100% dependente da API real
2. Sem dados falsos/mockados
3. Configurações salvando corretamente
4. Endpoints centralizados e organizados
5. Tratamento de erro apropriado
6. Visual dos botões aplicado corretamente
7. Código limpo e sem warnings

## 🚀 Comandos de Execução

```bash
# 1. Limpar e atualizar
cd app-flutter
flutter clean
flutter pub get

# 2. Verificar código
flutter analyze
dart fix --apply

# 3. Compilar
flutter build apk --debug

# 4. Executar QA
# Rodar QA-FLUTTER-COMPREHENSIVE.md
```

---

**Status**: Pronto para Execução Autônoma
**Prioridade**: CRÍTICA
**Tempo Estimado**: 2-3 horas