import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';
import 'package:moroccan_recipies_app/service/recipe_service.dart';
import 'package:moroccan_recipies_app/screens/recipe_details_page.dart';
import 'dart:convert';
import 'dart:async';
import 'package:moroccan_recipies_app/service/auth_service.dart';
import 'package:moroccan_recipies_app/widgets/book_search_recipe_card.dart';
import 'package:moroccan_recipies_app/widgets/common/moroccan_components.dart';

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
            // Enhanced Search Bar with Animated Transition
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: widget.onBack,
                      ),
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(screenWidth * 0.04),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search Moroccan recipes...',
                              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onChanged: (value) {
                              if (_debounce?.isActive ?? false) _debounce!.cancel();
                              _debounce = Timer(const Duration(milliseconds: 500), () {
                                setState(() {
                                  _searchQuery = value;
                                });
                              });
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color: _selectedCategory.isEmpty
                              ? AppColors.textSecondary
                              : AppColors.primary,
                        ),
                        onPressed: () => _showFilters(context),
                      ),
                    ],
                  ),
                  
                  // Filter Chips (if filters selected)
                  if (_selectedCategory.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const Text('Filters:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(_selectedCategory),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() {
                                _selectedCategory = '';
                              });
                            },
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            deleteIconColor: AppColors.primary,
                            labelStyle: TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                ],
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
    return StreamBuilder<List<Recipe>>(
      stream: _recipeService.searchRecipes(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorView(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final recipes = snapshot.data ?? [];
        
        // Filter by category if selected
        final filteredRecipes = _selectedCategory.isEmpty
            ? recipes
            : recipes.where((recipe) => recipe.category == _selectedCategory).toList();

        if (filteredRecipes.isEmpty) {
          return _buildEmptyResultsView();
        }

        return ListView.builder(
          padding: EdgeInsets.all(screenWidth * 0.04),
          itemCount: filteredRecipes.length,
          itemBuilder: (context, index) {
            final recipe = filteredRecipes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BookSearchRecipeCard(recipe: recipe, context: context),
            );
          },
        );
      },
    );
  }
  
  Widget _buildDefaultContent(double screenWidth, double screenHeight) {
    return ListView(
      padding: EdgeInsets.all(screenWidth * 0.04),
      children: [
        // Popular Categories Section
        Text('Popular Categories', style: AppTextStyles.heading2),
        SizedBox(height: screenHeight * 0.02),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildCategoryCard('Tajine', 'assets/images/welcomephoto1.jpg', 'Dinner'),
            _buildCategoryCard('Couscous', 'assets/images/welcomephoto1.jpg', 'Lunch'),
            _buildCategoryCard('Pastries', 'assets/images/welcomephoto1.jpg', 'Dessert'),
            _buildCategoryCard('Breakfast', 'assets/images/welcomephoto1.jpg', 'Breakfast'),
          ],
        ),

        SizedBox(height: screenHeight * 0.03),
        
        // Trending Searches
        Text('Trending Searches', style: AppTextStyles.heading2),
        SizedBox(height: screenHeight * 0.02),
        Wrap(
          spacing: screenWidth * 0.02,
          runSpacing: screenHeight * 0.01,
          children: [
            _buildTrendingChip('Tajine'),
            _buildTrendingChip('Couscous'),
            _buildTrendingChip('Pastilla'),
            _buildTrendingChip('Harira'),
            _buildTrendingChip('Rfissa'),
            _buildTrendingChip('Mint Tea'),
          ],
        ),
        
        SizedBox(height: screenHeight * 0.03),
        
        // Recent Searches
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Searches', style: AppTextStyles.heading2),
            if (recentSearches.isNotEmpty)
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
        SizedBox(height: screenHeight * 0.01),
        if (recentSearches.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No recent searches',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          ...recentSearches.map((search) => _buildRecentSearchTile(search)),
      ],
    );
  }
  
  Widget _buildCategoryCard(String title, String imagePath, String category) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
          _searchQuery = '';
          _searchController.clear();
        });
      },
      child: Stack(
        children: [
          // Image and Gradient
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          
          // Title
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTrendingChip(String label) {
    return ActionChip(
      avatar: const Icon(
        Icons.trending_up,
        size: 16,
        color: AppColors.primary,
      ),
      label: Text(label),
      backgroundColor: AppColors.primary.withOpacity(0.1),
      labelStyle: TextStyle(color: AppColors.textPrimary),
      onPressed: () {
        setState(() {
          _searchController.text = label;
          _searchQuery = label;
          
          // Add to recent searches if not already present
          if (!recentSearches.contains(label)) {
            recentSearches.insert(0, label);
            if (recentSearches.length > 5) {
              recentSearches.removeLast();
            }
          }
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
  
  Widget _buildEmptyResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64, 
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No recipes found',
            style: AppTextStyles.heading3.copyWith(
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedCategory.isEmpty
                ? 'Try different keywords or filters'
                : 'Try removing the "$_selectedCategory" filter',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64, 
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = _searchController.text;
              });
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
  
  void _showFilters(BuildContext context) {
    final categories = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Dessert'];
    final difficulties = ['Easy', 'Medium', 'Hard'];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.2,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter By',
                    style: AppTextStyles.heading2,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = '';
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Reset',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Text(
                    'Categories',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : '';
                          });
                          Navigator.pop(context);
                        },
                        selectedColor: AppColors.primary,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Difficulty',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: difficulties.map((difficulty) {
                      return FilterChip(
                        label: Text(difficulty),
                        selected: false,
                        onSelected: (selected) {
                          // Add difficulty filtering logic
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Cooking Time',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 12),
                  // Add time range slider here
                  RangeSlider(
                    values: const RangeValues(10, 60),
                    min: 0,
                    max: 120,
                    divisions: 12,
                    labels: const RangeLabels('10 min', '60 min'),
                    onChanged: (values) {
                      // Update time range
                    },
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primary.withOpacity(0.2),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
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