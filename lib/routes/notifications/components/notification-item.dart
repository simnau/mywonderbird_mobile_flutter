import 'package:flutter/material.dart';
import 'package:mywonderbird/components/avatar.dart';
import 'package:mywonderbird/components/horizontal-separator.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/user-notification.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:mywonderbird/routes/details/pages/user-location-details.dart';
import 'package:mywonderbird/routes/profile/current-user/main.dart';
import 'package:mywonderbird/routes/profile/other-user/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

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
    if (userNotification.type == NOTIFICATION_TYPE_LIKE) {
      return _likedPhotoNotification(context);
    }

    return Container();
  }

  Widget _likedPhotoNotification(BuildContext context) {
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
        onTap: () => _onViewLocationDetails(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadiusFactor(2),
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: spacingFactor(1),
          horizontal: spacingFactor(1),
        ),
        leading: _userAvatar(context),
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
          timeago.format(userNotification.updatedAt),
          color: Colors.black45,
        ),
      ),
    );
  }

  Widget _userAvatar(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.only(left: 8.0, right: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(60),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Avatar(
              url: userNotification.relatedUserProfile?.avatarUrl,
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(64),
                onTap: () => _onViewUserProfile(context),
              ),
            ),
          )
        ],
      ),
    );
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
    onMarkAsRead(userNotification);

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
}
