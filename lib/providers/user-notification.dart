import 'package:flutter/material.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/user-notification.dart';
import 'package:mywonderbird/services/user-notification.dart';

class UserNotificationProvider with ChangeNotifier {
  int _notificationCount = 0;

  int get notificationCount => _notificationCount;

  markNotificationAsRead(UserNotification notification) async {
    if (!notification.read) {
      final userNotificationService = locator<UserNotificationService>();

      userNotificationService.markAsRead(notification.id);
      _notificationCount--;
      notifyListeners();
    }
  }

  markAllNotificationsAsRead() async {
    final userNotificationService = locator<UserNotificationService>();

    userNotificationService.markAllAsRead();
    _notificationCount = 0;
    notifyListeners();
  }

  fetchNotificationCount() async {
    final userNotificationService = locator<UserNotificationService>();

    final notificationCount =
        await userNotificationService.fetchNotificationCount();

    _notificationCount = notificationCount;
    notifyListeners();
  }
}
