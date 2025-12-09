import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/recipe_service.dart';
import '../models/recipe.dart';

class RandomRecipeScreen extends StatelessWidget {
  static const routeName = '/random-recipe';

  const RandomRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeService = Provider.of<RecipeService>(context, listen: false);

    // Optional: pass recipe id in arguments from notification
    final recipeId = ModalRoute.of(context)?.settings.arguments as String?;
    Recipe recipe;
    if (recipeId != null) {
      recipe = recipeService.getById(recipeId) ?? recipeService.getRandomRecipe();
    } else {
      recipe = recipeService.getRandomRecipe();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Recipe of the Day')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recipe.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            if (recipe.imageUrl.isNotEmpty)
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Image.network(recipe.imageUrl, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Text(recipe.description),
          ],
        ),
      ),
    );
  }
}
