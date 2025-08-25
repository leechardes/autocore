import 'package:autocore_app/core/widgets/dynamic/dynamic_screen.dart';
import 'package:autocore_app/features/config/providers/config_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DynamicRouteScreen extends ConsumerWidget {
  final String route;

  const DynamicRouteScreen({super.key, required this.route});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);

    if (config == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    try {
      final screenConfig = config.screens.firstWhere((s) => s.route == route);

      return DynamicScreen(config: screenConfig);
    } catch (e) {
      // Se não encontrar a tela na configuração, mostra uma tela de erro
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                'Tela não configurada',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Route: $route',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
