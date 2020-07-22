import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:layout/locator.dart';
import 'package:layout/models/location.dart';
import 'package:layout/services/location.dart';

import 'package:layout/components/showcase-icon.dart';
import 'package:layout/util/debouncer.dart';
import 'package:layout/util/location.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';

class SelectLocation extends StatefulWidget {
  static const SUB_PATH = 'location';
  static const RELATIVE_PATH = "share-picture/$SUB_PATH";
  static const PATH = "/$RELATIVE_PATH";

  final LocationModel location;

  SelectLocation({this.location});

  @override
  _SelectLocationState createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  static const _INITIAL_ZOOM = 14.4746;
  static const _INITIAL_CAMERA_POSITION = CameraPosition(
    target: LatLng(
      37.42796133580664,
      -122.085749655962,
    ),
    zoom: _INITIAL_ZOOM,
  );

  Completer<GoogleMapController> _controller = Completer();
  PersistentBottomSheetController _bottomSheetController;
  bool _searchModalOpen = false;
  LocationModel _selectedLocation;
  LocationData _currentLocation;

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
  }

  void _setCurrentLocation() async {
    _currentLocation = await getCurrentLocation();
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

  void _onMapLongPress(LatLng pos) {
    setState(() {
      _selectedLocation = LocationModel(
        id: Uuid().v4(),
        name: latLngToString(pos),
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
    final initialCameraPosition = widget.location != null
        ? CameraPosition(target: widget.location.latLng, zoom: _INITIAL_ZOOM)
        : _INITIAL_CAMERA_POSITION;

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
              onTap: _searchModalOpen ? (_) => _closeSearch() : null,
              onLongPress: _searchModalOpen ? null : _onMapLongPress,
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
              child: RaisedButton(
                color: theme.primaryColor,
                textColor: Colors.white,
                child: Text(
                  'Select location',
                ),
                onPressed: _selectedLocation != null ? _selectPlace : null,
                disabledColor: Colors.grey[500],
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
  final LocationData currentLocation;

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
      final locationService = locator<LocationService>();
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
    final theme = Theme.of(context);

    return Container(
      height: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(32.0),
            child: TextField(
              autofocus: true,
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.primaryColor,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    style: BorderStyle.solid,
                    color: theme.primaryColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                hintText: 'Search for places',
                hintStyle: TextStyle(
                  color: Colors.black26,
                ),
              ),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
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
                  child: Text(
                    "What are\n"
                    "you searching for?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
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
                  child: Text(
                    "Is it an astonishing landmark?\n"
                    "Or perhaps it is a sight in a city?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black26,
                    ),
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
                    leading: Container(
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
                    ),
                    title: Text(
                      place.name,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      place.country,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black26,
                      ),
                    ),
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
