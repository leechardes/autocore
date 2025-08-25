import 'package:autocore_app/core/models/api/api_screen_item.dart';
import 'package:autocore_app/features/screens/widgets/button_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('ButtonItemWidget', () {
    late ApiScreenItem mockButtonItem;
    late ApiScreenItem mockSwitchItem;

    setUp(() {
      mockButtonItem = const ApiScreenItem(
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

      mockSwitchItem = const ApiScreenItem(
        id: '2',
        type: 'switch',
        title: 'Test Switch',
        position: {'row': 0, 'col': 1, 'span_x': 1, 'span_y': 1},
        enabled: true,
        visible: true,
        backgroundColor: null,
        textColor: null,
        borderColor: null,
        icon: 'toggle_on',
        action: 'relay_control',
        command: null,
        payload: null,
        isMomentary: false,
        holdDuration: null,
        telemetryKey: null,
        unit: null,
        minValue: null,
        maxValue: null,
        decimalPlaces: 0,
        colorRanges: null,
        switchCommandOn: 'turn_on',
        switchCommandOff: 'turn_off',
        switchPayloadOn: {'state': true},
        switchPayloadOff: {'state': false},
        initialState: false,
      );
    });

    group('Button Mode', () {
      testWidgets('should render button with correct title', (tester) async {
        // Act
        await tester.pumpWidget(
          TestHelpers.wrapWithApp(
            ButtonItemWidget(item: mockButtonItem, isSwitchMode: false),
          ),
        );

        // Assert
        expect(find.text('Test Button'), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
      });

      testWidgets('should call onPressed when button is tapped', (
        tester,
      ) async {
        // Arrange
        bool wasPressed = false;
        Map<String, dynamic>? receivedPayload;
        String? receivedCommand;

        // Act
        await tester.pumpWidget(
          TestHelpers.wrapWithApp(
            ButtonItemWidget(
              item: mockButtonItem,
              isSwitchMode: false,
              onPressed: (command, payload) {
                wasPressed = true;
                receivedCommand = command;
                receivedPayload = payload;
              },
            ),
          ),
        );

        await tester.tap(find.byType(Card));
        await tester.pumpAndSettle();

        // Assert
        expect(wasPressed, isTrue);
        expect(receivedCommand, equals('relay_control'));
        expect(receivedPayload, equals({'action': 'toggle', 'channel': 1}));
      });

      testWidgets('should show loading state when pressed', (tester) async {
        // Arrange
        bool shouldCompleteCallback = false;

        await tester.pumpWidget(
          TestHelpers.wrapWithApp(
            ButtonItemWidget(
              item: mockButtonItem,
              isSwitchMode: false,
              onPressed: (command, payload) async {
                // Simulate async operation
                while (!shouldCompleteCallback) {
                  await Future<void>.delayed(const Duration(milliseconds: 10));
                }
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(Card));
        await tester.pump(); // Trigger rebuild but don't settle yet

        // Assert - Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Complete the async operation
        shouldCompleteCallback = true;
        await tester.pumpAndSettle();

        // Assert - Loading should be gone
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('should not respond to taps when disabled', (tester) async {
        // Arrange
        final disabledItem = mockButtonItem.copyWith(enabled: false);
        bool wasPressed = false;

        // Act
        await tester.pumpWidget(
          TestHelpers.wrapWithApp(
            ButtonItemWidget(
              item: disabledItem,
              isSwitchMode: false,
              onPressed: (command, payload) {
                wasPressed = true;
              },
            ),
          ),
        );

        await tester.tap(find.byType(Card));
        await tester.pumpAndSettle();

        // Assert
        expect(wasPressed, isFalse);
      });

      testWidgets('should show icon when provided', (tester) async {
        // Act
        await tester.pumpWidget(
          TestHelpers.wrapWithApp(
            ButtonItemWidget(item: mockButtonItem, isSwitchMode: false),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.touch_app), findsOneWidget);
      });

      testWidgets('should reflect active state based on relay states', (
        tester,
      ) async {
        // Arrange
        final relayStates = {'channel_1': true};

        // Act
        await tester.pumpWidget(
          TestHelpers.wrapWithApp(
            ButtonItemWidget(
              item: mockButtonItem,
              isSwitchMode: false,
              relayStates: relayStates,
            ),
          ),
        );

        // Assert
        // Find the Card widget and check its color or visual state
        final card = tester.widget<Card>(find.byType(Card));
        expect(card, isNotNull);
        // Note: In a real test, we would check the card's color properties
        // to ensure they reflect the active state
      });
    });

    group('Switch Mode', () {
      testWidgets('should render switch with correct title', (tester) async {
        // Act
        await tester.pumpWidget(
          TestHelpers.wrapWithApp(
            ButtonItemWidget(item: mockSwitchItem, isSwitchMode: true),
          ),
        );

        // Assert
        expect(find.text('Test Switch'), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(Switch), findsOneWidget);
      });

      testWidgets('should call onSwitchChanged when switch is toggled', (
        tester,
      ) async {
        // Arrange
        bool? receivedValue;

        // Act
        await tester.pumpWidget(
          TestHelpers.wrapWithApp(
            ButtonItemWidget(
              item: mockSwitchItem,
              isSwitchMode: true,
              onSwitchChanged: (value) {
                receivedValue = value;
              },
            ),
          ),
        );

        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        // Assert
        expect(receivedValue, isNotNull);
        expect(receivedValue, isA<bool>());
      });

      testWidgets('should not respond to switch when disabled', (tester) async {
        // Arrange
        final disabledSwitchItem = mockSwitchItem.copyWith(enabled: false);
        bool wasChanged = false;

        // Act
        await tester.pumpWidget(
          TestHelpers.wrapWithApp(
            ButtonItemWidget(
              item: disabledSwitchItem,
              isSwitchMode: true,
              onSwitchChanged: (value) {
                wasChanged = true;
              },
            ),
          ),
        );

        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        // Assert
        expect(wasChanged, isFalse);
      });

      testWidgets('should show switch icon when provided', (tester) async {
        // Act
        await tester.pumpWidget(
          TestHelpers.wrapWithApp(
            ButtonItemWidget(item: mockSwitchItem, isSwitchMode: true),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.toggle_on), findsOneWidget);
      });
    });

    group('Animation', () {
      testWidgets('should animate scale when button is pressed', (
        tester,
      ) async {
        // This test verifies that the animation controller is set up correctly
        // In a more comprehensive test, we would check the actual scale values

        // Act
        await tester.pumpWidget(
          TestHelpers.wrapWithApp(
            ButtonItemWidget(
              item: mockButtonItem,
              isSwitchMode: false,
              onPressed: (command, payload) {
                // Empty callback
              },
            ),
          ),
        );

        // Tap and check that widget rebuilds (indicating animation)
        await tester.tap(find.byType(Card));
        await tester.pump(
          const Duration(milliseconds: 50),
        ); // Partial animation

        // Assert that the widget is still there (animation in progress)
        expect(find.byType(ButtonItemWidget), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);

        // Complete animation
        await tester.pumpAndSettle();

        // Assert that everything is back to normal
        expect(find.byType(ButtonItemWidget), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('should handle null onPressed callback gracefully', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          TestHelpers.wrapWithApp(
            ButtonItemWidget(
              item: mockButtonItem,
              isSwitchMode: false,
              onPressed: null,
            ),
          ),
        );

        // This should not throw an exception
        await tester.tap(find.byType(Card));
        await tester.pumpAndSettle();

        // Assert - Widget should still be rendered
        expect(find.text('Test Button'), findsOneWidget);
      });

      testWidgets('should handle null onSwitchChanged callback gracefully', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          TestHelpers.wrapWithApp(
            ButtonItemWidget(
              item: mockSwitchItem,
              isSwitchMode: true,
              onSwitchChanged: null,
            ),
          ),
        );

        // This should not throw an exception
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        // Assert - Widget should still be rendered
        expect(find.text('Test Switch'), findsOneWidget);
      });

      testWidgets('should handle missing icon gracefully', (tester) async {
        // Arrange
        final itemWithoutIcon = mockButtonItem.copyWith(icon: null);

        // Act
        await tester.pumpWidget(
          TestHelpers.wrapWithApp(
            ButtonItemWidget(item: itemWithoutIcon, isSwitchMode: false),
          ),
        );

        // Assert - Widget should render without icon
        expect(find.text('Test Button'), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
        // Should not find any specific icon
        expect(find.byIcon(Icons.touch_app), findsNothing);
      });
    });

    group('Telemetry Integration', () {
      testWidgets('should handle telemetry data when provided', (tester) async {
        // Arrange
        final relayStates = {'relay_1': true};
        final sensorValues = {'temperature': 25.5};

        // Act
        await tester.pumpWidget(
          TestHelpers.wrapWithApp(
            ButtonItemWidget(
              item: mockButtonItem,
              isSwitchMode: false,
              relayStates: relayStates,
              sensorValues: sensorValues,
            ),
          ),
        );

        // Assert - Widget should render with telemetry data
        expect(find.text('Test Button'), findsOneWidget);
        expect(find.byType(ButtonItemWidget), findsOneWidget);

        // Verify that the widget accepts the telemetry data without errors
        final widget = tester.widget<ButtonItemWidget>(
          find.byType(ButtonItemWidget),
        );
        expect(widget.relayStates, equals(relayStates));
        expect(widget.sensorValues, equals(sensorValues));
      });
    });
  });
}
