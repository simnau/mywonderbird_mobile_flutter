import 'package:flutter/material.dart';
import 'package:layout/components/bottom-nav-bar.dart';
import 'package:layout/components/feed-item.dart';
import 'package:layout/components/infinite-list.dart';
import 'package:layout/locator.dart';
import 'package:layout/models/feed-location.dart';
import 'package:layout/routes/select-picture/home.dart';
import 'package:layout/services/feed.dart';
import 'package:layout/services/like.dart';
import 'package:layout/services/navigation.dart';

Future<List<FeedLocation>> fetchFeedItems({DateTime lastDatetime}) async {
  final feedService = locator<FeedService>();

  return feedService.fetchFeedItems(lastDatetime);
}

class HomePage extends StatefulWidget {
  static const PATH = '/';

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
    return Scaffold(
      backgroundColor: Color(0xFFF2F3F7),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: AppBar(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
          leading: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'images/logo@025x.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          title: Text(
            'MyWonderbird',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 21.0,
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
      ),
      body: _feed(),
      floatingActionButton: Container(
        width: 72,
        height: 72,
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
      bottomNavigationBar: BottomNavBar(),
    );
  }

  Widget _feed() {
    if (_isLoading) {
      return new Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Center(
          child: new CircularProgressIndicator(),
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
      image: NetworkImage(item.imageUrl),
      title: item.title,
      country: item.country,
      likeCount: item.likeCount,
      isLiked: item.isLiked,
      isBookmarked: item.isBookmarked,
      onLike: () => item.isLiked ? _onUnlike(item) : _onLike(item),
      onBookmark: () =>
          item.isBookmarked ? _onUnbookmark(item) : _onBookmark(item),
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

  _onBookmark(FeedLocation item) {
    setState(() {
      item.isBookmarked = true;
    });
  }

  _onUnbookmark(FeedLocation item) {
    setState(() {
      item.isBookmarked = false;
    });
  }

  _onAddPicture() {
    locator<NavigationService>().pushNamed(SelectPictureHome.PATH);
  }
}
