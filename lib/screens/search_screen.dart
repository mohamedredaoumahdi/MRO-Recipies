import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';
import 'package:moroccan_recipies_app/service/recipe_service.dart';
import 'package:moroccan_recipies_app/screens/recipe_details_page.dart';
import 'dart:convert';
import 'dart:async';
import 'package:moroccan_recipies_app/service/auth_service.dart';
import 'package:moroccan_recipies_app/widgets/book_search_recipe_card.dart'; // Import the new widget

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RecipeService _recipeService = RecipeService();
  final AuthService _authService = AuthService();
  String _searchQuery = '';
  String _selectedCategory = '';
  List<Recipe> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;
  
  // Example data - replace with your actual data
  final List<String> trendingSearches = [
    'Couscous', 'Tajine', 'Pastilla', 'Harira', 'Rfissa'
  ];
  
  final List<String> recentSearches = [
    'Moroccan Bread', 'Mint Tea', 'Chicken Tajine'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for a recipe...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.filter_list, color: AppColors.primary),
                    onPressed: () => _showFilters(context),
                  ),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Search Results or Default Content
            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildDefaultContent(screenWidth, screenHeight)
                  : _buildSearchResults(screenWidth),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(double screenWidth) {
    if (_searchQuery.isEmpty) {
      return _buildDefaultContent(screenWidth, MediaQuery.of(context).size.height);
    }

    return StreamBuilder<List<Recipe>>(
      stream: _recipeService.searchRecipes(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, 
                  size: 64, 
                  color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final recipes = snapshot.data ?? [];

        if (recipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, 
                  size: 64, 
                  color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(
                  'No recipes found for "$_searchQuery"',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(screenWidth * 0.04),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return BookSearchRecipeCard(recipe: recipe, context: context); // Use the new BookSearchRecipeCard widget
          },
        );
      },
    );
  }

  Widget _buildDefaultContent(double screenWidth, double screenHeight) {
    return ListView(
      padding: EdgeInsets.all(screenWidth * 0.04),
      children: [
        Text('Trending Searches', style: AppTextStyles.heading2),
        SizedBox(height: screenHeight * 0.02),
        Wrap(
          spacing: screenWidth * 0.02,
          children: trendingSearches.map((search) => _buildTrendingChip(search)).toList(),
        ),
        SizedBox(height: screenHeight * 0.04),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Searches', style: AppTextStyles.heading2),
            TextButton(
              onPressed: () {
                setState(() {
                  recentSearches.clear();
                });
              },
              child: Text(
                'Clear',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),
        ...recentSearches.map((search) => _buildRecentSearchTile(search)),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      onSelected: (bool selected) {
        // Handle filter selection
      },
      backgroundColor: AppColors.cardBackground,
      selectedColor: AppColors.primary,
    );
  }

  Widget _buildTrendingChip(String label) {
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onPressed: () {
        setState(() {
          _searchController.text = label;
          _searchQuery = label;
        });
      },
    );
  }

  Widget _buildRecentSearchTile(String search) {
    return ListTile(
      leading: const Icon(Icons.history, color: AppColors.primary),
      title: Text(search),
      trailing: IconButton(
        icon: const Icon(Icons.close, color: AppColors.textSecondary),
        onPressed: () {
          setState(() {
            recentSearches.remove(search);
          });
        },
      ),
      onTap: () {
        setState(() {
          _searchController.text = search;
          _searchQuery = search;
        });
      },
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter By', style: AppTextStyles.heading2),
            const SizedBox(height: 16),
            // Add your filter options here
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Category'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Handle category filter
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Cooking Time'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Handle time filter
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Difficulty Level'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Handle difficulty filter
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
}
