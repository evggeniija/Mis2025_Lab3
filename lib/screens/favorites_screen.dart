import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import 'meal_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;

    if (favorites.isEmpty) {
      return const Center(child: Text('No favorite recipes yet.'));
    }

    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final meal = favorites[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              meal.thumbnail,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(meal.name),
          subtitle: Text(meal.category ?? ''),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MealDetailScreen(mealId: meal.id, meal: meal),
              ),
            );
          },
        );
      },
    );
  }
}
