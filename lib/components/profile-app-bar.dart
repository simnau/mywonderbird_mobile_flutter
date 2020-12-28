import 'package:flutter/material.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'typography/subtitle1.dart';

const double AVATAR_RADIUS = 50;
const double PROGRESS_WIDTH = 8;

class ProfileAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double collapsedHeight;
  final Function() onSettings;
  final Widget tabBar;
  final User user;

  const ProfileAppBar({
    @required this.expandedHeight,
    @required this.collapsedHeight,
    @required this.user,
    this.onSettings,
    this.tabBar,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Material(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Expanded(
                child: SafeArea(
                  child: NavigationToolbar(
                    leading: Align(
                      alignment: Alignment.topLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints.tightFor(
                          width: kToolbarHeight,
                          height: kToolbarHeight,
                        ),
                        child: BackButton(),
                      ),
                    ),
                    trailing: onSettings == null
                        ? null
                        : Align(
                            alignment: Alignment.topRight,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints.tightFor(
                                width: kToolbarHeight,
                                height: kToolbarHeight,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.settings),
                                onPressed: onSettings,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              tabBar,
            ],
          ),
        ),
        Positioned(
          top: 8 - shrinkOffset / 4,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Opacity(
              opacity: 1 - shrinkOffset / maxExtent,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _avatar(user),
                  Subtitle1(user?.username ?? 'Anonymous'),
                  // BodyText2(user?.level ?? 'Beginner'), TODO Implement user levels later
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  Widget _avatar(User user) {
    return Material(
      shape: CircleBorder(),
      elevation: 8,
      child: CircularPercentIndicator(
        startAngle: 180,
        backgroundColor: Colors.transparent,
        radius: AVATAR_RADIUS * 2, // This is actually the diameter...
        lineWidth: PROGRESS_WIDTH,
        percent: 0, // TODO: Change this once we have progress/levels
        center: CircleAvatar(
          backgroundImage: user?.profile?.avatarUrl != null
              ? NetworkImage(user.profile.avatarUrl)
              : null,
          child: user?.profile?.avatarUrl == null
              ? Text(
                  user?.initials ?? '??',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 32,
                  ),
                )
              : null,
          backgroundColor: user?.profile?.avatarUrl != null
              ? Colors.transparent
              : Colors.black12,
          radius: AVATAR_RADIUS - PROGRESS_WIDTH,
        ),
      ),
    );
  }
}
