import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moroccan_recipies_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap through welcome screen to sign in', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Expect to see the welcome screen
      expect(find.text('MOROCCAN RECIPES'), findsOneWidget);
      
      // Tap the "Skip" button (assuming guest mode is available)
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      
      // Expect to be on home screen 
      // (adjust this according to what appears on your home screen)
      expect(find.text('Discover, Cook, and Enjoy'), findsOneWidget);
    });
  });
}