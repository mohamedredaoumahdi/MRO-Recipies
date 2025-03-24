import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Create a simplified version of sign-in screen for testing
class TestSignInScreen extends StatefulWidget {
  @override
  _TestSignInScreenState createState() => _TestSignInScreenState();
}

class _TestSignInScreenState extends State<TestSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                _formKey.currentState?.validate();
              },
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('SignInScreen validates email and password fields', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: TestSignInScreen(),
      ),
    );
    
    // Find the form and button
    final signInButton = find.byType(ElevatedButton);
    
    // Tap the button without filling the form
    await tester.tap(signInButton);
    await tester.pump();
    
    // Expect validation error messages
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
    
    // Enter invalid email
    await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
    await tester.tap(signInButton);
    await tester.pump();
    
    // Expect email validation error
    expect(find.text('Please enter a valid email'), findsOneWidget);
    
    // Enter valid email but short password
    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.tap(signInButton);
    await tester.pump();
    
    // Expect password validation error
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });
}