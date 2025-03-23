import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';
import 'package:moroccan_recipies_app/screens/recipe_details_page.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';
import 'package:moroccan_recipies_app/service/recipe_service.dart';
import 'package:moroccan_recipies_app/service/auth_service.dart';
import 'package:moroccan_recipies_app/widgets/common/moroccan_components.dart';

class FeaturedRecipesCarousel extends StatefulWidget {
  final List<Recipe> recipes;
  final List<String> bookmarkedRecipeIds;
  final Function() onBookmarkUpdated;

  const FeaturedRecipesCarousel({
    Key? key,
    required this.recipes,
    required this.bookmarkedRecipeIds,
    required this.onBookmarkUpdated,
  }) : super(key: key);

  @override
  State<FeaturedRecipesCarousel> createState() => _FeaturedRecipesCarouselState();
}

class _FeaturedRecipesCarouselState extends State<FeaturedRecipesCarousel> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  final RecipeService _recipeService = RecipeService();
  final AuthService _authService = AuthService();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _pageOffset;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pageOffset = Tween<double>(begin: 0, end: 1).animate(_animationController);
    
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    final page = _pageController.page!.round();
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.recipes.isEmpty) {
      return _buildEmptyState();
    }
    
    return Column(
      children: [
        // Main carousel
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.recipes.length,
            itemBuilder: (context, index) {
              final recipe = widget.recipes[index];
              final isBookmarked = widget.bookmarkedRecipeIds.contains(recipe.id);
              
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = (_pageController.page! - index).abs();
                    value = (1 - (value * 0.3)).clamp(0.85, 1.0);
                  }
                  
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value.clamp(0.6, 1.0),
                      child: child,
                    ),
                  );
                },
                child: _buildFeaturedCard(recipe, isBookmarked),
              );
            },
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Page indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.recipes.length, 
            (index) => _buildIndicator(index == _currentPage),
          ),
        ),
      ],
    );
  }
  
  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
  
  Widget _buildFeaturedCard(Recipe recipe, bool isBookmarked) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          createRoute(RecipeDetailsPage(recipe: recipe)),
        ).then((_) {
          widget.onBookmarkUpdated();
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Hero(
                tag: 'recipe-image-${recipe.id}',
                child: _buildRecipeImage(recipe),
              ),
              
              // Gradient overlay for text legibility
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.5, 0.75, 1.0],
                  ),
                ),
              ),
              
              // Content overlay
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row with category and bookmark button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(recipe.category),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            recipe.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        
                        // Bookmark button
                        _buildBookmarkButton(recipe.id, isBookmarked),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Bottom content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          recipe.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 2,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Time and difficulty
                        Row(
                          children: [
                            // Time
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: 14,
                                  ),
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
                            
                            const SizedBox(width: 8),
                            
                            // Difficulty
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(recipe.difficulty).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getDifficultyIcon(recipe.difficulty),
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    recipe.difficulty,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
  
  Widget _buildBookmarkButton(String recipeId, bool isBookmarked) {
    return GestureDetector(
      onTap: () async {
        final userId = _authService.currentUser?.uid;
        if (userId != null) {
          await _recipeService.toggleLike(recipeId, userId);
          widget.onBookmarkUpdated();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isBookmarked ? AppColors.primary : Colors.black38,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isBookmarked ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
  
  Widget _buildRecipeImage(Recipe recipe) {
    try {
      return Image.memory(
        base64Decode(recipe.imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } catch (e) {
      return _buildPlaceholderImage();
    }
  }
  
  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.primary.withOpacity(0.6),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              color: Colors.white.withOpacity(0.7),
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No featured recipes yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for curated dishes',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Breakfast':
        return Colors.blue;
      case 'Lunch':
        return Colors.orange;
      case 'Dinner':
        return Colors.red;
      case 'Snack':
        return Colors.green;
      case 'Dessert':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }
  
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.green;
    }
  }
  
  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.sentiment_satisfied_alt;
      case 'medium':
        return Icons.sentiment_neutral;
      case 'hard':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_satisfied_alt;
    }
  }
}