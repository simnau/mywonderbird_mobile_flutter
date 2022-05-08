import 'package:flutter/material.dart';
import 'package:mywonderbird/components/achievement-badge.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/badge.dart';
import 'package:mywonderbird/models/user-notification.dart';
import 'package:timeago/timeago.dart' as timeago;

class BadgeReceivedNotificationItem extends StatelessWidget {
  final UserNotification userNotification;
  final Function onTap;

  const BadgeReceivedNotificationItem({
    Key key,
    @required this.userNotification,
    @required this.onTap,
  }) : super(key: key);

  Badge get _badge {
    if (userNotification.extraData == null) {
      return null;
    }

    final badgeLevels = userNotification.extraData['badgeLevels'];
    final level = userNotification.extraData['level'];
    final type = userNotification.extraData['badgeType'];
    final name = userNotification.extraData['name'];

    if (badgeLevels == null || level == null || type == null || name == null) {
      return null;
    }

    return Badge(
      badgeLevels: int.parse(badgeLevels),
      level: int.parse(level),
      type: userNotification.extraData['badgeType'],
      name: userNotification.extraData['name'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badge = _badge;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          borderRadiusFactor(2),
        ),
        color: !userNotification.read ? Colors.black.withOpacity(0.05) : null,
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadiusFactor(2),
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: spacingFactor(1),
          horizontal: spacingFactor(1),
        ),
        leading: badge != null
            ? Container(
                width: 60,
                height: 60,
                margin: EdgeInsets.only(
                  left: spacingFactor(1),
                  right: spacingFactor(2),
                ),
                child: AchievementBadge(badge: badge),
              )
            : null,
        title: Text.rich(
          TextSpan(children: [
            TextSpan(text: "You have received a new badge"),
            if (badge != null)
              TextSpan(
                text: " - ${badge.name}",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (badge != null)
              TextSpan(
                text: " level ${badge.level}",
              ),
          ]),
          style: theme.textTheme.subtitle1,
        ),
        subtitle: BodyText1(
          timeago.format(userNotification.createdAt),
          color: Colors.black45,
        ),
      ),
    );
  }
}
