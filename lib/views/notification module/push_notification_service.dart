import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mainproject1/views/notification module/ringtone_service.dart';
import 'notification_data.dart';
import '../../main.dart';
import './request_popup.dart';
import 'package:get/get.dart';
import '../home/HomePage.dart';

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // 🔥 store notification for killed state
  static Map<String, dynamic>? pendingNotificationData;

  // ======================
  // INIT
  // ======================
  static Future<void> initialize() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("🔔 Permission: ${settings.authorizationStatus}");

    String? token = await _messaging.getToken();
    print("🔥 FCM TOKEN: $token");

    // ======================
    // FOREGROUND
    // ======================
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 FOREGROUND MESSAGE");

      RingtoneService.start();

      final data = message.data;

      Future.delayed(const Duration(milliseconds: 300), () {
        final context = MyApp.navigatorKey.currentContext;

        if (context != null) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => RequestPopup(
              notificationData: NotificationData.fromMap(data),
            ),
          );
        }
      });

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
      print("📩 CLICKED (killed)");
      pendingNotificationData = initialMessage.data;
    }
  }

  // ======================
  // LOCAL NOTIFICATION INIT
  // ======================
  static Future<void> initializeLocalNotifications() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'request_channel',
      'Request Notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alert'),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

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
      'request_channel',
      'Request Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alert'),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch,
      message.notification?.title ?? message.data['title'] ?? '',
      message.notification?.body ?? message.data['body'] ?? '',
      const NotificationDetails(android: androidDetails),
      payload: jsonEncode(message.data),
    );
  }

  // ======================
  // HANDLE TAP
  // ======================
  static void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;

    Get.offAll(() => HomePage());

    Future.delayed(const Duration(milliseconds: 500), () {
      _showPopupWhenReady(data);
    });
  }

  static void _navigate(Map<String, dynamic> data) {
    Get.offAll(() => HomePage());

    Future.delayed(const Duration(milliseconds: 500), () {
      _showPopupWhenReady(data);
    });
  }

  // ======================
  // SAFE POPUP
  // ======================
  static void _showPopupWhenReady(Map<String, dynamic> data) {
    int retries = 0;

    void tryShow() {
      final context = MyApp.navigatorKey.currentContext;

      if (context != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => RequestPopup(
            notificationData: NotificationData.fromMap(data),
          ),
        );
      } else if (retries < 5) {
        retries++;
        Future.delayed(const Duration(milliseconds: 300), tryShow);
      }
    }

    tryShow();
  }
}

// ======================
// BACKGROUND HANDLER
// ======================
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await PushNotificationService.initializeLocalNotifications();
  await PushNotificationService._showLocalNotification(message);

  print("📩 BACKGROUND MESSAGE: ${message.data}");
}