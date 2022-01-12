import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/components/search-input.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/services/geo.dart';

import 'package:mywonderbird/components/showcase-icon.dart';
import 'package:mywonderbird/util/debouncer.dart';
import 'package:mywonderbird/util/location.dart';
import 'package:uuid/uuid.dart';

class SelectLocation extends StatefulWidget {
  final LocationModel location;

  SelectLocation({this.location});

  @override
  _SelectLocationState createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  static const _INITIAL_ZOOM = 14.4746;
  static const _INITIAL_LATITUDE = 37.42796133580664;
  static const _INITIAL_LONGITUDE = -122.085749655962;

  Completer<GoogleMapController> _controller = Completer();
  PersistentBottomSheetController _bottomSheetController;
  bool _searchModalOpen = false;
  LocationModel _selectedLocation;
  Position _currentLocation;

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
  }

  void _setCurrentLocation() async {
    final currLocation = await getCurrentLocation();
    setState(() {
      _currentLocation = currLocation;
    });
  }

  void _closeSearch() {
    _bottomSheetController.close();
  }

  void _onSelect(LocationModel location) async {
    final mapController = await _controller.future;

    setState(() {
      _selectedLocation = location;
    });

    _closeSearch();
    mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location.latLng,
          zoom: 12.0,
        ),
      ),
    );
  }

  void _onSelectLocation(LatLng pos) {
    setState(() {
      _selectedLocation = LocationModel(
        id: Uuid().v4(),
        country: null,
        countryCode: null,
        imageUrl: null,
        latLng: pos,
      );
    });
  }

  void _search(context) async {
    setState(() {
      _searchModalOpen = true;
    });

    _bottomSheetController = Scaffold.of(context).showBottomSheet(
      (_) => _BottomSheet(
        onSelect: _onSelect,
        currentLocation: _currentLocation,
      ),
    );

    await _bottomSheetController.closed;

    setState(() {
      _searchModalOpen = false;
    });
  }

  void _selectPlace() {
    Navigator.of(context).pop(_selectedLocation);
  }

  Set<Marker> _createMarkers() {
    if (_selectedLocation != null) {
      return Set.of(
        [
          Marker(
            markerId: MarkerId('Location'),
            position: _selectedLocation.latLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(199.0),
          ),
        ],
      );
    } else if (widget.location != null) {
      return Set.of(
        [
          Marker(
            markerId: MarkerId('Location'),
            position: widget.location.latLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(199.0),
          ),
        ],
      );
    }

    return Set.identity();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gesturesEnabled = !_searchModalOpen;
    final targetLoc = widget.location != null
        ? widget.location.latLng
        : LatLng(
            _currentLocation?.latitude ?? _INITIAL_LATITUDE,
            _currentLocation?.longitude ?? _INITIAL_LONGITUDE,
          );

    if (_currentLocation == null && widget.location == null)
      return Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(),
        ),
      );

    final initialCameraPosition =
        CameraPosition(target: targetLoc, zoom: _INITIAL_ZOOM);

    return new Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: <Widget>[
          Builder(
            builder: (iconButtonContext) => IconButton(
              color: Colors.white,
              icon: Icon(
                _searchModalOpen ? Icons.close : Icons.search,
                size: 40,
              ),
              onPressed: () => _searchModalOpen
                  ? _closeSearch()
                  : _search(iconButtonContext),
            ),
          )
        ],
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap:
                  _searchModalOpen ? (_) => _closeSearch() : _onSelectLocation,
              markers: _createMarkers(),
              mapToolbarEnabled: false,
              rotateGesturesEnabled: false,
              zoomControlsEnabled: false,
              zoomGesturesEnabled: gesturesEnabled,
              tiltGesturesEnabled: gesturesEnabled,
              scrollGesturesEnabled: gesturesEnabled,
            ),
            Positioned(
              bottom: 32,
              left: 32,
              right: 32,
              child: ElevatedButton(
                onPressed: _selectedLocation != null ? _selectPlace : null,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.disabled))
                      return Colors.grey;
                    return theme.primaryColor; // Defer to the widget's default.
                  }),
                  foregroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.disabled))
                      return Colors.grey;
                    return null; // Defer to the widget's default.
                  }),
                ),
                child: BodyText1.light('SELECT'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _BottomSheet extends StatefulWidget {
  final ValueChanged<LocationModel> onSelect;
  final Position currentLocation;

  _BottomSheet({
    @required this.onSelect,
    this.currentLocation,
  });

  @override
  _BottomSheetState createState() => _BottomSheetState();
}

class _BottomSheetState extends State<_BottomSheet> {
  final _searchController = TextEditingController();
  final _searchDebouncer = Debouncer(milliseconds: 300);

  List<LocationModel> _places = [];
  bool _loading = false;
  String _previousSearchValue = '';

  void _onPlaceSelect(LocationModel location) {
    widget.onSelect(location);
  }

  void _onSearchChange() {
    if (_searchController.text == _previousSearchValue) {
      return;
    }

    _previousSearchValue = _searchController.text;

    if (_searchController.text.isEmpty) {
      setState(() {
        _places = [];
        _loading = false;
      });
      _searchDebouncer.cancel();
      return;
    }

    _searchDebouncer.run(() async {
      setState(() {
        _loading = true;
      });
      final locationService = locator<GeoService>();
      final places = await locationService.searchLocations(
        _searchController.text,
        widget.currentLocation,
      );

      setState(() {
        _places = places;
        _loading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChange);
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.removeListener(_onSearchChange);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(32.0),
            child: SearchInput(
              hintText: 'Search for places',
              searchController: _searchController,
            ),
          ),
          Visibility(
            visible: !_loading && _places.isEmpty,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ShowcaseIcon(
                        icon: Icon(
                          Icons.landscape,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                      ShowcaseIcon(
                        icon: Icon(
                          Icons.account_balance,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                      ShowcaseIcon(
                        icon: Icon(
                          Icons.beach_access,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 32,
                  ),
                ),
                Container(
                  child: Subtitle1(
                    "What are\n"
                    "you searching for?",
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                    bottom: 32,
                  ),
                  child: Subtitle2(
                    "Is it an astonishing landmark?\n"
                    "Or perhaps it is a sight in a city?",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: _loading,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          Visibility(
            visible: !_loading && _places.isNotEmpty,
            child: Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final place = _places[index];

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 8.0,
                    ),
                    onTap: () => _onPlaceSelect(place),
                    leading: place.imageUrl != null
                        ? Container(
                            width: 64,
                            height: 64,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  place.imageUrl,
                                ),
                              ),
                            ),
                          )
                        : null,
                    title: Subtitle1(place.name),
                    subtitle: Subtitle2(place.country),
                  );
                },
                itemCount: _places.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
