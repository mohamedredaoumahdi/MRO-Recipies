// test/search_logic_test.dart
import 'package:flutter_test/flutter_test.dart';

// Simple recipe class for testing
class SimpleRecipe {
  final String title;
  final String category;
  final List<String> ingredients;
  final String description;

  SimpleRecipe({
    required this.title,
    required this.category,
    required this.ingredients,
    required this.description,
  });
}

// Search utility class
class SearchUtils {
  static List<SimpleRecipe> searchRecipes(List<SimpleRecipe> recipes, String query) {
    final lowercaseQuery = query.toLowerCase();
    
    return recipes.where((recipe) {
      // Search in title
      if (recipe.title.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }
      
      // Search in category
      if (recipe.category.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }
      
      // Search in description
      if (recipe.description.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }
      
      // Search in ingredients
      if (recipe.ingredients.any((ingredient) => 
          ingredient.toLowerCase().contains(lowercaseQuery))) {
        return true;
      }
      
      return false;
    }).toList();
  }
  
  static List<SimpleRecipe> filterByCategory(List<SimpleRecipe> recipes, String category) {
    if (category.isEmpty) {
      return recipes;
    }
    
    return recipes.where((recipe) => recipe.category == category).toList();
  }
}

void main() {
  group('Recipe Search Functionality', () {
    final recipes = [
      SimpleRecipe(
        title: 'Moroccan Tagine',
        category: 'Dinner',
        ingredients: ['Chicken', 'Olives', 'Lemon', 'Spices'],
        description: 'A traditional Moroccan dish',
      ),
      SimpleRecipe(
        title: 'Couscous Salad',
        category: 'Lunch',
        ingredients: ['Couscous', 'Tomatoes', 'Cucumber', 'Mint'],
        description: 'Fresh and healthy salad',
      ),
      SimpleRecipe(
        title: 'Mint Tea',
        category: 'Beverage',
        ingredients: ['Green tea', 'Mint leaves', 'Sugar'],
        description: 'Traditional Moroccan tea',
      ),
    ];
    
    test('Search by title works correctly', () {
      final results = SearchUtils.searchRecipes(recipes, 'tagine');
      expect(results.length, 1);
      expect(results[0].title, 'Moroccan Tagine');
    });
    
    test('Search by category works correctly', () {
      final results = SearchUtils.searchRecipes(recipes, 'lunch');
      expect(results.length, 1);
      expect(results[0].title, 'Couscous Salad');
    });
    
    test('Search by ingredient works correctly', () {
      final results = SearchUtils.searchRecipes(recipes, 'mint');
      expect(results.length, 2);
      expect(results.map((r) => r.title).toList(), ['Couscous Salad', 'Mint Tea']);
    });
    
    test('Search by description works correctly', () {
      final results = SearchUtils.searchRecipes(recipes, 'traditional');
      expect(results.length, 2);
      expect(results.map((r) => r.title).toList(), ['Moroccan Tagine', 'Mint Tea']);
    });
    
    test('Filter by category works correctly', () {
      final results = SearchUtils.filterByCategory(recipes, 'Dinner');
      expect(results.length, 1);
      expect(results[0].title, 'Moroccan Tagine');
    });
    
    test('Empty category filter returns all recipes', () {
      final results = SearchUtils.filterByCategory(recipes, '');
      expect(results.length, 3);
    });
  });
}