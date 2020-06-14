import 'package:layout/models/journey.dart';

class SelectJourneyArguments {
  final Journey journey;
  final bool createNew;

  SelectJourneyArguments({
    this.journey,
    this.createNew,
  });
}
