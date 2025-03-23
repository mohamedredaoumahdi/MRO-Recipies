import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';
import 'package:moroccan_recipies_app/screens/recipe_details_page.dart';
import 'package:moroccan_recipies_app/service/auth_service.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';
import 'package:moroccan_recipies_app/widgets/common/moroccan_components.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final List<String> bookmarkedRecipeIds;
  final Function() onBookmarkUpdated;

  const RecipeCard({
    Key? key,
    required this.recipe,
    required this.bookmarkedRecipeIds,
    required this.onBookmarkUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isBookmarked = bookmarkedRecipeIds.contains(recipe.id);

    return AnimatedRecipeCard(
      onTap: () {
        Navigator.push(
          context,
          createRoute(RecipeDetailsPage(recipe: recipe)),
        ).then((_) {
          onBookmarkUpdated();
        });
      },
      child: SizedBox(
        width: 220,
        height: 260,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with gradient overlay and category badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: _buildRecipeImage(),
                  ),
                ),
                // Category badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                    child: Text(
                      recipe.category,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Time indicator
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.prepTime + recipe.cookTime} min',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bookmark indicator
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: isBookmarked 
                          ? AppColors.primary 
                          : Colors.black38,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isBookmarked ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            
            // Recipe details
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    recipe.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Author
                  Row(
                    children: [
                      Text(
                        'by: ',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder<String?>(
                          future: AuthService().getUsernameById(recipe.createdBy),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? 'Unknown User',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.xs),
                  
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Calories
                      Row(
                        children: [
                          Icon(Icons.local_fire_department, 
                            size: 16, 
                            color: AppColors.accent2),
                          const SizedBox(width: 4),
                          Text(
                            '${recipe.calories ?? 0}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                      
                      // Difficulty
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: getDifficultyColor(recipe.difficulty),
                          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                        ),
                        child: Text(
                          recipe.difficulty,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textLight,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecipeImage() {
    try {
      return Image.memory(
        base64Decode(recipe.imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 120,
            color: AppColors.background,
            child: const Icon(
              Icons.image_not_supported, 
              color: AppColors.textSecondary
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        width: double.infinity,
        height: 120,
        color: AppColors.background,
        child: const Icon(
          Icons.image_not_supported,
          color: AppColors.textSecondary
        ),
      );
    }
  }
}