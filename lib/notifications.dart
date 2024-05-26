import 'dart:io';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppNotifications{
  static final FlutterLocalNotificationsPlugin _localnotifs = FlutterLocalNotificationsPlugin();
  static Future<void> initialize()async{
    Counter();
    if(Platform.isAndroid){
      tz.initializeTimeZones();
      final String timeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZone));

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

  static final List<NotificationLink> _scheduledNotifLinks = <NotificationLink>[].toList();

  static Future<void> cancelScheduledNotifs()async{
    //log('cancle');
    await _localnotifs.cancelAll();
    Counter.reset();
  }

  static Future<void> cancelScheduledNotifsId(int id)async{
    for (var item in _scheduledNotifLinks){
      if(item.id != id){
        continue;
      }
      await _localnotifs.cancel(item.counter);
    }
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
    //log("$title $time $id");
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
          '0',
          'Neptun 2 Időzített',
          channelDescription: 'Olyan értesítések csatornája, amelyeket időzítetten, azaz a nap folyamán valamikor akar az applikáció megjeleníteni neked.',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'Neptun 2 Időzített Értesítés',
          styleInformation: BigTextStyleInformation(content, contentTitle: title)
      ),
      linux: const LinuxNotificationDetails(
        defaultActionName: 'Dismiss',
        urgency: LinuxNotificationUrgency.normal,
      ),
    );
    final counter = Counter.getCount();
    _scheduledNotifLinks.add(NotificationLink(id, counter));
    if(Platform.isAndroid){
      await _localnotifs.zonedSchedule(
        counter,
        title,
        content,
        _convert(time.year, time.month, time.day, time.hour, time.minute),
        details,
        //androidAllowWhileIdle: true,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      );
    }
  }

  static Future<void> showNotification(String title, String desc) async{
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
          '1',
          'Neptun 2 Azonnali',
          channelDescription: 'Olyan értesítések csatornája, amelyeket azonnal akar az applikáció megjeleníteni neked.',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'Neptun 2 Azonnali Értesítés',
          styleInformation: BigTextStyleInformation(desc, contentTitle: title)
      ),
      linux: const LinuxNotificationDetails(
        defaultActionName: 'Dismiss',
        urgency: LinuxNotificationUrgency.normal,
      ),
    );
    _localnotifs.show(Counter.getCount(), title, desc, details);
  }
}

class Counter{ // using "static int counter" did not want to increment :(
  static Counter? _instance;
  Counter(){
    _instance = this;
  }

  int _counter = 0;
  static int getCount(){
    //log('${_instance!._counter + 1}');
    return ++_instance!._counter;
  }

  static void reset(){
    _instance!._counter = 0;
  }
}

class NotificationLink{
  final int id;
  final int counter;
  NotificationLink(this.id, this.counter);
}