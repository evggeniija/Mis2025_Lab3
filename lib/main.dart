import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'screens/categories_screen.dart';
import 'services/notification_service.dart';
import 'providers/favorites_provider.dart';
import 'package:provider/provider.dart';

// Background handler – only used on supported platforms
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

/// Firebase Messaging is NOT supported on:
/// - Web (requires HTTPS)
/// - Windows, Linux, Fuchsia
bool get _isMessagingSupported {
  if (kIsWeb) return false;

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return true;

    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      return false;
  }
}

/// Scheduled notifications NOT supported on:
/// - Web
/// - Windows, Linux, Fuchsia
bool get _isSchedulingSupported {
  if (kIsWeb) return false;

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return true;

    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      return false;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init (works on all platforms)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Local notifications (works everywhere except scheduling)
  await NotificationService.init();

  // Firebase Messaging only where supported
  if (_isMessagingSupported) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance.requestPermission();

    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM Token: $token');
  } else {
    debugPrint('Firebase Messaging disabled on this platform (Web/Windows).');
  }

  // Daily scheduled reminder only on supported platforms
  if (_isSchedulingSupported) {
    await NotificationService.scheduleDailyRandomMealReminder(
      const TimeOfDay(hour: 10, minute: 0),
    );
  } else {
    debugPrint(
        "Scheduled notifications disabled (Web/Windows doesn't support zonedSchedule).");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FavoritesProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TheMealDB Recipes',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
        ),
        home: const CategoriesScreen(),
      ),
    );
  }
}
