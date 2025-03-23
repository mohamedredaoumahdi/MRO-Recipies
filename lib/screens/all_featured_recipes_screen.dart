import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';
import 'package:moroccan_recipies_app/service/recipe_service.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';
import 'package:moroccan_recipies_app/widgets/recipe_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllFeaturedRecipesScreen extends StatefulWidget {
  const AllFeaturedRecipesScreen({super.key});

  @override
  State<AllFeaturedRecipesScreen> createState() => _AllFeaturedRecipesScreenState();
}

class _AllFeaturedRecipesScreenState extends State<AllFeaturedRecipesScreen> {
  final RecipeService _recipeService = RecipeService();
  late Future<List<Recipe>> _featuredRecipesFuture;
  List<String> _bookmarkedRecipeIds = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    _featuredRecipesFuture = _recipeService.getTopLikedRecipes();
    
    // Simulate loading state
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
  
  // Load bookmarks from shared preferences
  void _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bookmarkedRecipeIds = prefs.getStringList('bookmarkedRecipes') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Featured Recipes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? _buildLoadingView()
          : _buildContentView(),
    );
  }
  
  Widget _buildLoadingView() {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }
  
  Widget _buildContentView() {
    return FutureBuilder<List<Recipe>>(
      future: _featuredRecipesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading recipes: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        final recipes = snapshot.data ?? [];
        if (recipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No featured recipes yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            return RecipeCard(
              recipe: recipes[index],
              bookmarkedRecipeIds: _bookmarkedRecipeIds,
              onBookmarkUpdated: _loadBookmarks,
            );
          },
        );
      },
    );
  }
}