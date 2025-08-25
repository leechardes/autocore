/// Constantes gerais do aplicativo AutoCore
class AppConstants {
  AppConstants._();

  // === APP INFO ===
  static const String appName = 'AutoCore';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // === HEARTBEAT (CRÍTICO PARA SEGURANÇA) ===
  static const Duration heartbeatInterval = Duration(milliseconds: 500);
  static const Duration heartbeatTimeout = Duration(milliseconds: 1000);
  static const int heartbeatMaxRetries = 3;

  // Canais que DEVEM usar heartbeat (momentâneos)
  static const List<String> momentaryChannels = [
    'buzina',
    'guincho_in',
    'guincho_out',
    'partida',
    'lampejo',
    'sirene',
  ];

  // === TIMEOUTS ===
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration commandTimeout = Duration(seconds: 5);
  static const Duration macroExecutionTimeout = Duration(seconds: 30);
  static const Duration reconnectDelay = Duration(seconds: 5);

  // === CACHE ===
  static const String cacheBoxName = 'autocore_cache';
  static const String configCacheKey = 'app_config';
  static const String themeCacheKey = 'theme_config';
  static const String screensCacheKey = 'screens_config';
  static const Duration cacheExpiration = Duration(hours: 24);

  // === UI ===
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 16.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration feedbackDuration = Duration(seconds: 2);

  // === GRID LAYOUTS ===
  static const int gridColumnsMobile = 2;
  static const int gridColumnsTablet = 3;
  static const int gridColumnsDesktop = 4;

  // === LIMITS ===
  static const int maxMacrosInQuickActions = 10;
  static const int maxScreenButtons = 4;
  static const int maxRetryAttempts = 3;
  static const int maxLogEntries = 1000;

  // === STORAGE KEYS ===
  static const String keyThemeMode = 'theme_mode';
  static const String keyDeviceId = 'device_id';
  static const String keyLastSync = 'last_sync';
  static const String keyPendingCommands = 'pending_commands';

  // === VALIDATIONS ===
  static const int minChannelNumber = 1;
  static const int maxChannelNumber = 16;
  static const double minBatteryVoltage = 10.0;
  static const double maxBatteryVoltage = 15.0;
  static const double criticalBatteryVoltage = 11.0;

  // === FEATURES FLAGS ===
  static const bool enableOfflineMode = true;
  static const bool enableHapticFeedback = true;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = true;
  static const bool requireHeartbeatForMomentary =
      true; // NUNCA mude para false!
}
