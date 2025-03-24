import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'mocks/firebase_options_mock.dart';

Future<void> setupFirebaseForTesting() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Setup mock Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptionsMock.currentPlatform,
  );
}

class TestWrapper extends StatelessWidget {
  final Widget child;
  
  const TestWrapper({Key? key, required this.child}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }
}