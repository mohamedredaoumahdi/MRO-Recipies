import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';
import 'image_service.dart';

class RecipeService {
  final CollectionReference _recipesCollection = 
      FirebaseFirestore.instance.collection('recipes');
  final ImageService _imageService = ImageService();

  // Create a new recipe with image
  Future<String> createRecipeWithImage(Recipe recipe, File imageFile) async {
    try {
      // Convert image to base64
      final String base64Image = await _imageService.convertImageToBase64(imageFile);
      
      // Create recipe with the base64 image
      final recipeWithImage = Recipe(
        id: recipe.id,
        title: recipe.title,
        description: recipe.description,
        category: recipe.category,
        createdBy: recipe.createdBy,
        createdAt: recipe.createdAt,
        ingredients: recipe.ingredients,
        steps: recipe.steps,
        imageUrl: base64Image, // Store base64 string instead of URL
        prepTime: recipe.prepTime,
        cookTime: recipe.cookTime,
        servings: recipe.servings,
        difficulty: recipe.difficulty,
        videoUrl: recipe.videoUrl,
        tags: recipe.tags,
        calories: recipe.calories,
        likesCount: recipe.likesCount,
        commentsCount: recipe.commentsCount,
      );

      // Save to Firestore
      DocumentReference docRef = await _recipesCollection.add(recipeWithImage.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Failed to create recipe: $e';
    }
  }

  // Update recipe with new image
  Future<void> updateRecipeWithImage(String id, Map<String, dynamic> data, {File? newImageFile, String? oldImageUrl}) async {
    try {
      // If there's a new image, upload it and update the URL
      if (newImageFile != null) {
        // Delete old image if it exists
        if (oldImageUrl != null) {
          await _imageService.deleteImage(oldImageUrl);
        }
        
        // Upload new image
        final newImageUrl = await _imageService.uploadRecipeImage(newImageFile);
        data['imageUrl'] = newImageUrl;
      }

      // Update the recipe document
      await _recipesCollection.doc(id).update(data);
    } catch (e) {
      throw 'Failed to update recipe: $e';
    }
  }

  // Get all recipes
  Stream<List<Recipe>> getRecipes() {
    return _recipesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
    });
  }

  // Get recipes by category
  Stream<List<Recipe>> getRecipesByCategory(String category) {
    return _recipesCollection
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
    });
  }

  // Get a single recipe by ID
  Future<Recipe?> getRecipeById(String id) async {
    try {
      DocumentSnapshot doc = await _recipesCollection.doc(id).get();
      if (doc.exists) {
        return Recipe.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get recipe: $e';
    }
  }

  // Update a recipe
  Future<void> updateRecipe(String id, Map<String, dynamic> data) async {
    try {
      await _recipesCollection.doc(id).update(data);
    } catch (e) {
      throw 'Failed to update recipe: $e';
    }
  }

  // Delete a recipe
  Future<void> deleteRecipe(String id) async {
    try {
      await _recipesCollection.doc(id).delete();
    } catch (e) {
      throw 'Failed to delete recipe: $e';
    }
  }

  // Search recipes by title or tags
  Stream<List<Recipe>> searchRecipes(String query) {
    return _recipesCollection
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: '${query}z')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
    });
  }

  // Update likes count
  Future<void> updateLikesCount(String recipeId, int count) async {
    try {
      await _recipesCollection.doc(recipeId).update({'likesCount': count});
    } catch (e) {
      throw 'Failed to update likes count: $e';
    }
  }

  // Update comments count
  Future<void> updateCommentsCount(String recipeId, int count) async {
    try {
      await _recipesCollection.doc(recipeId).update({'commentsCount': count});
    } catch (e) {
      throw 'Failed to update comments count: $e';
    }
  }

  Future<String> getUserName(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        return userData?['fullName'] ?? userData?['displayName'] ?? userId;
      }
      return userId;
    } catch (e) {
      return userId;
    }
  }
}