import 'package:flutter/cupertino.dart';

import 'routes.dart';
import 'profile.dart';

class ProfileHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: Profile.RELATIVE_PATH,
      onGenerateRoute: onProfileGenerateRoute,
    );
  }
}
