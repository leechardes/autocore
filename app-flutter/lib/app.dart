import 'package:autocore_app/core/router/app_router.dart';
import 'package:autocore_app/core/theme/theme_provider.dart';
import 'package:autocore_app/infrastructure/services/heartbeat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class AutoCoreApp extends ConsumerStatefulWidget {
  const AutoCoreApp({super.key});

  @override
  ConsumerState<AutoCoreApp> createState() => _AutoCoreAppState();
}

class _AutoCoreAppState extends ConsumerState<AutoCoreApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _configurePlatform();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // CRÍTICO: Parar heartbeats ao minimizar app
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      HeartbeatService.instance.emergencyStopAll();
    }
  }

  void _configurePlatform() {
    // Status bar transparente
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Orientação portrait apenas
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = ref.watch(themeProvider);
    final router = ref.watch<RouterConfig<Object>>(appRouterProvider);

    return MaterialApp.router(
      title: 'AutoCore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: themeModel.primaryColor,
        scaffoldBackgroundColor: themeModel.backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: themeModel.surfaceColor,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: themeModel.surfaceColor,
          elevation:
              0, // Elevation 0 (flat) - especificação A33-PHASE2-IMPORTANT-FIXES
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(
              color: Color(
                0xFF27272A,
              ), // Border 1px #27272A - especificação A33-PHASE2-IMPORTANT-FIXES
              width: 1,
            ),
          ),
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme.copyWith(
            titleSmall: const TextStyle(
              fontSize:
                  12, // 12px conforme especificação A32-PHASE1-CRITICAL-FIXES
              fontWeight: FontWeight.w400, // w400 mais sutil
              letterSpacing: 1.0, // letterSpacing 1.0 conforme especificação
            ),
            bodyMedium: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            headlineMedium: const TextStyle(
              fontSize:
                  32, // 32px para valores conforme especificação A32-PHASE1-CRITICAL-FIXES
              fontWeight: FontWeight.w600, // w600 para valores grandes
            ),
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}
