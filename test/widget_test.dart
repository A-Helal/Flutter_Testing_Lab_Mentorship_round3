// This is a basic Flutter widget test for the Testing Lab app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_testing_lab/main.dart';

void main() {
  testWidgets('App should load and display home page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlutterTestingLabApp());

    // Verify that the app title and tabs are present
    expect(find.text('Flutter Testing Lab'), findsOneWidget);
    
    // Wait for any initial async operations
    await tester.pumpAndSettle();
    
    // App should have the main structure loaded
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
