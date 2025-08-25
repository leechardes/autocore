import 'package:autocore_app/core/theme/theme_model.dart';
import 'package:autocore_app/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension ContextExtensions on BuildContext {
  // Size helpers
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  // Device type helpers
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;

  // Orientation helpers
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  // Padding helpers
  EdgeInsets get padding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;

  // Theme helpers
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
}

// Theme extensions merged from shared/
extension ThemeExtensions on BuildContext {
  ACTheme get acTheme {
    final container = ProviderScope.containerOf(this, listen: false);
    return container.read(themeProvider);
  }

  // Color shortcuts
  Color get primaryColor => acTheme.primaryColor;
  Color get secondaryColor => acTheme.secondaryColor;
  Color get backgroundColor => acTheme.backgroundColor;
  Color get surfaceColor => acTheme.surfaceColor;
  Color get successColor => acTheme.successColor;
  Color get warningColor => acTheme.warningColor;
  Color get errorColor => acTheme.errorColor;
  Color get infoColor => acTheme.infoColor;

  // Text color shortcuts
  Color get textPrimary => acTheme.textPrimary;
  Color get textSecondary => acTheme.textSecondary;
  Color get textTertiary => acTheme.textTertiary;

  // Shadow shortcuts
  List<BoxShadow> get elevatedShadow => acTheme.elevatedShadow;
  List<BoxShadow> get depressedShadow => acTheme.depressedShadow;
  List<BoxShadow> get subtleShadow => acTheme.subtleShadow;

  // Spacing shortcuts
  double get spacingXs => acTheme.spacingXs;
  double get spacingSm => acTheme.spacingSm;
  double get spacingMd => acTheme.spacingMd;
  double get spacingLg => acTheme.spacingLg;
  double get spacingXl => acTheme.spacingXl;

  // Border radius shortcuts
  double get borderRadiusSmall => acTheme.borderRadiusSmall;
  double get borderRadiusMedium => acTheme.borderRadiusMedium;
  double get borderRadiusLarge => acTheme.borderRadiusLarge;

  // Font shortcuts
  String get fontFamily => acTheme.fontFamily;
  double get fontSizeSmall => acTheme.fontSizeSmall;
  double get fontSizeMedium => acTheme.fontSizeMedium;
  double get fontSizeLarge => acTheme.fontSizeLarge;
  FontWeight get fontWeightLight => acTheme.fontWeightLight;
  FontWeight get fontWeightRegular => acTheme.fontWeightRegular;
  FontWeight get fontWeightBold => acTheme.fontWeightBold;

  // Animation shortcuts
  Duration get animationFast => acTheme.animationFast;
  Duration get animationNormal => acTheme.animationNormal;
  Duration get animationSlow => acTheme.animationSlow;
  Curve get animationCurve => acTheme.animationCurve;
}

// Widget extensions for easier composition
extension WidgetExtension on Widget {
  Widget withPadding(EdgeInsets padding) {
    return Padding(padding: padding, child: this);
  }

  Widget withMargin(EdgeInsets margin) {
    return Container(margin: margin, child: this);
  }

  Widget centered() {
    return Center(child: this);
  }

  Widget expanded({int flex = 1}) {
    return Expanded(flex: flex, child: this);
  }

  Widget flexible({int flex = 1}) {
    return Flexible(flex: flex, child: this);
  }
}
