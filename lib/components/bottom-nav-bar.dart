import 'package:flutter/material.dart';
import 'package:layout/locator.dart';
import 'package:layout/routes/home/main.dart';
import 'package:layout/routes/profile/main.dart';
import 'package:layout/services/navigation.dart';

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
    final theme = Theme.of(context);
    final currentRoute = ModalRoute.of(context).settings.name;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 32.0,
          right: 32.0,
          bottom: 4.0,
          top: 4.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              iconSize: 32,
              icon: Icon(Icons.explore),
              color: routeSelected(currentRoute, HomePage.PATH)
                  ? theme.primaryColor
                  : Colors.grey[300],
              onPressed: _onNavigateToFeed,
            ),
            IconButton(
              iconSize: 32,
              icon: Icon(Icons.person),
              color: theme.disabledColor,
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
}
