# 🏠 Dashboard Screen - Documentação Detalhada

A tela de Dashboard é o ponto central do aplicativo AutoCore, servindo como hub de navegação e controle principal.

## 📋 Visão Geral

**Arquivo**: `lib/features/dashboard/dashboard_screen.dart`  
**Widget**: `DashboardScreen extends ConsumerStatefulWidget`  
**Provider**: `dashboardProvider`  
**Rota**: `/` (tela inicial do app)

## 🏗️ Arquitetura da Tela

### Estado do Widget

```dart
class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    AppLogger.init('DashboardScreen');
    // Carregamento após construção do widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConfiguration();
    });
  }
}
```

### Provider Integration

O dashboard utiliza Riverpod para gerenciamento de estado:

```dart
final dashboardState = ref.watch(dashboardProvider);

// Carregamento de dados
await ref.read(dashboardProvider.notifier).loadData();

// Execução de macro
await ref.read(dashboardProvider.notifier).executeMacro(id);
```

## 📱 Layout Structure

### AppBar

```dart
AppBar(
  title: const Text('AutoCore'),
  centerTitle: true,
  actions: [
    IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: _loadConfiguration,
    ),
    IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () => context.go('/settings'),
    ),
  ],
);
```

### Body Layout

```
ScrollView
├── Vehicle Card (opcional)
├── Screen Navigation Buttons
└── Quick Actions (Macros)
```

### Emergency FAB

```dart
FloatingActionButton(
  onPressed: _onEmergencyStop,
  backgroundColor: context.errorColor,
  tooltip: 'Parada de Emergência',
  child: const Icon(Icons.stop, size: 32),
);
```

## 🚗 Vehicle Card

### Estrutura de Dados

```dart
final vehicleInfo = dashboardState.vehicleInfo; // Map<String, dynamic>
final systemStatus = dashboardState.systemStatus; // Map<String, dynamic>
```

### Campos Exibidos

1. **Nome do Veículo**: `vehicleInfo['name']`
2. **Modelo**: `vehicleInfo['model']` (opcional)
3. **Status MQTT**: `systemStatus['mqttConnected']`
4. **Bateria**: `systemStatus['battery']['voltage']` + `['level']`
5. **Temperatura**: `systemStatus['temperature']`

### Implementação do Card

```dart
Widget _buildVehicleCard() {
  if (vehicleInfo.isEmpty) {
    return const SizedBox.shrink(); // Esconde se vazio
  }
  
  return Card(
    child: Padding(
      padding: EdgeInsets.all(context.spacingMd),
      child: Column(
        children: [
          const Icon(Icons.directions_car, size: 64),
          Text(vehicleInfo['name'] ?? 'AutoCore Vehicle'),
          // Status indicators row
          _buildStatusIndicators(),
        ],
      ),
    ),
  );
}
```

### Status Indicators

```dart
Widget _buildStatusIndicator(String label, String value, bool isActive) {
  return Column(
    children: [
      Text(
        value,
        style: TextStyle(
          color: isActive ? context.successColor : context.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(label, style: TextStyle(color: context.textTertiary)),
    ],
  );
}
```

## 🎯 Screen Navigation

### Dados dos Screens

```dart
final screens = ref.watch(dashboardProvider).screens; // List<ScreenConfig>
```

### Grid Responsivo

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: context.isMobile ? 2 : 4, // Responsivo
    crossAxisSpacing: context.spacingMd,
    mainAxisSpacing: context.spacingMd,
    childAspectRatio: 1.2,
  ),
  itemBuilder: (context, index) {
    final screen = screens[index];
    return _buildScreenButton(
      screen.id.toString(),
      screen.name,
      _getIconFromName(screen.icon ?? 'widgets'),
    );
  },
);
```

### Screen Button

```dart
Widget _buildScreenButton(String id, String name, IconData icon) {
  return Card(
    child: InkWell(
      onTap: () {
        AppLogger.userAction('Navigate to screen', params: {'screen': id});
        context.go('/screen/$id');
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: context.primaryColor),
          SizedBox(height: context.spacingSm),
          Text(name, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
```

### Mapeamento de Ícones

```dart
IconData _getIconFromName(String name) {
  switch (name.toLowerCase()) {
    case 'lightbulb': return Icons.lightbulb;
    case 'settings_input_component': return Icons.settings_input_component;
    case 'toggle_on': return Icons.toggle_on;
    case 'explore': return Icons.explore;
    case 'security': return Icons.security;
    case 'warning': return Icons.warning;
    default: return Icons.widgets;
  }
}
```

## ⚡ Quick Actions (Macros)

### Dados das Macros

```dart
final macros = ref.watch(dashboardProvider).macros; // List<Macro>
```

### Lista Horizontal

```dart
SizedBox(
  height: 60,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: macros.length,
    itemBuilder: (context, index) {
      final macro = macros[index];
      return _buildMacroButton(macro.id, macro.name, macro.icon ?? '⚡');
    },
  ),
);
```

### Macro Button

```dart
Widget _buildMacroButton(int id, String name, String emoji) {
  return ActionChip(
    onPressed: () async {
      AppLogger.userAction('Execute macro', params: {'macroId': id});
      
      final success = await ref
          .read(dashboardProvider.notifier)
          .executeMacro(id);
      
      // Feedback visual
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Macro executada!' : 'Erro na execução'),
          backgroundColor: success ? context.successColor : context.errorColor,
        ),
      );
    },
    avatar: Text(emoji, style: const TextStyle(fontSize: 20)),
    label: Text(name),
  );
}
```

## 🔄 Estados da UI

### Loading State

```dart
dashboardState.isLoading
    ? const Center(child: CircularProgressIndicator())
    : // Conteúdo normal
```

### Error State (Offline Mode)

```dart
dashboardState.error != null
    ? Center(
        child: Column(
          children: [
            Icon(Icons.cloud_off, size: 64),
            Text('Modo Offline'),
            Text(dashboardState.error!),
            ElevatedButton.icon(
              onPressed: _loadConfiguration,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      )
    : // Conteúdo normal
```

### Success State

Exibe todo o conteúdo: Vehicle Card + Screen Buttons + Quick Actions.

## 🚨 Sistema de Emergência

### Emergency Stop Function

```dart
void _onEmergencyStop() {
  AppLogger.warning('EMERGENCY STOP ACTIVATED');
  
  // TODO: Implementar via HeartbeatService
  // HeartbeatService.instance.emergencyStopAll();
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Parada de Emergência Ativada!'),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ),
  );
}
```

### FAB Positioning

```dart
floatingActionButton: FloatingActionButton(
  onPressed: _onEmergencyStop,
  backgroundColor: context.errorColor,
  tooltip: 'Parada de Emergência',
  child: const Icon(Icons.stop, size: 32),
);
```

## 📊 Logging e Analytics

### Logging de Ações

```dart
// Inicialização
AppLogger.init('DashboardScreen');

// Ações do usuário  
AppLogger.userAction('Navigate to screen', params: {'screen': id});
AppLogger.userAction('Execute macro', params: {'macroId': id});

// Eventos críticos
AppLogger.warning('EMERGENCY STOP ACTIVATED');

// Cleanup
AppLogger.dispose('DashboardScreen');
```

### Performance Tracking

```dart
// Tempo de carregamento
final stopwatch = Stopwatch()..start();
await ref.read(dashboardProvider.notifier).loadData();
AppLogger.performance('Dashboard load time', stopwatch.elapsed);
```

## 🎨 Responsividade

### Breakpoints

```dart
// Grid columns baseado no dispositivo
crossAxisCount: context.isMobile ? 2 : 4

// Espaçamentos responsivos
padding: EdgeInsets.all(context.spacingMd) // Adaptativo
```

### Extension Methods Utilizadas

```dart
// Context extensions para UI responsiva
context.isMobile          // bool
context.spacingMd         // double
context.fontSizeLarge     // double
context.primaryColor      // Color
context.successColor      // Color
context.errorColor        // Color
```

## 🧪 Testing

### Widget Tests

```dart
testWidgets('Dashboard shows vehicle card when data available', (tester) async {
  // Mock data
  final mockProvider = MockDashboardProvider();
  when(mockProvider.vehicleInfo).thenReturn({'name': 'Test Vehicle'});
  
  await tester.pumpWidget(
    ProviderScope(
      overrides: [dashboardProvider.overrideWith(() => mockProvider)],
      child: AutoCoreApp(),
    ),
  );
  
  expect(find.text('Test Vehicle'), findsOneWidget);
  expect(find.byIcon(Icons.directions_car), findsOneWidget);
});

testWidgets('Dashboard handles error state', (tester) async {
  final mockProvider = MockDashboardProvider();
  when(mockProvider.error).thenReturn('Connection failed');
  
  await tester.pumpWidget(createTestApp(mockProvider));
  
  expect(find.text('Modo Offline'), findsOneWidget);
  expect(find.text('Connection failed'), findsOneWidget);
  expect(find.text('Tentar Novamente'), findsOneWidget);
});
```

### Integration Tests

```dart
testWidgets('Dashboard navigation flow', (tester) async {
  await tester.pumpWidget(AutoCoreApp());
  await tester.pumpAndSettle();
  
  // Tap settings button
  await tester.tap(find.byIcon(Icons.settings));
  await tester.pumpAndSettle();
  
  expect(find.text('Configurações'), findsOneWidget);
});
```

## 🚀 Performance

### Otimizações Implementadas

1. **Widget Caching**: Cards são const quando possível
2. **Lazy Loading**: Screens carregam sob demanda
3. **Memory Management**: Dispose correto dos recursos
4. **State Management**: Riverpod otimizado para rebuilds

### Métricas Alvo

- **Initial Load**: < 500ms
- **Navigation**: < 100ms  
- **Macro Execution**: < 200ms
- **Frame Rate**: 60 FPS consistente

## 📝 Notas de Implementação

### TODOs Identificados

```dart
// TODO(autocore): Implementar parada de emergência
// HeartbeatService.instance.emergencyStopAll();
```

### Melhorias Futuras

1. **Animations**: Transições suaves entre estados
2. **Haptic Feedback**: Feedback tátil em ações críticas  
3. **Voice Control**: Comandos de voz para emergência
4. **Widget Customization**: Personalização de layout pelo usuário

---

**Ver também**: 
- [Settings Screen](settings-screens.md)
- [Dynamic Screens](device-screens.md)
- [Widgets Customizados](../widgets/README.md)