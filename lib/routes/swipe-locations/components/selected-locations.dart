import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/components/square-icon-button.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:mywonderbird/routes/swipe-locations/main.dart';

const HEIGHT = 40.0;

class SelectedLocations extends StatelessWidget {
  final List<SuggestedLocation> selectedLocations;
  final void Function() filterLocations;
  final void Function() viewLocations;
  final void Function() selectArea;
  final int selectedFilterCount;
  final bool isAreaSelected;

  const SelectedLocations({
    Key key,
    @required this.selectedLocations,
    @required this.filterLocations,
    @required this.viewLocations,
    @required this.selectArea,
    this.selectedFilterCount,
    this.isAreaSelected,
  }) : super(key: key);

  bool get hasFilters => selectedFilterCount > 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: _content(context),
    );
  }

  Widget _content(BuildContext context) {
    final theme = Theme.of(context);
    final selectedPlacesCount =
        selectedLocations.length > 9 ? '9+' : selectedLocations.length;
    final filterCountText = hasFilters
        ? Subtitle1.light(
            selectedFilterCount > 9 ? "9+" : selectedFilterCount.toString(),
          )
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SizedBox(
            height: HEIGHT,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: BodyText1(
                "Places selected: $selectedPlacesCount",
              ),
              onPressed: viewLocations,
            ),
          ),
        ),
        SizedBox(width: 16.0),
        DescribedFeatureOverlay(
          barrierDismissible: false,
          featureId: FILTER_LOCATIONS_FEATURE,
          tapTarget: Icon(FontAwesome.sliders),
          title: H6.light('Filter locations'),
          description: Subtitle2.light(
            'Filter the locations that you are suggested by their category',
          ),
          backgroundColor: theme.accentColor,
          child: SquareIconButton(
            size: HEIGHT,
            icon: Icon(
              FontAwesome.sliders,
              color: hasFilters ? null : theme.accentColor,
            ),
            onPressed: filterLocations,
            backgroundColor:
                hasFilters ? theme.accentColor : Colors.transparent,
            label: filterCountText,
            layout: Layout.horizontal,
            padding: EdgeInsets.symmetric(horizontal: spacingFactor(1)),
            side: hasFilters ? null : BorderSide(color: theme.accentColor),
          ),
        ),
        SizedBox(width: 8.0),
        DescribedFeatureOverlay(
          barrierDismissible: false,
          featureId: SELECT_AREA_FEATURE,
          tapTarget: Icon(MaterialCommunityIcons.map_marker),
          title: H6.light('Select area'),
          description: Subtitle2.light(
            'Select the area in which you would like to get location suggestions',
          ),
          backgroundColor: theme.primaryColor,
          child: SquareIconButton(
            size: HEIGHT,
            icon: Icon(
              MaterialCommunityIcons.map_marker,
              color: isAreaSelected ? null : theme.accentColor,
            ),
            onPressed: selectArea,
            backgroundColor:
                isAreaSelected ? theme.accentColor : Colors.transparent,
            side: isAreaSelected ? null : BorderSide(color: theme.accentColor),
          ),
        ),
      ],
    );
  }
}
