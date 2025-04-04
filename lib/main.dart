import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moroccan_recipies_app/firebase_options.dart';
import 'package:moroccan_recipies_app/screens/welcome_screen.dart';
import 'package:moroccan_recipies_app/screens/signin_screen.dart';
import 'package:moroccan_recipies_app/screens/register_screen.dart';
import 'package:moroccan_recipies_app/theme/app_theme.dart' show AppTheme;
import 'package:moroccan_recipies_app/widgets/bottom_nav_bar.dart';

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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If the snapshot has user data, then they're already signed in
          if (snapshot.hasData) {
            return const BottomNavBar();
          }
          // Otherwise, they're not signed in
          return const WelcomeScreen();
        },
      ),
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const BottomNavBar(),
        '/welcome': (context) => const WelcomeScreen(),
      },
    );
  }
}

