import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/firebase_options.dart';
import 'package:moroccan_recipies_app/screens/welcome_screen.dart';
import 'package:moroccan_recipies_app/screens/signin_screen.dart';
import 'package:moroccan_recipies_app/screens/register_screen.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';
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
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          //padding: const EdgeInsets.all(AppSpacing.md),
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Cart Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.wb_sunny_outlined, 
                              color: AppColors.primary, 
                              size: 24),
                          const SizedBox(width: AppSpacing.sm),
                          Text('Good Morning',
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Alena Sabyan',
                          style: Theme.of(context).textTheme.displayLarge),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {},
                    color: AppColors.textPrimary,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Featured Section
              Text('Featured',
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFeaturedCard(
                      'Asian white noodle\nwith extra seafood',
                      'James Spader',
                      '20 Min',
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _buildFeaturedCard(
                      'Healthy breakfast\nwith fruits',
                      'Olivia Wilson',
                      '15 Min',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Category Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Category',
                      style: Theme.of(context).textTheme.displayMedium),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All',
                        style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('Breakfast', true),
                    const SizedBox(width: AppSpacing.sm),
                    _buildCategoryChip('Lunch', false),
                    const SizedBox(width: AppSpacing.sm),
                    _buildCategoryChip('Dinner', false),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Popular Recipes Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Popular Recipes',
                      style: Theme.of(context).textTheme.displayMedium),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All',
                        style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 240,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildRecipeCard(
                      'Healthy Taco Salad\nwith fresh vegetable',
                      '120 Kcal',
                      '20 Min',
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _buildRecipeCard(
                      'Japanese-style\nPancakes Recipe',
                      '64 Kcal',
                      '12 Min',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(String title, String chef, String duration) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const CircleAvatar(radius: 12),
              const SizedBox(width: AppSpacing.sm),
              Text(chef,
                  style: const TextStyle(color: AppColors.textLight)),
              const Spacer(),
              const Icon(Icons.access_time, color: AppColors.textLight, size: 16),
              const SizedBox(width: 4),
              Text(duration,
                  style: const TextStyle(color: AppColors.textLight)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {},
    );
  }

  Widget _buildRecipeCard(String title, String calories, String duration) {
    return SizedBox(
      width: 200,
      child: Card(
        elevation: 0,
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    child: Image.asset(
                      'assets/images/recipe1.jpg',
                      width: 168,
                      height: 128,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary, // Makes sure the text is in primary color
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  Text(
                    calories,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  Text(
                    duration,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
