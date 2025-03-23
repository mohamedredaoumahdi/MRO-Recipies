import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';
import 'package:moroccan_recipies_app/service/recipe_service.dart';
import 'package:moroccan_recipies_app/service/auth_service.dart';
import 'package:moroccan_recipies_app/screens/recipe_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

class SearchScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SearchScreen({super.key, required this.onBack});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final RecipeService _recipeService = RecipeService();
  final AuthService _authService = AuthService();
  String _searchQuery = '';
  String _selectedCategory = '';
  String _selectedDifficulty = '';
  RangeValues _timeRange = const RangeValues(0, 120);
  bool _isLoading = false;
  bool _filtersVisible = false;
  Timer? _debounce;
  List<String> _recentSearches = [];
  bool _showClearButton = false;
  late AnimationController _animationController;
  late Animation<double> _filtersAnimation;
  final FocusNode _searchFocusNode = FocusNode();
  
  // Placeholder trending data
  final List<String> _trendingSearches = [
    'Tagine', 'Couscous', 'Pastilla', 'Harira', 'Rfissa', 'Mint Tea'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      setState(() {
        _filtersVisible = false;
      });
    });
    _loadRecentSearches();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _filtersAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _showClearButton = _searchController.text.isNotEmpty;
    });
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }
  
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }
  
  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recentSearches', _recentSearches);
  }
  
  void _addToRecentSearches(String query) {
    if (query.isEmpty) return;
    
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      
      // Limit to 5 recent searches
      if (_recentSearches.length > 5) {
        _recentSearches = _recentSearches.sublist(0, 5);
      }
    });
    
    _saveRecentSearches();
  }
  
  Future<void> _clearRecentSearches() async {
    setState(() {
      _recentSearches = [];
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recentSearches');
  }
  
  void _toggleFilters() {
    setState(() {
      _filtersVisible = !_filtersVisible;
    });
    
    if (_filtersVisible) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
  
  void _resetFilters() {
    setState(() {
      _selectedCategory = '';
      _selectedDifficulty = '';
      _timeRange = const RangeValues(0, 120);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search header
            _buildSearchHeader(),
            
            // Filter section
            SizeTransition(
              sizeFactor: _filtersAnimation,
              child: _buildFilters(),
            ),
            
            // Results or suggestions
            Expanded(
              child: _searchQuery.isEmpty 
                  ? _buildSuggestions() 
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
              
              // Search field
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search Moroccan recipes...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _showClearButton
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        _searchQuery = value;
                        _addToRecentSearches(value);
                      });
                    },
                  ),
                ),
              ),
              
              // Filter button
              IconButton(
                icon: Icon(
                  Icons.tune,
                  color: _filtersVisible || _hasActiveFilters()
                      ? AppColors.primary
                      : Colors.grey,
                ),
                onPressed: _toggleFilters,
              ),
            ],
          ),
          
          // Active filter chips
          if (_hasActiveFilters() && !_filtersVisible)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_selectedCategory.isNotEmpty)
                      _buildFilterChip(
                        label: _selectedCategory,
                        onRemove: () {
                          setState(() {
                            _selectedCategory = '';
                          });
                        },
                      ),
                    if (_selectedDifficulty.isNotEmpty)
                      _buildFilterChip(
                        label: _selectedDifficulty,
                        onRemove: () {
                          setState(() {
                            _selectedDifficulty = '';
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip({required String label, required VoidCallback onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
  
  bool _hasActiveFilters() {
    return _selectedCategory.isNotEmpty || 
           _selectedDifficulty.isNotEmpty || 
           _timeRange.start > 0 || 
           _timeRange.end < 120;
  }
  
  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.black12,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with reset button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: Text(
                  'Reset All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Categories
          Text(
            'Category',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryOption('Breakfast'),
                _buildCategoryOption('Lunch'),
                _buildCategoryOption('Dinner'),
                _buildCategoryOption('Snack'),
                _buildCategoryOption('Dessert'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Difficulty
          Text(
            'Difficulty',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildDifficultyOption('Easy', Colors.green),
              _buildDifficultyOption('Medium', Colors.orange),
              _buildDifficultyOption('Hard', Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          
          // Time range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Time',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${_timeRange.start.round()} - ${_timeRange.end.round()} min',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withOpacity(0.2),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
              valueIndicatorColor: AppColors.primary,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
              ),
            ),
            child: RangeSlider(
              values: _timeRange,
              min: 0,
              max: 120,
              divisions: 12,
              labels: RangeLabels(
                '${_timeRange.start.round()} min',
                '${_timeRange.end.round()} min',
              ),
              onChanged: (values) {
                setState(() {
                  _timeRange = values;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _toggleFilters();
                setState(() {
                  _searchQuery = _searchQuery.isEmpty ? ' ' : _searchQuery;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryOption(String category) {
    final bool isSelected = _selectedCategory == category;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = isSelected ? '' : category;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _getCategoryColor(category) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _getCategoryColor(category) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  Widget _buildDifficultyOption(String difficulty, Color color) {
    final bool isSelected = _selectedDifficulty == difficulty;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDifficulty = isSelected ? '' : difficulty;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              difficulty,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSuggestions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Recent searches
        if (_recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: _clearRecentSearches,
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._recentSearches.map((search) => _buildSearchItem(
            icon: Icons.history,
            text: search,
            onTap: () {
              setState(() {
                _searchController.text = search;
                _searchQuery = search;
              });
            },
          )),
          const SizedBox(height: 24),
        ],
        
        // Trending searches
        Text(
          'Trending Searches',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _trendingSearches.map((search) => GestureDetector(
            onTap: () {
              setState(() {
                _searchController.text = search;
                _searchQuery = search;
                _addToRecentSearches(search);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(search),
                ],
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 24),
        
        // Popular categories
        Text(
          'Popular Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCategoryCard('Tajine', 'Dinner'),
            _buildCategoryCard('Couscous', 'Lunch'),
            _buildCategoryCard('Pastries', 'Dessert'),
            _buildCategoryCard('Breakfast', 'Breakfast'),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSearchItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Icon(Icons.north_west, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoryCard(String title, String category) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
          _searchQuery = ' '; // Trigger search with empty query but with category filter
        });
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: _getCategoryColor(category).withOpacity(0.2),
              child: Center(
                child: Icon(
                  _getCategoryIcon(category),
                  size: 40,
                  color: _getCategoryColor(category),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCategoryColor(category),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchResults() {
    return StreamBuilder<List<Recipe>>(
      stream: _recipeService.searchRecipes(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorView('Error loading recipes: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final recipes = snapshot.data ?? [];
        
        // Apply filters
        final List<Recipe> filteredRecipes = recipes.where((recipe) {
          // Filter by category if selected
          if (_selectedCategory.isNotEmpty && recipe.category != _selectedCategory) {
            return false;
          }
          
          // Filter by difficulty if selected
          if (_selectedDifficulty.isNotEmpty && recipe.difficulty != _selectedDifficulty) {
            return false;
          }
          
          // Filter by time range
          final totalTime = recipe.prepTime + recipe.cookTime;
          if (totalTime < _timeRange.start || totalTime > _timeRange.end) {
            return false;
          }
          
          return true;
        }).toList();

        if (filteredRecipes.isEmpty) {
          return _buildEmptyView();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredRecipes.length,
          itemBuilder: (context, index) {
            return _buildRecipeCard(filteredRecipes[index]);
          },
        );
      },
    );
  }
  
  Widget _buildRecipeCard(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailsPage(recipe: recipe),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Image and category badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.memory(
                    base64Decode(recipe.imageUrl),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(Icons.broken_image, color: Colors.grey[400]),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(recipe.category),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      recipe.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.timer,
                          color: Colors.white,
                          size: 12,
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
                ),
              ],
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Difficulty
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recipe.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(recipe.difficulty).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getDifficultyIcon(recipe.difficulty),
                              size: 14,
                              color: _getDifficultyColor(recipe.difficulty),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              recipe.difficulty,
                              style: TextStyle(
                                fontSize: 12,
                                color: _getDifficultyColor(recipe.difficulty),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    recipe.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // Bottom metadata
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Author
                      FutureBuilder<String?>(
                        future: _authService.getUsernameById(recipe.createdBy),
                        builder: (context, snapshot) {
                          return Row(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'By ${snapshot.data ?? 'Unknown'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      
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
                            '${recipe.calories} kcal',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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
    );
  }
  
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'No recipes found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _hasActiveFilters()
                ? 'Try changing your filters'
                : 'Try a different search term',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_hasActiveFilters())
            ElevatedButton(
              onPressed: _resetFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Reset Filters'),
            ),
        ],
      ),
    );
  }
  
  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.error.withOpacity(0.7),
          ),
          const SizedBox(height: 24),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = _searchController.text;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Try Again'),
          ),
        ],
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
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      case 'dessert':
        return Icons.cake;
      default:
        return Icons.restaurant_menu;
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