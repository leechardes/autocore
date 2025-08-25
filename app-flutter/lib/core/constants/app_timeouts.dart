/// Constantes de timeout e duração para evitar magic numbers
library;

abstract class AppTimeouts {
  // Network timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Cache timeouts
  static const Duration cacheTimeout = Duration(minutes: 5);
  static const Duration configCacheTimeout = Duration(minutes: 10);
  static const Duration telemetryCacheTimeout = Duration(seconds: 30);

  // Retry configurations
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration backoffDelay = Duration(seconds: 5);
  static const int maxRetryAttempts = 3;
  static const int maxBackoffAttempts = 5;

  // UI timeouts
  static const Duration debounceDelay = Duration(milliseconds: 300);
  static const Duration animationDuration = Duration(milliseconds: 250);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  static const Duration tooltipDelay = Duration(seconds: 1);

  // MQTT timeouts
  static const Duration mqttConnectionTimeout = Duration(seconds: 30);
  static const Duration mqttKeepAlive = Duration(seconds: 60);
  static const Duration mqttReconnectDelay = Duration(seconds: 5);
  static const Duration heartbeatInterval = Duration(seconds: 30);

  // Background task timeouts
  static const Duration backgroundSyncInterval = Duration(minutes: 5);
  static const Duration healthCheckInterval = Duration(minutes: 1);
  static const Duration cleanupInterval = Duration(hours: 1);
}

abstract class AppLimits {
  // UI limits
  static const int maxToastLength = 200;
  static const int maxInputLength = 255;
  static const int maxDescriptionLength = 500;
  static const int maxItemsPerPage = 50;

  // Cache limits
  static const int maxCacheSize = 100;
  static const int maxLogEntries = 1000;
  static const int maxTelemetryHistory = 500;

  // Network limits
  static const int maxConcurrentRequests = 5;
  static const int maxRequestRetries = 3;
  static const int maxFileUploadSize = 10 * 1024 * 1024; // 10MB

  // Device limits
  static const int maxDevicesPerUser = 10;
  static const int maxRelaysPerDevice = 32;
  static const int maxScreensPerDevice = 10;
}

abstract class AppDefaults {
  // Theme defaults
  static const String defaultTheme = 'dark';
  static const String defaultLanguage = 'pt-BR';
  static const double defaultOpacity = 0.8;

  // Network defaults
  static const String defaultApiUrl = 'https://api.autocore.local';
  static const int defaultApiPort = 443;
  static const String defaultMqttHost = '10.0.10.100';
  static const int defaultMqttPort = 1883;

  // UI defaults
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 8.0;
  static const double defaultRadius = 8.0;
  static const double defaultElevation = 2.0;

  // Data defaults
  static const int defaultTelemetryInterval = 5; // seconds
  static const int defaultDecimalPlaces = 1;
  static const bool defaultRetainMessages = true;
}
