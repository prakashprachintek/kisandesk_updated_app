import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../main.dart';
import 'notification_data.dart';
import 'notification_page.dart';
import 'push_notification_service.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  if (notificationResponse.payload != null &&
      PushNotificationService.navigatorContext != null) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json.decode(notificationResponse.payload!));
    final notificationData = NotificationData.fromMap(data);

    MyApp.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => NotificationPage(notificationData: notificationData),
        ),
      );
  }
}