import 'package:flutter/material.dart';
import 'package:layout/routes/share-picture/select-destination.dart';

import 'routes.dart';

class SharePictureRoot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: SelectDestination.RELATIVE_PATH,
      onGenerateRoute: onSharePictureGenerateRoute,
    );
  }
}
