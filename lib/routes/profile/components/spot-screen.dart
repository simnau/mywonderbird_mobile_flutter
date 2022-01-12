import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/spot-stats.dart';
import 'package:mywonderbird/providers/profile.dart';
import 'package:mywonderbird/routes/details/pages/user-location-details.dart';
import 'package:mywonderbird/routes/profile/components/spot-list-item.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/user-location.dart';
import 'package:mywonderbird/util/snackbar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:timeago/timeago.dart' as timeago;

const MAX_TILE_HEIGHT = 200;

final List<StaggeredTile> tiles = [
  StaggeredTile.count(2, 3),
  StaggeredTile.count(2, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(2, 2),
  StaggeredTile.count(1, 2),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(2, 3),
  StaggeredTile.count(2, 1),
  StaggeredTile.count(2, 2),
  StaggeredTile.count(2, 2),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1),
];

final List<StaggeredTile> tilesLength1 = [
  StaggeredTile.count(4, 2),
];

final List<StaggeredTile> tilesLength2 = [
  StaggeredTile.count(2, 2),
  StaggeredTile.count(2, 2),
];

final List<StaggeredTile> tilesLength3 = [
  StaggeredTile.count(2, 2),
  StaggeredTile.count(2, 1),
  StaggeredTile.count(2, 1),
];

final List<StaggeredTile> tilesLength4 = [
  StaggeredTile.count(2, 2),
  StaggeredTile.count(2, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1),
];

List<StaggeredTile> getTilesBySpotCount(int spotCount) {
  switch (spotCount) {
    case 1:
      return tilesLength1;
    case 2:
      return tilesLength2;
    case 3:
      return tilesLength3;
    case 4:
      return tilesLength4;
    default:
      return tiles;
  }
}

class SpotScreen extends StatefulWidget {
  final String title;
  final Future<List<SpotStats>> Function() fetchSpotsFunction;
  final Widget emptyListPlaceholder;
  final bool showItemActions;

  const SpotScreen({
    Key key,
    @required this.title,
    this.fetchSpotsFunction,
    this.emptyListPlaceholder,
    bool showItemActions,
  })  : showItemActions = showItemActions ?? false,
        super(key: key);

  @override
  _SpotScreenState createState() => _SpotScreenState();
}

class _SpotScreenState extends State<SpotScreen> {
  List<SpotStats> _spots;
  List<GroupedSpot> _groupedSpots;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _fetchSpots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Subtitle1(widget.title),
        backgroundColor: Colors.transparent,
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groupedSpots.isEmpty) {
      if (widget.emptyListPlaceholder != null) {
        return Center(child: widget.emptyListPlaceholder);
      } else {
        return Container();
      }
    }

    return RefreshIndicator(
      onRefresh: _fetchSpots,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: spacingFactor(2),
          vertical: spacingFactor(1),
        ),
        itemBuilder: _spotGrid,
        separatorBuilder: (context, index) =>
            SizedBox(height: spacingFactor(3)),
        itemCount: _groupedSpots.length,
        shrinkWrap: true,
      ),
    );
  }

  Widget _spotGrid(BuildContext context, int index) {
    final groupedSpot = _groupedSpots[index];
    final country = groupedSpot.country;
    final spots = groupedSpot.spots;

    if (spots.isEmpty) {
      return Container();
    }

    final firstSpotDate = spots.first.updatedAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Subtitle2(country, color: Colors.black87),
            SizedBox(width: spacingFactor(1)),
            BodyText1(timeago.format(firstSpotDate)),
          ],
        ),
        SizedBox(height: spacingFactor(1)),
        StaggeredGridView.countBuilder(
          shrinkWrap: true,
          crossAxisCount: 4,
          mainAxisSpacing: spacingFactor(1),
          crossAxisSpacing: spacingFactor(1),
          physics: NeverScrollableScrollPhysics(),
          itemCount: spots.length,
          staggeredTileBuilder: (index) => _tileBuilder(index, spots.length),
          itemBuilder: (context, index) {
            final spot = spots[index];

            return SpotListItem(
              spot: spot,
              onTap: _onViewSpot,
              showActions: widget.showItemActions,
              onDelete: _onDeleteSpot,
            );
          },
        ),
      ],
    );
  }

  StaggeredTile _tileBuilder(index, spotCount) {
    final matchingTiles = getTilesBySpotCount(spotCount);

    return matchingTiles[index % matchingTiles.length];
  }

  Future<void> _fetchSpots() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final spots = await widget.fetchSpotsFunction();
      final groupedSpots = groupSpots(spots);

      setState(() {
        _spots = spots;
        _groupedSpots = groupedSpots;
        _isLoading = false;
      });
    } catch (error) {
      final errorSnackbar = createErrorSnackbar(
        text: "There was an error loading the spots. Please try again",
      );

      ScaffoldMessenger.of(context).showSnackBar(errorSnackbar);
    }
  }

  _onViewSpot(SpotStats spot) {
    final navigationService = locator<NavigationService>();

    navigationService.push(MaterialPageRoute(
      builder: (_) => UserLocationDetails(locationId: spot.id),
    ));
  }

  _onDeleteSpot(SpotStats spot) async {
    final navigationService = locator<NavigationService>();
    final theme = Theme.of(context);

    final result = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Subtitle1("Are you sure?"),
        content: Subtitle2("You cannot undo this action"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              navigationService.pop(false);
            },
            child: BodyText1(
              'Cancel',
              color: theme.primaryColor,
            ),
          ),
          TextButton(
            onPressed: () {
              navigationService.pop(true);
            },
            child: BodyText1(
              'Delete',
              color: theme.errorColor,
            ),
          ),
        ],
      ),
    );

    if (result != null && result) {
      await _deleteSpot(spot);
    }
  }

  _deleteSpot(SpotStats spot) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userLocationService = locator<UserLocationService>();
      await userLocationService.deleteById(spot.id);

      setState(() {
        _spots.remove(spot);
        _groupedSpots = groupSpots(_spots);
        _isLoading = false;
      });

      final profileProvider = locator<ProfileProvider>();
      profileProvider.reloadProfile = true;

      final snackBar = createSuccessSnackbar(
        text: 'The spot has been deleted',
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      final snackBar = createErrorSnackbar(
        text: 'An unexpected error has occurred. Please try again later.',
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}

class GroupedSpot {
  final String country;
  final String countryCode;
  final List<SpotStats> spots;

  GroupedSpot({
    @required this.country,
    @required this.countryCode,
    @required this.spots,
  });
}

List<GroupedSpot> groupSpots(List<SpotStats> spots) {
  if (spots.isEmpty) {
    return [];
  }

  final List<GroupedSpot> result = [];
  String currentCountry = spots.first.country;
  String currentCountryCode = spots.first.countryCode;
  List<SpotStats> currentCountrySpots = [spots.first];

  for (var i = 1; i < spots.length; i++) {
    final spot = spots[i];

    if (spot.countryCode == currentCountryCode) {
      currentCountrySpots.add(spot);
    } else {
      result.add(GroupedSpot(
        country: currentCountry,
        countryCode: currentCountryCode,
        spots: currentCountrySpots,
      ));
      currentCountry = spot.country;
      currentCountryCode = spot.countryCode;
      currentCountrySpots = [spot];
    }
  }

  result.add(GroupedSpot(
    country: currentCountry,
    countryCode: currentCountryCode,
    spots: currentCountrySpots,
  ));

  return result;
}
