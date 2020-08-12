import 'package:flutter/material.dart';
import 'package:layout/models/user.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

const double AVATAR_RADIUS = 50;
const double PROGRESS_WIDTH = 8;

class ProfileAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double collapsedHeight;
  final Function() onSettings;
  final Widget tabBar;

  const ProfileAppBar({
    @required this.expandedHeight,
    @required this.collapsedHeight,
    this.onSettings,
    this.tabBar,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final user = Provider.of<User>(context);

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
                    trailing: Align(
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
                  Text(
                    _getUsername(user),
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _getLevel(),
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.black45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
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

  Widget _avatar(user) {
    return Material(
      shape: CircleBorder(),
      elevation: 8,
      child: CircularPercentIndicator(
        startAngle: 180,
        backgroundColor: Colors.transparent,
        radius: AVATAR_RADIUS * 2, // This is actually the diameter...
        lineWidth: PROGRESS_WIDTH,
        percent: 0.4,
        center: CircleAvatar(
          backgroundImage: user?.profile?.avatarUrl != null
              ? AssetImage('images/logo.png')
              : null,
          child: user?.profile?.avatarUrl == null
              ? Text(
                  _getUserInitials(user),
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

  // TODO: extract into the user class
  String _getUsername(User user) {
    return user?.profile?.username ?? 'Anonymous';
  }

  // TODO: extract into the user class
  String _getUserInitials(User user) {
    return user?.profile?.username?.substring(0, 2)?.toUpperCase() ?? '??';
  }

  String _getLevel() {
    return 'Beginner';
  }
}
