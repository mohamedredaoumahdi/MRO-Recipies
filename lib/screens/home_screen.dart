import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';
import 'package:moroccan_recipies_app/widgets/homeContent_navBar.dart';
import 'package:moroccan_recipies_app/service/recipe_service.dart';
import 'package:moroccan_recipies_app/service/auth_service.dart';
import 'package:moroccan_recipies_app/screens/recipe_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moroccan_recipies_app/widgets/featured_card_list.dart';
import 'package:moroccan_recipies_app/widgets/category_chip.dart';
import 'package:moroccan_recipies_app/widgets/recipe_card.dart';

// First, define HomeContent widget
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final RecipeService _recipeService = RecipeService();
  final AuthService _authService = AuthService();
  String _selectedCategory = 'All';  // Track selected category
  List<String> _bookmarkedRecipeIds = []; // List to store bookmarked recipe IDs
  late Future<List<Recipe>> _featuredRecipesFuture; // Future for featured recipes

  @override
  void initState() {
    super.initState();
    _loadBookmarks(); // Load bookmarks from persistent storage
    _featuredRecipesFuture = _recipeService.getTopLikedRecipes(); // Initialize the future
  }

  // Load bookmarks from shared preferences
  void _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bookmarkedRecipeIds = prefs.getStringList('bookmarkedRecipes') ?? [];
    });
  }

  // Save bookmarks to shared preferences
  void _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('bookmarkedRecipes', _bookmarkedRecipeIds);
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category; // Update only the selected category
    });
    // No need to refetch featured recipes here
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeContentNavBar(),
            const SizedBox(height: AppSpacing.xl),
            // Featured Section
            Text('Featured', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: AppSpacing.md),
            const FeaturedCardList(),
            const SizedBox(height: AppSpacing.lg),
            // Category Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Category', style: Theme.of(context).textTheme.displayMedium),
                // Add your category selection logic here
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryChip(label: 'All', onSelected: _onCategorySelected, isSelected: _selectedCategory == 'All'),
                  const SizedBox(width: AppSpacing.sm),
                  CategoryChip(label: 'Breakfast', onSelected: _onCategorySelected, isSelected: _selectedCategory == 'Breakfast'),
                  const SizedBox(width: AppSpacing.sm),
                  CategoryChip(label: 'Lunch', onSelected: _onCategorySelected, isSelected: _selectedCategory == 'Lunch'),
                  const SizedBox(width: AppSpacing.sm),
                  CategoryChip(label: 'Dinner', onSelected: _onCategorySelected, isSelected: _selectedCategory == 'Dinner'),
                  const SizedBox(width: AppSpacing.sm),
                  CategoryChip(label: 'Snack', onSelected: _onCategorySelected, isSelected: _selectedCategory == 'Snack'),
                  const SizedBox(width: AppSpacing.sm),
                  CategoryChip(label: 'Dessert', onSelected: _onCategorySelected, isSelected: _selectedCategory == 'Dessert'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 240,
              child: StreamBuilder<List<Recipe>>(
                stream: _recipeService.getRecipes(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final recipes = snapshot.data ?? [];
                  
                  // Filter recipes based on selected category
                  final filteredRecipes = _selectedCategory == 'All' 
                      ? recipes 
                      : recipes.where((recipe) => recipe.category == _selectedCategory).toList();
                  
                  if (filteredRecipes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.no_meals, color: AppColors.textSecondary, size: 48),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'No recipes found in $_selectedCategory category',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredRecipes.length,
                    separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) => RecipeCard(
                      recipe: filteredRecipes[index],
                      bookmarkedRecipeIds: _bookmarkedRecipeIds,
                      onBookmarkUpdated: _loadBookmarks,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
