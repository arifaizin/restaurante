import 'package:flutter/foundation.dart';
import 'package:restaurant_app/main.dart';
import 'package:restaurant_app/utils/notification_helper.dart';

class BackgroundService {
  static BackgroundService? _instance;

  BackgroundService._internal() {
    _instance = this;
  }

  factory BackgroundService() => _instance ?? BackgroundService._internal();

  static Future<void> callback() async {
    debugPrint('Alarm fired!');
    final NotificationHelper notificationHelper = NotificationHelper();
    await notificationHelper.initNotifications(flutterLocalNotificationsPlugin);
    await notificationHelper.showNotification(flutterLocalNotificationsPlugin);
  }
}
