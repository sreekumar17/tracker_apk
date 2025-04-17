import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeForegroundService() async {
  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  final service = FlutterBackgroundService();

  await service.configure(
  androidConfiguration: AndroidConfiguration(
    onStart: onServiceStart,
    autoStart: true,
    isForegroundMode: true,
    notificationChannelId: 'background_service_channel',
    initialNotificationTitle: 'Location Tracker',
    initialNotificationContent: 'Waiting for updates...',
  ),
  iosConfiguration: IosConfiguration(
    onForeground: onServiceStart,
  ),
);

  await service.startService();
}

void onServiceStart(ServiceInstance service) {
  Timer.periodic(const Duration(minutes: 10), (timer) async {
    final now = DateTime.now();
    final formattedTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    flutterLocalNotificationsPlugin.show(
      0,
      "Location Tracker",
      "Last update at $formattedTime",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'background_service_channel',
          'Background Service',
          importance: Importance.high,
          priority: Priority.high,
          ongoing: true,
        ),
      ),
    );

    // Optional: Send update to background service too
    service.invoke("update", {"time": formattedTime});
  });
}
