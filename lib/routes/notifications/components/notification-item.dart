import 'package:flutter/material.dart';
import 'package:mywonderbird/components/horizontal-separator.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/user-notification.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:mywonderbird/routes/details/pages/user-location-details.dart';
import 'package:mywonderbird/routes/notifications/components/badge-received-notification-item.dart';
import 'package:mywonderbird/routes/notifications/components/liked-photo-notification-item.dart';
import 'package:mywonderbird/routes/profile/current-user/main.dart';
import 'package:mywonderbird/routes/profile/current-user/my-badges.dart';
import 'package:mywonderbird/routes/profile/other-user/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:provider/provider.dart';

class NotificationItem extends StatelessWidget {
  final UserNotification userNotification;
  final Function(UserNotification userNotification) onMarkAsRead;

  const NotificationItem({
    Key key,
    @required this.userNotification,
    @required this.onMarkAsRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _body(context),
      SizedBox(height: spacingFactor(1)),
      HorizontalSeparator(),
    ]);
  }

  Widget _body(BuildContext context) {
    switch (userNotification.type) {
      case NOTIFICATION_TYPE_LIKE:
        return LikedPhotoNotificationItem(
          userNotification: userNotification,
          onTap: () => _onViewLocationDetails(context),
          onViewUserProfile: () => _onViewUserProfile(context),
        );
      case NOTIFICATION_TYPE_BADGE_RECEIVED:
        return BadgeReceivedNotificationItem(
          userNotification: userNotification,
          onTap: () => _onViewAchievements(context),
        );
    }

    if (userNotification.type == NOTIFICATION_TYPE_LIKE) {
      return LikedPhotoNotificationItem(
        userNotification: userNotification,
        onTap: () => _onViewLocationDetails(context),
        onViewUserProfile: () => _onViewUserProfile(context),
      );
    }

    return Container();
  }

  _onViewUserProfile(BuildContext context) {
    if (userNotification.relatedUserProfile == null) {
      return;
    }

    final navigationService = locator<NavigationService>();
    final user = Provider.of<User>(context, listen: false);

    if (userNotification.relatedUserProfile.providerId == user.id) {
      navigationService.push(MaterialPageRoute(
        builder: (_) => Profile(),
      ));
    } else {
      navigationService.push(MaterialPageRoute(
        builder: (_) => OtherUser(
          id: userNotification.relatedUserProfile.providerId,
        ),
      ));
    }
  }

  _onViewLocationDetails(BuildContext context) async {
    await onMarkAsRead(userNotification);

    if (userNotification.entityType != ENTITY_TYPE_GEM ||
        userNotification.entityId == null) {
      return;
    }

    final navigationService = locator<NavigationService>();
    final user = Provider.of<User>(context, listen: false);

    navigationService.push(
      MaterialPageRoute(
        builder: (_) => UserLocationDetails(
          locationId: userNotification.entityId,
          userAvatar: user.profile.avatarUrl,
          userName: user.profile.username,
          userBio: user.profile.bio,
          userId: user.profile.providerId,
        ),
      ),
    );
  }

  _onViewAchievements(BuildContext context) async {
    await onMarkAsRead(userNotification);

    final navigationService = locator<NavigationService>();
    navigationService.push(
      MaterialPageRoute(builder: (_) => MyBadges()),
    );
  }
}
