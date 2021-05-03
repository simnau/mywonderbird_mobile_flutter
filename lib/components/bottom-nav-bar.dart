import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/constants/analytics-events.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/bookmarks/main.dart';
import 'package:mywonderbird/routes/swipe-locations/main.dart';
import 'package:mywonderbird/services/navigation.dart';

class BottomNavBar extends StatefulWidget {
  final Function() onHome;
  final Function() onTripPlanning;
  final bool isPlanningTabActive;

  const BottomNavBar(
      {Key key, this.onHome, this.onTripPlanning, this.isPlanningTabActive})
      : super(key: key);

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
            new Container(
              decoration: !widget.isPlanningTabActive
                  ? new BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: 1.0, color: Colors.blue.shade300)))
                  : null,
              child: TextButton.icon(
                  onPressed: widget.onHome,
                  icon: Icon(Ionicons.md_globe),
                  label: Text('Feed')),
            ),
            Spacer(),
            new Container(
              decoration: widget.isPlanningTabActive
                  ? BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: 1.0, color: Colors.blue.shade300)))
                  : null,
              child: TextButton.icon(
                  onPressed: widget.onTripPlanning,
                  icon: Icon(Ionicons.md_globe),
                  label: Text('Planning')),
            )
          ],
        ),
      ),
    );
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
