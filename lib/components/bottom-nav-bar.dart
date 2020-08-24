import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/bookmarks/main.dart';
import 'package:mywonderbird/routes/home/main.dart';
import 'package:mywonderbird/routes/notifications/main.dart';
import 'package:mywonderbird/routes/profile/main.dart';
import 'package:mywonderbird/services/navigation.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  bool routeSelected(String currentRoute, String routeName) {
    return currentRoute == routeName;
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: 4.0,
          top: 4.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              iconSize: 32,
              icon: Icon(Ionicons.md_globe),
              color: Colors.black87,
              onPressed: _onNavigateToFeed,
            ),
            IconButton(
              iconSize: 32,
              icon: Icon(Icons.collections_bookmark),
              color: Colors.black54,
              onPressed: _onNavigateToBookmarks,
            ),
            SizedBox(
              width: 60,
            ),
            IconButton(
              iconSize: 32,
              icon: Icon(Icons.notifications_none),
              color: Colors.black54,
              onPressed: _onNavigateToNotifications,
            ),
            IconButton(
              iconSize: 32,
              icon: Icon(Icons.person),
              color: Colors.black54,
              onPressed: _onNavigateToProfile,
            ),
          ],
        ),
      ),
    );
  }

  _onNavigateToFeed() {
    final currentRoute = ModalRoute.of(context).settings.name;

    if (!routeSelected(currentRoute, HomePage.PATH)) {
      locator<NavigationService>().pushReplacementNamed(HomePage.PATH);
    }
  }

  _onNavigateToProfile() {
    locator<NavigationService>().pushNamed(Profile.PATH);
  }

  _onNavigateToBookmarks() {
    locator<NavigationService>().pushNamed(Bookmarks.PATH);
  }

  _onNavigateToNotifications() {
    locator<NavigationService>().pushNamed(Notifications.PATH);
  }
}
