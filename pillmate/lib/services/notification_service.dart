import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../addMedication.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    final String fullTimezoneString = (await FlutterTimezone.getLocalTimezone()).toString();
    final int startIndex = fullTimezoneString.indexOf('(') + 1;
    final int endIndex = fullTimezoneString.indexOf(',', startIndex);
    final String timeZoneName = fullTimezoneString.substring(startIndex, endIndex);

    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> scheduleMedicineReminder(Medicine medicine, int dbId) async {
    if (medicine.startTime == null) return;
    final int notificationId = dbId; 
    final String title = 'Time for your medicine!';
    final String body = 'Take your ${medicine.name} (${medicine.strength})';
    final NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'medicine_channel_id',
        'Medicine Reminders',
        channelDescription: 'Channel for medicine reminder notifications',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher', 
      ),
      iOS: DarwinNotificationDetails(
        sound: 'default.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    final tz.TZDateTime scheduledTime = _nextInstanceOfTime(medicine.startTime!);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    if (medicine.dosageFrequency == 'Twice a day') {
      final TimeOfDay secondTime =
          TimeOfDay(hour: (medicine.startTime!.hour + 12) % 24, minute: medicine.startTime!.minute);
      final tz.TZDateTime secondScheduledTime = _nextInstanceOfTime(secondTime);
      final int secondNotificationId = notificationId + 100000; 
      await flutterLocalNotificationsPlugin.zonedSchedule(
        secondNotificationId,
        title,
        body,
        secondScheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelReminder(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    await flutterLocalNotificationsPlugin.cancel(id + 100000); 
  }
}