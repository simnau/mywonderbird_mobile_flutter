// This needs to be in sync with the back-end types
// Should never really change though
import 'package:flutter/material.dart';
import 'package:mywonderbird/models/user-profile.dart';

const NOTIFICATION_TYPE_LIKE = 10;
const NOTIFICATION_TYPE_BADGE_RECEIVED = 20;

// This needs to be in sync with the back-end types
// Should never really change though
const ENTITY_TYPE_GEM = 1000;

class UserNotification {
  final String id;
  final String userId;
  final String relatedUserId;
  final UserProfile relatedUserProfile;
  final int type;
  final int entityType;
  final String entityId;
  bool read;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> extraData;

  UserNotification({
    @required this.id,
    @required this.userId,
    @required this.relatedUserId,
    @required this.relatedUserProfile,
    @required this.type,
    @required this.entityType,
    @required this.entityId,
    @required this.read,
    @required this.createdAt,
    @required this.updatedAt,
    this.extraData,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'];
    final updatedAt = json['updatedAt'];

    final relatedUserProfile = json['relatedUserProfile'];

    return UserNotification(
      id: json['id'],
      userId: json['userId'],
      relatedUserId: json['relatedUserId'],
      relatedUserProfile: relatedUserProfile != null
          ? UserProfile.fromJson(relatedUserProfile)
          : null,
      type: json['type'],
      entityType: json['entityType'],
      entityId: json['entityId'],
      read: json['read'],
      createdAt: createdAt != null ? DateTime.parse(createdAt) : null,
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt) : null,
      extraData: json['extraData'],
    );
  }
}
