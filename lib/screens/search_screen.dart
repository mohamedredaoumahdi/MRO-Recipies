import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Example data - replace with your actual data
  final List<String> trendingSearches = [
    'Couscous', 'Tajine', 'Pastilla', 'Harira', 'Rfissa'
  ];
  
  final List<String> recentSearches = [
    'Moroccan Bread', 'Mint Tea', 'Chicken Tajine'
  ];

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

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Row(
                children: [
                  _buildFilterChip('Category'),
                  SizedBox(width: screenWidth * 0.02),
                  _buildFilterChip('Ingredients'),
                  SizedBox(width: screenWidth * 0.02),
                  _buildFilterChip('Cooking Time'),
                  SizedBox(width: screenWidth * 0.02),
                  _buildFilterChip('Difficulty'),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.all(screenWidth * 0.04),
                children: [
                  // Trending Searches
                  Text(
                    'Trending Searches',
                    style: AppTextStyles.heading2,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Wrap(
                    spacing: screenWidth * 0.02,
                    children: trendingSearches
                        .map((search) => _buildTrendingChip(search))
                        .toList(),
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // Recent Searches
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Searches',
                        style: AppTextStyles.heading2,
                      ),
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
              ),
            ),
          ],
        ),
      ),
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
          SizedBox(width: 4),
          Text(label),
        ],
      ),
      onPressed: () {
        // Handle trending search selection
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
        // Handle recent search selection
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
}
