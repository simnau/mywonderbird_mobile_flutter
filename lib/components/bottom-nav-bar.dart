import 'package:flutter/material.dart';
import 'package:layout/routes/home.dart';
import 'package:layout/routes/profile.dart';

class BottomNavBar extends StatelessWidget {
  bool routeSelected(String currentRoute, String routeName) {
    return currentRoute == routeName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var currentRoute = ModalRoute.of(context).settings.name;

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
              color: routeSelected(currentRoute, Home.PATH)
                  ? theme.primaryColor
                  : Colors.grey[300],
              onPressed: () {
                if (!routeSelected(currentRoute, Home.PATH)) {
                  Navigator.pushReplacementNamed(context, Home.PATH);
                }
              },
            ),
            IconButton(
              iconSize: 32,
              icon: Icon(Icons.person),
              color: theme.disabledColor,
              onPressed: () {
                Navigator.pushNamed(context, Profile.PATH);
              },
            ),
          ],
        ),
      ),
    );
  }
}
