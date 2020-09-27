import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:mywonderbird/services/navigation.dart';

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
            child: hasImage
                ? Image.network(
                    widget.location.images.first?.url,
                    fit: BoxFit.cover,
                  )
                : Container(color: Colors.grey),
          ),
        ),
        Positioned(
          right: 16.0,
          bottom: 0,
          height: 48,
          width: 48,
          child: FloatingActionButton(
            onPressed: _onBack,
            child: Ink(
              height: 48,
              width: 48,
              child: Icon(FontAwesome.arrow_down),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
      ],
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

  _onBack() {
    final navigationService = locator<NavigationService>();
    navigationService.pop();
  }
}
