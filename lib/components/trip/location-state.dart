import 'package:flutter/material.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/util/color.dart';

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
      return lighten(theme.primaryColor, amount: 0.05);
    case LocationState.skipped:
      return Colors.grey[300];
    case LocationState.visited:
      return Color(0xFF38D01F);
    default:
      return Colors.white;
  }
}
