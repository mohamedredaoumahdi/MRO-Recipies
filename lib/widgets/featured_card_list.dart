import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';
import 'package:moroccan_recipies_app/widgets/featured_card.dart';
import 'package:moroccan_recipies_app/service/recipe_service.dart';

class FeaturedCardList extends StatefulWidget {
  const FeaturedCardList({Key? key}) : super(key: key);

  @override
  _FeaturedCardListState createState() => _FeaturedCardListState();
}

class _FeaturedCardListState extends State<FeaturedCardList> {
  final RecipeService _recipeService = RecipeService();
  late Future<List<Recipe>> _featuredRecipesFuture;

  @override
  void initState() {
    super.initState();
    _featuredRecipesFuture = _recipeService.getTopLikedRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      future: _featuredRecipesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final recipes = snapshot.data ?? [];

        return SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Row(
                children: [
                  FeaturedCard(
                    title: recipe.title,
                    recipe: recipe,
                    duration: '${recipe.prepTime + recipe.cookTime} Min',
                  ),
                  if (index < recipes.length - 1) const SizedBox(width: 12),
                ],
              );
            },
          ),
        );
      },
    );
  }
} 