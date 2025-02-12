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

  // Search recipes by title
  Stream<List<Recipe>> searchRecipes(String query) {
    // Convert query to lowercase for case-insensitive search
    query = query.toLowerCase();
    
    return _recipesCollection
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Recipe.fromFirestore(doc))
              .where((recipe) => 
                  recipe.title.toLowerCase().contains(query) ||
                  recipe.description.toLowerCase().contains(query) ||
                  recipe.category.toLowerCase().contains(query) ||
                  recipe.ingredients.any((ingredient) => 
                      ingredient.toLowerCase().contains(query)))
              .toList();
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

  Future<bool> toggleLike(String recipeId, String userId) async {
    print('Toggling like for recipe: $recipeId, user: $userId'); // Debug print
    try {
      final userLikesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('likes')
          .doc(recipeId);

      final likeDoc = await userLikesRef.get();
      print('Like document exists: ${likeDoc.exists}'); // Debug print

      if (likeDoc.exists) {
        await userLikesRef.delete();
        print('Like removed'); // Debug print
        return false;
      } else {
        await userLikesRef.set({
          'timestamp': FieldValue.serverTimestamp(),
        });
        print('Like added'); // Debug print
        return true;
      }
    } catch (e) {
      print('Error in toggleLike: $e'); // Debug print
      throw e;
    }
  }

  Stream<List<Recipe>> getLikedRecipes(String userId) {
    print('Getting liked recipes for user: $userId'); // Debug print
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('likes')
        .snapshots()
        .asyncMap((snapshot) async {
          print('Likes snapshot size: ${snapshot.docs.length}'); // Debug print
          final recipes = <Recipe>[];
          for (var doc in snapshot.docs) {
            print('Processing like document: ${doc.id}'); // Debug print
            try {
              final recipeDoc = await FirebaseFirestore.instance
                  .collection('recipes')
                  .doc(doc.id)
                  .get();
              print('Recipe document exists: ${recipeDoc.exists}'); // Debug print
              if (recipeDoc.exists) {
                recipes.add(Recipe.fromFirestore(recipeDoc));
              }
            } catch (e) {
              print('Error fetching recipe: $e'); // Debug print
            }
          }
          print('Returning ${recipes.length} recipes'); // Debug print
          return recipes;
        });
  }

  Stream<bool> isLikedByUser(String recipeId, String userId) {
    return _recipesCollection
        .doc(userId)
        .collection('likes')
        .doc(recipeId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Stream<QuerySnapshot> getUserStats(String userId) {
    return _recipesCollection
        .where('createdBy', isEqualTo: userId)
        .snapshots();
  }
}