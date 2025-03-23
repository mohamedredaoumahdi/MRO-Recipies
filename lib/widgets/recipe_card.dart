import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';
import 'package:moroccan_recipies_app/screens/recipe_details_page.dart';
import 'package:moroccan_recipies_app/service/auth_service.dart';
import 'package:moroccan_recipies_app/service/recipe_service.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';
import 'package:moroccan_recipies_app/widgets/common/moroccan_components.dart';

class RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final List<String> bookmarkedRecipeIds;
  final Function() onBookmarkUpdated;
  final bool featured;

  const RecipeCard({
    Key? key,
    required this.recipe,
    required this.bookmarkedRecipeIds,
    required this.onBookmarkUpdated,
    this.featured = false,
  }) : super(key: key);

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  final RecipeService _recipeService = RecipeService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isBookmarked = widget.bookmarkedRecipeIds.contains(widget.recipe.id);
    final cardWidth = widget.featured ? 280.0 : 220.0;
    final cardHeight = widget.featured ? 320.0 : 260.0;
    final imageHeight = widget.featured ? 180.0 : 140.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailsPage(recipe: widget.recipe),
          ),
        ).then((_) {
          widget.onBookmarkUpdated();
        });
      },
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _isHovered = true;
            _controller.forward();
          });
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
            _controller.reverse();
          });
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? Colors.black.withOpacity(0.15)
                          : Colors.black.withOpacity(0.08),
                      blurRadius: _isHovered ? 10 : 5,
                      offset: Offset(0, _isHovered ? 5 : 2),
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                Stack(
                  children: [
                    Hero(
                      tag: 'recipe-image-${widget.recipe.id}',
                      child: SizedBox(
                        height: imageHeight,
                        width: double.infinity,
                        child: _buildRecipeImage(imageHeight),
                      ),
                    ),
                    // Gradient overlay for better text visibility
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                            stops: const [0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Category badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(widget.recipe.category),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.recipe.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Cooking time badge
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.recipe.prepTime + widget.recipe.cookTime} min',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Bookmark button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildBookmarkButton(isBookmarked),
                    ),
                  ],
                ),
                
                // Content section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.recipe.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        
                        // Description or author
                        if (widget.featured)
                          Expanded(
                            child: Text(
                              widget.recipe.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else
                          Row(
                            children: [
                              Text(
                                'by ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Expanded(
                                child: FutureBuilder<String?>(
                                  future: _authService.getUsernameById(widget.recipe.createdBy),
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.data ?? 'Unknown',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        
                        const Spacer(),
                        
                        // Bottom stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Calories
                            Row(
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  size: 14,
                                  color: AppColors.accent2,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.recipe.calories ?? 0} kcal',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            
                            // Difficulty badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(widget.recipe.difficulty).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getDifficultyIcon(widget.recipe.difficulty),
                                    size: 10,
                                    color: _getDifficultyColor(widget.recipe.difficulty),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.recipe.difficulty,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _getDifficultyColor(widget.recipe.difficulty),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildRecipeImage(double height) {
    try {
      return Image.memory(
        base64Decode(widget.recipe.imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage(height);
        },
      );
    } catch (e) {
      return _buildPlaceholderImage(height);
    }
  }
  
  Widget _buildPlaceholderImage(double height) {
    return Container(
      width: double.infinity,
      height: height,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            color: Colors.grey[400],
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Image not available',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBookmarkButton(bool isBookmarked) {
    return InkWell(
      onTap: () async {
        final userId = _authService.currentUser?.uid;
        if (userId != null) {
          await _recipeService.toggleLike(widget.recipe.id, userId);
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
          size: 16,
        ),
      ),
    );
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
  
  Color _getCategoryColor(String category) {
    return AppColors.categoryColors[category] ?? AppColors.primary;
  }
}