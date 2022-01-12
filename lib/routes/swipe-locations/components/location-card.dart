import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:story_view/controller/story_controller.dart';

import 'first-card.dart';
import 'location-details.dart';

class LocationCard extends StatelessWidget {
  final bool isStoryView;
  final SuggestedLocation item;
  final StoryController storyController;
  final Position userLocation;
  final void Function() onViewDetails;

  const LocationCard({
    Key key,
    @required this.isStoryView,
    @required this.item,
    @required this.storyController,
    @required this.onViewDetails,
    @required this.userLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isStoryView && item.images.length > 1)
            FirstCard(
              images: item.images,
              storyController: storyController,
            )
          else if (item.images.isNotEmpty && item.images.first.url != null)
            Image.network(
              item.images.first.url,
              fit: BoxFit.cover,
            )
          else
            Container(
              color: Colors.grey,
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black38],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: LocationDetails(
              item: item,
              onTap: onViewDetails,
              userLocation: userLocation,
            ),
          ),
        ],
      ),
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    );
  }
}
