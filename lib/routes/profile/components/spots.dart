import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/spot.dart';
import 'package:mywonderbird/models/user-profile.dart';
import 'package:mywonderbird/routes/details/pages/user-location-details.dart';
import 'package:mywonderbird/routes/profile/components/spot-item.dart';
import 'package:mywonderbird/services/navigation.dart';

class Spots extends StatelessWidget {
  final String title;
  final List<Spot> spots;
  final int allSpotCount;
  final double spotSize;
  final Function() onViewAllSpots;
  final UserProfile userProfile;

  const Spots({
    Key key,
    @required this.title,
    @required this.spots,
    @required this.allSpotCount,
    @required this.spotSize,
    @required this.onViewAllSpots,
    @required this.userProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Subtitle1(
              title,
              color: Color(0xFF484242),
            ),
            TextButton(
              onPressed: onViewAllSpots,
              child: Row(
                children: [
                  Subtitle2(
                    "View all",
                    color: Colors.black45,
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Colors.black45,
                  )
                ],
              ),
              style: TextButton.styleFrom(alignment: Alignment.centerLeft),
            ),
          ],
        ),
        SizedBox(height: spacingFactor(1)),
        Container(
          height: spots.length > 4 ? spotSize * 2 + spacingFactor(1) : spotSize,
          child: Wrap(
            children: _spots(spotSize: spotSize),
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: spacingFactor(1),
            spacing: spacingFactor(1),
          ),
        ),
      ],
    );
  }

  List<Widget> _spots({double spotSize}) {
    final hasMoreSpots = spots.length < allSpotCount;
    final List<Widget> widgets = [];

    for (final spot in spots) {
      if (hasMoreSpots && spot == spots.last) {
        widgets.add(_viewMoreSpot(spot, spotSize));
      } else {
        widgets.add(
          SpotItem(
            size: spotSize,
            spot: spot,
            onView: _onViewSpot,
          ),
        );
      }
    }

    return widgets;
  }

  Widget _viewMoreSpot(Spot spot, double size) {
    final moreSpotCount = allSpotCount - spots.length;

    return Stack(
      children: [
        SpotItem(
          size: size,
          spot: spot,
          onView: _onViewSpot,
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onViewAllSpots,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.all(Radius.circular(borderRadiusFactor(1))),
                  color: Colors.black54,
                ),
                alignment: Alignment.center,
                child: H6.light("+$moreSpotCount"),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _onViewSpot(Spot spot) {
    final navigationService = locator<NavigationService>();

    navigationService.push(MaterialPageRoute(
      builder: (_) => UserLocationDetails(
        locationId: spot.id,
        userAvatar: userProfile.avatarUrl,
        userBio: userProfile.bio,
        userId: userProfile.providerId,
        userName: userProfile.username,
      ),
    ));
  }
}
