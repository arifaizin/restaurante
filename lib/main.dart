import 'dart:io';
import 'package:flutter/material.dart';
import 'package:restaurant_app/common/navigation.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/data/preferences/preferences_helper.dart';
import 'package:restaurant_app/providers/preferences_provider.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart';
import 'package:restaurant_app/providers/restaurant_detail_provider.dart';
import 'package:restaurant_app/providers/search_provider.dart';
import 'package:restaurant_app/providers/review_submission_provider.dart';
import 'package:restaurant_app/providers/database_provider.dart';
import 'package:restaurant_app/screens/detail_screen.dart';
import 'package:restaurant_app/screens/favorite_screen.dart';
import 'package:restaurant_app/services/database_helper.dart';
import 'package:restaurant_app/screens/search_screen.dart';
import 'package:restaurant_app/screens/splash_screen.dart';
import 'package:restaurant_app/util/constants.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:restaurant_app/providers/scheduling_provider.dart';
import 'package:restaurant_app/screens/settings_screen.dart';
import 'package:restaurant_app/utils/notification_helper.dart';
import 'package:workmanager/workmanager.dart';
import 'package:restaurant_app/utils/background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*
  The line below 'WidgetsFlutterBinding.ensureInitialized()' is necessary because 
  SharedPreferences.getInstance() uses platform channels, calling native code. 
  WidgetsFlutterBinding ensures the Flutter engine interacts with the native layer 
  before running the app.
  */
  final NotificationHelper notificationHelper = NotificationHelper();

  if (Platform.isAndroid) {
    await AndroidAlarmManager.initialize();
  }

  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  await notificationHelper.initNotifications(flutterLocalNotificationsPlugin);

  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PreferencesProvider(
            preferencesHelper: PreferencesHelper(
              sharedPreferences: Future.value(prefs),
            ),
          ),
        ),
        ChangeNotifierProvider(create: (context) => RestaurantProvider()),
        ChangeNotifierProvider(create: (context) => RestaurantDetailProvider()),
        ChangeNotifierProvider(create: (context) => SearchProvider()),
        ChangeNotifierProvider(create: (context) => ReviewSubmissionProvider()),
        ChangeNotifierProvider(
          create: (_) => DatabaseProvider(databaseHelper: DatabaseHelper()),
        ),
        ChangeNotifierProvider(create: (_) => SchedulingProvider()),
      ],
      child: Consumer<PreferencesProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: Constants.appName,
            theme: provider.themeData,
            navigatorKey: navigatorKey,
            initialRoute: SplashScreen.routeName,
            routes: {
              SplashScreen.routeName: (context) => const SplashScreen(),
              MainScreen.routeName: (context) => const MainScreen(),
              SearchScreen.routeName: (context) => const SearchScreen(),
              FavoriteScreen.routeName: (context) => const FavoriteScreen(),
              SettingsScreen.routeName: (context) => const SettingsScreen(),
            },
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case DetailScreen.routeName:
                  final restaurantId = settings.arguments as String?;
                  if (restaurantId != null) {
                    return MaterialPageRoute(
                      builder: (context) =>
                          DetailScreen(restaurantId: restaurantId),
                    );
                  }
                  return MaterialPageRoute(
                    builder: (context) => const MainScreen(),
                  );
                default:
                  return null;
              }
            },
          );
        },
      ),
    );
  }
}
