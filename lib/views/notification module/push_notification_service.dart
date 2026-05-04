import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mainproject1/views/notification%20module/ringtone_service.dart';
import 'notification_page.dart';
import 'notification_data.dart';
import '../../main.dart';
import './request_popup.dart';

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // ======================
  // INIT
  // ======================
  static Future<void> initialize() async {
    // 🔥 REQUEST PERMISSION
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("🔔 Permission: ${settings.authorizationStatus}");

    // 🔥 GET TOKEN
    String? token = await _messaging.getToken();
    print("🔥 FCM TOKEN: $token");

    // ======================
    // FOREGROUND
    // ======================
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 FOREGROUND MESSAGE RECEIVED");

      RingtoneService.start();

      _showLocalNotification(message);

      _handleNotificationTap(message);

      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");
      print("Data: ${message.data}");

      _showLocalNotification(message);
    });

    // ======================
    // BACKGROUND CLICK
    // ======================
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📩 CLICKED (background)");
      _handleNotificationTap(message);
    });

    // ======================
    // KILLED STATE
    // ======================
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print("📩 CLICKED (killed state)");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationTap(initialMessage);
      });
    }
  }

  // ======================
  // LOCAL NOTIFICATION INIT
  // ======================
  static Future<void> initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          _navigate(data);
        }
      },
    );
  }

  // ======================
  // SHOW LOCAL NOTIFICATION
  // ======================
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _localNotifications.show(
      0,
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      const NotificationDetails(android: androidDetails),
      payload: jsonEncode(message.data),
    );
  }

  // ======================
  // HANDLE TAP
  // ======================
 static void _handleNotificationTap(RemoteMessage message) {
  final data = message.data;

  if (MyApp.navigatorKey.currentContext != null) {
    showDialog(
      context: MyApp.navigatorKey.currentContext!,
      barrierDismissible: false, // 🔥 user must act
      builder: (_) => RequestPopup(
        notificationData: NotificationData.fromMap(data),
      ),
    );
  }
}

  static void _navigate(Map<String, dynamic> data) {
    if (MyApp.navigatorKey.currentState != null) {
      MyApp.navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => NotificationPage(
              notificationData: NotificationData.fromMap(data)),
        ),
      );
    }
  }
}

// BACKGROUND HANDLER
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("📩 BACKGROUND MESSAGE: ${message.data}");
}
