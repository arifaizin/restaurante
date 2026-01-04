import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/preferences_provider.dart';
import 'package:restaurant_app/providers/scheduling_provider.dart';
import 'package:restaurant_app/main.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({Key? key}) : super(key: key);

  Future<bool> _requestNotificationPermission(BuildContext context) async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted =
          await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }
    return true; // For iOS or if permission is already granted
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<PreferencesProvider>(
        builder: (context, provider, child) {
          return ListView(
            children: [
              Material(
                child: ListTile(
                  leading: const Icon(Icons.notifications_active),
                  title: const Text('Daily Reminder'),
                  subtitle: const Text('Notification at 11:00 AM'),
                  trailing: Consumer<SchedulingProvider>(
                    builder: (context, scheduled, _) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          // Ensure switch is visible in light mode when disabled
                          colorScheme: Theme.of(context).colorScheme.copyWith(
                                outline: Colors.grey.shade400,
                              ),
                        ),
                        child: Switch.adaptive(
                          value: provider.isDailyReminderActive,
                          activeThumbColor:
                              Theme.of(context).colorScheme.primary,
                          inactiveThumbColor: Colors.grey.shade300,
                          inactiveTrackColor: Colors.grey.shade400,
                          onChanged: (value) async {
                            if (value) {
                              // Request permission first
                              bool hasPermission =
                                  await _requestNotificationPermission(context);

                              if (!hasPermission) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Notification permission is required'),
                                  ),
                                );
                                return;
                              }
                            }

                            // Update schedule via SchedulingProvider
                            try {
                              bool result =
                                  await scheduled.scheduledNews(value);
                              debugPrint("Scheduled Result: $result");

                              // Update preference
                              provider.enableDailyReminder(value);

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(value
                                      ? 'Daily reminder enabled at 11:00 AM'
                                      : 'Daily reminder disabled'),
                                ),
                              );
                            } catch (e) {
                              debugPrint("Error scheduling: $e");
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Failed to schedule: $e"),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
