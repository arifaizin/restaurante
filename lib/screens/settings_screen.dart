import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/preferences_provider.dart';
import 'package:restaurant_app/providers/scheduling_provider.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({Key? key}) : super(key: key);

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
                  title: const Text('Dark Theme'),
                  trailing: Switch.adaptive(
                    value: provider.isDarkTheme,
                    onChanged: (value) {
                      provider.enableDarkTheme(value);
                    },
                  ),
                ),
              ),
              Material(
                child: ListTile(
                  title: const Text('Scheduling News (11:00 AM)'),
                  trailing: Consumer<SchedulingProvider>(
                    builder: (context, scheduled, _) {
                      return Switch.adaptive(
                        value: provider.isDailyReminderActive,
                        onChanged: (value) async {
                          // Update schedule via SchedulingProvider
                          try {
                            // Ensure persistence matches actual schedule status
                            // (Though usually we might want to decouple UI state from async result,
                            // here we couple them for simplicity as per common flutter patterns)
                            bool result = await scheduled.scheduledNews(value);
                            print("Scheduled Result: $result");

                            // Update preference
                            provider.enableDailyReminder(value);
                          } catch (e) {
                            print("Error scheduling: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to schedule: $e"),
                              ),
                            );
                          }
                        },
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
