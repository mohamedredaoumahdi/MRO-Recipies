import 'package:flutter_test/flutter_test.dart';

// Simple Recipe class for testing
class SimpleRecipe {
  final String title;
  final String category;
  final List<String> ingredients;
  final int prepTime;
  final int cookTime;

  SimpleRecipe({
    required this.title,
    required this.category,
    required this.ingredients,
    required this.prepTime,
    required this.cookTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'ingredients': ingredients,
      'prepTime': prepTime,
      'cookTime': cookTime,
    };
  }

  int get totalTime => prepTime + cookTime;
}

void main() {
  group('Recipe Model', () {
    test('toMap() converts Recipe to Map correctly', () {
      final recipe = SimpleRecipe(
        title: 'Test Recipe',
        category: 'Breakfast',
        ingredients: ['Egg', 'Bread'],
        prepTime: 10,
        cookTime: 15,
      );
      
      final map = recipe.toMap();
      
      expect(map['title'], 'Test Recipe');
      expect(map['category'], 'Breakfast');
      expect(map['ingredients'], ['Egg', 'Bread']);
      expect(map['prepTime'], 10);
      expect(map['cookTime'], 15);
    });
    
    test('totalTime calculates correctly', () {
      final recipe = SimpleRecipe(
        title: 'Test Recipe',
        category: 'Breakfast',
        ingredients: ['Egg', 'Bread'],
        prepTime: 10,
        cookTime: 15,
      );
      
      expect(recipe.totalTime, 25);
    });
  });
}