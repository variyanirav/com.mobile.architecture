// Widget test for Clean Architecture Login Feature

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('Login page loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that login page elements are present.
    expect(find.text('Clean Architecture Demo'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(
      find.byType(TextField),
      findsNWidgets(2),
    ); // Email and password fields
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Login button triggers authentication flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // Find text fields
    final emailField = find.byType(TextField).first;
    final passwordField = find.byType(TextField).last;
    final loginButton = find.byType(ElevatedButton);

    // Enter email and password
    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'password123');

    // Tap login button
    await tester.tap(loginButton);
    await tester.pump();

    // Verify loading state appears
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the async operation to complete (500ms mock delay)
    await tester.pumpAndSettle();

    // Verify success message appears
    expect(find.text('Welcome test@example.com!'), findsOneWidget);
  });
}
