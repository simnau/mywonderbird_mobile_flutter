import 'package:flutter/material.dart';
import 'package:layout/routes/share-picture/select-journey.dart';
import 'package:layout/types/select-journey-arguments.dart';
import 'package:layout/types/select-location-arguments.dart';
import 'package:layout/types/share-screen-arguments.dart';

import 'select-destination.dart';
import 'select-location.dart';
import 'share-screen.dart';

MaterialPageRoute onSharePictureGenerateRoute(settings) {
  var path = settings.name;

  var builder;
  switch (path) {
    case SelectDestination.RELATIVE_PATH:
      builder = (BuildContext context) => SelectDestination();
      break;
    case ShareScreen.RELATIVE_PATH:
      final ShareScreenArguments arguments = settings.arguments;
      builder = (BuildContext context) => ShareScreen(
            selectedJourney: arguments?.selectedJourney,
          );
      break;
    case SelectJourney.RELATIVE_PATH:
      final SelectJourneyArguments arguments = settings.arguments;

      builder = (BuildContext context) => SelectJourney(
            journey: arguments?.journey,
            createNew: arguments?.createNew,
          );
      break;
    case SelectLocation.RELATIVE_PATH:
      final SelectLocationArguments arguments = settings.arguments;

      builder = (BuildContext context) => SelectLocation(
            location: arguments?.location,
          );
      break;
    default:
      builder = (BuildContext context) => SelectDestination();
      break;
  }

  return MaterialPageRoute(builder: builder);
}
