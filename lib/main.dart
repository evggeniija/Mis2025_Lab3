
import 'dart:io' show Platform; // ⭐ Needed to check Windows

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/firebase_messaging_service.dart';
import 'services/recipe_service.dart';

import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/random_recipe_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ---------------------------------------------------------------
// 🔥 BACKGROUND MESSAGE HANDLER
// (Not supported on Web or Windows → safe skipped)
// ---------------------------------------------------------------
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kIsWeb || Platform.isWindows) return; // Skip on Web & Windows

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().showSimpleNotification(
    title: message.notification?.title ?? 'Recipe of the Day',
    body: message.notification?.body ?? 'Open the app to see a random recipe!',
    payload: message.data['recipeId'],
  );
}

// ---------------------------------------------------------------
// MAIN ENTRY
// ---------------------------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ⭐ Initialize LOCAL notifications everywhere except Web
  if (!kIsWeb) {
    await NotificationService().init();
  }

  // ⭐ Initialize Firebase Messaging ONLY on supported platforms
  if (!kIsWeb && !Platform.isWindows) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await FirebaseMessagingService().init();
  }

  runApp(const MyApp());
}

// ---------------------------------------------------------------
// APP ROOT
// ---------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipeService(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Recipes',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (ctx) => const RootScreen(),
          '/favorites': (ctx) => const FavoritesScreen(),
          RandomRecipeScreen.routeName: (ctx) => const RandomRecipeScreen(),
        },
      ),
    );
  }
}

// ---------------------------------------------------------------
// ROOT SCREEN
// ---------------------------------------------------------------
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    FavoritesScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // ⭐ Skip message handling on Web & Windows
    if (!kIsWeb && !Platform.isWindows) {
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final recipeId = message.data['recipeId'];
        navigatorKey.currentState?.pushNamed(
          RandomRecipeScreen.routeName,
          arguments: recipeId,
        );
      });
      _checkInitialMessage();
    }
  }

  Future<void> _checkInitialMessage() async {
    if (kIsWeb || Platform.isWindows) return;

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final recipeId = initialMessage.data['recipeId'];
      navigatorKey.currentState?.pushNamed(
        RandomRecipeScreen.routeName,
        arguments: recipeId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
