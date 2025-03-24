// test/navigation_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/details': (context) => DetailScreen(),
        '/search': (context) => SearchScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/details');
              },
              child: Text('Go to Details'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/search');
              },
              child: Text('Go to Search'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details')),
      body: Center(
        child: Text('Detail Screen'),
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: Center(
        child: Text('Search Screen'),
      ),
    );
  }
}

void main() {
  testWidgets('Navigation test', (WidgetTester tester) async {
    await tester.pumpWidget(TestApp());
    
    // Verify we're on the home screen
    expect(find.text('Home'), findsOneWidget);
    
    // Navigate to details screen
    await tester.tap(find.text('Go to Details'));
    await tester.pumpAndSettle();
    
    // Verify we're on the details screen
    expect(find.text('Details'), findsOneWidget);
    
    // Go back to home
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    
    // Verify we're back on home screen
    expect(find.text('Home'), findsOneWidget);
    
    // Navigate to search screen
    await tester.tap(find.text('Go to Search'));
    await tester.pumpAndSettle();
    
    // Verify we're on the search screen
    expect(find.text('Search Screen'), findsOneWidget);
  });
}