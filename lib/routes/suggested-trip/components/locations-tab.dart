import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:transparent_image/transparent_image.dart';

class LocationsTab extends StatelessWidget {
  final List<List<SuggestedLocation>> locations;
  final Function(int) onRemoveLocation;

  const LocationsTab({
    Key key,
    this.locations,
    this.onRemoveLocation,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: _day,
      itemCount: locations.length,
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
      ),
    );
  }

  Widget _day(context, dayIndex) {
    final day = locations[dayIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: H6(
            "Day ${dayIndex + 1}",
          ),
        ),
        _locations(day),
      ],
    );
  }

  Widget _locations(List<SuggestedLocation> locations) {
    return Column(
      children: locations.map(_location).toList(),
    );
  }

  Widget _location(location) {
    final imageUrl = location.coverImage?.url;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8.0,
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
        // TODO: Implement this when necessary
        // trailing: IconButton(
        //   icon: Icon(
        //     Icons.delete_forever,
        //     color: Colors.red,
        //   ),
        //   onPressed: () {},
        // ),
      ),
    );
  }
}
