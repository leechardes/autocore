import 'package:autocore_app/core/models/api/api_device_info.dart';
import 'package:autocore_app/core/models/api/api_screen_config.dart';
import 'package:autocore_app/core/models/api/api_screen_item.dart';
import 'package:autocore_app/core/models/api/config_full_response.dart';
import 'package:autocore_app/core/models/api/system_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

/// Central helper class for tests providing common utilities and mocks
class TestHelpers {
  /// Wraps a widget with MaterialApp for testing
  static Widget wrapWithApp(Widget widget) {
    return MaterialApp(home: Scaffold(body: widget));
  }

  /// Wraps a widget with ProviderScope and MaterialApp for Riverpod testing
  static Widget wrapWithProviders(Widget widget, {List<Override>? overrides}) {
    return ProviderScope(
      overrides: overrides ?? [],
      child: MaterialApp(home: Scaffold(body: widget)),
    );
  }

  /// Wraps widget testing with network image mocking
  static Future<void> pumpWithNetworkImages(
    WidgetTester tester,
    Widget widget,
  ) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
    });
  }
}

/// Mock data factory for tests
class MockData {
  /// Mock ConfigFullResponse for testing
  static ConfigFullResponse get configFullResponse {
    // Simplified mock - will be enhanced when ThemeConfig is fixed
    throw UnimplementedError('ConfigFullResponse mock needs fixing');
  }

  /// Mock DeviceInfo for testing
  static const mockDeviceInfo = ApiDeviceInfo(
    uuid: 'test-uuid-12345',
    name: 'Test Device',
    firmwareVersion: '1.0.0',
    hardwareVersion: '1.0.0',
    ipAddress: '192.168.1.100',
    macAddress: 'AA:BB:CC:DD:EE:FF',
    mqttBroker: 'localhost',
    mqttPort: 1883,
    mqttClientId: 'test_client',
    apiBaseUrl: 'http://localhost:8000',
    deviceType: 'esp32_display',
    timezone: 'America/Sao_Paulo',
    location: null,
  );

  /// Mock SystemConfig for testing
  static const mockSystemConfig = SystemConfig(
    telemetryEnabled: true,
    telemetryInterval: 1000,
    heartbeatInterval: 5000,
    autoReconnect: true,
    reconnectDelay: 5000,
    maxReconnectAttempts: 10,
    debugMode: false,
    logLevel: 'info',
    enableOfflineMode: true,
    cacheDuration: 300000,
    screenTimeout: 30000,
    language: 'pt-BR',
  );

  /// Mock ScreenConfig for testing
  static const mockScreenConfig = ApiScreenConfig(
    id: '1',
    name: 'home',
    title: 'Test Screen',
    order: 1,
    enabled: true,
    icon: 'home',
    route: '/home',
    items: [mockScreenItem],
    refreshInterval: null,
    requiresAuthentication: false,
    backgroundColor: null,
    textColor: null,
    layoutType: 'grid',
    columns: 2,
  );

  /// Mock ScreenItem for testing
  static const mockScreenItem = ApiScreenItem(
    id: '1',
    type: 'button',
    title: 'Test Button',
    position: {'row': 0, 'col': 0, 'span_x': 1, 'span_y': 1},
    enabled: true,
    visible: true,
    backgroundColor: null,
    textColor: null,
    borderColor: null,
    icon: 'touch_app',
    action: 'relay_control',
    command: null,
    payload: {'action': 'toggle', 'channel': 1},
    isMomentary: false,
    holdDuration: null,
    telemetryKey: null,
    unit: null,
    minValue: null,
    maxValue: null,
    decimalPlaces: 0,
    colorRanges: null,
    switchCommandOn: null,
    switchCommandOff: null,
    switchPayloadOn: null,
    switchPayloadOff: null,
    initialState: false,
  );

  /// Mock gauge screen item for testing
  static const mockGaugeItem = ApiScreenItem(
    id: '2',
    type: 'gauge',
    title: 'Test Gauge',
    position: {'row': 0, 'col': 1, 'span_x': 1, 'span_y': 1},
    enabled: true,
    visible: true,
    backgroundColor: null,
    textColor: null,
    borderColor: null,
    icon: 'speed',
    action: null,
    command: null,
    payload: null,
    isMomentary: false,
    holdDuration: null,
    telemetryKey: 'engine_rpm',
    unit: 'rpm',
    minValue: 0,
    maxValue: 5000,
    decimalPlaces: 0,
    colorRanges: null,
    switchCommandOn: null,
    switchCommandOff: null,
    switchPayloadOn: null,
    switchPayloadOff: null,
    initialState: false,
  );

  /// Mock display screen item for testing
  static const mockDisplayItem = ApiScreenItem(
    id: '3',
    type: 'display',
    title: 'Test Display',
    position: {'row': 1, 'col': 0, 'span_x': 1, 'span_y': 1},
    enabled: true,
    visible: true,
    backgroundColor: null,
    textColor: null,
    borderColor: null,
    icon: 'info',
    action: null,
    command: null,
    payload: null,
    isMomentary: false,
    holdDuration: null,
    telemetryKey: 'temperature',
    unit: '°C',
    minValue: -20,
    maxValue: 100,
    decimalPlaces: 1,
    colorRanges: null,
    switchCommandOn: null,
    switchCommandOff: null,
    switchPayloadOn: null,
    switchPayloadOff: null,
    initialState: false,
  );
}

/// Test constants
class TestConstants {
  static const Duration defaultTimeout = Duration(seconds: 5);
  static const Duration shortTimeout = Duration(milliseconds: 500);
  static const Duration longTimeout = Duration(seconds: 10);

  // Test device info
  static const String testDeviceUuid = 'test-device-uuid-12345';
  static const String testDeviceName = 'Test Device';
  static const String testApiBaseUrl = 'http://localhost:8000';

  // Test MQTT info
  static const String testMqttHost = 'localhost';
  static const int testMqttPort = 1883;
  static const String testMqttUsername = 'test_user';
  static const String testMqttPassword = 'test_pass';

  // Test topics
  static const String testMqttTopic = 'autocore/devices/test-device/status';
  static const String testMqttCommand = 'autocore/devices/test-device/commands';
}

/// Verification helpers for tests
class TestVerifications {
  /// Verifies that a widget exists and has expected text
  static void verifyWidgetText(String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// Verifies that a widget type exists
  static void verifyWidgetType<T extends Widget>() {
    expect(find.byType(T), findsOneWidget);
  }

  /// Verifies that multiple widgets of a type exist
  static void verifyWidgetCount<T extends Widget>(int count) {
    expect(find.byType(T), findsNWidgets(count));
  }

  /// Verifies loading state
  static void verifyLoadingState() {
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }

  /// Verifies error state with message
  static void verifyErrorState(String errorMessage) {
    expect(find.text(errorMessage), findsOneWidget);
  }
}

/// Gesture helpers for widget tests
class TestGestures {
  /// Taps a widget by text
  static Future<void> tapByText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  /// Taps a widget by type
  static Future<void> tapByType<T extends Widget>(WidgetTester tester) async {
    await tester.tap(find.byType(T));
    await tester.pumpAndSettle();
  }

  /// Long presses a widget by text
  static Future<void> longPressByText(WidgetTester tester, String text) async {
    await tester.longPress(find.text(text));
    await tester.pumpAndSettle();
  }

  /// Scrolls until a widget is visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder,
    Finder scrollable, {
    double scrollDelta = 100.0,
  }) async {
    await tester.scrollUntilVisible(
      finder,
      scrollDelta,
      scrollable: scrollable,
    );
  }
}
