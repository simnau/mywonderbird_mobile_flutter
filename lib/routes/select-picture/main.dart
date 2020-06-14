import 'package:flutter/material.dart';

import 'home.dart';
import 'routes.dart';

class SelectPictureRoot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: SelectPictureHome.RELATIVE_PATH,
      onGenerateRoute: onSelectPictureGenerateRoute,
    );
  }
}
