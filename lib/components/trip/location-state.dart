import 'package:flutter/material.dart';
import 'package:mywonderbird/models/location.dart';

enum LocationState {
  visited,
  active,
  skipped,
}

LocationState locationStateFromLocation(LocationModel location, bool isActive) {
  if (location.skipped ?? false) {
    return LocationState.skipped;
  } else if (location.visitedAt != null) {
    return LocationState.visited;
  } else if (isActive) {
    return LocationState.active;
  }

  return null;
}

Color colorFromLocationState(LocationState state, ThemeData theme) {
  switch (state) {
    case LocationState.active:
      return theme.primaryColor;
    case LocationState.skipped:
      return Colors.grey[400];
    case LocationState.visited:
      return Colors.green;
    default:
      return Colors.white;
  }
}
