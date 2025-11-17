import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../addMedication.dart'; // Adjust path to your Medicine model

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone database
    tz.initializeTimeZones();
    
    // Parse the timezone string
    final String fullTimezoneString = (await FlutterTimezone.getLocalTimezone()).toString();
    final int startIndex = fullTimezoneString.indexOf('(') + 1;
    final int endIndex = fullTimezoneString.indexOf(',', startIndex);
    final String timeZoneName = fullTimezoneString.substring(startIndex, endIndex);

    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
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

    // Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // --- THIS IS THE FIX ---
    // We must request permissions *after* initializing
    await _requestPermissions();
    // --- END OF FIX ---
  }

  // --- ADDED NEW FUNCTION TO REQUEST PERMISSIONS ---
  Future<void> _requestPermissions() async {
    // Request notification permission (for Android 13+)
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // This will open a dialog for notifications
      await androidImplementation.requestNotificationsPermission();
      
      // This will open a *separate* dialog for exact alarms
      await androidImplementation.requestExactAlarmsPermission();
    }
  }
  // --- END OF NEW FUNCTION ---

  // Helper to get the next notification time
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    // ... (This function is unchanged) ...
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

  // Schedule a new medicine reminder
  Future<void> scheduleMedicineReminder(Medicine medicine, int dbId) async {
    // ... (This function is unchanged) ...
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

  // Cancel a notification
  Future<void> cancelReminder(int id) async {
    // ... (This function is unchanged) ...
    await flutterLocalNotificationsPlugin.cancel(id);
    await flutterLocalNotificationsPlugin.cancel(id + 100000); 
  }
}