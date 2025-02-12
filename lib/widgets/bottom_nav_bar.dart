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
      HomeContent(),
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
                child: const Icon(Icons.add),
              );
            }
            return const SizedBox.shrink(); // Hide button for non-admin users
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          height: 40,
          padding: EdgeInsets.zero,
          notchMargin: 12.0,
          color: Colors.white,
          elevation: 0,
          shape: const CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home_filled,
                  color: _selectedIndex == 0 
                      ? Theme.of(context).primaryColor 
                      : const Color(0xFFADB5BD),
                  size: 26,
                ),
                onPressed: () => _onItemTapped(0),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: _selectedIndex == 1 
                      ? Theme.of(context).primaryColor 
                      : const Color(0xFFADB5BD),
                  size: 26,
                ),
                onPressed: () => _onItemTapped(1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: Icon(
                  Icons.bookmark,
                  color: _selectedIndex == 2 
                      ? Theme.of(context).primaryColor 
                      : const Color(0xFFADB5BD),
                  size: 26,
                ),
                onPressed: () => _onItemTapped(2),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              IconButton(
                icon: Icon(
                  Icons.person,
                  color: _selectedIndex == 3 
                      ? Theme.of(context).primaryColor 
                      : const Color(0xFFADB5BD),
                  size: 26,
                ),
                onPressed: () => _onItemTapped(3),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
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
