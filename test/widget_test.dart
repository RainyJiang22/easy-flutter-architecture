import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_flutter_architecture/main.dart';

void main() {
  testWidgets('App displays architecture ready message', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is correct
    expect(find.text('Flutter Architecture'), findsOneWidget);

    // Verify that the architecture ready message is displayed
    expect(find.text('Architecture is Ready!'), findsOneWidget);

    // Verify that the 'Get Started' button is present
    expect(find.text('Get Started'), findsOneWidget);
  });
}
