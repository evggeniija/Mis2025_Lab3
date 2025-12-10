import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/meal.dart';

class ApiService {
  static const String _baseUrl = 'www.themealdb.com';

  Future<List<Category>> fetchCategories() async {
    final uri = Uri.https(_baseUrl, '/api/json/v1/1/categories.php');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final categoriesJson = data['categories'] as List<dynamic>;
      return categoriesJson
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Meal>> fetchMealsByCategory(String category) async {
    final uri =
    Uri.https(_baseUrl, '/api/json/v1/1/filter.php', {'c': category});
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final mealsJson = data['meals'] as List<dynamic>;
      return mealsJson
          .map((e) => Meal.fromSummaryJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load meals');
    }
  }

  /// Search meals by text, then filter locally by category (to satisfy lab requirement).
  Future<List<Meal>> searchMealsInCategory(
      String category, String query) async {
    final uri =
    Uri.https(_baseUrl, '/api/json/v1/1/search.php', {'s': query});
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final mealsJson = data['meals'] as List<dynamic>?;
      if (mealsJson == null) return [];
      return mealsJson
          .map((e) => Meal.fromDetailJson(e as Map<String, dynamic>))
          .where((m) => m.category == category)
          .toList();
    } else {
      throw Exception('Failed to search meals');
    }
  }

  Future<Meal> fetchMealDetail(String id) async {
    final uri =
    Uri.https(_baseUrl, '/api/json/v1/1/lookup.php', {'i': id});
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final mealsJson = data['meals'] as List<dynamic>;
      return Meal.fromDetailJson(mealsJson.first as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load meal detail');
    }
  }

  Future<Meal> fetchRandomMeal() async {
    final uri = Uri.https(_baseUrl, '/api/json/v1/1/random.php');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final mealsJson = data['meals'] as List<dynamic>;
      return Meal.fromDetailJson(mealsJson.first as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load random meal');
    }
  }
}
