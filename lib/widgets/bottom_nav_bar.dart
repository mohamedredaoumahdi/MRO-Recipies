import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/screens/home_screen.dart';
import 'package:moroccan_recipies_app/screens/search_screen.dart';
import 'package:moroccan_recipies_app/screens/bookmark_screen.dart';
import 'package:moroccan_recipies_app/screens/profile_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0; // Navigate back to the home page
      });
      _pageController.jumpToPage(0);
      return false; // Prevent the default back navigation
    }
    return true; // Allow the default back navigation
  }

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
          physics: const NeverScrollableScrollPhysics(), // Prevent swiping
          children: screens,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Bookmark'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
