import 'package:autocore_app/core/extensions/context_extensions.dart';
import 'package:autocore_app/core/models/screen_config.dart';
import 'package:autocore_app/core/theme/theme_model.dart';
import 'package:autocore_app/core/widgets/base/ac_button.dart';
import 'package:autocore_app/core/widgets/base/ac_container.dart';
import 'package:autocore_app/core/widgets/base/ac_grid.dart';
import 'package:autocore_app/core/widgets/controls/ac_control_tile.dart';
import 'package:autocore_app/core/widgets/controls/ac_switch.dart';
import 'package:autocore_app/core/widgets/indicators/ac_gauge.dart';
import 'package:autocore_app/core/widgets/indicators/ac_status_indicator.dart';
import 'package:flutter/material.dart';

class DynamicWidgetBuilder {
  static Widget build(
    BuildContext context,
    WidgetConfig config, {
    Map<String, dynamic>? state,
    void Function(String action, Map<String, dynamic> params)? onAction,
  }) {
    if (!config.visible) return const SizedBox.shrink();

    switch (config.type) {
      case 'control_tile':
        return _buildControlTile(context, config, state, onAction);
      case 'button':
        return _buildButton(context, config, onAction);
      case 'switch':
        return _buildSwitch(context, config, state, onAction);
      case 'gauge':
        return _buildGauge(context, config, state);
      case 'status_indicator':
        return _buildStatusIndicator(context, config, state);
      case 'container':
        return _buildContainer(context, config, state, onAction);
      case 'text':
        return _buildText(context, config, state);
      case 'grid':
        return _buildGrid(context, config, state, onAction);
      case 'column':
        return _buildColumn(context, config, state, onAction);
      case 'row':
        return _buildRow(context, config, state, onAction);
      case 'spacer':
        return _buildSpacer(context, config);
      default:
        return _buildPlaceholder(context, config);
    }
  }

  static Widget _buildControlTile(
    BuildContext context,
    WidgetConfig config,
    Map<String, dynamic>? state,
    void Function(String, Map<String, dynamic>)? onAction,
  ) {
    final props = config.properties;
    final deviceId = props['deviceId'] as String?;
    final channelId = props['channelId'] as String?;
    final stateKey = '$deviceId.$channelId';
    final currentState = state?[stateKey] ?? false;

    // RepaintBoundary para evitar rebuilds desnecessários
    return RepaintBoundary(
      child: ACControlTile(
        id: config.id,
        label: (props['label'] as String?) ?? 'Control',
        subtitle: props['subtitle'] as String?,
        icon: _getIconData((props['icon'] as String?) ?? 'lightbulb'),
        type: _getControlType(props['controlType'] as String?),
        size: _getControlSize(props['size'] as String?),
        value: currentState as bool,
        dimmerValue: (state?['$stateKey.dimmer'] as num?)?.toDouble(),
        onToggle: (value) {
          onAction?.call('toggle', {
            'deviceId': deviceId,
            'channelId': channelId,
            'value': value,
          });
        },
        onDimmerChanged: (value) {
          onAction?.call('dimmer', {
            'deviceId': deviceId,
            'channelId': channelId,
            'value': value,
          });
        },
        isOnline: (state?['$deviceId.online'] as bool?) ?? true,
        confirmAction: (props['confirmAction'] as bool?) ?? false,
        confirmMessage: props['confirmMessage'] as String?,
        activeColor: _getColor(props['activeColor'] as String?),
        inactiveColor: _getColor(props['inactiveColor'] as String?),
      ),
    );
  }

  static Widget _buildButton(
    BuildContext context,
    WidgetConfig config,
    void Function(String, Map<String, dynamic>)? onAction,
  ) {
    final props = config.properties;
    final action = config.actions['onPressed'];

    return ACButton(
      onPressed: action != null
          ? () => onAction?.call(action.type, action.params)
          : null,
      type: _getButtonType(props['type'] as String?),
      size: _getButtonSize(props['size'] as String?),
      color: _getColor(props['color'] as String?),
      width: (props['width'] as num?)?.toDouble(),
      height: (props['height'] as num?)?.toDouble(),
      child: _buildButtonChild(props),
    );
  }

  static Widget _buildSwitch(
    BuildContext context,
    WidgetConfig config,
    Map<String, dynamic>? state,
    void Function(String, Map<String, dynamic>)? onAction,
  ) {
    final props = config.properties;
    final stateKey = props['stateKey'] as String?;
    final value = state?[stateKey] ?? false;
    final action = config.actions['onChanged'];

    return ACSwitch(
      value: value as bool,
      onChanged: action != null
          ? (value) =>
                onAction?.call(action.type, {...action.params, 'value': value})
          : null,
      label: props['label'] as String?,
      subtitle: props['subtitle'] as String?,
      activeColor: _getColor(props['activeColor'] as String?),
      inactiveColor: _getColor(props['inactiveColor'] as String?),
    );
  }

  static Widget _buildGauge(
    BuildContext context,
    WidgetConfig config,
    Map<String, dynamic>? state,
  ) {
    final props = config.properties;
    final stateKey = props['stateKey'] as String?;
    final value = ((state?[stateKey] ?? props['value'] ?? 0) as num).toDouble();

    // RepaintBoundary para widgets de gauge que são expensive
    return RepaintBoundary(
      child: ACGauge(
        value: value,
        min: (props['min'] as num?)?.toDouble() ?? 0,
        max: (props['max'] as num?)?.toDouble() ?? 100,
        type: _getGaugeType(props['type'] as String?),
        unit: props['unit'] as String?,
        label: props['label'] as String?,
        width: (props['width'] as num?)?.toDouble(),
        height: (props['height'] as num?)?.toDouble(),
        primaryColor: _getColor(props['primaryColor'] as String?),
        zones: _buildGaugeZones(props['zones']),
      ),
    );
  }

  static Widget _buildStatusIndicator(
    BuildContext context,
    WidgetConfig config,
    Map<String, dynamic>? state,
  ) {
    final props = config.properties;
    final stateKey = props['stateKey'] as String?;
    final statusValue = state?[stateKey] ?? props['status'] ?? 'offline';

    return ACStatusIndicator(
      status: _getStatusType(statusValue as String),
      size: _getIndicatorSize(props['size'] as String?),
      shape: _getIndicatorShape(props['shape'] as String?),
      label: props['label'] as String?,
      showLabel: (props['showLabel'] as bool?) ?? true,
      pulse: (props['pulse'] as bool?) ?? true,
      glow: (props['glow'] as bool?) ?? false,
      color: _getColor(props['color'] as String?),
    );
  }

  static Widget _buildContainer(
    BuildContext context,
    WidgetConfig config,
    Map<String, dynamic>? state,
    void Function(String, Map<String, dynamic>)? onAction,
  ) {
    final props = config.properties;
    final theme = context.acTheme;

    return ACContainer(
      type: _getContainerType(props['type'] as String?),
      width: (props['width'] as num?)?.toDouble(),
      height: (props['height'] as num?)?.toDouble(),
      padding: _getEdgeInsets(props['padding'], theme),
      margin: _getEdgeInsets(props['margin'], theme),
      color: _getColor(props['color'] as String?),
      child: config.children.isNotEmpty
          ? _buildChildren(context, config.children, state, onAction)
          : const SizedBox.shrink(),
    );
  }

  static Widget _buildText(
    BuildContext context,
    WidgetConfig config,
    Map<String, dynamic>? state,
  ) {
    final props = config.properties;
    final theme = context.acTheme;
    final stateKey = props['stateKey'] as String?;
    final text = stateKey != null
        ? (state?[stateKey]?.toString() ?? props['text'] ?? '')
        : (props['text'] ?? '');

    return Text(
      text as String,
      style: TextStyle(
        color: _getColor(props['color'] as String?) ?? theme.textPrimary,
        fontSize:
            (props['fontSize'] as num?)?.toDouble() ?? theme.fontSizeMedium,
        fontWeight:
            _getFontWeight(props['fontWeight'] as String?) ??
            theme.fontWeightRegular,
      ),
      textAlign: _getTextAlign(props['textAlign'] as String?),
      maxLines: props['maxLines'] as int?,
      overflow: props['overflow'] == 'ellipsis'
          ? TextOverflow.ellipsis
          : TextOverflow.visible,
    );
  }

  static Widget _buildGrid(
    BuildContext context,
    WidgetConfig config,
    Map<String, dynamic>? state,
    void Function(String, Map<String, dynamic>)? onAction,
  ) {
    final props = config.properties;

    // RepaintBoundary para grids com muitos children
    return RepaintBoundary(
      child: ACGrid(
        type: _getGridType(props['type'] as String?),
        columns: props['columns'] as int?,
        minColumns: (props['minColumns'] as int?) ?? 1,
        maxColumns: (props['maxColumns'] as int?) ?? 6,
        minItemWidth: (props['minItemWidth'] as num?)?.toDouble(),
        aspectRatio: (props['aspectRatio'] as num?)?.toDouble() ?? 1.0,
        children: config.children
            .asMap()
            .entries
            .map(
              (entry) => KeyedSubtree(
                key: ValueKey('${config.id}_grid_${entry.key}'),
                child: build(
                  context,
                  entry.value,
                  state: state,
                  onAction: onAction,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  static Widget _buildColumn(
    BuildContext context,
    WidgetConfig config,
    Map<String, dynamic>? state,
    void Function(String, Map<String, dynamic>)? onAction,
  ) {
    final props = config.properties;

    return Column(
      mainAxisAlignment: _getMainAxisAlignment(
        props['mainAxisAlignment'] as String?,
      ),
      crossAxisAlignment: _getCrossAxisAlignment(
        props['crossAxisAlignment'] as String?,
      ),
      mainAxisSize: _getMainAxisSize(props['mainAxisSize'] as String?),
      children: config.children
          .asMap()
          .entries
          .map(
            (entry) => KeyedSubtree(
              key: ValueKey('${config.id}_column_${entry.key}'),
              child: build(
                context,
                entry.value,
                state: state,
                onAction: onAction,
              ),
            ),
          )
          .toList(),
    );
  }

  static Widget _buildRow(
    BuildContext context,
    WidgetConfig config,
    Map<String, dynamic>? state,
    void Function(String, Map<String, dynamic>)? onAction,
  ) {
    final props = config.properties;

    return Row(
      mainAxisAlignment: _getMainAxisAlignment(
        props['mainAxisAlignment'] as String?,
      ),
      crossAxisAlignment: _getCrossAxisAlignment(
        props['crossAxisAlignment'] as String?,
      ),
      mainAxisSize: _getMainAxisSize(props['mainAxisSize'] as String?),
      children: config.children
          .asMap()
          .entries
          .map(
            (entry) => KeyedSubtree(
              key: ValueKey('${config.id}_row_${entry.key}'),
              child: build(
                context,
                entry.value,
                state: state,
                onAction: onAction,
              ),
            ),
          )
          .toList(),
    );
  }

  static Widget _buildSpacer(BuildContext context, WidgetConfig config) {
    final props = config.properties;
    final theme = context.acTheme;

    if (props['flex'] != null) {
      return Spacer(flex: props['flex'] as int);
    }

    final size = props['size'] ?? 'md';
    double spacing;

    switch (size) {
      case 'xs':
        spacing = theme.spacingXs;
        break;
      case 'sm':
        spacing = theme.spacingSm;
        break;
      case 'md':
        spacing = theme.spacingMd;
        break;
      case 'lg':
        spacing = theme.spacingLg;
        break;
      case 'xl':
        spacing = theme.spacingXl;
        break;
      default:
        spacing = (props['height'] as num?)?.toDouble() ?? theme.spacingMd;
    }

    return SizedBox(
      height: props['horizontal'] == true ? null : spacing,
      width: props['horizontal'] == true ? spacing : null,
    );
  }

  static Widget _buildChildren(
    BuildContext context,
    List<WidgetConfig> children,
    Map<String, dynamic>? state,
    void Function(String, Map<String, dynamic>)? onAction,
  ) {
    if (children.length == 1) {
      return build(context, children.first, state: state, onAction: onAction);
    }

    return Column(
      children: children
          .map(
            (child) => build(context, child, state: state, onAction: onAction),
          )
          .toList(),
    );
  }

  static Widget _buildPlaceholder(BuildContext context, WidgetConfig config) {
    final theme = context.acTheme;

    return Container(
      padding: EdgeInsets.all(theme.spacingMd),
      decoration: BoxDecoration(
        border: Border.all(color: theme.errorColor),
        borderRadius: BorderRadius.circular(theme.borderRadiusSmall),
      ),
      child: Text(
        'Unknown widget type: ${config.type}',
        style: TextStyle(color: theme.errorColor),
      ),
    );
  }

  static Widget _buildButtonChild(Map<String, dynamic> props) {
    if (props['icon'] != null && props['text'] != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIconData(props['icon'] as String?), size: 20),
          const SizedBox(width: 8),
          Text(props['text'] as String),
        ],
      );
    } else if (props['icon'] != null) {
      return Icon(_getIconData(props['icon'] as String?));
    } else {
      return Text((props['text'] as String?) ?? 'Button');
    }
  }

  // Helper methods for conversions

  static IconData _getIconData(String? iconName) {
    // Map common icon names to IconData
    final iconMap = {
      'lightbulb': Icons.lightbulb,
      'power': Icons.power_settings_new,
      'lock': Icons.lock,
      'unlock': Icons.lock_open,
      'home': Icons.home,
      'settings': Icons.settings,
      'alarm': Icons.alarm,
      'warning': Icons.warning,
      'error': Icons.error,
      'info': Icons.info,
      'check': Icons.check,
      'close': Icons.close,
      'play': Icons.play_arrow,
      'pause': Icons.pause,
      'stop': Icons.stop,
      'refresh': Icons.refresh,
      'timer': Icons.timer,
      'schedule': Icons.schedule,
      'battery': Icons.battery_full,
      'thermostat': Icons.thermostat,
      'speed': Icons.speed,
      'gauge': Icons.speed,
      'fan': Icons.air,
      'ac': Icons.ac_unit,
      'heating': Icons.whatshot,
    };

    return iconMap[iconName] ?? Icons.device_unknown;
  }

  static Color? _getColor(String? colorValue) {
    if (colorValue == null) return null;

    if (colorValue.startsWith('#')) {
      return Color(int.parse(colorValue.substring(1), radix: 16) | 0xFF000000);
    }

    // Named colors
    final colorMap = {
      'primary': Colors.blue,
      'success': Colors.green,
      'warning': Colors.orange,
      'error': Colors.red,
      'info': Colors.lightBlue,
    };
    return colorMap[colorValue];
  }

  static ACControlType _getControlType(String? type) {
    switch (type) {
      case 'toggle':
        return ACControlType.toggle;
      case 'dimmer':
        return ACControlType.dimmer;
      case 'momentary':
        return ACControlType.momentary;
      case 'timer':
        return ACControlType.timer;
      case 'state':
        return ACControlType.state;
      default:
        return ACControlType.toggle;
    }
  }

  static ACControlSize _getControlSize(String? size) {
    switch (size) {
      case 'compact':
        return ACControlSize.compact;
      case 'normal':
        return ACControlSize.normal;
      case 'expanded':
        return ACControlSize.expanded;
      default:
        return ACControlSize.normal;
    }
  }

  static ACButtonType _getButtonType(String? type) {
    switch (type) {
      case 'elevated':
        return ACButtonType.elevated;
      case 'flat':
        return ACButtonType.flat;
      case 'outlined':
        return ACButtonType.outlined;
      case 'ghost':
        return ACButtonType.ghost;
      default:
        return ACButtonType.elevated;
    }
  }

  static ACButtonSize _getButtonSize(String? size) {
    switch (size) {
      case 'small':
        return ACButtonSize.small;
      case 'medium':
        return ACButtonSize.medium;
      case 'large':
        return ACButtonSize.large;
      default:
        return ACButtonSize.medium;
    }
  }

  static ACGaugeType _getGaugeType(String? type) {
    switch (type) {
      case 'circular':
        return ACGaugeType.circular;
      case 'linear':
        return ACGaugeType.linear;
      case 'battery':
        return ACGaugeType.battery;
      case 'semicircular':
        return ACGaugeType.semicircular;
      default:
        return ACGaugeType.circular;
    }
  }

  static List<ACGaugeZone>? _buildGaugeZones(dynamic zones) {
    if (zones == null || zones is! List) return null;

    return zones
        .map((zone) {
          if (zone is Map<String, dynamic>) {
            return ACGaugeZone(
              start: (zone['start'] as num?)?.toDouble() ?? 0,
              end: (zone['end'] as num?)?.toDouble() ?? 100,
              color: _getColor(zone['color'] as String?) ?? Colors.grey,
              label: zone['label'] as String?,
            );
          }
          return null;
        })
        .whereType<ACGaugeZone>()
        .toList();
  }

  static ACStatusType _getStatusType(String? status) {
    switch (status) {
      case 'online':
        return ACStatusType.online;
      case 'offline':
        return ACStatusType.offline;
      case 'connected':
        return ACStatusType.connected;
      case 'disconnected':
        return ACStatusType.disconnected;
      case 'active':
        return ACStatusType.active;
      case 'inactive':
        return ACStatusType.inactive;
      case 'warning':
        return ACStatusType.warning;
      case 'error':
        return ACStatusType.error;
      case 'success':
        return ACStatusType.success;
      case 'info':
        return ACStatusType.info;
      default:
        return ACStatusType.custom;
    }
  }

  static ACIndicatorSize _getIndicatorSize(String? size) {
    switch (size) {
      case 'small':
        return ACIndicatorSize.small;
      case 'medium':
        return ACIndicatorSize.medium;
      case 'large':
        return ACIndicatorSize.large;
      default:
        return ACIndicatorSize.medium;
    }
  }

  static ACIndicatorShape _getIndicatorShape(String? shape) {
    switch (shape) {
      case 'circle':
        return ACIndicatorShape.circle;
      case 'square':
        return ACIndicatorShape.square;
      case 'rounded':
        return ACIndicatorShape.rounded;
      default:
        return ACIndicatorShape.circle;
    }
  }

  static ACContainerType _getContainerType(String? type) {
    switch (type) {
      case 'surface':
        return ACContainerType.surface;
      case 'elevated':
        return ACContainerType.elevated;
      case 'depressed':
        return ACContainerType.depressed;
      case 'flat':
        return ACContainerType.flat;
      case 'outlined':
        return ACContainerType.outlined;
      default:
        return ACContainerType.surface;
    }
  }

  static ACGridType _getGridType(String? type) {
    switch (type) {
      case 'fixed':
        return ACGridType.fixed;
      case 'responsive':
        return ACGridType.responsive;
      case 'masonry':
        return ACGridType.masonry;
      default:
        return ACGridType.responsive;
    }
  }

  static EdgeInsets? _getEdgeInsets(dynamic value, ACTheme theme) {
    if (value == null) return null;

    if (value is Map) {
      return EdgeInsets.fromLTRB(
        (value['left'] as num?)?.toDouble() ?? 0,
        (value['top'] as num?)?.toDouble() ?? 0,
        (value['right'] as num?)?.toDouble() ?? 0,
        (value['bottom'] as num?)?.toDouble() ?? 0,
      );
    }

    if (value is num) {
      return EdgeInsets.all(value.toDouble());
    }

    if (value is String) {
      switch (value) {
        case 'xs':
          return EdgeInsets.all(theme.spacingXs);
        case 'sm':
          return EdgeInsets.all(theme.spacingSm);
        case 'md':
          return EdgeInsets.all(theme.spacingMd);
        case 'lg':
          return EdgeInsets.all(theme.spacingLg);
        case 'xl':
          return EdgeInsets.all(theme.spacingXl);
      }
    }

    return null;
  }

  static MainAxisAlignment _getMainAxisAlignment(String? alignment) {
    switch (alignment) {
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'spaceBetween':
        return MainAxisAlignment.spaceBetween;
      case 'spaceAround':
        return MainAxisAlignment.spaceAround;
      case 'spaceEvenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  static CrossAxisAlignment _getCrossAxisAlignment(String? alignment) {
    switch (alignment) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'center':
        return CrossAxisAlignment.center;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      default:
        return CrossAxisAlignment.start;
    }
  }

  static MainAxisSize _getMainAxisSize(String? size) {
    switch (size) {
      case 'min':
        return MainAxisSize.min;
      case 'max':
        return MainAxisSize.max;
      default:
        return MainAxisSize.max;
    }
  }

  static TextAlign? _getTextAlign(String? align) {
    switch (align) {
      case 'left':
        return TextAlign.left;
      case 'right':
        return TextAlign.right;
      case 'center':
        return TextAlign.center;
      case 'justify':
        return TextAlign.justify;
      default:
        return null;
    }
  }

  static FontWeight? _getFontWeight(String? weight) {
    switch (weight) {
      case 'light':
        return FontWeight.w300;
      case 'regular':
        return FontWeight.w400;
      case 'medium':
        return FontWeight.w500;
      case 'semibold':
        return FontWeight.w600;
      case 'bold':
        return FontWeight.w700;
      default:
        return null;
    }
  }
}
