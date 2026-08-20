import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationServices {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initilize() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/launcher_icon");
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin);

    _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        print('Notification details $details');
      },
    );
  }

  static void showNotifiationForground(RemoteMessage message) {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails('com.stars.app', 'stars',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon'),
      iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          threadIdentifier: 'AutotelLite'),
    );
    _notificationsPlugin.show(
        id: DateTime.now().microsecond,
        title: message.notification!.title,
        body: message.notification!.body,
        notificationDetails: notificationDetails);
  }

  static void showNotifiationForgroundString(String title, String body) {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'com.stars.app',
        'AutotelLite',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          threadIdentifier: 'AutotelLite'),
    );
    _notificationsPlugin.show(
        id: DateTime.now().microsecond,
        title: title,
        body: body,
        notificationDetails: notificationDetails);
  }
}
