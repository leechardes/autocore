import 'package:autocore_app/core/models/screen_config.dart';
import 'package:autocore_app/core/utils/logger.dart';
import 'package:autocore_app/core/widgets/dynamic/dynamic_widget_builder.dart';
import 'package:autocore_app/infrastructure/services/mqtt_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DynamicScreen extends ConsumerStatefulWidget {
  final ScreenConfig config;

  const DynamicScreen({super.key, required this.config});

  @override
  ConsumerState<DynamicScreen> createState() => _DynamicScreenState();
}

class _DynamicScreenState extends ConsumerState<DynamicScreen> {
  final Map<String, dynamic> _screenState = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.config.visible ? _buildAppBar() : null,
      body: _buildBody(),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    return AppBar(title: Text(widget.config.name), centerTitle: true);
  }

  Widget _buildBody() {
    final layout = widget.config.layout;

    if (widget.config.widgets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.widgets_outlined,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum widget configurado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Configure widgets no arquivo JSON',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(layout.spacing),
      child: _buildLayout(),
    );
  }

  Widget _buildLayout() {
    final layout = widget.config.layout;

    switch (layout.type) {
      case 'grid':
        return _buildGridLayout();
      case 'list':
        return _buildListLayout();
      case 'column':
        return _buildColumnLayout();
      case 'row':
        return _buildRowLayout();
      case 'stack':
        return _buildStackLayout();
      case 'custom':
        return _buildCustomLayout();
      default:
        return _buildGridLayout();
    }
  }

  Widget _buildGridLayout() {
    final layout = widget.config.layout;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: layout.columns,
        crossAxisSpacing: layout.spacing,
        mainAxisSpacing: layout.spacing,
        childAspectRatio: layout.aspectRatio,
      ),
      itemCount: widget.config.widgets.length,
      itemBuilder: (context, index) {
        final widgetConfig = widget.config.widgets[index];
        return DynamicWidgetBuilder.build(
          context,
          widgetConfig,
          state: _screenState,
          onAction: _handleAction,
        );
      },
    );
  }

  Widget _buildListLayout() {
    return ListView.separated(
      itemCount: widget.config.widgets.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: widget.config.layout.spacing),
      itemBuilder: (context, index) {
        final widgetConfig = widget.config.widgets[index];
        return DynamicWidgetBuilder.build(
          context,
          widgetConfig,
          state: _screenState,
          onAction: _handleAction,
        );
      },
    );
  }

  Widget _buildColumnLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.config.widgets.map((widgetConfig) {
          return Padding(
            padding: EdgeInsets.only(bottom: widget.config.layout.spacing),
            child: DynamicWidgetBuilder.build(
              context,
              widgetConfig,
              state: _screenState,
              onAction: _handleAction,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRowLayout() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.config.widgets.map((widgetConfig) {
          return Padding(
            padding: EdgeInsets.only(right: widget.config.layout.spacing),
            child: DynamicWidgetBuilder.build(
              context,
              widgetConfig,
              state: _screenState,
              onAction: _handleAction,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStackLayout() {
    return Stack(
      children: widget.config.widgets.map((widgetConfig) {
        return DynamicWidgetBuilder.build(
          context,
          widgetConfig,
          state: _screenState,
          onAction: _handleAction,
        );
      }).toList(),
    );
  }

  Widget _buildCustomLayout() {
    // Para layouts customizados, usa o primeiro widget como root
    if (widget.config.widgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return DynamicWidgetBuilder.build(
      context,
      widget.config.widgets.first,
      state: _screenState,
      onAction: _handleAction,
    );
  }

  void _handleAction(String action, Map<String, dynamic> params) {
    switch (action) {
      case 'navigate':
        _handleNavigate(params);
        break;
      case 'mqtt_publish':
        _handleMqttPublish(params);
        break;
      case 'update_state':
        _handleUpdateState(params);
        break;
      case 'show_dialog':
        _handleShowDialog(params);
        break;
      case 'show_snackbar':
        _handleShowSnackbar(params);
        break;
      default:
        debugPrint('Unknown action: $action');
    }
  }

  void _handleNavigate(Map<String, dynamic> params) {
    final route = params['route'] as String?;
    if (route != null) {
      Navigator.pushNamed(context, route, arguments: params['arguments']);
    }
  }

  void _handleMqttPublish(Map<String, dynamic> params) {
    final topic = params['topic'] as String?;
    final payload = params['payload'];
    final retain = params['retain'] as bool? ?? false;

    if (topic != null && payload != null) {
      MqttService.instance.publishJson(
        topic,
        payload as Map<String, dynamic>,
        retain: retain,
      );
      AppLogger.info('MQTT Published to $topic: $payload');
    }
  }

  void _handleUpdateState(Map<String, dynamic> params) {
    setState(() {
      _screenState.addAll(params);
    });
  }

  void _handleShowDialog(Map<String, dynamic> params) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text((params['title'] ?? 'Aviso') as String),
        content: Text((params['message'] ?? '') as String),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleShowSnackbar(Map<String, dynamic> params) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text((params['message'] ?? '') as String),
        duration: Duration(seconds: (params['duration'] ?? 3) as int),
      ),
    );
  }
}
