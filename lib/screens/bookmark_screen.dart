import 'package:flutter/material.dart';

class BookmarkScreen extends StatelessWidget {
  final VoidCallback onBack;

  const BookmarkScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Bookmarks'),
      ),
      body: const Center(
        child: Text('Bookmark Screen Content'),
      ),
    );
  }
}
