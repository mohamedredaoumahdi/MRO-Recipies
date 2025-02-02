import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';
import 'package:moroccan_recipies_app/widgets/homeContent_navBar.dart';

// First, define HomeContent widget
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

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
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildRecipeCard(
                    'Healthy Taco Salad\nwith fresh vegetable',
                    '120 Kcal',
                    '20 Min',
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _buildRecipeCard(
                    'Japanese-style\nPancakes Recipe',
                    '64 Kcal',
                    '12 Min',
                  ),
                ],
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

  Widget _buildRecipeCard(String title, String calories, String duration) {
    return SizedBox(
      width: 200,
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
                    child: Image.asset(
                      'assets/images/recipe1.jpg',
                      width: 168,
                      height: 128,
                      fit: BoxFit.cover,
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
                      child: Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  Text(
                    calories,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  Text(
                    duration,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
