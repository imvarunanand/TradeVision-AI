import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> showSimpleNotification({required String title, required String body}) async {
    const android = AndroidNotificationDetails('default', 'Default', importance: Importance.defaultImportance);
    const platform = NotificationDetails(android: android);
    await _flutterLocalNotificationsPlugin.show(0, title, body, platform);
  }
}
