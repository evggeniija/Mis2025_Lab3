import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal.dart';
import '../services/api_service.dart';
import '../providers/favorites_provider.dart';
import 'package:url_launcher/url_launcher.dart';


class MealDetailScreen extends StatefulWidget {
  final String mealId;
  final Meal? meal; // optional pre-fetched

  const MealDetailScreen({super.key, required this.mealId, this.meal});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final ApiService _apiService = ApiService();
  Meal? _meal;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.meal != null && widget.meal!.instructions != null) {
      _meal = widget.meal;
      _isLoading = false;
    } else {
      _loadMealDetail();
    }
  }

  Future<void> _loadMealDetail() async {
    try {
      final meal = await _apiService.fetchMealDetail(widget.mealId);
      setState(() {
        _meal = meal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading meal detail: $e')),
      );
    }
  }

  void _toggleFavorite(FavoritesProvider favs) {
    if (_meal == null) return;
    favs.toggleFavorite(_meal!);
  }

  Future<void> _openYoutube(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open YouTube link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favs = Provider.of<FavoritesProvider>(context);
    final meal = _meal;

    return Scaffold(
      appBar: AppBar(
        title: Text(meal?.name ?? 'Recipe'),
        actions: [
          if (meal != null)
            IconButton(
              icon: Icon(
                favs.isFavorite(meal.id) ? Icons.favorite : Icons.favorite_border,
              ),
              onPressed: () => _toggleFavorite(favs),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : meal == null
          ? const Center(child: Text('Meal not found.'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(meal.thumbnail),
            ),
            const SizedBox(height: 12),
            Text(
              meal.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (meal.category != null || meal.area != null)
              Text(
                '${meal.category ?? ''} • ${meal.area ?? ''}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 16),
            Text(
              'Ingredients',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...meal.ingredients.map(
                  (ing) => Text('• ${ing.ingredient} - ${ing.measure}'),
            ),
            const SizedBox(height: 16),
            Text(
              'Instructions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(meal.instructions ?? ''),
            const SizedBox(height: 16),
            if (meal.youtubeUrl != null &&
                meal.youtubeUrl!.trim().isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _openYoutube(meal.youtubeUrl!),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Watch on YouTube'),
              ),
          ],
        ),
      ),
    );
  }
}
