import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/firebase_options.dart';
import 'package:moroccan_recipies_app/screens/welcome_screen.dart';
import 'package:moroccan_recipies_app/screens/signin_screen.dart';
import 'package:moroccan_recipies_app/screens/register_screen.dart';
import 'package:moroccan_recipies_app/theme/app_theme.dart' show AppTheme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MRO Recipes',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/signin': (context) => const SignInScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MyHomePage(title: "Home Page",), // Create this page
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(), // Empty container to clear the interface
      ),
    );
  }
}
