import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  final VoidCallback onBack;

  const SearchScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack, // Call the function passed from BottomNavBar
        ),
        title: const Text('Search'),
      ),
      body: const Center(
        child: Text('Search Screen Content'),
      ),
    );
  }
}
