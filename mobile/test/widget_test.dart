// Widget test for State Management Patterns

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('State management home page loads correctly', (
    WidgetTester tester,
  ) async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that home page elements are present.
    expect(find.text('State Management Patterns'), findsOneWidget);
    expect(find.text('Provider'), findsOneWidget);
    expect(find.text('Riverpod'), findsOneWidget);
    expect(find.text('BLoC'), findsOneWidget);
  });

  testWidgets('Can navigate to Provider cart', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(MyApp());

    // Find Provider card
    final providerCard = find.text('Provider');
    expect(providerCard, findsOneWidget);

    // Tap on Provider card
    await tester.tap(providerCard);
    await tester.pumpAndSettle();

    // Verify we navigated to cart page
    expect(find.text('Shopping Cart (Provider)'), findsOneWidget);
  });
}
