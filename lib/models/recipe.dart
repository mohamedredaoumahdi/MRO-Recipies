
import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String title;
  final String description;
  final String category;
  final String createdBy;
  final DateTime createdAt;
  final List<String> ingredients;
  final List<String> steps;
  final String imageUrl;
  final int prepTime;
  final int cookTime;
  final int servings;
  final String difficulty;
  final String? videoUrl;
  final List<String>? tags;
  final int? calories;
  final int likesCount;
  final int commentsCount;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdBy,
    required this.createdAt,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.difficulty,
    this.videoUrl,
    this.tags,
    this.calories,
    this.likesCount = 0,
    this.commentsCount = 0,
  });


  // Add the totalTime getter here
  int get totalTime => prepTime + cookTime;


  
  // Convert Recipe object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'ingredients': ingredients,
      'steps': steps,
      'imageUrl': imageUrl,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'difficulty': difficulty,
      'videoUrl': videoUrl,
      'tags': tags,
      'calories': calories,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
    };
  }

    // Add this factory constructor for easier testing
  factory Recipe.fromMap(String id, Map<String, dynamic> data) {
    return Recipe(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      ingredients: List<String>.from(data['ingredients'] ?? []),
      steps: List<String>.from(data['steps'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
      prepTime: data['prepTime'] ?? 0,
      cookTime: data['cookTime'] ?? 0,
      servings: data['servings'] ?? 0,
      difficulty: data['difficulty'] ?? 'Easy',
      videoUrl: data['videoUrl'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      calories: data['calories'],
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
    );
  }

  // Then modify your fromFirestore to use the new method
  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Recipe.fromMap(doc.id, data);
  }

}