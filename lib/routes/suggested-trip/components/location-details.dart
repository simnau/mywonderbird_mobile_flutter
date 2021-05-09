import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/constants/analytics-events.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:transparent_image/transparent_image.dart';

class SuggestedTripLocationDetails extends StatelessWidget {
  final SuggestedLocation location;
  final void Function(SuggestedLocation) onRemoveLocation;
  final Function(SuggestedLocation, String event) onViewLocation;
  final bool isLoading;

  const SuggestedTripLocationDetails({
    Key key,
    @required this.location,
    @required this.onRemoveLocation,
    @required this.onViewLocation,
    @required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _body(context);
  }

  Widget _body(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: ListTile(
        onTap: _onViewLocation,
        contentPadding: const EdgeInsets.all(16.0),
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
            child: location.coverImage != null
                ? FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image: location.coverImage.url,
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_forever,
            color: isLoading ? theme.disabledColor : Colors.red,
            size: 32.0,
          ),
          onPressed: isLoading ? null : _onRemoveLocation,
        ),
      ),
    );
  }

  _onRemoveLocation() {
    onRemoveLocation(location);
  }

  _onViewLocation() {
    onViewLocation(
      location,
      LOCATION_INFO_SUGGESTED_MAP,
    );
  }
}
