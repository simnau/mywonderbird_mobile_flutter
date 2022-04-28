import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mywonderbird/models/user-notification.dart';
import 'package:mywonderbird/services/api.dart';

const NOTIFICATIONS_PATH = '/api/notifications';
const NOTIFICATIONS_COUNT_PATH = '$NOTIFICATIONS_PATH/count';
const MARK_ALL_AS_READ_PATH = "$NOTIFICATIONS_PATH/read";
final markAsReadPath = (String id) => "$NOTIFICATIONS_PATH/read/$id";

class UserNotificationService {
  final API api;

  UserNotificationService({
    @required this.api,
  });

  Future<List<UserNotification>> fetchNotifications(
    DateTime lastDatetime,
  ) async {
    final formattedtLastDateTime = lastDatetime?.toUtc()?.toIso8601String();

    final response = await api.get(
      NOTIFICATIONS_PATH,
      params: {
        'lastDatetime': formattedtLastDateTime,
      },
    );
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('An error occurred');
    }

    final notifications = response['body']['notifications'];

    return notifications.map<UserNotification>((notification) {
      return UserNotification.fromJson(notification);
    }).toList();
  }

  Future<int> fetchNotificationCount() async {
    final response = await api.get(NOTIFICATIONS_COUNT_PATH);
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('An error occurred');
    }

    final notificationCount = response['body']['notificationCount'];

    return notificationCount;
  }

  markAllAsRead() async {
    final response = await api.post(MARK_ALL_AS_READ_PATH, {});
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('An error occurred');
    }
  }

  markAsRead(String id) async {
    final response = await api.post(markAsReadPath(id), {});
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('An error occurred');
    }
  }
}
