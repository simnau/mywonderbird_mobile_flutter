import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/models/location.dart';

class LocationSlide extends StatelessWidget {
  final LocationModel location;
  final Function(LocationModel) onSkip;
  final Function(LocationModel) onUploadPhoto;
  final Function(LocationModel) onVisited;
  final Function(LocationModel) onNavigate;

  const LocationSlide({
    Key key,
    @required this.location,
    @required this.onSkip,
    @required this.onNavigate,
    @required this.onVisited,
    @required this.onUploadPhoto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: location.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(
                  location.imageUrl,
                ),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.black54,
            ],
            stops: [0, 0.8],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ..._locationName(),
            _actions(),
          ],
        ),
      ),
    );
  }

  List<Widget> _locationName() {
    if (location?.name == null) {
      return [];
    }

    return [
      H6.light(location.name),
      Padding(padding: const EdgeInsets.only(bottom: 16.0)),
    ];
  }

  Widget _actions() {
    return SizedBox(
      height: 68,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FloatingActionButton(
            onPressed: _onSkip,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            child: Icon(Icons.close),
            heroTag: null,
            mini: true,
          ),
          Align(
            alignment: Alignment.center,
            child: FloatingActionButton(
              onPressed: _onUploadPhoto,
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              child: Icon(
                MaterialCommunityIcons.image_plus,
                size: 32,
              ),
              heroTag: null,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: FloatingActionButton(
              onPressed: _onVisited,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              child: Icon(
                MaterialCommunityIcons.map_check,
                size: 32,
              ),
              heroTag: null,
            ),
          ),
          FloatingActionButton(
            onPressed: _onNavigate,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            child: Icon(Icons.directions),
            heroTag: null,
            mini: true,
          ),
        ],
      ),
    );
  }

  _onSkip() {
    onSkip(location);
  }

  _onUploadPhoto() {
    onUploadPhoto(location);
  }

  _onVisited() {
    onVisited(location);
  }

  _onNavigate() {
    onNavigate(location);
  }
}
