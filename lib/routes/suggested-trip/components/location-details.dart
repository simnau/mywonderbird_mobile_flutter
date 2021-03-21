import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:transparent_image/transparent_image.dart';

class SuggestedTripLocationDetails extends StatelessWidget {
  final SuggestedLocation location;
  final void Function(SuggestedLocation) onRemoveLocation;

  const SuggestedTripLocationDetails({
    Key key,
    @required this.location,
    @required this.onRemoveLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 64,
              height: 64,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Colors.grey,
              ),
              child: location.coverImage != null
                  ? FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: location.coverImage.url,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  children: [
                    Subtitle1(
                      location.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.0),
            IconButton(
              icon: Icon(
                Icons.delete_forever,
                color: Colors.red,
              ),
              onPressed: _onRemoveLocation,
            ),
          ],
        ),
      ),
    );
  }

  _onRemoveLocation() {
    onRemoveLocation(location);
  }
}
