// test/home_screen_simplified_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';

// A simplified version of your home screen for testing
class SimpleHomeScreen extends StatelessWidget {
  final List<Recipe> featuredRecipes;

  const SimpleHomeScreen({Key? key, required this.featuredRecipes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const Text('Featured Recipes'),
          ...featuredRecipes.map((recipe) => ListTile(
            title: Text(recipe.title),
            subtitle: Text(recipe.category),
          )).toList(),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('SimpleHomeScreen displays featured recipes', (WidgetTester tester) async {
    // Create test recipes
    final recipes = [
      Recipe(
        id: '1',
        title: 'Moroccan Tagine',
        description: 'A delicious tagine',
        category: 'Dinner',
        createdBy: 'user1',
        createdAt: DateTime.now(),
        ingredients: ['ingredient1', 'ingredient2'],
        steps: ['step1', 'step2'],
        imageUrl: 'imageUrl',
        prepTime: 30,
        cookTime: 60,
        servings: 4,
        difficulty: 'Medium',
      ),
      Recipe(
        id: '2',
        title: 'Couscous',
        description: 'Traditional couscous',
        category: 'Lunch',
        createdBy: 'user2',
        createdAt: DateTime.now(),
        ingredients: ['ingredient1', 'ingredient2'],
        steps: ['step1', 'step2'],
        imageUrl: 'imageUrl',
        prepTime: 20,
        cookTime: 40,
        servings: 6,
        difficulty: 'Easy',
      ),
    ];

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: SimpleHomeScreen(featuredRecipes: recipes),
      ),
    );

    // Check if the title is displayed
    expect(find.text('Featured Recipes'), findsOneWidget);
    
    // Check if recipes are displayed
    expect(find.text('Moroccan Tagine'), findsOneWidget);
    expect(find.text('Couscous'), findsOneWidget);
    expect(find.text('Dinner'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
  });
}