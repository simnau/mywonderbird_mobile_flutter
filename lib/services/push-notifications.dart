import 'dart:io';

import 'package:flutter/material.dart';

import 'api.dart';

const TOKEN_PATH = '/api/push-notifications/token';
final deleteTokenPath =
    (String deviceToken) => "/api/push-notifications/token/$deviceToken";

class PushNotificationService {
  final API api;

  PushNotificationService({
    @required this.api,
  });

  saveUserDeviceToken(String deviceToken) async {
    final response = await api.post(TOKEN_PATH, {
      'deviceToken': deviceToken,
    });
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error saving the device token');
    }
  }

  deleteUserDeviceToken(String deviceToken) async {
    final response = await api.delete(deleteTokenPath(deviceToken));
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error removing the device token');
    }
  }
}
