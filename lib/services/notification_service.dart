import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const int notificationId = 100; // Use fixed ID to update
  static const String channelId = 'tracker_channel';
  static const String channelName = 'Tracking Notifications';
  static const String channelDescription = 'Background location tracking updates';

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(initSettings);
  }

  static Future<void> showInitialNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true, // make it persistent
      onlyAlertOnce: true, // don't make sound on update
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      notificationId,
      'Tracking Started',
      'Location tracking is active',
      notificationDetails,
    );
  }

  static Future<void> updateNotification() async {
    final String updatedTime = DateTime.now().toLocal().toIso8601String();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      onlyAlertOnce: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      notificationId,
      'Tracking Active',
      'Last updated: $updatedTime',
      notificationDetails,
    );
  }
}
