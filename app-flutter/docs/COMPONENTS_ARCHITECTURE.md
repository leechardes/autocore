# 🧩 AutoCore Flutter - Arquitetura de Componentes

## 🎯 Visão Geral

Este documento detalha a arquitetura completa do sistema de componentes do AutoCore Flutter, focando na filosofia de **100% tematização** e **máxima reutilização**. Cada componente é projetado para funcionar como CSS para web - totalmente parametrizável através do sistema de temas dinâmico.

### Princípios Arquiteturais

1. **Tematização Universal**: Todo aspecto visual controlado pelo sistema de temas
2. **Composição sobre Herança**: Componentes compostos por partes menores
3. **Responsividade Nativa**: Adaptação automática a diferentes dispositivos
4. **Performance First**: Otimização para 60fps consistente
5. **Acessibilidade Built-in**: Suporte a screen readers e navegação por teclado
6. **Testabilidade**: Cada componente 100% testável

---

## 🏗️ ESTRUTURA DO SISTEMA DE TEMAS

### ACTheme - Modelo Principal

```dart
class ACTheme {
  const ACTheme({
    // === CORES PRINCIPAIS ===
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    
    // === CORES DE ESTADO ===
    required this.stateColors,
    
    // === HIERARQUIA DE TEXTO ===
    required this.textColors,
    
    // === SOMBRAS NEUMÓRFICAS ===
    required this.shadows,
    
    // === SISTEMA DE ESPAÇAMENTO ===
    required this.spacing,
    
    // === RAIOS DE BORDA ===
    required this.borderRadius,
    
    // === TIPOGRAFIA COMPLETA ===
    required this.typography,
    
    // === ANIMAÇÕES E TRANSIÇÕES ===
    required this.animations,
    
    // === OVERRIDES POR DISPOSITIVO ===
    this.deviceOverrides,
    
    // === CONFIGURAÇÕES AVANÇADAS ===
    this.accessibility,
    this.performance,
  });

  // Cores principais
  final Color primaryColor;      // Cor primária da marca
  final Color secondaryColor;    // Cor secundária para acentos
  final Color backgroundColor;   // Background principal
  final Color surfaceColor;      // Cor de superfícies (cards, containers)
  
  // Sistema de cores de estado
  final ACStateColors stateColors;
  
  // Cores de texto hierárquicas
  final ACTextColors textColors;
  
  // Sistema de sombras neumórficas
  final ACNeumorphicShadows shadows;
  
  // Espaçamentos consistentes
  final ACSpacing spacing;
  
  // Raios de borda padronizados
  final ACBorderRadius borderRadius;
  
  // Sistema tipográfico completo
  final ACTypography typography;
  
  // Configurações de animação
  final ACAnimations animations;
  
  // Overrides específicos por dispositivo
  final ACDeviceOverrides? deviceOverrides;
  
  // Configurações de acessibilidade
  final ACAccessibilityConfig? accessibility;
  
  // Otimizações de performance
  final ACPerformanceConfig? performance;
}
```

### ACStateColors - Cores de Estado

```dart
class ACStateColors {
  const ACStateColors({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.disabled,
    
    // Variações automáticas
    Color? successLight,
    Color? successDark,
    Color? warningLight,
    Color? warningDark,
    Color? errorLight,
    Color? errorDark,
    Color? infoLight,
    Color? infoDark,
  }) : 
    successLight = successLight ?? _lighten(success, 0.2),
    successDark = successDark ?? _darken(success, 0.2),
    warningLight = warningLight ?? _lighten(warning, 0.2),
    warningDark = warningDark ?? _darken(warning, 0.2),
    errorLight = errorLight ?? _lighten(error, 0.2),
    errorDark = errorDark ?? _darken(error, 0.2),
    infoLight = infoLight ?? _lighten(info, 0.2),
    infoDark = infoDark ?? _darken(info, 0.2);

  final Color success;       // #32D74B - Verde para sucesso
  final Color warning;       // #FF9500 - Laranja para atenção
  final Color error;         // #FF3B30 - Vermelho para erro
  final Color info;          // #007AFF - Azul para informação
  final Color disabled;      // #8E8E93 - Cinza para desabilitado
  
  // Variações automáticas (light/dark)
  final Color successLight;
  final Color successDark;
  final Color warningLight;
  final Color warningDark;
  final Color errorLight;
  final Color errorDark;
  final Color infoLight;
  final Color infoDark;
  
  // Métodos utilitários
  Color getStateColor(ACComponentState state) {
    switch (state) {
      case ACComponentState.success:
        return success;
      case ACComponentState.warning:
        return warning;
      case ACComponentState.error:
        return error;
      case ACComponentState.info:
        return info;
      case ACComponentState.disabled:
        return disabled;
    }
  }
}
```

### ACNeumorphicShadows - Sistema de Sombras

```dart
class ACNeumorphicShadows {
  const ACNeumorphicShadows({
    required this.elevated,
    required this.depressed,
    required this.subtle,
    required this.strong,
    this.custom = const {},
  });

  // Sombra elevada (botões, cards)
  final List<BoxShadow> elevated;
  
  // Sombra deprimida (inputs, switches pressionados)
  final List<BoxShadow> depressed;
  
  // Sombra sutil (hover states)
  final List<BoxShadow> subtle;
  
  // Sombra forte (dialogs, modals)
  final List<BoxShadow> strong;
  
  // Sombras customizadas por componente
  final Map<String, List<BoxShadow>> custom;
  
  // Factory para criar sombras neumórficas
  static ACNeumorphicShadows create({
    required Color lightColor,
    required Color darkColor,
    double intensity = 1.0,
  }) {
    return ACNeumorphicShadows(
      elevated: [
        BoxShadow(
          color: darkColor.withOpacity(0.5 * intensity),
          offset: Offset(8, 8),
          blurRadius: 16,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: lightColor.withOpacity(0.03 * intensity),
          offset: Offset(-8, -8),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ],
      depressed: [
        BoxShadow(
          color: darkColor.withOpacity(0.5 * intensity),
          offset: Offset(4, 4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: lightColor.withOpacity(0.03 * intensity),
          offset: Offset(-4, -4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ],
      subtle: [
        BoxShadow(
          color: darkColor.withOpacity(0.3 * intensity),
          offset: Offset(4, 4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: lightColor.withOpacity(0.02 * intensity),
          offset: Offset(-4, -4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ],
      strong: [
        BoxShadow(
          color: darkColor.withOpacity(0.7 * intensity),
          offset: Offset(12, 12),
          blurRadius: 24,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: lightColor.withOpacity(0.05 * intensity),
          offset: Offset(-12, -12),
          blurRadius: 24,
          spreadRadius: 0,
        ),
      ],
    );
  }
}
```

---

## 🧩 COMPONENTES BASE REUTILIZÁVEIS

### ACButton - Botão Universal

```dart
class ACButton extends StatefulWidget {
  const ACButton({
    super.key,
    
    // === CALLBACKS ===
    this.onPressed,
    this.onPressedAsync,
    this.onLongPress,
    
    // === CONTEÚDO ===
    this.child,
    this.text,
    this.icon,
    this.trailingIcon,
    
    // === ESTILO VISUAL ===
    this.style,
    this.type = ACButtonType.elevated,
    this.size = ACButtonSize.medium,
    this.variant = ACButtonVariant.primary,
    
    // === ESTADOS ===
    this.isLoading = false,
    this.isDisabled = false,
    this.showLoadingText = true,
    
    // === COMPORTAMENTO ===
    this.hapticFeedback = true,
    this.confirmationRequired = false,
    this.confirmationMessage,
    
    // === RESPONSIVIDADE ===
    this.mobileSize,
    this.tabletSize,
    this.desktopSize,
    
    // === ACESSIBILIDADE ===
    this.semanticLabel,
    this.tooltip,
    
    // === ANIMAÇÃO ===
    this.animationDuration,
    this.animationCurve,
  });

  // Callbacks de ação
  final VoidCallback? onPressed;
  final AsyncCallback? onPressedAsync;
  final VoidCallback? onLongPress;
  
  // Conteúdo do botão
  final Widget? child;
  final String? text;
  final IconData? icon;
  final IconData? trailingIcon;
  
  // Estilo visual
  final ACButtonStyle? style;
  final ACButtonType type;
  final ACButtonSize size;
  final ACButtonVariant variant;
  
  // Estados do botão
  final bool isLoading;
  final bool isDisabled;
  final bool showLoadingText;
  
  // Comportamento
  final bool hapticFeedback;
  final bool confirmationRequired;
  final String? confirmationMessage;
  
  // Responsividade
  final ACButtonSize? mobileSize;
  final ACButtonSize? tabletSize;
  final ACButtonSize? desktopSize;
  
  // Acessibilidade
  final String? semanticLabel;
  final String? tooltip;
  
  // Animação
  final Duration? animationDuration;
  final Curve? animationCurve;

  @override
  State<ACButton> createState() => _ACButtonState();
}

class _ACButtonState extends State<ACButton> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  bool _isPressed = false;
  bool _isHovered = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }
  
  void _initAnimations() {
    final theme = context.acTheme;
    _animationController = AnimationController(
      duration: widget.animationDuration ?? theme.animations.fast,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve ?? theme.animations.curve,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.acTheme;
    final effectiveStyle = _getEffectiveStyle(theme);
    final effectiveSize = _getEffectiveSize(context);
    
    return Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.text,
      enabled: _isEnabled,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: _buildButtonContent(theme, effectiveStyle, effectiveSize),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildButtonContent(ACTheme theme, ACButtonStyle style, ACButtonSize size) {
    return Container(
      constraints: _getConstraints(size),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isEnabled ? _handleTap : null,
          onLongPress: _isEnabled ? _handleLongPress : null,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          borderRadius: BorderRadius.circular(style.borderRadius),
          child: AnimatedContainer(
            duration: theme.animations.fast,
            decoration: _getDecoration(theme, style),
            padding: _getPadding(size),
            child: _buildContent(theme, style, size),
          ),
        ),
      ),
    );
  }
  
  Widget _buildContent(ACTheme theme, ACButtonStyle style, ACButtonSize size) {
    if (_isLoading) {
      return _buildLoadingContent(theme, style, size);
    }
    
    final List<Widget> children = [];
    
    // Ícone principal
    if (widget.icon != null) {
      children.add(Icon(
        widget.icon,
        size: _getIconSize(size),
        color: style.iconColor,
      ));
    }
    
    // Texto
    if (widget.text != null || widget.child != null) {
      if (children.isNotEmpty) {
        children.add(SizedBox(width: theme.spacing.sm));
      }
      
      children.add(
        widget.child ?? Text(
          widget.text!,
          style: _getTextStyle(theme, style, size),
        ),
      );
    }
    
    // Ícone trailing
    if (widget.trailingIcon != null) {
      if (children.isNotEmpty) {
        children.add(SizedBox(width: theme.spacing.sm));
      }
      
      children.add(Icon(
        widget.trailingIcon,
        size: _getIconSize(size),
        color: style.iconColor,
      ));
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
  
  void _handleTap() async {
    if (widget.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    
    if (widget.confirmationRequired) {
      final confirmed = await _showConfirmation();
      if (!confirmed) return;
    }
    
    if (widget.onPressedAsync != null) {
      setState(() => _isLoading = true);
      try {
        await widget.onPressedAsync!();
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      widget.onPressed?.call();
    }
  }
  
  Future<bool> _showConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ACDialog.confirmation(
        title: 'Confirmar Ação',
        message: widget.confirmationMessage ?? 'Tem certeza que deseja continuar?',
      ),
    );
    return result ?? false;
  }
}
```

### ACButtonStyle - Sistema de Estilos

```dart
class ACButtonStyle {
  const ACButtonStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.iconColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.boxShadow,
    this.textStyle,
    this.padding,
    this.minWidth,
    this.minHeight,
    this.gradient,
  });

  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? iconColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final double? minWidth;
  final double? minHeight;
  final Gradient? gradient;
  
  // Factory constructors para diferentes tipos
  static ACButtonStyle elevated(ACTheme theme, ACButtonVariant variant) {
    final color = _getVariantColor(theme, variant);
    return ACButtonStyle(
      backgroundColor: color,
      foregroundColor: _getContrastColor(color),
      borderRadius: theme.borderRadius.medium,
      boxShadow: theme.shadows.elevated,
      textStyle: theme.typography.button,
    );
  }
  
  static ACButtonStyle filled(ACTheme theme, ACButtonVariant variant) {
    final color = _getVariantColor(theme, variant);
    return ACButtonStyle(
      backgroundColor: color,
      foregroundColor: _getContrastColor(color),
      borderRadius: theme.borderRadius.medium,
      textStyle: theme.typography.button,
    );
  }
  
  static ACButtonStyle outlined(ACTheme theme, ACButtonVariant variant) {
    final color = _getVariantColor(theme, variant);
    return ACButtonStyle(
      backgroundColor: Colors.transparent,
      foregroundColor: color,
      borderColor: color,
      borderWidth: 1.5,
      borderRadius: theme.borderRadius.medium,
      textStyle: theme.typography.button,
    );
  }
  
  static ACButtonStyle text(ACTheme theme, ACButtonVariant variant) {
    final color = _getVariantColor(theme, variant);
    return ACButtonStyle(
      backgroundColor: Colors.transparent,
      foregroundColor: color,
      textStyle: theme.typography.button,
    );
  }
  
  // Criação a partir de JSON (configuração dinâmica)
  factory ACButtonStyle.fromJson(Map<String, dynamic> json, ACTheme theme) {
    return ACButtonStyle(
      backgroundColor: _parseColor(json['backgroundColor']),
      foregroundColor: _parseColor(json['foregroundColor']),
      iconColor: _parseColor(json['iconColor']),
      borderColor: _parseColor(json['borderColor']),
      borderWidth: json['borderWidth']?.toDouble(),
      borderRadius: json['borderRadius']?.toDouble() ?? theme.borderRadius.medium,
      textStyle: _parseTextStyle(json['textStyle'], theme),
      padding: _parsePadding(json['padding']),
    );
  }
}

enum ACButtonType {
  elevated,   // Botão elevado com sombra
  filled,     // Botão preenchido sem sombra
  outlined,   // Botão com borda
  text,       // Botão apenas texto
  icon,       // Botão apenas ícone
}

enum ACButtonVariant {
  primary,    // Cor primária do tema
  secondary,  // Cor secundária do tema
  success,    // Verde para confirmações
  warning,    // Laranja para atenção
  error,      // Vermelho para ações destrutivas
  info,       // Azul para informações
  neutral,    // Cinza neutro
}

enum ACButtonSize {
  small,      // 32px altura
  medium,     // 40px altura
  large,      // 48px altura
  extraLarge, // 56px altura
}
```

---

## 🎛️ COMPONENTES DE CONTROLE

### ACControlTile - Tile de Controle Adaptativo

```dart
class ACControlTile extends StatefulWidget {
  const ACControlTile({
    super.key,
    
    // === IDENTIFICAÇÃO ===
    required this.id,
    required this.label,
    this.labelShort,
    this.description,
    
    // === VISUAL ===
    required this.icon,
    this.iconMobile,
    this.iconTablet,
    this.color,
    this.style,
    this.size = ACTileSize.normal,
    
    // === COMPORTAMENTO ===
    required this.type,
    this.value,
    this.min = 0.0,
    this.max = 100.0,
    this.step = 1.0,
    this.onChanged,
    this.onTap,
    this.onLongPress,
    
    // === CONFIRMAÇÃO ===
    this.confirmOnAction = false,
    this.confirmMessage,
    
    // === VISIBILIDADE ===
    this.showOnMobile = true,
    this.showOnTablet = true,
    this.showOnDesktop = true,
    
    // === TAMANHOS ESPECÍFICOS ===
    this.sizeMobile,
    this.sizeTablet,
    this.sizeDesktop,
    
    // === ESTADO ===
    this.isOnline = true,
    this.isLoading = false,
    this.lastUpdate,
    
    // === ACESSIBILIDADE ===
    this.semanticLabel,
    this.semanticHint,
  });

  // Identificação única
  final String id;
  final String label;
  final String? labelShort;     // Label curto para displays pequenos
  final String? description;
  
  // Aparência visual
  final IconData icon;
  final IconData? iconMobile;   // Ícone específico para mobile
  final IconData? iconTablet;   // Ícone específico para tablet
  final Color? color;
  final ACTileStyle? style;
  final ACTileSize size;
  
  // Comportamento do controle
  final ACControlType type;
  final dynamic value;          // Valor atual (bool, double, String)
  final double min;             // Valor mínimo (para sliders)
  final double max;             // Valor máximo (para sliders)
  final double step;            // Passo do controle
  final Function(dynamic value)? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  // Sistema de confirmação
  final bool confirmOnAction;
  final String? confirmMessage;
  
  // Visibilidade por dispositivo
  final bool showOnMobile;
  final bool showOnTablet;
  final bool showOnDesktop;
  
  // Tamanhos específicos por dispositivo
  final ACTileSize? sizeMobile;
  final ACTileSize? sizeTablet;
  final ACTileSize? sizeDesktop;
  
  // Estado do dispositivo
  final bool isOnline;
  final bool isLoading;
  final DateTime? lastUpdate;
  
  // Acessibilidade
  final String? semanticLabel;
  final String? semanticHint;

  @override
  State<ACControlTile> createState() => _ACControlTileState();
}

class _ACControlTileState extends State<ACControlTile> 
    with TickerProviderStateMixin {
  late AnimationController _pressedController;
  late AnimationController _valueController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  
  bool _isPressed = false;
  dynamic _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _initAnimations();
  }
  
  void _initAnimations() {
    final theme = context.acTheme;
    
    _pressedController = AnimationController(
      duration: theme.animations.fast,
      vsync: this,
    );
    
    _valueController = AnimationController(
      duration: theme.animations.normal,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _pressedController,
      curve: theme.animations.curve,
    ));
    
    _colorAnimation = ColorTween(
      begin: widget.color ?? theme.primaryColor,
      end: (widget.color ?? theme.primaryColor).withOpacity(0.8),
    ).animate(_pressedController);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.acTheme;
    final deviceType = context.deviceType;
    
    // Verifica se deve exibir no dispositivo atual
    if (!_shouldShowOnDevice(deviceType)) {
      return const SizedBox.shrink();
    }
    
    final effectiveStyle = _getEffectiveStyle(theme);
    final effectiveSize = _getEffectiveSize(deviceType);
    final effectiveIcon = _getEffectiveIcon(deviceType);
    final effectiveLabel = _getEffectiveLabel(deviceType);
    
    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      hint: widget.semanticHint,
      value: _getSemanticValue(),
      enabled: widget.isOnline && !widget.isLoading,
      child: AnimatedBuilder(
        animation: _pressedController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildTileContent(
              theme, 
              effectiveStyle, 
              effectiveSize, 
              effectiveIcon, 
              effectiveLabel
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildTileContent(
    ACTheme theme,
    ACTileStyle style,
    ACTileSize size,
    IconData icon,
    String label,
  ) {
    return Container(
      constraints: _getTileConstraints(size),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          onLongPress: _handleLongPress,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          borderRadius: BorderRadius.circular(style.borderRadius),
          child: AnimatedContainer(
            duration: theme.animations.fast,
            decoration: _getDecoration(theme, style),
            padding: _getPadding(size),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(theme, style, size, icon),
                SizedBox(height: theme.spacing.sm),
                _buildLabel(theme, style, size, label),
                if (widget.description != null) ...[
                  SizedBox(height: theme.spacing.xs),
                  _buildDescription(theme, style, size),
                ],
                SizedBox(height: theme.spacing.sm),
                _buildControl(theme, style, size),
                if (widget.lastUpdate != null) ...[
                  SizedBox(height: theme.spacing.xs),
                  _buildLastUpdate(theme, style, size),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildControl(ACTheme theme, ACTileStyle style, ACTileSize size) {
    switch (widget.type) {
      case ACControlType.toggle:
        return ACSwitch(
          value: _currentValue as bool? ?? false,
          onChanged: _handleValueChange,
          size: ACTileSize.compact == size ? ACSwitch.small : ACSwitch.medium,
        );
      
      case ACControlType.slider:
        return ACSlider(
          value: (_currentValue as double?) ?? widget.min,
          min: widget.min,
          max: widget.max,
          onChanged: _handleValueChange,
          showValue: true,
        );
      
      case ACControlType.momentary:
        return ACButton(
          onPressed: () => _handleValueChange(true),
          type: ACButtonType.filled,
          size: ACTileSize.compact == size ? ACButtonSize.small : ACButtonSize.medium,
          child: Text('ATIVAR'),
        );
      
      case ACControlType.selector:
        return _buildSelector(theme, style, size);
      
      case ACControlType.display:
        return _buildDisplayValue(theme, style, size);
    }
  }
  
  void _handleValueChange(dynamic newValue) async {
    if (widget.confirmOnAction) {
      final confirmed = await _showConfirmation();
      if (!confirmed) return;
    }
    
    setState(() {
      _currentValue = newValue;
    });
    
    _valueController.forward().then((_) {
      _valueController.reverse();
    });
    
    widget.onChanged?.call(newValue);
  }
}

enum ACControlType {
  toggle,     // Switch on/off
  slider,     // Controle deslizante
  momentary,  // Botão momentâneo
  selector,   // Seletor múltipla escolha
  display,    // Apenas exibição de valor
}

enum ACTileSize {
  compact,    // 80x80
  normal,     // 120x120
  large,      // 160x160
  wide,       // 200x120 (2x1)
  tall,       // 120x200 (1x2)
  grid,       // Ocupa grid completo
}
```

---

## 📊 COMPONENTES DE INDICAÇÃO

### ACGauge - Medidores Universais

```dart
class ACGauge extends StatefulWidget {
  const ACGauge({
    super.key,
    
    // === DADOS ===
    required this.value,
    required this.min,
    required this.max,
    this.targetValue,
    
    // === VISUAL ===
    this.title,
    this.subtitle,
    this.unit,
    this.style,
    this.type = ACGaugeType.circular,
    this.size = ACGaugeSize.medium,
    
    // === ZONAS COLORIDAS ===
    this.ranges,
    this.dangerZone,
    this.warningZone,
    this.optimalZone,
    
    // === COMPORTAMENTO ===
    this.showValue = true,
    this.showTitle = true,
    this.showMinMax = false,
    this.animateChanges = true,
    this.animationDuration,
    
    // === FORMATAÇÃO ===
    this.valueFormatter,
    this.precision = 1,
    
    // === INTERAÇÃO ===
    this.onTap,
    this.onValueChanged,
    
    // === ACESSIBILIDADE ===
    this.semanticLabel,
    this.semanticValue,
  });

  // Valores do gauge
  final double value;
  final double min;
  final double max;
  final double? targetValue;     // Valor objetivo (linha de referência)
  
  // Informações textuais
  final String? title;
  final String? subtitle;
  final String? unit;
  
  // Estilo e tipo
  final ACGaugeStyle? style;
  final ACGaugeType type;
  final ACGaugeSize size;
  
  // Zonas de valores
  final List<ACGaugeRange>? ranges;
  final ACGaugeRange? dangerZone;   // Zona de perigo (vermelho)
  final ACGaugeRange? warningZone;  // Zona de atenção (amarelo)
  final ACGaugeRange? optimalZone;  // Zona ideal (verde)
  
  // Configuração de exibição
  final bool showValue;
  final bool showTitle;
  final bool showMinMax;
  final bool animateChanges;
  final Duration? animationDuration;
  
  // Formatação de valores
  final String Function(double)? valueFormatter;
  final int precision;
  
  // Callbacks
  final VoidCallback? onTap;
  final Function(double)? onValueChanged;
  
  // Acessibilidade
  final String? semanticLabel;
  final String? semanticValue;

  @override
  State<ACGauge> createState() => _ACGaugeState();
}

class _ACGaugeState extends State<ACGauge> 
    with TickerProviderStateMixin {
  late AnimationController _valueController;
  late AnimationController _colorController;
  late Animation<double> _valueAnimation;
  late Animation<Color?> _colorAnimation;
  
  double _displayValue = 0.0;
  Color _currentColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _displayValue = widget.value;
    _currentColor = _getValueColor(widget.value);
  }
  
  void _initAnimations() {
    final theme = context.acTheme;
    
    _valueController = AnimationController(
      duration: widget.animationDuration ?? theme.animations.normal,
      vsync: this,
    );
    
    _colorController = AnimationController(
      duration: theme.animations.fast,
      vsync: this,
    );
    
    _valueAnimation = Tween<double>(
      begin: _displayValue,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _valueController,
      curve: Curves.easeInOutCubic,
    ));
    
    _colorAnimation = ColorTween(
      begin: _currentColor,
      end: _getValueColor(widget.value),
    ).animate(_colorController);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.acTheme;
    final effectiveStyle = widget.style ?? ACGaugeStyle.fromTheme(theme, widget.type);
    
    return Semantics(
      label: widget.semanticLabel ?? widget.title,
      value: widget.semanticValue ?? _formatValue(_displayValue),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          constraints: _getConstraints(widget.size),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.showTitle && widget.title != null) ...[
                _buildTitle(theme, effectiveStyle),
                SizedBox(height: theme.spacing.sm),
              ],
              Expanded(
                child: _buildGaugeByType(theme, effectiveStyle),
              ),
              if (widget.showValue) ...[
                SizedBox(height: theme.spacing.sm),
                _buildValueDisplay(theme, effectiveStyle),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildGaugeByType(ACTheme theme, ACGaugeStyle style) {
    switch (widget.type) {
      case ACGaugeType.circular:
        return _buildCircularGauge(theme, style);
      case ACGaugeType.semicircle:
        return _buildSemicircleGauge(theme, style);
      case ACGaugeType.linear:
        return _buildLinearGauge(theme, style);
      case ACGaugeType.battery:
        return _buildBatteryGauge(theme, style);
      case ACGaugeType.arc:
        return _buildArcGauge(theme, style);
    }
  }
  
  Widget _buildCircularGauge(ACTheme theme, ACGaugeStyle style) {
    return AnimatedBuilder(
      animation: _valueAnimation,
      builder: (context, child) {
        final progress = (_valueAnimation.value - widget.min) / 
                        (widget.max - widget.min);
        
        return CustomPaint(
          painter: CircularGaugePainter(
            progress: progress.clamp(0.0, 1.0),
            backgroundColor: style.backgroundColor,
            progressColor: _colorAnimation.value ?? _currentColor,
            strokeWidth: style.strokeWidth,
            startAngle: style.startAngle,
            sweepAngle: style.sweepAngle,
            ranges: _buildRanges(),
            showTicks: style.showTicks,
            tickCount: style.tickCount,
          ),
          size: Size.infinite,
        );
      },
    );
  }
  
  Widget _buildLinearGauge(ACTheme theme, ACGaugeStyle style) {
    return AnimatedBuilder(
      animation: _valueAnimation,
      builder: (context, child) {
        final progress = (_valueAnimation.value - widget.min) / 
                        (widget.max - widget.min);
        
        return Container(
          height: style.strokeWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(style.strokeWidth / 2),
            color: style.backgroundColor,
          ),
          child: Stack(
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(style.strokeWidth / 2),
                  color: style.backgroundColor.withOpacity(0.3),
                ),
              ),
              // Progress
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(style.strokeWidth / 2),
                    gradient: style.gradient ?? LinearGradient(
                      colors: [
                        _colorAnimation.value ?? _currentColor,
                        (_colorAnimation.value ?? _currentColor).withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
              // Target line
              if (widget.targetValue != null)
                _buildTargetIndicator(theme, style),
            ],
          ),
        );
      },
    );
  }
  
  Color _getValueColor(double value) {
    final theme = context.acTheme;
    
    // Verifica zonas personalizadas
    if (widget.dangerZone?.contains(value) == true) {
      return theme.stateColors.error;
    }
    if (widget.warningZone?.contains(value) == true) {
      return theme.stateColors.warning;
    }
    if (widget.optimalZone?.contains(value) == true) {
      return theme.stateColors.success;
    }
    
    // Verifica ranges customizados
    final range = widget.ranges?.firstWhere(
      (r) => r.contains(value),
      orElse: () => ACGaugeRange(min: 0, max: 0, color: theme.primaryColor),
    );
    
    return range?.color ?? theme.primaryColor;
  }
}

enum ACGaugeType {
  circular,   // Gauge circular completo
  semicircle, // Gauge semicircular
  linear,     // Barra linear
  battery,    // Indicador de bateria
  arc,        // Arco simples
}

enum ACGaugeSize {
  small,      // 60x60
  medium,     // 100x100
  large,      // 140x140
  extraLarge, // 200x200
}

class ACGaugeRange {
  const ACGaugeRange({
    required this.min,
    required this.max,
    required this.color,
    this.label,
  });

  final double min;
  final double max;
  final Color color;
  final String? label;
  
  bool contains(double value) {
    return value >= min && value <= max;
  }
}
```

---

## 🔄 SISTEMA RESPONSIVO E ADAPTATIVO

### ACResponsiveBuilder - Builder Adaptativo

```dart
class ACResponsiveBuilder extends StatelessWidget {
  const ACResponsiveBuilder({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.watch,
    this.tv,
    this.breakpoints,
  });

  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? watch;
  final Widget? tv;
  final ACBreakpoints? breakpoints;

  @override
  Widget build(BuildContext context) {
    final deviceType = context.deviceType;
    final customBreakpoints = breakpoints ?? ACBreakpoints.material();
    
    switch (deviceType) {
      case ACDeviceType.mobile:
        return mobile ?? tablet ?? desktop ?? const SizedBox.shrink();
      case ACDeviceType.tablet:
        return tablet ?? mobile ?? desktop ?? const SizedBox.shrink();
      case ACDeviceType.desktop:
        return desktop ?? tablet ?? mobile ?? const SizedBox.shrink();
      case ACDeviceType.watch:
        return watch ?? mobile ?? const SizedBox.shrink();
      case ACDeviceType.tv:
        return tv ?? desktop ?? tablet ?? const SizedBox.shrink();
    }
  }
}

class ACBreakpoints {
  const ACBreakpoints({
    required this.mobile,
    required this.tablet,
    required this.desktop,
    this.watch = 200,
    this.tv = 1920,
  });

  final double mobile;    // Até 600px
  final double tablet;    // 600px - 1200px
  final double desktop;   // 1200px+
  final double watch;     // Até 200px
  final double tv;        // 1920px+
  
  factory ACBreakpoints.material() {
    return const ACBreakpoints(
      mobile: 600,
      tablet: 1200,
      desktop: 1920,
    );
  }
  
  factory ACBreakpoints.custom({
    double mobile = 600,
    double tablet = 1024,
    double desktop = 1440,
  }) {
    return ACBreakpoints(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

enum ACDeviceType {
  mobile,
  tablet,
  desktop,
  watch,
  tv,
}

// Extension para fácil acesso
extension ACDeviceExtension on BuildContext {
  ACDeviceType get deviceType {
    final width = MediaQuery.of(this).size.width;
    final breakpoints = ACBreakpoints.material();
    
    if (width <= breakpoints.watch) return ACDeviceType.watch;
    if (width <= breakpoints.mobile) return ACDeviceType.mobile;
    if (width <= breakpoints.tablet) return ACDeviceType.tablet;
    if (width <= breakpoints.desktop) return ACDeviceType.desktop;
    return ACDeviceType.tv;
  }
  
  bool get isMobile => deviceType == ACDeviceType.mobile;
  bool get isTablet => deviceType == ACDeviceType.tablet;
  bool get isDesktop => deviceType == ACDeviceType.desktop;
  bool get isWatch => deviceType == ACDeviceType.watch;
  bool get isTV => deviceType == ACDeviceType.tv;
  
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isLandscape => screenWidth > screenHeight;
  bool get isPortrait => screenHeight >= screenWidth;
}
```

---

## 🎨 CSS-LIKE STYLING SYSTEM

### ACStyles - Sistema de Classes

```dart
class ACStyles {
  static const Map<String, ACWidgetStyle> styles = {
    // === BOTÕES ===
    'btn-primary': ACButtonStyle(
      backgroundColor: ACColors.primary,
      foregroundColor: ACColors.onPrimary,
      borderRadius: 12,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
    
    'btn-secondary': ACButtonStyle(
      backgroundColor: ACColors.secondary,
      foregroundColor: ACColors.onSecondary,
      borderRadius: 12,
    ),
    
    'btn-outline': ACButtonStyle(
      backgroundColor: Colors.transparent,
      foregroundColor: ACColors.primary,
      borderColor: ACColors.primary,
      borderWidth: 1.5,
      borderRadius: 12,
    ),
    
    'btn-danger': ACButtonStyle(
      backgroundColor: ACColors.error,
      foregroundColor: ACColors.onError,
      borderRadius: 12,
    ),
    
    // === CONTAINERS ===
    'card-elevated': ACContainerStyle(
      backgroundColor: ACColors.surface,
      borderRadius: 16,
      boxShadow: ACShadows.elevated,
      padding: EdgeInsets.all(16),
    ),
    
    'card-flat': ACContainerStyle(
      backgroundColor: ACColors.surface,
      borderRadius: 8,
      border: Border.all(color: ACColors.outline, width: 1),
      padding: EdgeInsets.all(16),
    ),
    
    'panel-neumorphic': ACContainerStyle(
      backgroundColor: ACColors.surface,
      borderRadius: 20,
      boxShadow: ACShadows.neumorphic,
      padding: EdgeInsets.all(20),
    ),
    
    // === TEXTO ===
    'text-heading': TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: ACColors.onSurface,
    ),
    
    'text-body': TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: ACColors.onSurface,
    ),
    
    'text-caption': TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: ACColors.onSurfaceVariant,
    ),
    
    // === INPUTS ===
    'input-default': ACInputStyle(
      backgroundColor: ACColors.surfaceVariant,
      borderColor: ACColors.outline,
      borderRadius: 12,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    
    'input-error': ACInputStyle(
      backgroundColor: ACColors.errorContainer,
      borderColor: ACColors.error,
      borderRadius: 12,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  };
  
  // Método para aplicar estilo
  static T? getStyle<T extends ACWidgetStyle>(String className) {
    return styles[className] as T?;
  }
  
  // Método para combinar estilos
  static ACWidgetStyle combineStyles(List<String> classNames) {
    ACWidgetStyle combined = ACWidgetStyle.empty();
    
    for (final className in classNames) {
      final style = styles[className];
      if (style != null) {
        combined = combined.merge(style);
      }
    }
    
    return combined;
  }
  
  // Método para aplicar modificadores
  static ACWidgetStyle withModifiers(String baseClass, List<String> modifiers) {
    final base = styles[baseClass];
    if (base == null) return ACWidgetStyle.empty();
    
    ACWidgetStyle modified = base;
    
    for (final modifier in modifiers) {
      final modifierStyle = styles['$baseClass-$modifier'];
      if (modifierStyle != null) {
        modified = modified.merge(modifierStyle);
      }
    }
    
    return modified;
  }
}

// Sistema de cores similar ao CSS
class ACColors {
  // Cores primárias
  static const Color primary = Color(0xFF007AFF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFB3D9FF);
  static const Color onPrimaryContainer = Color(0xFF001E33);
  
  // Cores secundárias
  static const Color secondary = Color(0xFF32D74B);
  static const Color onSecondary = Color(0xFF000000);
  static const Color secondaryContainer = Color(0xFFB8F5C4);
  static const Color onSecondaryContainer = Color(0xFF002106);
  
  // Cores de estado
  static const Color error = Color(0xFFFF3B30);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);
  
  static const Color warning = Color(0xFFFF9500);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFE0B3);
  static const Color onWarningContainer = Color(0xFF2E1800);
  
  // Superfícies
  static const Color surface = Color(0xFF1C1C1E);
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFF2C2C2E);
  static const Color onSurfaceVariant = Color(0xFF8E8E93);
  
  // Background
  static const Color background = Color(0xFF121212);
  static const Color onBackground = Color(0xFFFFFFFF);
  
  // Outline
  static const Color outline = Color(0xFF636366);
  static const Color outlineVariant = Color(0xFF48484A);
}

// Sistema de sombras
class ACShadows {
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> neumorphic = [
    BoxShadow(
      color: Color(0x80000000),
      offset: Offset(8, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0DFFFFFF),
      offset: Offset(-8, -8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];
}
```

---

## 🔧 FACTORY PATTERN PARA WIDGETS DINÂMICOS

### WidgetFactory - Criação Dinâmica

```dart
class WidgetFactory {
  static final Map<String, WidgetBuilder> _builders = {
    'button': _buildButton,
    'switch': _buildSwitch,
    'slider': _buildSlider,
    'gauge': _buildGauge,
    'indicator': _buildIndicator,
    'display': _buildDisplay,
    'container': _buildContainer,
    'text': _buildText,
    'icon': _buildIcon,
    'spacer': _buildSpacer,
    'divider': _buildDivider,
    'image': _buildImage,
    'chart': _buildChart,
    'list': _buildList,
    'grid': _buildGrid,
  };
  
  static Widget build(WidgetConfig config) {
    final builder = _builders[config.type];
    if (builder == null) {
      Logger.warning('Widget type not found: ${config.type}');
      return ErrorWidget('Unknown widget type: ${config.type}');
    }
    
    try {
      return builder(config);
    } catch (e, stackTrace) {
      Logger.error('Error building widget: ${config.type}', e, stackTrace);
      return ErrorWidget('Error building ${config.type}: $e');
    }
  }
  
  static Widget _buildButton(WidgetConfig config) {
    return ACButton(
      onPressed: () => _handleAction(config.action),
      text: config.label,
      icon: _parseIcon(config.icon),
      type: _parseButtonType(config.style?['type']),
      size: _parseButtonSize(config.style?['size']),
      variant: _parseButtonVariant(config.style?['variant']),
      isLoading: config.state?['loading'] ?? false,
      isDisabled: config.state?['disabled'] ?? false,
      confirmationRequired: config.behavior?['confirmRequired'] ?? false,
      confirmationMessage: config.behavior?['confirmMessage'],
      hapticFeedback: config.behavior?['hapticFeedback'] ?? true,
    );
  }
  
  static Widget _buildSwitch(WidgetConfig config) {
    return ACSwitch(
      value: config.value as bool? ?? false,
      onChanged: (value) => _handleValueChange(config, value),
      label: config.label,
      size: _parseSwitchSize(config.style?['size']),
      hapticFeedback: config.behavior?['hapticFeedback'] ?? true,
    );
  }
  
  static Widget _buildGauge(WidgetConfig config) {
    return ACGauge(
      value: (config.value as num?)?.toDouble() ?? 0.0,
      min: (config.min as num?)?.toDouble() ?? 0.0,
      max: (config.max as num?)?.toDouble() ?? 100.0,
      title: config.label,
      unit: config.unit,
      type: _parseGaugeType(config.style?['type']),
      size: _parseGaugeSize(config.style?['size']),
      showValue: config.style?['showValue'] ?? true,
      ranges: _parseGaugeRanges(config.style?['ranges']),
    );
  }
  
  static Widget _buildContainer(WidgetConfig config) {
    final children = <Widget>[];
    
    // Processa children se existirem
    if (config.children != null) {
      for (final childConfig in config.children!) {
        children.add(build(childConfig));
      }
    }
    
    return ACContainer(
      style: _parseContainerStyle(config.style),
      child: config.layout == 'column' 
        ? Column(children: children)
        : config.layout == 'row'
          ? Row(children: children)
          : config.layout == 'stack'
            ? Stack(children: children)
            : children.isNotEmpty 
              ? children.first 
              : const SizedBox.shrink(),
    );
  }
  
  // Handlers para ações
  static void _handleAction(ActionConfig? action) {
    if (action == null) return;
    
    switch (action.type) {
      case 'mqtt_publish':
        _handleMqttPublish(action);
        break;
      case 'navigate':
        _handleNavigation(action);
        break;
      case 'dialog':
        _handleDialog(action);
        break;
      case 'custom':
        _handleCustomAction(action);
        break;
    }
  }
  
  static void _handleValueChange(WidgetConfig config, dynamic value) {
    // Atualiza valor local
    config.value = value;
    
    // Executa ação configurada
    if (config.onChange != null) {
      _handleAction(config.onChange);
    }
    
    // Publica via MQTT se configurado
    if (config.mqttTopic != null) {
      GetIt.instance<MqttService>().publish(
        config.mqttTopic!,
        json.encode({
          'id': config.id,
          'value': value,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    }
  }
  
  // Parsers para diferentes tipos
  static ACButtonType _parseButtonType(String? type) {
    switch (type) {
      case 'elevated': return ACButtonType.elevated;
      case 'filled': return ACButtonType.filled;
      case 'outlined': return ACButtonType.outlined;
      case 'text': return ACButtonType.text;
      case 'icon': return ACButtonType.icon;
      default: return ACButtonType.elevated;
    }
  }
  
  static IconData? _parseIcon(String? iconName) {
    if (iconName == null) return null;
    
    // Mapeamento de ícones comuns
    const iconMap = {
      'lightbulb': Icons.lightbulb,
      'power': Icons.power_settings_new,
      'settings': Icons.settings,
      'home': Icons.home,
      'car': Icons.directions_car,
      'battery': Icons.battery_std,
      'wifi': Icons.wifi,
      'bluetooth': Icons.bluetooth,
      // Adicionar mais ícones conforme necessário
    };
    
    return iconMap[iconName] ?? Icons.help_outline;
  }
}

// Model para configuração de widgets
class WidgetConfig {
  const WidgetConfig({
    required this.id,
    required this.type,
    this.label,
    this.icon,
    this.value,
    this.min,
    this.max,
    this.unit,
    this.style,
    this.behavior,
    this.state,
    this.action,
    this.onChange,
    this.children,
    this.layout,
    this.mqttTopic,
  });

  final String id;
  final String type;
  final String? label;
  final String? icon;
  final dynamic value;
  final dynamic min;
  final dynamic max;
  final String? unit;
  final Map<String, dynamic>? style;
  final Map<String, dynamic>? behavior;
  final Map<String, dynamic>? state;
  final ActionConfig? action;
  final ActionConfig? onChange;
  final List<WidgetConfig>? children;
  final String? layout;
  final String? mqttTopic;
  
  factory WidgetConfig.fromJson(Map<String, dynamic> json) {
    return WidgetConfig(
      id: json['id'],
      type: json['type'],
      label: json['label'],
      icon: json['icon'],
      value: json['value'],
      min: json['min'],
      max: json['max'],
      unit: json['unit'],
      style: json['style'],
      behavior: json['behavior'],
      state: json['state'],
      action: json['action'] != null ? ActionConfig.fromJson(json['action']) : null,
      onChange: json['onChange'] != null ? ActionConfig.fromJson(json['onChange']) : null,
      children: (json['children'] as List?)?.map((e) => WidgetConfig.fromJson(e)).toList(),
      layout: json['layout'],
      mqttTopic: json['mqttTopic'],
    );
  }
}
```

---

## 🎯 PADRÕES DE CÓDIGO E NOMENCLATURA

### Convenções de Nomenclatura

```dart
// === CLASSES DE COMPONENTES ===
// Prefixo AC (AutoCore) + Nome descritivo
class ACButton extends StatefulWidget { }
class ACSwitch extends StatefulWidget { }
class ACGauge extends StatefulWidget { }

// === ESTILOS DE COMPONENTES ===  
// Prefixo AC + Nome do componente + Style
class ACButtonStyle { }
class ACSwitchStyle { }
class ACGaugeStyle { }

// === ENUMS ===
// Prefixo AC + Nome do componente + Propriedade
enum ACButtonType { elevated, filled, outlined }
enum ACButtonSize { small, medium, large }
enum ACButtonVariant { primary, secondary, success }

// === EXTENSÕES ===
// Prefixo AC + Nome + Extension
extension ACThemeExtension on BuildContext { }
extension ACResponsiveExtension on BuildContext { }

// === SERVIÇOS ===
// Nome + Service
class MqttService { }
class ThemeService { }
class StorageService { }

// === MODELOS DE DADOS ===
// Nome sem prefixo para DTOs e models
class DeviceModel { }
class RelayChannel { }
class ScreenConfig { }
```

### Estrutura de Arquivos

```
lib/
├── core/
│   ├── theme/
│   │   ├── ac_theme.dart              # Modelo principal do tema
│   │   ├── theme_provider.dart        # Provider de temas
│   │   ├── theme_extensions.dart      # Extensions no BuildContext
│   │   ├── color_palette.dart         # Paletas de cores
│   │   ├── typography.dart            # Sistema tipográfico
│   │   ├── shadows.dart               # Sombras neumórficas
│   │   └── animations.dart            # Configurações de animação
│   │
│   ├── widgets/
│   │   ├── base/
│   │   │   ├── ac_button.dart         # Botão universal
│   │   │   ├── ac_container.dart      # Container tematizado
│   │   │   ├── ac_text.dart           # Texto com tema
│   │   │   └── ac_icon.dart           # Ícone tematizado
│   │   │
│   │   ├── controls/
│   │   │   ├── ac_switch.dart         # Switch tematizado
│   │   │   ├── ac_slider.dart         # Slider customizado
│   │   │   ├── ac_control_tile.dart   # Tile de controle
│   │   │   └── ac_input_field.dart    # Campo de input
│   │   │
│   │   ├── indicators/
│   │   │   ├── ac_gauge.dart          # Medidores diversos
│   │   │   ├── ac_status_indicator.dart # Indicador de status
│   │   │   ├── ac_progress_bar.dart   # Barra de progresso
│   │   │   └── ac_badge.dart          # Badge de notificação
│   │   │
│   │   ├── layout/
│   │   │   ├── ac_grid.dart           # Grid responsivo
│   │   │   ├── ac_card.dart           # Card neumórfico
│   │   │   ├── ac_header.dart         # Cabeçalho customizado
│   │   │   └── ac_bottom_nav.dart     # Navegação inferior
│   │   │
│   │   └── feedback/
│   │       ├── ac_dialog.dart         # Dialogs diversos
│   │       ├── ac_snackbar.dart       # Snack bars
│   │       ├── ac_loading.dart        # Indicadores de loading
│   │       └── ac_empty_state.dart    # Estado vazio
│   │
│   ├── utils/
│   │   ├── responsive.dart            # Utilities responsivos
│   │   ├── widget_factory.dart        # Factory de widgets
│   │   ├── style_parser.dart          # Parser de estilos
│   │   └── theme_helpers.dart         # Helpers de tema
│   │
│   └── extensions/
│       ├── context_extensions.dart    # Extensions no BuildContext
│       ├── color_extensions.dart      # Extensions em Color
│       └── widget_extensions.dart     # Extensions em Widget
│
└── shared/
    ├── constants/
    │   ├── app_constants.dart         # Constantes da aplicação
    │   ├── style_constants.dart       # Constantes de estilo
    │   └── breakpoints.dart           # Breakpoints responsivos
    │
    └── styles/
        ├── ac_styles.dart             # Sistema CSS-like
        ├── predefined_themes.dart     # Temas predefinidos
        └── style_mixins.dart          # Mixins de estilo
```

### Padrões de Implementação

```dart
// === PADRÃO PARA COMPONENTES BASE ===
class ACComponent extends StatefulWidget {
  const ACComponent({
    super.key,
    // Callbacks primeiro
    this.onTap,
    this.onChanged,
    // Dados depois
    this.value,
    this.label,
    // Estilo por último
    this.style,
    this.size = ComponentSize.medium,
  });

  // Sempre documentar parâmetros públicos
  /// Callback executado quando o componente é tocado
  final VoidCallback? onTap;
  
  /// Valor atual do componente
  final dynamic value;
  
  /// Estilo customizado do componente
  final ComponentStyle? style;

  @override
  State<ACComponent> createState() => _ACComponentState();
}

// === PADRÃO PARA STATE CLASSES ===
class _ACComponentState extends State<ACComponent> 
    with TickerProviderStateMixin {
  // Controllers de animação
  late AnimationController _controller;
  late Animation<double> _animation;
  
  // Estado interno
  bool _isPressed = false;
  dynamic _currentValue;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _currentValue = widget.value;
  }
  
  @override
  void didUpdateWidget(ACComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _updateValue(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.acTheme;
    final style = widget.style ?? ComponentStyle.fromTheme(theme);
    
    return Semantics(
      // Sempre incluir semântica
      label: _getSemanticLabel(),
      value: _getSemanticValue(),
      child: _buildComponent(theme, style),
    );
  }
}

// === PADRÃO PARA STYLES ===
class ComponentStyle {
  const ComponentStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.boxShadow,
  });

  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;
  
  // Factory constructor para criar a partir do tema
  factory ComponentStyle.fromTheme(ACTheme theme) {
    return ComponentStyle(
      backgroundColor: theme.surfaceColor,
      foregroundColor: theme.textColors.primary,
      borderRadius: theme.borderRadius.medium,
      padding: EdgeInsets.all(theme.spacing.md),
      boxShadow: theme.shadows.elevated,
    );
  }
  
  // Método copyWith para modificações
  ComponentStyle copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    List<BoxShadow>? boxShadow,
  }) {
    return ComponentStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      boxShadow: boxShadow ?? this.boxShadow,
    );
  }
  
  // Merge com outro estilo
  ComponentStyle merge(ComponentStyle? other) {
    if (other == null) return this;
    
    return ComponentStyle(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      foregroundColor: other.foregroundColor ?? foregroundColor,
      borderRadius: other.borderRadius ?? borderRadius,
      padding: other.padding ?? padding,
      boxShadow: other.boxShadow ?? boxShadow,
    );
  }
}
```

### Critérios de Qualidade

```dart
// === PERFORMANCE ===
// 1. Use const constructors sempre que possível
const ACButton(child: Text('Static'));

// 2. Use ValueKey para widgets que mudam de posição
ACButton(key: ValueKey(item.id), /* ... */);

// 3. Evite rebuilds desnecessários
class OptimizedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use Selector do provider para escutar apenas mudanças específicas
    return Selector<ThemeProvider, Color>(
      selector: (context, theme) => theme.primaryColor,
      builder: (context, primaryColor, child) {
        return Container(color: primaryColor);
      },
    );
  }
}

// === TESTES ===
// 1. Todo componente público deve ter testes
testWidgets('ACButton should trigger onPressed callback', (tester) async {
  bool pressed = false;
  
  await tester.pumpWidget(
    MaterialApp(
      home: ACButton(
        onPressed: () => pressed = true,
        child: Text('Test'),
      ),
    ),
  );
  
  await tester.tap(find.byType(ACButton));
  expect(pressed, isTrue);
});

// === ACESSIBILIDADE ===
// 1. Sempre incluir semântica apropriada
Semantics(
  label: 'Botão para ligar a luz principal',
  hint: 'Toque duas vezes para ativar',
  button: true,
  enabled: isEnabled,
  child: widget,
);

// === DOCUMENTAÇÃO ===
/// Botão universal do sistema AutoCore.
/// 
/// Este componente suporta múltiplos tipos visuais e é 100% tematizável.
/// Pode ser usado para qualquer ação na interface.
/// 
/// Exemplo de uso:
/// ```dart
/// ACButton(
///   onPressed: () => print('Pressionado'),
///   text: 'Clique aqui',
///   type: ACButtonType.elevated,
/// )
/// ```
class ACButton extends StatefulWidget {
  /// Cria um novo botão AutoCore.
  /// 
  /// O parâmetro [child] ou [text] deve ser fornecido.
  const ACButton({
    super.key,
    this.onPressed,
    this.child,
    this.text,
    // ...
  }) : assert(child != null || text != null, 
             'Either child or text must be provided');
}
```

Esta arquitetura de componentes garante:
- **100% Tematização**: Todos os aspectos visuais controláveis
- **Máxima Reutilização**: Componentes funcionam em qualquer contexto
- **Performance Otimizada**: 60fps consistente
- **Responsividade Total**: Adaptação automática a dispositivos
- **Acessibilidade Nativa**: Suporte completo a screen readers
- **Testabilidade**: Cada componente 100% testável
- **Manutenibilidade**: Código limpo e bem estruturado