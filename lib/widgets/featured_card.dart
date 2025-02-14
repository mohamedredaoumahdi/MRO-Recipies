import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';
import 'package:moroccan_recipies_app/screens/recipe_details_page.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';

class FeaturedCard extends StatelessWidget {
  final String title;
  final Recipe recipe;
  final String duration;

  const FeaturedCard({
    Key? key,
    required this.title,
    required this.recipe,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    try {
      imageBytes = base64Decode(recipe.imageUrl);
    } catch (e) {
      print('Error decoding image: $e');
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailsPage(recipe: recipe),
          ),
        );
      },
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          image: imageBytes != null
              ? DecorationImage(
                  image: MemoryImage(imageBytes),
                  fit: BoxFit.cover,
                )
              : null,
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
            Text(duration,
                style: const TextStyle(color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }
} 