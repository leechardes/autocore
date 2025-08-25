# A32 - Agente Fase 1: Correções Críticas (P0)

## 📋 Objetivo
Implementar todas as correções críticas de prioridade P0 identificadas na análise arquitetural, focando em sistema de cores, tipografia e correção de valores em gauges.

## 🎯 Tarefas da Fase 1

### 1. Sistema de Cores do Tema Escuro
- [ ] Atualizar backgroundColor para #0A0A0B (mais sutil que o preto atual)
- [ ] Ajustar surfaceColor para #18181B (cards)
- [ ] Corrigir textSecondary para #A1A1AA (muted)
- [ ] Implementar border colors #27272A
- [ ] Aplicar accent colors corretas

### 2. Sistema de Tipografia
- [ ] Garantir fonte Inter em todo o app
- [ ] Ajustar tamanhos de fonte:
  - titleSmall: 12px (era 11px)
  - bodyMedium: 14px
  - headlineMedium: 32px para valores grandes
- [ ] Implementar letter-spacing:
  - Títulos uppercase: 1.0
  - Texto normal: 0
- [ ] Corrigir font-weights:
  - Títulos: w400 (não w500)
  - Valores: w600

### 3. Correção de Valores em Gauges
- [ ] Implementar método _getCurrentValue corretamente
- [ ] Adicionar formatação com unidades
- [ ] Mostrar "0 km/h", "0 rpm", "0 °C", "0 %"
- [ ] Garantir binding correto com telemetria
- [ ] Remover gauge circular, usar apenas texto

### 4. Estrutura de Cards
- [ ] BorderRadius: 8px (já está correto)
- [ ] Padding interno: 16px
- [ ] Elevation: 0 (flat design)
- [ ] Border: 1px solid #27272A

## 🔧 Implementações Específicas

### 1. theme_model.dart
```dart
static ACTheme defaultDark() => ACTheme(
  primaryColor: const Color(0xFF3B82F6), // blue-500
  backgroundColor: const Color(0xFF0A0A0B), // zinc-950
  surfaceColor: const Color(0xFF18181B), // zinc-900
  textPrimary: const Color(0xFFFAFAFA), // zinc-50
  textSecondary: const Color(0xFFA1A1AA), // zinc-400
  textTertiary: const Color(0xFF71717A), // zinc-500
  borderColor: const Color(0xFF27272A), // zinc-800
  ...
);
```

### 2. app.dart - TextTheme
```dart
textTheme: GoogleFonts.interTextTheme(
  ThemeData.dark().textTheme.copyWith(
    titleSmall: const TextStyle(
      fontSize: 12, // Aumentado de 11
      fontWeight: FontWeight.w400, // Reduzido de w500
      letterSpacing: 1.0, // Para uppercase
    ),
    bodyMedium: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    headlineMedium: const TextStyle(
      fontSize: 32, // Para valores grandes
      fontWeight: FontWeight.w600,
    ),
  ),
),
```

### 3. gauge_item_widget.dart
```dart
Widget build(BuildContext context) {
  final currentValue = _getCurrentValue();
  final displayValue = _formatDisplayValue(currentValue);
  
  return Card(
    elevation: 0, // Flat
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(
        color: theme.colorScheme.outline, // #27272A
        width: 1,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título uppercase pequeno
          Text(
            item.title.toUpperCase(),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.textTheme.bodySmall?.color,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          // Valor grande com unidade
          Text(
            displayValue,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

String _formatDisplayValue(double? value) {
  final val = value ?? 0;
  final formatted = val.toStringAsFixed(item.decimalPlaces ?? 0);
  return '$formatted ${item.unit ?? ''}';
}
```

## ✅ Checklist de Validação

### Cores
- [ ] Background geral: #0A0A0B
- [ ] Cards: #18181B
- [ ] Borders: #27272A
- [ ] Texto primário: #FAFAFA
- [ ] Texto secundário: #A1A1AA

### Tipografia
- [ ] Fonte Inter aplicada
- [ ] Títulos: 12px, w400, uppercase, letter-spacing 1.0
- [ ] Valores: 32px, w600
- [ ] Corpo: 14px, w400

### Gauges
- [ ] Mostram valores formatados
- [ ] Incluem unidades
- [ ] Layout vertical simples
- [ ] Sem gauge circular

### Cards
- [ ] Border radius 8px
- [ ] Border 1px #27272A
- [ ] Padding 16px
- [ ] Elevation 0

## 📊 Métricas de Sucesso
- Visual mais próximo do React
- Valores aparecem em todos os gauges
- Tipografia consistente
- Cores suaves do tema escuro

## ⏱️ Tempo Estimado
13 horas de implementação

---

**Tipo**: Agente de Implementação Fase 1
**Prioridade**: P0 - Crítica
**Dependências**: A31-VISUAL-ARCHITECTURE-ANALYSIS