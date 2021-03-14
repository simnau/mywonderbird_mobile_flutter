import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

import 'package:mywonderbird/models/suggested-location-image.dart';

class FirstCard extends StatelessWidget {
  final StoryController storyController;
  final List<SuggestedLocationImage> images;

  FirstCard({
    Key key,
    this.images,
    this.storyController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoryView(
      controller: storyController,
      repeat: true,
      storyItems: images.map((image) {
        return StoryItem.inlineProviderImage(
          NetworkImage(image.url),
        );
      }).toList(),
    );
  }
}
