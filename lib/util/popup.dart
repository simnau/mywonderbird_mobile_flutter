import 'package:flutter/material.dart';
import 'package:mywonderbird/components/achievement-badge.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/badge.dart';
import 'package:mywonderbird/models/popup-data.dart';
import 'package:mywonderbird/routes/profile/current-user/my-badges.dart';
import 'package:mywonderbird/services/navigation.dart';

_openAchievementsPage() {
  final navigationService = locator<NavigationService>();
  ScaffoldMessenger.of(navigationService.currentContext).clearSnackBars();

  navigationService.push(
    MaterialPageRoute(
      builder: (_) => MyBadges(),
    ),
  );
}

PopupData _createBadgeReceivedData(Map<String, dynamic> popupData) {
  final badgeType = popupData['badgeType'];

  if (badgeType == null) {
    return null;
  }

  final level = popupData['level'];
  final badgeLevels = popupData['badgeLevels'];
  final name = popupData['name'];

  final badge = Badge(
    badgeLevels: int.parse(badgeLevels),
    level: int.parse(level),
    type: badgeType,
    name: name,
  );

  return PopupData(
    title: "You have received a new badge!",
    body: level != null && name != null ? "$name level $level" : null,
    leading: AchievementBadge(
      badge: badge,
    ),
    onPress: _openAchievementsPage,
  );
}

PopupData getPopupData(String popupType, Map<String, dynamic> popupData) {
  switch (popupType) {
    case 'badge-received':
      return _createBadgeReceivedData(popupData);
    default:
      return null;
  }
}
