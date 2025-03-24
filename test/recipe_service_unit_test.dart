// test/recipe_service_unit_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';

// This is a simplified version of your service method for testing
String generateRecipeSearchTags(Recipe recipe) {
  final List<String> tags = [];
  
  // Add title words
  tags.addAll(recipe.title.toLowerCase().split(' '));
  
  // Add category
  tags.add(recipe.category.toLowerCase());
  
  // Add difficulty
  tags.add(recipe.difficulty.toLowerCase());
  
  // Add ingredients
  tags.addAll(recipe.ingredients.map((i) => i.toLowerCase()));
  
  return tags.join(' ');
}

void main() {
  group('Recipe Search Functions', () {
    test('generateRecipeSearchTags creates correct search tags', () {
      final recipe = Recipe(
        id: 'test-id',
        title: 'Moroccan Chicken Tagine',
        description: 'A delicious tagine',
        category: 'Dinner',
        createdBy: 'user1',
        createdAt: DateTime.now(),
        ingredients: ['Chicken', 'Olives', 'Lemon'],
        steps: ['step1', 'step2'],
        imageUrl: 'imageUrl',
        prepTime: 30,
        cookTime: 60,
        servings: 4,
        difficulty: 'Medium',
      );
      
      final tags = generateRecipeSearchTags(recipe);
      
      // Check that tags contain expected values
      expect(tags.contains('moroccan'), true);
      expect(tags.contains('chicken'), true);
      expect(tags.contains('tagine'), true);
      expect(tags.contains('dinner'), true);
      expect(tags.contains('medium'), true);
      expect(tags.contains('olives'), true);
      expect(tags.contains('lemon'), true);
    });
  });
}