import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/components/infinite-list.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/bookmark-group.dart';
import 'package:mywonderbird/models/bookmarked-location.dart';
import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/providers/journey.dart';
import 'package:mywonderbird/routes/image-view/main.dart';
import 'package:mywonderbird/routes/share-picture/mock.dart';
import 'package:mywonderbird/routes/trip-overview/main.dart';
import 'package:mywonderbird/services/bookmark.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/suggestion.dart';
import 'package:transparent_image/transparent_image.dart';

const DEFAULT_PAGE_SIZE = 20;

Future<List<BookmarkedLocationModel>> fetchBookmarkedLocations({
  int page,
  String bookmarkGroupId,
  int offset = DEFAULT_PAGE_SIZE,
}) async {
  final bookmarkedLocationService = locator<BookmarkService>();

  return bookmarkedLocationService.fetchBookmarkedGemCaptures(
    bookmarkGroupId,
    page,
    offset,
  );
}

final journey = FullJourney(
  name: 'Incredible trip to Iceland',
  country: 'Iceland',
  imageUrl: MOCK_IMAGE,
  startDate: DateTime.now(),
  locations: [
    LocationModel(
      name: 'Iceland canyon',
      countryCode: 'IS',
      country: 'Iceland',
      latLng: LatLng(63.402945, -19.042128),
      imageUrl: MOCK_IMAGE_2,
    ),
    LocationModel(
      name: 'The black beach',
      countryCode: 'IS',
      country: 'Iceland',
      latLng: LatLng(63.797931, -18.048729),
      imageUrl: MOCK_IMAGE_4,
    ),
    LocationModel(
      name: 'Reynisfjara',
      countryCode: 'IS',
      country: 'Iceland',
      latLng: LatLng(64.045201, -16.186505),
      imageUrl: MOCK_IMAGE_3,
    ),
  ],
);

class BookmarkedLocations extends StatefulWidget {
  final BookmarkGroupModel bookmarkGroup;

  const BookmarkedLocations({
    Key key,
    this.bookmarkGroup,
  }) : super(key: key);

  @override
  _BookmarkedLocationsState createState() => _BookmarkedLocationsState();
}

class _BookmarkedLocationsState extends State<BookmarkedLocations> {
  final GlobalKey<InfiniteListState> _infiniteListKey = GlobalKey();

  List<BookmarkedLocationModel> _items = [];
  bool _isPerformingRequest = false;
  bool _isLoading = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F3F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.bookmarkGroup?.title ?? '',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 18.0,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _bookmarks(),
      ),
    );
  }

  Widget _bookmarks() {
    if (_isLoading) {
      return new Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Center(
          child: new CircularProgressIndicator(),
        ),
      );
    }

    final theme = Theme.of(context);

    return Stack(
      children: [
        InfiniteList(
          key: _infiniteListKey,
          fetchMore: _fetchMore,
          itemBuilder: (BuildContext context, int index) {
            return _bookmarkItem(_items[index], index);
          },
          itemCount: _items.length,
          padding: const EdgeInsets.only(
            top: 16.0,
            bottom: 64.0,
          ),
          rowPadding: const EdgeInsets.only(bottom: 0),
          isPerformingRequest: _isPerformingRequest,
        ),
        // Positioned(
        //   bottom: 16,
        //   left: 16,
        //   right: 16,
        //   child: RaisedButton(
        //     color: theme.primaryColor,
        //     colorBrightness: Brightness.dark,
        //     child: Text('Suggest me a trip'),
        //     onPressed: _suggestTrip,
        //   ),
        // ),
      ],
    );
  }

  Widget _bookmarkItem(BookmarkedLocationModel location, int index) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 32.0,
        vertical: 8.0,
      ),
      leading: GestureDetector(
        onTap: () => _onImageTap(location.imageUrl),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            fit: BoxFit.cover,
            image: location.imageUrl,
          ),
        ),
      ),
      title: Text(
        location.title ?? '-',
        style: TextStyle(
          fontSize: 20,
          color: Colors.black87,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        location.country ?? '-',
        style: TextStyle(
          fontSize: 18,
          color: Colors.black26,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.delete_forever,
          color: Colors.red,
        ),
        onPressed: () => _onUnbookmark(location.gemCaptureId, index),
      ),
    );
  }

  _onImageTap(String imageUrl) async {
    final navigationService = locator<NavigationService>();

    navigationService.push(
      MaterialPageRoute(
        builder: (context) => ImageView(
          image: NetworkImage(imageUrl),
        ),
      ),
    );
  }

  _onUnbookmark(String gemCaptureId, int index) async {
    final bookmarkService = locator<BookmarkService>();
    await bookmarkService.unbookmarkGemCapture(gemCaptureId);
    setState(() {
      _items.removeAt(index);
    });
  }

  _fetchInitial() async {
    setState(() {
      _isLoading = true;
    });
    List<BookmarkedLocationModel> newEntries = await fetchBookmarkedLocations(
      bookmarkGroupId: widget.bookmarkGroup.id,
    );
    _currentPage += 1;
    setState(() {
      _items = newEntries;
      _isLoading = false;
    });
  }

  Future<void> _refresh() async {
    _currentPage = 0;
    setState(() {
      _isLoading = true;
      _items = [];
    });
    List<BookmarkedLocationModel> newEntries = await fetchBookmarkedLocations(
      bookmarkGroupId: widget.bookmarkGroup.id,
    );
    _currentPage += 1;
    setState(() {
      _items = newEntries;
      _isLoading = false;
    });
  }

  _fetchMore() async {
    if (!_isPerformingRequest) {
      setState(() => _isPerformingRequest = true);
      List<BookmarkedLocationModel> newEntries = await fetchBookmarkedLocations(
        page: _currentPage,
        bookmarkGroupId: widget.bookmarkGroup.id,
      );

      if (newEntries.isEmpty) {
        _infiniteListKey.currentState.onNoNewResults();
      }

      if (newEntries.isNotEmpty) {
        _currentPage += 1;
      }

      setState(() {
        _isPerformingRequest = false;

        if (newEntries.isNotEmpty) {
          _items = List.from(_items)..addAll(newEntries);
        }
      });
    }
  }

  _suggestTrip() async {
    // final navigationService = locator<NavigationService>();
    // final journeyProvider = locator<JourneyProvider>();

    // final journey = await journeyProvider.suggestJourney(
    //   widget.bookmarkGroup.id,
    // );

    // navigationService.push(
    //   MaterialPageRoute(
    //     builder: (context) => TripOverview(
    //       journey: journey,
    //     ),
    //   ),
    // );
  }
}
