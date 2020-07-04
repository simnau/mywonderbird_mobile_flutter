import 'package:flutter/cupertino.dart';
import 'package:layout/routes/authentication/select-auth-option.dart';

import 'routes.dart';

class AuthenticationHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: SelectAuthOption.RELATIVE_PATH,
      onGenerateRoute: onAuthenticationGenerateRoute,
    );
  }
}
