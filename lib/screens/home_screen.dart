import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';
import 'package:moroccan_recipies_app/widgets/homeContent_navBar.dart';
import 'dart:convert';
import 'package:moroccan_recipies_app/service/recipe_service.dart';

// First, define HomeContent widget
class HomeContent extends StatelessWidget {
  final RecipeService _recipeService = RecipeService();
  HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar with Cart Icon
            HomeContentNavBar(),
            const SizedBox(height: AppSpacing.xl),
            // Featured Section
            Text('Featured',style: Theme.of(context).textTheme.displayMedium),
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
                  
                  if (recipes.isEmpty) {
                    return const Center(child: Text('No recipes found'));
                  }

                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: recipes.length,
                    separatorBuilder: (context, index) => 
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) => _buildRecipeCard(recipes[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
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

  Widget _buildRecipeCard(Recipe recipe) {
    return SizedBox(
      width: 200,
      height: 240,  // Fixed height
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
                    child: Image.memory(
                      base64Decode(recipe.imageUrl),
                      width: double.infinity,
                      height: 120,  // Reduced height
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 120,
                          color: AppColors.background,
                          child: Icon(Icons.image_not_supported, color: AppColors.textSecondary),
                        );
                      },
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
                      child: Icon(Icons.favorite_border, size: 20, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(  // Make text area flexible
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<String>(
                      future: _recipeService.getUserName(recipe.createdBy),  // Add this method
                      builder: (context, snapshot) {
                        return Text(
                          'by ${snapshot.data ?? recipe.createdBy}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.calories ?? 0} Kcal',
                          style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.prepTime + recipe.cookTime} Min',
                          style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
