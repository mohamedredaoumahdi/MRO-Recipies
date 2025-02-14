import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';
import 'package:moroccan_recipies_app/screens/recipe_details_page.dart';
import 'package:moroccan_recipies_app/service/auth_service.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';

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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailsPage(recipe: recipe),
          ),
        ).then((_) {
          onBookmarkUpdated();
        });
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
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'by: ',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
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