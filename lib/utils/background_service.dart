import 'package:flutter/foundation.dart';
import 'package:restaurant_app/main.dart';
import 'package:restaurant_app/utils/notification_helper.dart';
import 'dart:math';
import '../services/api_service.dart';

class BackgroundService {
  static BackgroundService? _instance;

  BackgroundService._internal() {
    _instance = this;
  }

  factory BackgroundService() => _instance ?? BackgroundService._internal();

  static Future<void> callback() async {
    debugPrint('Alarm fired!');
    final NotificationHelper notificationHelper = NotificationHelper();
    final result = await ApiService().getRestaurants();

    if (result.isSuccess && result.data.isNotEmpty) {
      final restaurants = result.data;
      final randomIndex = Random().nextInt(restaurants.length);
      final randomRestaurant = restaurants[randomIndex];

      await notificationHelper
          .initNotifications(flutterLocalNotificationsPlugin);
      await notificationHelper.showNotification(
          flutterLocalNotificationsPlugin, randomRestaurant);
    } else {
      debugPrint('Failed to fetch restaurants for daily reminder');
    }
  }
}
