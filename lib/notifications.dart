import 'dart:io';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppNotifications{
  static final FlutterLocalNotificationsPlugin _localnotifs = FlutterLocalNotificationsPlugin();
  static Future<void> initialize()async{
    if(Platform.isAndroid){
      AndroidFlutterLocalNotificationsPlugin().requestExactAlarmsPermission();
      _localnotifs.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    }
    await _localnotifs.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        linux: LinuxInitializationSettings(
            defaultActionName: 'Dismiss'
        )
    ));
  }

  static Future<void> cancelScheduledNotifs(int id)async{
    await _localnotifs.cancel(id);
  }

  static tz.TZDateTime _convert(int year, int month, int day, int hour, int minute){
    final now = tz.TZDateTime.now(tz.local);
    var scheduleDate = tz.TZDateTime(
      tz.local,
      year,
      month,
      day,
      hour,
      minute,
    );
    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }
    return scheduleDate;
  }

  static Future<void> scheduleNotification(String title, String content, DateTime time, int id) async{
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
          '$id',
          'Neptun 2 Időzített',
          channelDescription: 'Olyan értesítések csatornája, amelyeket időzítetten, azaz a nap folyamán valamikor akar az applikáció megjeleníteni neked.',
          importance: Importance.max,
          priority: Priority.max,
          ticker: 'Neptun 2 Időzített Értesítés'
      ),
      linux: const LinuxNotificationDetails(
        defaultActionName: 'Dismiss',
        urgency: LinuxNotificationUrgency.critical,
      ),
    );
    if(Platform.isAndroid){
      tz.initializeTimeZones();
      final String timeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZone));

      await _localnotifs.zonedSchedule(
        id,
        title,
        content,
        _convert(time.year, time.month, time.day, time.hour, time.minute),
        details,
        androidAllowWhileIdle: true,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> showNotification(String title, String desc,) async{
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
          '1',
          'Neptun 2 Azonnali',
          channelDescription: 'Olyan értesítések csatornája, amelyeket azonnal akar az applikáció megjeleníteni neked.',
          importance: Importance.max,
          priority: Priority.max,
          ticker: 'Neptun 2 Azonnali Értesítés'
      ),
      linux: LinuxNotificationDetails(
        defaultActionName: 'Dismiss',
        urgency: LinuxNotificationUrgency.normal,
      ),
    );
    _localnotifs.show(1, title, desc, details);
  }
}