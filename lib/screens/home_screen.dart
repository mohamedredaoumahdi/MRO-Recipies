import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';
import 'package:moroccan_recipies_app/screens/all_featured_recipes_screen.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';
import 'package:moroccan_recipies_app/service/recipe_service.dart';
import 'package:moroccan_recipies_app/service/auth_service.dart';
import 'package:moroccan_recipies_app/screens/recipe_details_page.dart';
import 'package:moroccan_recipies_app/screens/search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moroccan_recipies_app/widgets/category_chip.dart';
import 'package:moroccan_recipies_app/widgets/recipe_card.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with TickerProviderStateMixin {
  final RecipeService _recipeService = RecipeService();
  final AuthService _authService = AuthService();
  String _selectedCategory = 'All';
  List<String> _bookmarkedRecipeIds = [];
  late Future<List<Recipe>> _featuredRecipesFuture;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  late TabController _categoryTabController;
  final List<String> _categories = ['All', 'Breakfast', 'Lunch', 'Dinner', 'Snack', 'Dessert'];
  
  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    _featuredRecipesFuture = _recipeService.getTopLikedRecipes();
    _categoryTabController = TabController(length: _categories.length, vsync: this);
    
    _categoryTabController.addListener(() {
      if (!_categoryTabController.indexIsChanging) {
        setState(() {
          _selectedCategory = _categories[_categoryTabController.index];
        });
      }
    });
    
    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _categoryTabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Load bookmarks from shared preferences
  void _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bookmarkedRecipeIds = prefs.getStringList('bookmarkedRecipes') ?? [];
    });
  }

  // Save bookmarks to shared preferences
  void _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('bookmarkedRecipes', _bookmarkedRecipeIds);
  }
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
  
  IconData _getTimeIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return Icons.wb_sunny_outlined;
    } else if (hour < 17) {
      return Icons.wb_sunny;
    } else {
      return Icons.wb_twilight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            setState(() {
              _isLoading = true;
            });
            _featuredRecipesFuture = _recipeService.getTopLikedRecipes();
            await Future.delayed(const Duration(milliseconds: 800));
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          child: _isLoading ? _buildLoadingView() : _buildContentView(),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        if (index == 0) {
          // Header shimmer loading effect
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerContainer(height: 24, width: 200),
              const SizedBox(height: 8),
              _buildShimmerContainer(height: 18, width: 150),
              const SizedBox(height: 24),
            ],
          );
        } else if (index == 1) {
          // Featured section loading
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerContainer(height: 24, width: 160),
              const SizedBox(height: 16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        } else if (index == 2) {
          // Categories loading
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerContainer(height: 24, width: 120),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    5,
                    (i) => Container(
                      width: 100,
                      height: 40,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        } else {
          // Recipe cards loading
          return Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerContainer(height: 16, width: double.infinity),
                      const SizedBox(height: 8),
                      _buildShimmerContainer(height: 14, width: 100),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildShimmerContainer(height: 12, width: 80),
                          _buildShimmerContainer(height: 12, width: 60),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildShimmerContainer({
    required double height,
    required double width,
    double borderRadius = 4,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  Widget _buildContentView() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting and search
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getTimeIcon(),
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getGreeting(),
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<String?>(
                          future: _authService.getCurrentUsername(),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? 'Guest',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    _buildSearchButton(),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Featured recipes section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Recipes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllFeaturedRecipesScreen(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            'View all',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Recipe>>(
                  future: _featuredRecipesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return _buildErrorView('Error loading featured recipes');
                    }

                    final featuredRecipes = snapshot.data ?? [];
                    if (featuredRecipes.isEmpty) {
                      return _buildEmptyView('No featured recipes available');
                    }

                    return SizedBox(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: featuredRecipes.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: RecipeCard(
                              recipe: featuredRecipes[index],
                              bookmarkedRecipeIds: _bookmarkedRecipeIds,
                              onBookmarkUpdated: _loadBookmarks,
                              featured: true,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Categories section
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _categoryTabController,
                  isScrollable: true,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  tabs: _categories.map((category) => Tab(text: category)).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // Recipes grid based on selected category
        StreamBuilder<List<Recipe>>(
          stream: _recipeService.getRecipes(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return SliverFillRemaining(
                child: _buildErrorView('Error loading recipes'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final recipes = snapshot.data ?? [];
            
            // Filter recipes based on selected category
            final filteredRecipes = _selectedCategory == 'All' 
                ? recipes 
                : recipes.where((recipe) => recipe.category == _selectedCategory).toList();
            
            if (filteredRecipes.isEmpty) {
              return SliverFillRemaining(
                child: _buildEmptyView('No recipes found in $_selectedCategory category'),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return RecipeCard(
                      recipe: filteredRecipes[index],
                      bookmarkedRecipeIds: _bookmarkedRecipeIds,
                      onBookmarkUpdated: _loadBookmarks,
                    );
                  },
                  childCount: filteredRecipes.length,
                ),
              ),
            );
          },
        ),
        
        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  Widget _buildSearchButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchScreen(onBack: () {
            Navigator.pop(context);
          })),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.search, color: AppColors.textPrimary),
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
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              
              // Refresh data
              _featuredRecipesFuture = _recipeService.getTopLikedRecipes();
              
              // Set loading to false after a delay
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
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
}