class Meal {
  final String id;
  final String name;
  final String thumbnail;
  final String? category;
  final String? area;
  final String? instructions;
  final String? youtubeUrl;
  final List<MealIngredient> ingredients;

  Meal({
    required this.id,
    required this.name,
    required this.thumbnail,
    this.category,
    this.area,
    this.instructions,
    this.youtubeUrl,
    this.ingredients = const [],
  });

  /// Summary meal (from filter/search endpoints)
  factory Meal.fromSummaryJson(Map<String, dynamic> json) {
    return Meal(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      thumbnail: json['strMealThumb'] as String,
    );
  }

  /// Detailed meal (from lookup/random/search full)
  factory Meal.fromDetailJson(Map<String, dynamic> json) {
    final ingredients = <MealIngredient>[];
    for (int i = 1; i <= 20; i++) {
      final ing = json['strIngredient$i'] as String?;
      final meas = json['strMeasure$i'] as String?;
      if (ing != null &&
          ing.trim().isNotEmpty &&
          (meas != null && meas.trim().isNotEmpty)) {
        ingredients.add(
          MealIngredient(
            ingredient: ing.trim(),
            measure: meas.trim(),
          ),
        );
      }
    }

    return Meal(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      thumbnail: json['strMealThumb'] as String,
      category: json['strCategory'] as String?,
      area: json['strArea'] as String?,
      instructions: json['strInstructions'] as String?,
      youtubeUrl: json['strYoutube'] as String?,
      ingredients: ingredients,
    );
  }
}

class MealIngredient {
  final String ingredient;
  final String measure;

  MealIngredient({required this.ingredient, required this.measure});
}
