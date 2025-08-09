import 'package:autocore_app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AutoCore App loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: AutoCoreApp()));

    // Wait for any animations
    await tester.pumpAndSettle();

    // Verify that AutoCore text is present
    expect(find.text('AutoCore'), findsOneWidget);
  });
}
