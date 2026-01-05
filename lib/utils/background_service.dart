import 'package:flutter/foundation.dart';
import 'package:restaurant_app/main.dart';
import 'package:restaurant_app/utils/notification_helper.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:math';
import '../services/api_service.dart';

class BackgroundService {
  static BackgroundService? _instance;

  BackgroundService._internal() {
    _instance = this;
  }

  factory BackgroundService() => _instance ?? BackgroundService._internal();

  @pragma('vm:entry-point')
  static Future<void> callback() async {
    debugPrint('Alarm Manager: Fired at 11:00 AM');
    final NotificationHelper notificationHelper = NotificationHelper();
    final result = await ApiService().getRestaurants();

    if (result.isSuccess && result.data.isNotEmpty) {
      final restaurants = result.data;
      final randomIndex = Random().nextInt(restaurants.length);
      final randomRestaurant = restaurants[randomIndex];

      await notificationHelper.initNotifications(
        flutterLocalNotificationsPlugin,
      );
      await notificationHelper.showNotification(
        flutterLocalNotificationsPlugin,
        randomRestaurant,
      );
    } else {
      debugPrint('Alarm Manager: Failed to fetch restaurants');
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('Workmanager: Task "$task" started');

    final NotificationHelper notificationHelper = NotificationHelper();
    final result = await ApiService().getRestaurants();

    if (result.isSuccess && result.data.isNotEmpty) {
      final restaurants = result.data;
      final randomIndex = Random().nextInt(restaurants.length);
      final randomRestaurant = restaurants[randomIndex];

      await notificationHelper.initNotifications(
        flutterLocalNotificationsPlugin,
      );
      await notificationHelper.showNotification(
        flutterLocalNotificationsPlugin,
        randomRestaurant,
      );

      debugPrint(
        'Workmanager: Notification shown for ${randomRestaurant.name}',
      );
    } else {
      debugPrint('Workmanager: Failed to fetch restaurants');
    }

    return Future.value(true);
  });
}
