// AutoCore Flutter Widget Template
// Gerado pelo sistema de agentes AutoCore
// Data: ${DateTime.now().toString().split(' ')[0]}

import 'package:autocore_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// [WIDGET_DESCRIPTION]
/// 
/// Este widget fornece [WIDGET_PURPOSE] com as seguintes funcionalidades:
/// - [FEATURE_1]
/// - [FEATURE_2]
/// - [FEATURE_3]
/// 
/// Exemplo de uso:
/// ```dart
/// [WIDGET_NAME](
///   value: currentValue,
///   onChanged: (newValue) => setState(() => currentValue = newValue),
///   label: 'Meu Widget',
/// )
/// ```
class [WIDGET_NAME] extends StatefulWidget {
  /// Callback executado quando o valor é alterado
  final ValueChanged<[VALUE_TYPE]>? onChanged;
  
  /// Callback executado quando o widget é tocado
  final VoidCallback? onTap;
  
  /// Callback executado em long press
  final VoidCallback? onLongPress;
  
  /// Valor atual do widget
  final [VALUE_TYPE]? value;
  
  /// Label/título exibido no widget
  final String? label;
  
  /// Subtítulo ou descrição adicional
  final String? subtitle;
  
  /// Ícone a ser exibido
  final IconData? icon;
  
  /// Tamanho do widget
  final [WIDGET_NAME]Size size;
  
  /// Tipo/variante do widget
  final [WIDGET_NAME]Type type;
  
  /// Estado do widget (ativo, desabilitado, etc)
  final [WIDGET_NAME]State state;
  
  /// Cor customizada do widget
  final Color? color;
  
  /// Cor do texto/ícone
  final Color? textColor;
  
  /// Se deve fornecer feedback háptico
  final bool hapticFeedback;
  
  /// Largura do widget (opcional)
  final double? width;
  
  /// Altura do widget (opcional)  
  final double? height;
  
  /// Padding interno customizado
  final EdgeInsets? padding;
  
  /// Border radius customizado
  final BorderRadius? borderRadius;
  
  /// Sombra customizada
  final List<BoxShadow>? boxShadow;
  
  /// Duração das animações
  final Duration? animationDuration;
  
  /// Curva das animações
  final Curve? animationCurve;
  
  /// Label semântico para acessibilidade
  final String? semanticLabel;
  
  /// Hint semântico para acessibilidade
  final String? semanticHint;

  const [WIDGET_NAME]({
    super.key,
    // Callbacks primeiro
    this.onChanged,
    this.onTap,
    this.onLongPress,
    // Dados principais
    this.value,
    this.label,
    this.subtitle,
    this.icon,
    // Configuração visual
    this.size = [WIDGET_NAME]Size.medium,
    this.type = [WIDGET_NAME]Type.standard,
    this.state = [WIDGET_NAME]State.enabled,
    // Personalização
    this.color,
    this.textColor,
    this.hapticFeedback = true,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.boxShadow,
    this.animationDuration,
    this.animationCurve,
    // Acessibilidade
    this.semanticLabel,
    this.semanticHint,
  });
  
  /// Factory constructor para widget desabilitado
  const [WIDGET_NAME].disabled({
    super.key,
    this.value,
    this.label,
    this.subtitle,
    this.icon,
    this.size = [WIDGET_NAME]Size.medium,
    this.type = [WIDGET_NAME]Type.standard,
    this.color,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.boxShadow,
    this.animationDuration,
    this.animationCurve,
    this.semanticLabel,
    this.semanticHint,
  }) : onChanged = null,
       onTap = null,
       onLongPress = null,
       state = [WIDGET_NAME]State.disabled,
       hapticFeedback = false;

  @override
  State<[WIDGET_NAME]> createState() => _[WIDGET_NAME]State();
}

class _[WIDGET_NAME]State extends State<[WIDGET_NAME]> 
    with TickerProviderStateMixin {
  
  // Controllers de animação
  late AnimationController _pressedController;
  late AnimationController _valueController;
  
  // Animações
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Color?> _colorAnimation;
  
  // Estado interno
  bool _isPressed = false;
  bool _isHovered = false;
  [VALUE_TYPE]? _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _initAnimations();
  }

  @override
  void didUpdateWidget([WIDGET_NAME] oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.value != oldWidget.value) {
      _updateValue(widget.value);
    }
  }

  @override
  void dispose() {
    _pressedController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _initAnimations() {
    final theme = context.acTheme;
    
    _pressedController = AnimationController(
      duration: widget.animationDuration ?? theme.animationFast,
      vsync: this,
    );
    
    _valueController = AnimationController(
      duration: theme.animationNormal,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressedController,
      curve: widget.animationCurve ?? theme.animationCurve,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(_pressedController);
    
    _colorAnimation = ColorTween(
      begin: _getEffectiveColor(),
      end: _getEffectiveColor().withValues(alpha: 0.8),
    ).animate(_pressedController);
  }

  void _updateValue([VALUE_TYPE]? newValue) {
    if (_currentValue != newValue) {
      setState(() {
        _currentValue = newValue;
      });
      
      // Animar mudança de valor
      _valueController.forward().then((_) {
        if (mounted) {
          _valueController.reverse();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.acTheme;
    final isEnabled = widget.state == [WIDGET_NAME]State.enabled;
    
    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      hint: widget.semanticHint,
      value: _getSemanticValue(),
      enabled: isEnabled,
      button: widget.onTap != null,
      child: MouseRegion(
        onEnter: isEnabled ? (_) => _handleHover(true) : null,
        onExit: isEnabled ? (_) => _handleHover(false) : null,
        child: GestureDetector(
          onTapDown: isEnabled ? _handleTapDown : null,
          onTapUp: isEnabled ? _handleTapUp : null,
          onTapCancel: isEnabled ? _handleTapCancel : null,
          onTap: isEnabled ? _handleTap : null,
          onLongPress: widget.onLongPress != null && isEnabled ? _handleLongPress : null,
          child: AnimatedBuilder(
            animation: Listenable.merge([_pressedController, _valueController]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _getEffectiveOpacity(),
                  child: _buildWidget(theme),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWidget(ThemeData theme) {
    return AnimatedContainer(
      duration: widget.animationDuration ?? Duration(milliseconds: 200),
      width: widget.width ?? _getEffectiveWidth(),
      height: widget.height ?? _getEffectiveHeight(),
      decoration: _getDecoration(),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: widget.padding ?? _getEffectivePadding(),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ícone (se presente)
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: _getIconSize(),
            color: _getEffectiveTextColor(),
          ),
          if (widget.label != null) 
            SizedBox(height: context.spacingSm),
        ],
        
        // Label principal
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: _getFontSize(),
              fontWeight: _getFontWeight(),
              color: _getEffectiveTextColor(),
            ),
            textAlign: TextAlign.center,
          ),
        ],
        
        // Subtitle (se presente)
        if (widget.subtitle != null) ...[
          SizedBox(height: context.spacingXs),
          Text(
            widget.subtitle!,
            style: TextStyle(
              fontSize: _getFontSize() * 0.85,
              color: _getEffectiveTextColor().withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
        
        // Conteúdo específico do widget
        _buildSpecificContent(),
      ],
    );
  }

  /// Constrói o conteúdo específico do widget (sobrescrever conforme necessário)
  Widget _buildSpecificContent() {
    // TODO: Implementar conteúdo específico
    // Exemplo: switch, slider, gauge, etc.
    
    if (_currentValue != null) {
      return Padding(
        padding: EdgeInsets.only(top: context.spacingSm),
        child: Text(
          _formatValue(_currentValue),
          style: TextStyle(
            fontSize: _getFontSize() * 1.2,
            fontWeight: FontWeight.bold,
            color: _getEffectiveColor(),
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  // Métodos de manipulação de eventos
  
  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _pressedController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _pressedController.reverse();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _pressedController.reverse();
  }

  void _handleTap() {
    if (widget.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    
    widget.onTap?.call();
    
    // Se há callback onChanged, alternar valor (para widgets toggle)
    if (widget.onChanged != null && _currentValue is bool) {
      final newValue = !(_currentValue as bool) as [VALUE_TYPE];
      widget.onChanged!(newValue);
    }
  }

  void _handleLongPress() {
    if (widget.hapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    widget.onLongPress?.call();
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }

  // Métodos de estilo e aparência
  
  Color _getEffectiveColor() {
    final theme = context.acTheme;
    
    if (widget.color != null) return widget.color!;
    
    switch (widget.type) {
      case [WIDGET_NAME]Type.standard:
        return theme.primaryColor;
      case [WIDGET_NAME]Type.secondary:
        return theme.secondaryColor;
      case [WIDGET_NAME]Type.success:
        return theme.successColor;
      case [WIDGET_NAME]Type.warning:
        return theme.warningColor;
      case [WIDGET_NAME]Type.error:
        return theme.errorColor;
    }
  }

  Color _getEffectiveTextColor() {
    if (widget.textColor != null) return widget.textColor!;
    
    final theme = context.acTheme;
    
    switch (widget.state) {
      case [WIDGET_NAME]State.enabled:
        return theme.textPrimary;
      case [WIDGET_NAME]State.disabled:
        return theme.textPrimary.withValues(alpha: 0.3);
      case [WIDGET_NAME]State.loading:
        return theme.textPrimary.withValues(alpha: 0.7);
    }
  }

  double _getEffectiveOpacity() {
    switch (widget.state) {
      case [WIDGET_NAME]State.enabled:
        return _isHovered ? 0.9 : _opacityAnimation.value;
      case [WIDGET_NAME]State.disabled:
        return 0.3;
      case [WIDGET_NAME]State.loading:
        return 0.7;
    }
  }

  BoxDecoration _getDecoration() {
    return BoxDecoration(
      color: _getBackgroundColor(),
      borderRadius: widget.borderRadius ?? _getEffectiveBorderRadius(),
      boxShadow: widget.state == [WIDGET_NAME]State.disabled 
          ? null 
          : (widget.boxShadow ?? _getEffectiveBoxShadow()),
      border: _getBorder(),
    );
  }

  Color _getBackgroundColor() {
    final baseColor = _getEffectiveColor();
    
    if (_isPressed) {
      return baseColor.withValues(alpha: 0.8);
    }
    
    if (_isHovered) {
      return baseColor.withValues(alpha: 0.9);
    }
    
    return baseColor;
  }

  Border? _getBorder() {
    if (widget.type == [WIDGET_NAME]Type.outlined) {
      return Border.all(
        color: _getEffectiveColor(),
        width: 2,
      );
    }
    return null;
  }

  // Métodos de dimensionamento
  
  double? _getEffectiveWidth() {
    switch (widget.size) {
      case [WIDGET_NAME]Size.small:
        return 80;
      case [WIDGET_NAME]Size.medium:
        return 120;
      case [WIDGET_NAME]Size.large:
        return 160;
    }
  }

  double? _getEffectiveHeight() {
    switch (widget.size) {
      case [WIDGET_NAME]Size.small:
        return 60;
      case [WIDGET_NAME]Size.medium:
        return 80;
      case [WIDGET_NAME]Size.large:
        return 100;
    }
  }

  EdgeInsets _getEffectivePadding() {
    switch (widget.size) {
      case [WIDGET_NAME]Size.small:
        return EdgeInsets.all(context.spacingSm);
      case [WIDGET_NAME]Size.medium:
        return EdgeInsets.all(context.spacingMd);
      case [WIDGET_NAME]Size.large:
        return EdgeInsets.all(context.spacingLg);
    }
  }

  BorderRadius _getEffectiveBorderRadius() {
    switch (widget.size) {
      case [WIDGET_NAME]Size.small:
        return BorderRadius.circular(context.borderRadiusSmall);
      case [WIDGET_NAME]Size.medium:
        return BorderRadius.circular(context.borderRadiusMedium);
      case [WIDGET_NAME]Size.large:
        return BorderRadius.circular(context.borderRadiusLarge);
    }
  }

  List<BoxShadow>? _getEffectiveBoxShadow() {
    final theme = context.acTheme;
    
    if (_isPressed) {
      return theme.depressedShadow;
    }
    
    switch (widget.size) {
      case [WIDGET_NAME]Size.small:
        return theme.subtleShadow;
      case [WIDGET_NAME]Size.medium:
        return theme.elevatedShadow;
      case [WIDGET_NAME]Size.large:
        return theme.strongShadow;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case [WIDGET_NAME]Size.small:
        return context.fontSizeSmall;
      case [WIDGET_NAME]Size.medium:
        return context.fontSizeMedium;
      case [WIDGET_NAME]Size.large:
        return context.fontSizeLarge;
    }
  }

  FontWeight _getFontWeight() {
    return context.fontWeightRegular;
  }

  double _getIconSize() {
    switch (widget.size) {
      case [WIDGET_NAME]Size.small:
        return 20;
      case [WIDGET_NAME]Size.medium:
        return 24;
      case [WIDGET_NAME]Size.large:
        return 32;
    }
  }

  // Métodos utilitários
  
  String _getSemanticValue() {
    if (_currentValue != null) {
      return _formatValue(_currentValue);
    }
    return '';
  }

  String _formatValue([VALUE_TYPE]? value) {
    if (value == null) return '';
    // TODO: Implementar formatação específica do tipo
    return value.toString();
  }
}

// Enums de configuração

enum [WIDGET_NAME]Size {
  small,
  medium,
  large,
}

enum [WIDGET_NAME]Type {
  standard,
  secondary,
  success,
  warning,
  error,
  outlined,
  transparent,
}

enum [WIDGET_NAME]State {
  enabled,
  disabled,
  loading,
}

/*
INSTRUÇÕES PARA USO DESTE TEMPLATE:

1. SUBSTITUIÇÕES OBRIGATÓRIAS:
   - [WIDGET_NAME] → Nome do widget (ex: ACSwitch, ACGauge, ACSlider)
   - [WIDGET_DESCRIPTION] → Descrição do que o widget faz
   - [WIDGET_PURPOSE] → Propósito principal do widget
   - [FEATURE_1], [FEATURE_2], [FEATURE_3] → Funcionalidades principais
   - [VALUE_TYPE] → Tipo do valor (bool, double, String, etc.)

2. CUSTOMIZAÇÕES ESPECÍFICAS:
   - Implementar _buildSpecificContent() com lógica específica
   - Adicionar/remover propriedades conforme necessário
   - Customizar enums de Size/Type/State conforme o widget
   - Ajustar dimensionamento e estilos específicos

3. FUNCIONALIDADES INCLUÍDAS:
   - ✅ Animações suaves (scale, opacity, color)
   - ✅ Estados visuais (enabled, disabled, loading)
   - ✅ Feedback háptico configurável
   - ✅ Hover effects (desktop)
   - ✅ Responsividade automática
   - ✅ Acessibilidade completa (Semantics)
   - ✅ Tematização via context extensions
   - ✅ Gestão adequada de recursos (dispose)

4. PADRÕES IMPLEMENTADOS:
   - Nomenclatura consistente com sistema AutoCore
   - Context extensions para tema e responsividade
   - Feedback visual adequado para todos os estados
   - Performance otimizada (AnimationController, mounted checks)
   - Código limpo e bem documentado

5. TESTES RECOMENDADOS:
   - Teste de renderização básica
   - Teste de interações (tap, long press)
   - Teste de estados (enabled, disabled)
   - Teste de animações
   - Teste de acessibilidade
   - Golden tests para aparência visual

EXEMPLO DE CUSTOMIZAÇÃO PARA ACSwitch:
- [WIDGET_NAME] → ACSwitch
- [VALUE_TYPE] → bool
- _buildSpecificContent() implementaria o visual do switch
- Enums customizados para switch específico

EXEMPLO DE CUSTOMIZAÇÃO PARA ACGauge:
- [WIDGET_NAME] → ACGauge  
- [VALUE_TYPE] → double
- _buildSpecificContent() implementaria o gauge circular/linear
- Propriedades adicionais: min, max, ranges, etc.
*/