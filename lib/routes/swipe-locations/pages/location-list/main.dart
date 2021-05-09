import 'package:flutter/material.dart';
import 'package:mywonderbird/components/empty-list-placeholder.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:mywonderbird/providers/swipe.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class LocationList extends StatelessWidget {
  final void Function(int) removeLocation;
  final void Function() clearLocations;
  final void Function(SuggestedLocation) viewLocation;

  const LocationList({
    Key key,
    @required this.removeLocation,
    @required this.clearLocations,
    @required this.viewLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final swipeProvider = Provider.of<SwipeProvider>(context);
    final locations = swipeProvider.selectedLocations;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          if (locations.isNotEmpty)
            TextButton(
              onPressed: clearLocations,
              child: Text(
                'REMOVE ALL',
                style: TextStyle(
                  color: theme.errorColor,
                ),
              ),
            ),
        ],
      ),
      body: _content(context),
    );
  }

  Widget _content(BuildContext context) {
    final swipeProvider = Provider.of<SwipeProvider>(context);
    final locations = swipeProvider.selectedLocations;

    if (locations.isEmpty) {
      return EmptyListPlaceholder(
        title: 'You have not selected any places',
        subtitle: 'Like some places and they will appear here',
      );
    }

    return ListView.separated(
      itemBuilder: _location,
      itemCount: locations.length,
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
      ),
    );
  }

  Widget _location(BuildContext context, int locationIndex) {
    final swipeProvider = Provider.of<SwipeProvider>(context);
    final locations = swipeProvider.selectedLocations;

    final location = locations[locationIndex];
    final imageUrl = location.coverImage?.url;
    final onRemove = () => removeLocation(locationIndex);
    final onViewLocation = () => viewLocation(location);

    return ListTile(
      onTap: onViewLocation,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 32.0,
        vertical: 8.0,
      ),
      title: Subtitle1(
        location.name,
        overflow: TextOverflow.ellipsis,
      ),
      leading: AspectRatio(
        aspectRatio: 1,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: Colors.grey,
          ),
          child: imageUrl != null
              ? FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: imageUrl,
                  fit: BoxFit.cover,
                )
              : null,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.delete_forever,
          color: Colors.red,
        ),
        onPressed: onRemove,
      ),
    );
  }
}
