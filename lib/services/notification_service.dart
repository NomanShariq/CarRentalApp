import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // ✅ Timezones initialize karna zaroori hai schedule ke liye
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(settings);

    // Permission request for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // ✅ YE NAYA FUNCTION HAI: Exact time par notification ke liye
  static Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(
          scheduledTime,
          tz.local,
        ), // Mobile ke local time par chalega
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'car_rental_channel',
            'Car Rental Bookings',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode
            .exactAllowWhileIdle, // Phone lock ho tab bhi chale
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print("Notification scheduled for: $scheduledTime");
    } catch (e) {
      print("Schedule Error: $e");
    }
  }

  static Future<void> showInstantNotification(String title, String body) async {
    const AndroidNotificationDetails details = AndroidNotificationDetails(
      'car_rental_channel',
      'Car Rental',
      importance: Importance.max,
      priority: Priority.high,
    );
    await _notificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(android: details),
    );
  }
}
