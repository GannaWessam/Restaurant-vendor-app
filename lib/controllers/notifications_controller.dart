import 'package:get/get.dart';
import '../models/notification_model.dart';

class NotificationsController extends GetxController {
  // Store all notifications
  final RxList<AppNotification> notifications = <AppNotification>[].obs;

  // Add a notification
  void addNotification(AppNotification notification) {
    // Add to the beginning of the list (newest first)
    notifications.insert(0, notification);
  }

  // Clear all notifications
  void clearAllNotifications() {
    notifications.clear();
  }

  // Remove a specific notification
  void removeNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
  }
}
