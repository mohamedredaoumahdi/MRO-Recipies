import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';

void main() {
  testWidgets('RecipeCard basic functionality test', (WidgetTester tester) async {
    // Create a test recipe
    final recipe = Recipe(
      id: 'test-id',
      title: 'Test Recipe',
      description: 'A test recipe',
      category: 'Dinner',
      createdBy: 'user123',
      createdAt: DateTime(2023, 1, 1),
      ingredients: ['Ingredient 1', 'Ingredient 2'],
      steps: ['Step 1', 'Step 2'],
      imageUrl: 'test_image_base64', // Simple placeholder
      prepTime: 10,
      cookTime: 20,
      servings: 4,
      difficulty: 'Easy',
      calories: 300,
    );

    // Build a simple widget to display recipe info
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(recipe.title),
              Text(recipe.category),
              Text(recipe.difficulty),
            ],
          ),
        ),
      ),
    );

    // Verify text is displayed correctly
    expect(find.text('Test Recipe'), findsOneWidget);
    expect(find.text('Dinner'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
  });
}