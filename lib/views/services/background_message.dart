import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'push_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data.isEmpty) return;

  final data = Map<String, dynamic>.from(message.data);
  final title = data['title'] ?? 'KisanDesk';
  final body = data['body'] ?? '';

  PushNotificationService.showLocalNotification(
    title: title,
    body: body,
    data: data,
  );
}