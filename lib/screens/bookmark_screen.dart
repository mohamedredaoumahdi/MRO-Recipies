import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';
import 'package:moroccan_recipies_app/service/auth_service.dart';
import 'package:moroccan_recipies_app/service/recipe_service.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';
import 'package:moroccan_recipies_app/screens/recipe_details_page.dart';
import 'package:moroccan_recipies_app/widgets/book_search_recipe_card.dart'; // Import the new widget

class BookmarkScreen extends StatelessWidget {
  final VoidCallback onBack;
  final RecipeService _recipeService = RecipeService();
  final AuthService _authService = AuthService();
  BookmarkScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid;
    print('Current UserID: $userId'); // Debug print

    if (userId == null) {
      print('No user logged in'); // Debug print
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Please sign in to see your bookmarks',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookmarks'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack, // Call the function passed from BottomNavBar
        ),
      ),
      body: StreamBuilder<List<Recipe>>(
        stream: _recipeService.getLikedRecipes(userId),
        builder: (context, snapshot) {
          print('StreamBuilder state: ${snapshot.connectionState}'); // Debug print
          print('StreamBuilder error: ${snapshot.error}'); // Debug print
          print('StreamBuilder data: ${snapshot.data?.length}'); // Debug print

          if (snapshot.hasError) {
            print('Error in StreamBuilder: ${snapshot.error}'); // Debug print
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final recipes = snapshot.data ?? [];
          print('Number of recipes: ${recipes.length}'); // Debug print

          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No bookmarked recipes yet',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your favorite recipes will appear here',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return BookSearchRecipeCard(recipe: recipe, context: context); // Use the new BookSearchRecipeCard widget
            },
          );
        },
      ),
    );
  }
}
