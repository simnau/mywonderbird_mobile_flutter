import 'package:flutter/material.dart';
import 'package:mywonderbird/components/bottom-nav-bar.dart';
import 'package:mywonderbird/components/feed-item.dart';
import 'package:mywonderbird/components/infinite-list.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/feed-location.dart';
import 'package:mywonderbird/routes/image-view/main.dart';
import 'package:mywonderbird/routes/select-bookmark-group/main.dart';
import 'package:mywonderbird/routes/select-picture/main.dart';
import 'package:mywonderbird/routes/trip-overview/main.dart';
import 'package:mywonderbird/services/bookmark.dart';
import 'package:mywonderbird/services/feed.dart';
import 'package:mywonderbird/services/journeys.dart';
import 'package:mywonderbird/services/like.dart';
import 'package:mywonderbird/services/navigation.dart';

Future<List<FeedLocation>> fetchFeedItems({DateTime lastDatetime}) async {
  final feedService = locator<FeedService>();

  return feedService.fetchFeedItems(lastDatetime);
}

class HomePage extends StatefulWidget {
  static const RELATIVE_PATH = 'home';
  static const PATH = "/$RELATIVE_PATH";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<InfiniteListState> _infiniteListKey = GlobalKey();

  List<FeedLocation> _items = [];
  bool _isPerformingRequest = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: Color(0xFFF2F3F7),
      appBar: AppBar(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(4.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.accentColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'images/logo@025x.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        title: Text(
          'MyWonderbird',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 18.0,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.tune,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.search,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _feed(),
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.all(2.0),
        child: FloatingActionButton(
          child: Icon(
            Icons.add,
            size: 36,
          ),
          onPressed: _onAddPicture,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavBar(
        onHome: _refresh,
      ),
    );
  }

  Widget _feed() {
    if (_isLoading) {
      return new Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return InfiniteList(
      key: _infiniteListKey,
      fetchMore: _fetchMore,
      itemBuilder: (BuildContext context, int index) {
        return _feedItem(_items[index]);
      },
      itemCount: _items.length,
      padding: const EdgeInsets.only(
        top: 16.0,
        bottom: 64.0,
      ),
      rowPadding: const EdgeInsets.only(bottom: 24.0),
      isPerformingRequest: _isPerformingRequest,
    );
  }

  Widget _feedItem(FeedLocation item) {
    return FeedItem(
      key: Key(item.id),
      imageUrl: item.imageUrl,
      title: item.title,
      country: item.country,
      likeCount: item.likeCount,
      isLiked: item.isLiked,
      isBookmarked: item.isBookmarked,
      onLike: () => item.isLiked ? _onUnlike(item) : _onLike(item),
      onBookmark: () =>
          item.isBookmarked ? _onUnbookmark(item) : _onBookmark(item),
      onTap: () => _onFeedItemTap(item),
      onViewJourney: () => _onViewJourney(item),
    );
  }

  _fetchInitial() async {
    setState(() {
      _isLoading = true;
    });
    List<FeedLocation> newEntries = await fetchFeedItems();
    setState(() {
      _items = newEntries;
      _isLoading = false;
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _items = [];
    });
    List<FeedLocation> newEntries = await fetchFeedItems();
    setState(() {
      _items = newEntries;
      _isLoading = false;
    });
  }

  _fetchMore() async {
    if (!_isPerformingRequest) {
      setState(() => _isPerformingRequest = true);
      List<FeedLocation> newEntries = await fetchFeedItems(
        lastDatetime: _items.last != null ? _items.last.updatedAt : null,
      );

      if (newEntries.isEmpty) {
        _infiniteListKey.currentState.onNoNewResults();
      }

      setState(() {
        _isPerformingRequest = false;

        if (newEntries.isNotEmpty) {
          _items = List.from(_items)..addAll(newEntries);
        }
      });
    }
  }

  _onFeedItemTap(FeedLocation item) async {
    final navigationService = locator<NavigationService>();

    navigationService.push(
      MaterialPageRoute(
        builder: (context) => ImageView(
          image: NetworkImage(item.imageUrl),
        ),
      ),
    );
  }

  _onLike(FeedLocation item) async {
    final likeService = locator<LikeService>();

    try {
      setState(() {
        item.isLiked = true;
        item.likeCount += 1;
      });

      await likeService.likeGemCapture(item.id);
    } catch (e) {
      setState(() {
        item.isLiked = false;
        item.likeCount -= 1;
      });
    }
  }

  _onUnlike(FeedLocation item) async {
    final likeService = locator<LikeService>();

    try {
      setState(() {
        item.isLiked = false;
        item.likeCount -= 1;
      });

      await likeService.unlikeGemCapture(item.id);
    } catch (e) {
      setState(() {
        item.isLiked = true;
        item.likeCount += 1;
      });
    }
  }

  _onBookmark(FeedLocation item) async {
    final navigationService = locator<NavigationService>();
    final bookmarkGroup = await navigationService.push(
      MaterialPageRoute(
        builder: (context) => SelectBookmarkGroup(),
      ),
    );

    if (bookmarkGroup == null) {
      return;
    }

    final bookmarkService = locator<BookmarkService>();

    try {
      setState(() {
        item.isBookmarked = true;
      });

      await bookmarkService.bookmarkGemCapture(item.id, bookmarkGroup.id);
    } catch (e) {
      setState(() {
        item.isBookmarked = false;
      });
    }
  }

  _onUnbookmark(FeedLocation item) async {
    final bookmarkService = locator<BookmarkService>();

    try {
      setState(() {
        item.isBookmarked = false;
      });

      await bookmarkService.unbookmarkGemCapture(item.id);
    } catch (e) {
      setState(() {
        item.isBookmarked = true;
      });
    }
  }

  _onViewJourney(FeedLocation item) async {
    final journeyService = locator<JourneyService>();
    final journey = await journeyService.getJourney(item.journeyId);

    locator<NavigationService>().push(
      MaterialPageRoute(
        builder: (context) => TripOverview(
          journey: journey,
        ),
      ),
    );
  }

  _onAddPicture() {
    locator<NavigationService>().pushNamed(SelectPicture.PATH);
  }
}
