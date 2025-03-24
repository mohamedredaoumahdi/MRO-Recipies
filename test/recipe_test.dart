import 'package:flutter_test/flutter_test.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Recipe', () {
    test('should create a Recipe instance from a map', () {
      // Arrange
      final Map<String, dynamic> recipeMap = {
        'title': 'Test Recipe',
        'description': 'A test recipe',
        'category': 'Dinner',
        'createdBy': 'user123',
        'createdAt': Timestamp.fromDate(DateTime(2023, 1, 1)),
        'ingredients': ['Ingredient 1', 'Ingredient 2'],
        'steps': ['Step 1', 'Step 2'],
        'imageUrl': 'test_image_url',
        'prepTime': 10,
        'cookTime': 20,
        'servings': 4,
        'difficulty': 'Easy',
        'calories': 300,
        'likesCount': 5,
        'commentsCount': 2,
      };

      // Act
      final recipe = Recipe.fromMap('recipe123', recipeMap);

      // Assert
      expect(recipe.id, 'recipe123');
      expect(recipe.title, 'Test Recipe');
      expect(recipe.description, 'A test recipe');
      expect(recipe.category, 'Dinner');
      expect(recipe.ingredients.length, 2);
      expect(recipe.steps.length, 2);
      expect(recipe.prepTime, 10);
      expect(recipe.cookTime, 20);
      expect(recipe.difficulty, 'Easy');
      expect(recipe.calories, 300);
    });

    test('should convert Recipe to a Map correctly', () {
      // Arrange
      final recipe = Recipe(
        id: 'recipe123',
        title: 'Test Recipe',
        description: 'A test recipe',
        category: 'Dinner',
        createdBy: 'user123',
        createdAt: DateTime(2023, 1, 1),
        ingredients: ['Ingredient 1', 'Ingredient 2'],
        steps: ['Step 1', 'Step 2'],
        imageUrl: 'test_image_url',
        prepTime: 10,
        cookTime: 20,
        servings: 4,
        difficulty: 'Easy',
        calories: 300,
      );

      // Act
      final recipeMap = recipe.toMap();

      // Assert
      expect(recipeMap['title'], 'Test Recipe');
      expect(recipeMap['description'], 'A test recipe');
      expect(recipeMap['category'], 'Dinner');
      expect(recipeMap['prepTime'], 10);
      expect(recipeMap['cookTime'], 20);
      expect(recipeMap['difficulty'], 'Easy');
      expect(recipeMap['calories'], 300);
    });
  });
}