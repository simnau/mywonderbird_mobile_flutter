import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/country-geo-stats.dart';
import 'package:mywonderbird/models/country-stats.dart';
import 'package:mywonderbird/models/spot-stats.dart';
import 'package:mywonderbird/models/trip-stats.dart';
import 'package:mywonderbird/routes/profile/components/country-switch.dart';
import 'package:mywonderbird/routes/profile/components/spot-card.dart';
import 'package:mywonderbird/routes/profile/components/trip-card.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

const LOCATIONS_HEIGHT = 275.0;

class VisitedLocationsMapPage extends StatelessWidget {
  final MapShapeSource shapeSource;
  final bool isLoading;
  final bool isLoadingStats;
  final Function() onPreviousCountry;
  final Function() onNextCountry;
  final Function(int index) onSelectCountry;
  final Function(TripStats tripStats) onViewTrip;
  final Function(SpotStats spotStats) onViewSpot;
  final int selectedCountryIndex;
  final CountryGeoStats selectedCountry;
  final MapZoomPanBehavior mapZoomPanBehavior;
  final List<CountryStats> selectedCountryStats;
  final List<CountryGeoStats> visitedCountries;

  const VisitedLocationsMapPage({
    Key key,
    @required this.shapeSource,
    @required this.isLoading,
    @required this.isLoadingStats,
    @required this.onPreviousCountry,
    @required this.onNextCountry,
    @required this.onSelectCountry,
    @required this.onViewTrip,
    @required this.onViewSpot,
    @required this.selectedCountryIndex,
    @required this.selectedCountry,
    @required this.mapZoomPanBehavior,
    @required this.selectedCountryStats,
    @required this.visitedCountries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
            minWidth: constraints.maxWidth,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.3, 0.6],
                colors: [
                  Color(0xFF3098FE),
                  Color(0xAA3098FE),
                  Color(0x003098FE),
                ],
              ),
            ),
            padding: const EdgeInsets.only(top: kToolbarHeight / 2),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: LOCATIONS_HEIGHT),
                    child: _map(context),
                  ),
                ),
                if (visitedCountries.isNotEmpty)
                  Positioned(
                    child: _countryLocations(),
                    bottom: 0,
                    left: 0,
                    right: 0,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _map(BuildContext context) {
    final theme = Theme.of(context);

    return Hero(
      tag: 'visited_country_map',
      child: SfMapsTheme(
        data: SfMapsThemeData(selectionColor: theme.primaryColorDark),
        child: SfMaps(
          layers: <MapShapeLayer>[
            MapShapeLayer(
              initialLatLngBounds: MapLatLngBounds(
                MapLatLng(
                  selectedCountry.boundTopLeft.latitude,
                  selectedCountry.boundBottomRight.longitude,
                ),
                MapLatLng(
                  selectedCountry.boundBottomRight.latitude,
                  selectedCountry.boundTopLeft.longitude,
                ),
              ),
              zoomPanBehavior: mapZoomPanBehavior,
              source: shapeSource,
              color: Colors.white,
              loadingBuilder: (_) => Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              selectedIndex: selectedCountryIndex,
              onSelectionChanged: onSelectCountry,
            ),
          ],
        ),
      ),
    );
  }

  Widget _countryLocations() {
    if (isLoadingStats) {
      return Container(
        height: LOCATIONS_HEIGHT,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      height: LOCATIONS_HEIGHT,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _locationsHeading(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: spacingFactor(2)),
              child: PageView.builder(
                clipBehavior: Clip.none,
                controller: PageController(
                  initialPage: 0,
                  viewportFraction: 0.9,
                ),
                itemBuilder: (context, index) {
                  final countryStat = selectedCountryStats[index];

                  if (countryStat.item is TripStats) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacingFactor(1),
                      ),
                      child: TripCard(
                        tripStats: countryStat.item,
                        onViewTrip: onViewTrip,
                        renderProgress: false,
                        showActions: false,
                        onDeleteTrip: null,
                        showCountry: false,
                        showType: true,
                      ),
                    );
                  }

                  if (countryStat.item is SpotStats) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacingFactor(1),
                      ),
                      child: SpotCard(
                        onViewSpot: onViewSpot,
                        spotStats: countryStat.item,
                        showType: true,
                      ),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacingFactor(1),
                    ),
                    child: Container(
                      color: Colors.black,
                    ),
                  );
                },
                itemCount: selectedCountryStats.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationsHeading() {
    return Padding(
      padding: EdgeInsets.only(
        left: spacingFactor(2),
        right: spacingFactor(2),
        top: spacingFactor(1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Subtitle2(
            'All adventures in:',
            color: Color(0xFF484242),
          ),
          SizedBox(width: spacingFactor(1)),
          Expanded(
            child: CountrySwitch(
              child: Subtitle2(
                selectedCountry.country,
                color: Color(0xFF484242),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              onPrevious: onPreviousCountry,
              onNext: onNextCountry,
              showNavigation: visitedCountries.length > 1,
            ),
          ),
        ],
      ),
    );
  }
}
