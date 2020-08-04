import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  Future<T> push<T extends Object>(Route<T> route) {
    return navigatorKey.currentState.push(route);
  }

  Future<dynamic> pushNamed(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState.pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushReplacementNamed(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  void popUntil(RoutePredicate predicate) {
    navigatorKey.currentState.popUntil(predicate);
  }

  void pop<T extends Object>([T result]) {
    return navigatorKey.currentState.pop(result);
  }
}
