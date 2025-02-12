import 'package:flutter/material.dart';

class BookmarkManager with ChangeNotifier {
  List<String> _bookmarkedRecipeIds = [];

  List<String> get bookmarkedRecipeIds => _bookmarkedRecipeIds;

  void addBookmark(String recipeId) {
    if (!_bookmarkedRecipeIds.contains(recipeId)) {
      _bookmarkedRecipeIds.add(recipeId);
      notifyListeners(); // Notify listeners about the change
    }
  }

  void removeBookmark(String recipeId) {
    if (_bookmarkedRecipeIds.contains(recipeId)) {
      _bookmarkedRecipeIds.remove(recipeId);
      notifyListeners(); // Notify listeners about the change
    }
  }

  bool isBookmarked(String recipeId) {
    return _bookmarkedRecipeIds.contains(recipeId);
  }

  Future<void> loadBookmarks() async {
    // Load bookmarks from shared preferences or database
    // Update _bookmarkedRecipeIds and call notifyListeners()
  }

  Future<void> saveBookmarks() async {
    // Save _bookmarkedRecipeIds to shared preferences or database
  }
} 