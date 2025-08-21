import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_page.dart';
import 'notification_data.dart';
import '../../main.dart';


class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // ======================
  // Initialize push notifications
  // ======================
  static Future<void> initialize() async {
    // Request notification permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("🔔 Notification permission: ${settings.authorizationStatus}");

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Handle taps when app is in background but not killed
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });

    // Handle taps when app is killed
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationTap(initialMessage);
      });
    }

  }

  // ======================
  // Local notifications setup
  // ======================
  static Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _handlePayloadTap(response.payload!);
        }
      },
    );
  }

  // ======================
  // Show local notification for foreground messages
  // ======================
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel_id',
      'General Notifications',
      channelDescription: 'Channel for app notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.notification.hashCode,
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      notificationDetails,
      payload: message.data.isNotEmpty ? message.data.toString() : null,
    );
  }

  // ======================
  // Handle notification tap (background/killed)
  // ======================
  static void _handleNotificationTap(RemoteMessage message) {
    print("📩 Notification tap data: ${message.data}");

    MyApp.navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => NotificationPage(
          notificationData: NotificationData.fromMap(message.data),
        ),
      ),
    );
  }

  // ======================
  // Handle payload tap (foreground local notification)
  // ======================
  static void _handlePayloadTap(String payload) {
    try {
      final Map<String, dynamic> data = _parsePayload(payload);

      MyApp.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => NotificationPage(
            notificationData: NotificationData.fromMap(data),
          ),
        ),
      );
    } catch (e) {
      print("❌ Error parsing notification payload: $e");
    }
  }

  // ======================
  // Convert payload string to Map
  // ======================
  static Map<String, dynamic> _parsePayload(String payload) {
    payload = payload.replaceAll(RegExp(r'^\{|}$'), ''); // remove {}
    final Map<String, dynamic> result = {};
    for (var part in payload.split(',')) {
      var keyValue = part.split(':');
      if (keyValue.length == 2) {
        result[keyValue[0].trim()] = keyValue[1].trim();
      }
    }
    return result;
  }
}

// ======================
// Background handler
// ======================
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("📩 Background message: ${message.data}");
}