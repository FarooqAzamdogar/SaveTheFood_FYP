import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ForegroundNotificationManagement {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings _androidInitializationSettings =
      AndroidInitializationSettings('app_icon'); // Ensure 'app_icon' is correct

  ForegroundNotificationManagement() {
    final InitializationSettings _initializationSettings =
        InitializationSettings(
          android: _androidInitializationSettings,
        );

    print("Foreground Notification Constructor");

    initAll(_initializationSettings);
  }

  Future<void> initAll(InitializationSettings initializationSettings) async {
    final bool? initializationResult = await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tapped event here
        print("On Select Notification Payload: ${response.payload}");
      },
    );

    print("Local Notification Initialization Status: $initializationResult");
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    try {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'CHANNEL_ID', // Unique channel ID
        'Channel Name', // Channel name
        channelDescription: 'Channel description',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      final NotificationDetails generalNotificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        0, // Notification ID
        title,
        body,
        generalNotificationDetails,
        payload: title, // Use payload to handle notification tapping
      );
    } catch (e) {
      print("Foreground Notification Error: ${e.toString()}");
    }
  }
}
