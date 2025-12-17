import 'package:get/get.dart';
import '../models/notification_model.dart';

class NotificationsController extends GetxController {
  // Store all notifications
  final RxList<AppNotification> notifications = <AppNotification>[].obs;

  // Add a notification
  void addNotification(AppNotification notification) {
    // Force unread on arrival
    notifications.insert(0, notification.copyWith(isRead: false));
  }

  // Clear all notifications
  void clearAllNotifications() {
    notifications.clear();
  }

  // Remove a specific notification
  void removeNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
  }

  // Mark a specific notification as read
  void markAsRead(String id) {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && notifications[idx].isRead == false) {
      notifications[idx] = notifications[idx].copyWith(isRead: true);
    }
  }

  // Mark all as read (e.g., when opening the notifications screen)
  void markAllAsRead() {
    notifications.assignAll(
      notifications
          .map((n) => n.isRead ? n : n.copyWith(isRead: true))
          .toList(),
    );
  }
}
