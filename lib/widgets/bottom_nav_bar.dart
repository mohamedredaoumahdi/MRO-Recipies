import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/screens/home_screen.dart';
import 'package:moroccan_recipies_app/screens/search_screen.dart';
import 'package:moroccan_recipies_app/screens/bookmark_screen.dart';
import 'package:moroccan_recipies_app/screens/profile_screen.dart';
import 'package:moroccan_recipies_app/screens/add_recipe_screen.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';
import 'package:moroccan_recipies_app/service/auth_service.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeContent(),
      SearchScreen(
        onBack: () {
          setState(() {
            _selectedIndex = 0;
          });
          _pageController.jumpToPage(0);
        },
      ),
      BookmarkScreen(
        onBack: () {
          setState(() {
            _selectedIndex = 0;
          });
          _pageController.jumpToPage(0);
        },
      ),
      ProfileScreen(
        onBack: () {
          setState(() {
            _selectedIndex = 0;
          });
          _pageController.jumpToPage(0);
        },
      ),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: screens,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        floatingActionButton: FutureBuilder<bool>(
          future: _authService.isCurrentUserAdmin(),
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
                  );
                },
                backgroundColor: AppColors.primary,
                elevation: 4,
                child: const Icon(Icons.add),
              );
            }
            return const SizedBox.shrink(); // Hide button for non-admin users
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomAppBar(
              height: 60,
              padding: EdgeInsets.zero,
              notchMargin: 10.0,
              color: Colors.white,
              elevation: 0,
              shape: const CircularNotchedRectangle(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.home_filled,
                    label: 'Home',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.search,
                    label: 'Search',
                    index: 1,
                  ),
                  const SizedBox(width: 20),
                  _buildNavItem(
                    icon: Icons.bookmark,
                    label: 'Saved',
                    index: 2,
                  ),
                  _buildNavItem(
                    icon: Icons.person,
                    label: 'Profile',
                    index: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for navigation items
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? AppColors.primary
                    : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      _pageController.jumpToPage(0);
      return false;
    }
    return true;
  }
}