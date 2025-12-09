import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Request permission (especially for iOS)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token (for testing from console)
    final token = await _messaging.getToken();
    // print('FCM Token: $token'); // copy this to Firebase console

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotificationService().showSimpleNotification(
        title: message.notification?.title ?? 'Recipe of the day',
        body: message.notification?.body ??
            'Open the app to see today\'s random recipe!',
        payload: message.data['recipeId'],
      );
    });
  }
}
