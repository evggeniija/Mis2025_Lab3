import 'package:flutter/foundation.dart';
import '../models/meal.dart';

class FavoritesProvider extends ChangeNotifier {
  final Map<String, Meal> _favorites = {};

  List<Meal> get favorites => _favorites.values.toList();

  bool isFavorite(String mealId) => _favorites.containsKey(mealId);

  void toggleFavorite(Meal meal) {
    if (_favorites.containsKey(meal.id)) {
      _favorites.remove(meal.id);
    } else {
      _favorites[meal.id] = meal;
    }
    notifyListeners();
  }
}
