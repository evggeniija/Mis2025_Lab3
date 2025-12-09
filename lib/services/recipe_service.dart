import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/recipe.dart';

class RecipeService extends ChangeNotifier {
  final List<Recipe> _recipes = [
    Recipe(
      id: '1',
      title: 'Pasta Carbonara',
      description: 'Classic Italian pasta with eggs, cheese and pancetta.',
      imageUrl: 'https://example.com/pasta.jpg',
    ),
    Recipe(
      id: '2',
      title: 'Chicken Curry',
      description: 'Spicy curry with rice.',
      imageUrl: 'https://example.com/curry.jpg',
    ),
    // add more recipes...
  ];

  List<Recipe> get recipes => List.unmodifiable(_recipes);

  List<Recipe> get favoriteRecipes =>
      _recipes.where((r) => r.isFavorite).toList(growable: false);

  void toggleFavorite(String id) {
    final index = _recipes.indexWhere((r) => r.id == id);
    if (index == -1) return;
    _recipes[index].isFavorite = !_recipes[index].isFavorite;
    notifyListeners();
  }

  Recipe getRandomRecipe() {
    final rnd = Random();
    return _recipes[rnd.nextInt(_recipes.length)];
  }

  Recipe? getById(String id) {
    try {
      return _recipes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
