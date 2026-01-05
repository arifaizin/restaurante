import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:restaurant_app/utils/background_service.dart';
import 'package:restaurant_app/utils/datetime_helper.dart';
import 'package:workmanager/workmanager.dart';

class SchedulingProvider extends ChangeNotifier {
  bool _isScheduled = false;

  bool get isScheduled => _isScheduled;

  Future<bool> scheduledNews(bool value) async {
    _isScheduled = value;
    if (_isScheduled) {
      debugPrint('Scheduling News Activated');
      notifyListeners();

      // Schedule Alarm Manager (Precise at 11:00 AM)
      await AndroidAlarmManager.periodic(
        const Duration(hours: 24),
        1,
        BackgroundService.callback,
        startAt: DateTimeHelper.format(),
        exact: true,
        wakeup: true,
      );

      // Schedule Workmanager (Periodic refresh)
      await Workmanager().registerPeriodicTask(
        "periodic-refresh",
        "fetch-data-task",
        frequency: const Duration(hours: 24), // Can be different or the same
        initialDelay: DateTimeHelper.format().difference(DateTime.now()),
        constraints: Constraints(networkType: NetworkType.connected),
      );

      return true;
    } else {
      debugPrint('Scheduling News Canceled');
      notifyListeners();

      await AndroidAlarmManager.cancel(1);
      await Workmanager().cancelByUniqueName("periodic-refresh");

      return true;
    }
  }
}
