import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/components/custom-icons.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/analytics-events.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/bookmarks/main.dart';
import 'package:mywonderbird/routes/home/main.dart';
import 'package:mywonderbird/routes/swipe-locations/main.dart';
import 'package:mywonderbird/services/navigation.dart';

class BottomNavBar extends StatefulWidget {
  final Function() onHome;
  final Function() onTripPlanning;

  const BottomNavBar({
    Key key,
    this.onHome,
    this.onTripPlanning,
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
    final theme = Theme.of(context);

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: TextButton.icon(
              onPressed: widget.onHome,
              icon: Icon(
                Ionicons.md_globe,
                color: theme.primaryColor,
              ),
              label: BodyText1(
                'Feed',
                color: theme.primaryColor,
              ),
              style: TextButton.styleFrom(
                minimumSize: Size.fromHeight(48),
              ),
            ),
          ),
          Spacer(
            flex: 1,
          ),
          Expanded(
            flex: 2,
            child: DescribedFeatureOverlay(
              barrierDismissible: false,
              featureId: PLANNING_FEATURE,
              tapTarget: Icon(CustomIcons.route),
              title: H6.light('Plan a trip'),
              description: Subtitle2.light(
                'Get suggestions for locations that you like and swipe them into a route that suits you best',
              ),
              child: TextButton.icon(
                onPressed: widget.onTripPlanning,
                icon: Icon(CustomIcons.route),
                label: BodyText1('Planning'),
                style: TextButton.styleFrom(
                  minimumSize: Size.fromHeight(48),
                ),
              ),
            ),
          ),
        ],
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
