import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_flutter_architecture/main.dart';
import 'package:easy_flutter_architecture/core/di/injection.dart';

void main() {
  testWidgets('App displays architecture ready message', (WidgetTester tester) async {
    // Reset and initialize dependencies
    await resetDependencies();
    await configureDependencies();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: const MyApp()));

    // Verify that the app title is correct
    expect(find.text('Easy Flutter Architecture'), findsOneWidget);

    // Verify that the app uses Material 3 theme
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp).first);
    expect(materialApp.theme?.useMaterial3, isTrue);
  });
}
