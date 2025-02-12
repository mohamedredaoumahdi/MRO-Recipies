import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';
import 'package:moroccan_recipies_app/widgets/homeContent_navBar.dart';
import 'dart:convert';
import 'package:moroccan_recipies_app/service/recipe_service.dart';
import 'package:moroccan_recipies_app/service/auth_service.dart';
import 'package:moroccan_recipies_app/screens/recipe_details_page.dart';

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
                // TextButton(
                //   onPressed: () {},
                //   child: const Text('See All',
                //       style: TextStyle(color: AppColors.primary)),
                // ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('All'),
                  const SizedBox(width: AppSpacing.sm),
                  _buildCategoryChip('Breakfast'),
                  const SizedBox(width: AppSpacing.sm),
                  _buildCategoryChip('Lunch'),
                  const SizedBox(width: AppSpacing.sm),
                  _buildCategoryChip('Dinner'),
                  const SizedBox(width: AppSpacing.sm),
                  _buildCategoryChip('Snack'),
                  const SizedBox(width: AppSpacing.sm),
                  _buildCategoryChip('Dessert'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // // Popular Recipes Section
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text('Popular Recipes',
            //         style: Theme.of(context).textTheme.displayMedium),
            //     TextButton(
            //       onPressed: () {},
            //       child: const Text('See All',
            //           style: TextStyle(color: AppColors.primary)),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: AppSpacing.md),
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
                    separatorBuilder: (context, index) => 
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) => _buildRecipeCard(filteredRecipes[index]),
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

  Widget _buildCategoryChip(String label) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: _selectedCategory == label ? AppColors.textLight : AppColors.textPrimary,
        ),
      ),
      selected: _selectedCategory == label,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      showCheckmark: false,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedCategory = label;
          });
        }
      },
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailsPage(recipe: recipe),
          ),
        );
      },
      child: SizedBox(
        width: 200,
        height: 240,
        child: Card(
          elevation: 0,
          color: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          ),
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
                      height: 120,
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
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          final userId = _authService.currentUser?.uid;
                          if (userId != null) {
                            final isLiked = await _recipeService.toggleLike(recipe.id, userId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isLiked ? 'Added to bookmarks' : 'Removed from bookmarks'),
                                backgroundColor: isLiked ? AppColors.success : AppColors.textSecondary,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to update bookmark'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                        ),
                        child: StreamBuilder<bool>(
                          stream: _recipeService.isLikedByUser(recipe.id, _authService.currentUser?.uid ?? ''),
                          builder: (context, snapshot) {
                            final isLiked = snapshot.data ?? false;
                            return Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: isLiked ? AppColors.success : AppColors.textPrimary,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<String>(
                      future: _recipeService.getUserName(recipe.createdBy),
                      builder: (context, snapshot) {
                        return Text(
                          'by ${snapshot.data ?? recipe.createdBy}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department, 
                          size: 16, 
                          color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.calories ?? 0} Kcal',
                          style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                        ),
                        const Spacer(),
                        Icon(Icons.access_time, 
                          size: 16, 
                          color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.prepTime + recipe.cookTime} min',
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
