import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/routes/saved-trip-overview/components/location-slide.dart';

int locationIndexFromPage(int page) {
  if (page == null) {
    return 0;
  }

  return page - 1;
}

int pageFromLocationIndex(int locationIndex) {
  return locationIndex + 1;
}

class TripSlides extends StatelessWidget {
  final Function() onStart;
  final Function(LocationModel) onSkip;
  final Function(LocationModel) onVisited;
  final Function(LocationModel) onUploadPhoto;
  final Function(LocationModel) onNavigate;
  final FullJourney journey;
  final PageController pageController;
  final Function(int) onPageChanged;

  const TripSlides({
    Key key,
    @required this.onStart,
    @required this.journey,
    @required this.onVisited,
    @required this.onSkip,
    @required this.onUploadPhoto,
    @required this.onNavigate,
    this.pageController,
    this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      onPageChanged: onPageChanged,
      children: [
        _tripDetailSlide(context),
        ..._locationSlides(),
      ],
      physics: NeverScrollableScrollPhysics(),
    );
  }

  Widget _tripDetailSlide(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        image: journey?.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(
                  journey.imageUrl,
                ),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.black54,
            ],
            stops: [0, 0.8],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ..._journeyName(),
            ..._journeyCountry(),
            ElevatedButton(
              child: BodyText1.light('Start trip'),
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                primary: theme.primaryColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _locationSlides() {
    if (journey == null || journey.locations == null) {
      return [];
    }

    return journey.locations
        .map<Widget>(
          (location) => LocationSlide(
            location: location,
            onVisited: onVisited,
            onSkip: onSkip,
            onUploadPhoto: onUploadPhoto,
            onNavigate: onNavigate,
          ),
        )
        .toList();
  }

  List<Widget> _journeyName() {
    if (journey?.name == null) {
      return [];
    }

    return [
      H6.light(journey.name),
      Padding(padding: const EdgeInsets.only(bottom: 16.0)),
    ];
  }

  List<Widget> _journeyCountry() {
    if (journey?.countryDescription == null) {
      return [];
    }

    return [
      Subtitle2.light(
        journey.countryDescription,
        softWrap: true,
      ),
      Padding(padding: const EdgeInsets.only(bottom: 16.0)),
    ];
  }
}
