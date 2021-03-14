import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/models/suggested-location.dart';

const HEIGHT = 40.0;

class SelectedLocations extends StatelessWidget {
  final List<SuggestedLocation> selectedLocations;
  final void Function() filterLocations;
  final void Function() viewLocations;
  final void Function() selectTerritory;

  const SelectedLocations({
    Key key,
    @required this.selectedLocations,
    @required this.filterLocations,
    @required this.viewLocations,
    @required this.selectTerritory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: _content(context),
    );
  }

  Widget _content(BuildContext context) {
    final theme = Theme.of(context);
    final selectedPlacesCount =
        selectedLocations.length > 9 ? '9+' : selectedLocations.length;

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
        SizedBox(
          height: HEIGHT,
          width: HEIGHT,
          child: FloatingActionButton(
            heroTag: null,
            backgroundColor: theme.primaryColor,
            child: Icon(
              FontAwesome.sliders,
            ),
            onPressed: filterLocations,
            elevation: 0,
            highlightElevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        SizedBox(width: 8.0),
        SizedBox(
          height: HEIGHT,
          width: HEIGHT,
          child: FloatingActionButton(
            heroTag: null,
            backgroundColor: theme.primaryColor,
            child: Icon(
              MaterialCommunityIcons.map_marker,
            ),
            onPressed: selectTerritory,
            elevation: 0,
            highlightElevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ],
    );
  }
}
