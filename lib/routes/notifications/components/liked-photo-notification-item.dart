import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/user-notification.dart';
import 'package:mywonderbird/routes/notifications/components/user-avatar.dart';
import 'package:timeago/timeago.dart' as timeago;

class LikedPhotoNotificationItem extends StatelessWidget {
  final UserNotification userNotification;
  final Function onTap;
  final Function onViewUserProfile;

  const LikedPhotoNotificationItem({
    Key key,
    @required this.userNotification,
    @required this.onTap,
    @required this.onViewUserProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final username =
        userNotification.relatedUserProfile?.username ?? 'Anonymous';

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
        leading: UserAvatar(
          avatarUrl: userNotification.relatedUserProfile?.avatarUrl,
          onTap: onViewUserProfile,
        ),
        title: Text.rich(
          TextSpan(children: [
            TextSpan(
              text: username,
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: " liked your photo")
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
