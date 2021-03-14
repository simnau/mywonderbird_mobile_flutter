import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/components/custom-icons.dart';
import 'package:mywonderbird/constants/analytics-events.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/bookmarks/main.dart';
import 'package:mywonderbird/routes/profile/main.dart';
import 'package:mywonderbird/routes/swipe-locations/main.dart';
import 'package:mywonderbird/services/navigation.dart';

class BottomNavBar extends StatefulWidget {
  final Function() onHome;

  const BottomNavBar({
    Key key,
    this.onHome,
  }) : super(key: key);

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
              onPressed: widget.onHome,
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
              icon: Icon(CustomIcons.route),
              color: Colors.black54,
              onPressed: _onSuggestTrip,
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

  _onNavigateToProfile() {
    locator<NavigationService>().pushNamed(Profile.PATH);
  }

  _onNavigateToBookmarks() {
    locator<NavigationService>().pushNamed(Bookmarks.PATH);
  }

  _onSuggestTrip() {
    locator<NavigationService>().push(
      MaterialPageRoute(builder: (context) => SwipeLocations()),
    );

    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: INIT_TRIP_SUGGESTION);
  }
}
