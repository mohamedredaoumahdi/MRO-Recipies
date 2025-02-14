import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';
import 'package:moroccan_recipies_app/screens/recipe_details_page.dart';
import 'dart:convert';
import 'package:moroccan_recipies_app/theme/app_colors.dart'; // Import AppColors
import 'package:moroccan_recipies_app/service/auth_service.dart'; // Import AuthService

class BookSearchRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final BuildContext context;
  final AuthService _authService = AuthService(); // Define AuthService instance

  BookSearchRecipeCard({Key? key, required this.recipe, required this.context}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailsPage(recipe: recipe),
          ),
        );
      },
      child: Card(
        elevation: 4, // Increased elevation for a more pronounced shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)), // Rounded top corners
              child: Image.memory(
                base64Decode(recipe.imageUrl),
                fit: BoxFit.cover,
                height: 150, // Fixed height for the image
                width: double.infinity, // Full width
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary, // Use AppColors
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary, // Use AppColors
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: AppColors.textSecondary), // Use AppColors
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.prepTime + recipe.cookTime} min',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12), // Use AppColors
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.local_fire_department, size: 16, color: AppColors.textSecondary), // Use AppColors
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.calories} Kcal',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12), // Use AppColors
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'by: ',
                        style: TextStyle(color: AppColors.textSecondary), // Use AppColors
                      ),
                      Expanded(
                        child: FutureBuilder<String?>(
                          future: _authService.getUsernameById(recipe.createdBy),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? 'Unknown User',
                              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold), // Use AppColors
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
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
}