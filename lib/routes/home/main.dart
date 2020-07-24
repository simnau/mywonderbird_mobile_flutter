import 'package:flutter/material.dart';
import 'package:layout/components/bottom-nav-bar.dart';
import 'package:layout/components/feed-item.dart';
import 'package:layout/locator.dart';
import 'package:layout/models/feed-location.dart';
import 'package:layout/routes/select-picture/home.dart';
import 'package:layout/services/feed.dart';
import 'package:layout/services/navigation.dart';

Future<List<FeedLocation>> fetchFeedItems({DateTime lastDatetime}) async {
  final feedService = locator<FeedService>();

  return feedService.fetchFeedItems(lastDatetime);
}

const LIMIT = 10;

class HomePage extends StatefulWidget {
  static const PATH = '/';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<FeedLocation> _items = [];
  ScrollController _scrollController = new ScrollController();
  bool _isPerformingRequest = false;
  bool _isLoading = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchInitial(LIMIT);
      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          _fetchPage(LIMIT);
        }
      });
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

    return ListView.separated(
      padding: const EdgeInsets.only(
        top: 16.0,
        bottom: 64.0,
      ),
      itemCount: _items.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == _items.length) {
          return _progressIndicator();
        } else {
          return _feedItem(_items[index]);
        }
      },
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
      ),
      controller: _scrollController,
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

  Widget _progressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: _isPerformingRequest ? 1.0 : 0.0,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  // Extract the logic into a component
  _fetchInitial(int limit) async {
    setState(() {
      _isLoading = true;
    });
    List<FeedLocation> newEntries = await fetchFeedItems();
    setState(() {
      _items = newEntries;
      _isLoading = false;
    });
  }

  _fetchPage(int limit) async {
    if (!_isPerformingRequest) {
      setState(() => _isPerformingRequest = true);
      List<FeedLocation> newEntries = await fetchFeedItems(
        lastDatetime: _items.last != null ? _items.last.updatedAt : null,
      );
      if (newEntries.isEmpty) {
        double edge = 50.0;
        double offsetFromBottom = _scrollController.position.maxScrollExtent -
            _scrollController.position.pixels;
        if (offsetFromBottom < edge) {
          _scrollController.animateTo(
              _scrollController.offset - (edge - offsetFromBottom),
              duration: new Duration(milliseconds: 500),
              curve: Curves.easeOut);
        }
      }
      setState(() {
        _isPerformingRequest = false;

        if (newEntries.isNotEmpty) {
          _items = List.from(_items)..addAll(newEntries);
          _currentPage = _currentPage + 1;
        }
      });
    }
  }

  _onLike(FeedLocation item) {
    setState(() {
      item.isLiked = true;
      item.likeCount += 1;
    });
  }

  _onUnlike(FeedLocation item) {
    setState(() {
      item.isLiked = false;
      item.likeCount -= 1;
    });
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
