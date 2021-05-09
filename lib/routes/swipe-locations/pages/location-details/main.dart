import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:story_view/story_view.dart';

class LocationDetails extends StatefulWidget {
  final SuggestedLocation location;

  const LocationDetails({
    Key key,
    @required this.location,
  }) : super(key: key);

  @override
  _LocationDetailsState createState() => _LocationDetailsState();
}

class _LocationDetailsState extends State<LocationDetails> {
  final storyController = StoryController();

  bool get hasImage =>
      widget.location.images.isNotEmpty &&
      widget.location.images.first?.url != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      _image(),
                      _details(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _image() {
    final theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: _imageContent(),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _imageContent() {
    if (!hasImage) {
      return Container(color: Colors.grey);
    }

    if (widget.location.images.length == 1) {
      return Image.network(
        widget.location.images.first?.url,
        fit: BoxFit.cover,
      );
    }

    return StoryView(
      controller: storyController,
      repeat: true,
      inline: true,
      storyItems: widget.location.images.map((image) {
        return StoryItem.inlineProviderImage(
          NetworkImage(image.url),
          roundedTop: false,
          roundedBottom: false,
        );
      }).toList(),
    );
  }

  Widget _details() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Subtitle1(
            widget.location.name,
            softWrap: true,
          ),
          Padding(padding: const EdgeInsets.only(bottom: 4.0)),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.black54,
              ),
              Padding(padding: const EdgeInsets.only(right: 4.0)),
              Subtitle2(
                widget.location.country,
                softWrap: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
