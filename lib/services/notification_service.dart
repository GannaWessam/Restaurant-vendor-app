import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../controllers/notifications_controller.dart';
//
// class NotificationService extends GetxService {
//   static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   /// -------------------------------
//   /// 1) Initialize local notifications
//   /// -------------------------------
//   static Future<void> initializeLocalNotifications() async {
//     const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iOSInit = DarwinInitializationSettings();
//
//     const initSettings =
//     InitializationSettings(android: androidInit, iOS: iOSInit);
//
//     await flutterLocalNotificationsPlugin.initialize(initSettings);
//   }
//
//   /// -------------------------------------------
//   /// 2) Show Notification when App is foreground
//   /// -------------------------------------------
//   static void showFlutterNotification(RemoteMessage message) {
//     final notification = message.notification;
//
//     if (notification == null) return;
//
//     flutterLocalNotificationsPlugin.show(
//       notification.hashCode,
//       notification.title,
//       notification.body,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'default_channel',
//           'General Notifications',
//           importance: Importance.high,
//           priority: Priority.high,
//         ),
//       ),
//     );
//   }
//
//   /// -------------------------------------------
//   /// 3) Send Notification using HTTP POST (Dio)
//   /// -------------------------------------------
//   // Future<void> sendNotificationToDevice({
//   //   required String serverKey,   // FCM server key
//   //   required String token,       // target device token
//   //   required String title,
//   //   required String body,
//   //   Map<String, dynamic>? data,
//   // }) async {
//   //   const url = "https://fcm.googleapis.com/fcm/send";
//   //
//   //   final payload = {
//   //     "to": token,
//   //     "notification": {
//   //       "title": title,
//   //       "body": body,
//   //       "sound": "default",
//   //     },
//   //     "data": data ?? {}, // custom data for navigation, etc.
//   //   };
//   //
//   //   try {
//   //     await Dio().post(
//   //       url,
//   //       data: payload,
//   //       options: Options(
//   //         headers: {
//   //           HttpHeaders.contentTypeHeader: "application/json",
//   //           HttpHeaders.authorizationHeader: "key=$serverKey",
//   //         },
//   //       ),
//   //     );
//   //     print("Notification sent successfully");
//   //   } catch (e) {
//   //     print("Error sending notification: $e");
//   //   }
//   // }
// }


class NotificationService {
  static final _local = FlutterLocalNotificationsPlugin();
  static const String _notificationChannelId = 'default_channel';
  static const String _notificationChannelName = 'Notifications';

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialize with onSelectNotification callback
    await _local.initialize(
      InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        _handleNotificationTap(response);
      },
    );

    // Request permissions (for iOS)
    await _local
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static void _handleNotificationTap(NotificationResponse response) {
    // Navigate to notifications screen when notification is tapped
    if (response.actionId == null) {
      // Only navigate if it's a tap, not an action button
      // Use a small delay to ensure GetX context is ready
      Future.delayed(const Duration(milliseconds: 100), () {
        try {
          Get.toNamed('/notifications');
        } catch (e) {
          print('Error navigating to notifications: $e');
        }
      });
    }
  }

  static void showForeground(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    // Create AppNotification model
    final appNotification = AppNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification.title ?? 'Notification',
      body: notification.body ?? '',
      timestamp: message.sentTime ?? DateTime.now(),
      data: message.data,
    );

    // Add to notifications controller if available
    try {
      if (Get.isRegistered<NotificationsController>()) {
        Get.find<NotificationsController>().addNotification(appNotification);
      }
    } catch (e) {
      print('NotificationsController not found: $e');
    }

    // Show local notification with tap handler
    _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _notificationChannelId,
          _notificationChannelName,
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: appNotification.id, // Pass notification ID as payload
    );
  }

  /// Show notification when app is in background or terminated
  /// This can be called from the background message handler
  static Future<void> showBackground(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // Create AppNotification model
    final appNotification = AppNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification.title ?? 'Notification',
      body: notification.body ?? '',
      timestamp: message.sentTime ?? DateTime.now(),
      data: message.data,
    );

    // Show local notification - when tapped, it will navigate via onDidReceiveNotificationResponse
    await _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _notificationChannelId,
          _notificationChannelName,
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: appNotification.id, // Pass notification ID as payload
    );
  }

  Future<void> sendNotificationToDevice({
    required String token,       // target device token
    required String title,
    required String body,
    required String reservedRestaurant,
    Map<String, dynamic>? data,
  }) async {
    try {
      await Dio().post(
        "http://localhost/send-notification",
        data: {
          "token": token,
          "title": title,
          "body": body,
          "data": {
            "reserved restaurant": reservedRestaurant,
            ...?data,
          }
        },
      );

      print("Notification sent successfully");
    } catch (e) {
      print("Error sending notification: $e");
    }
  }
}
