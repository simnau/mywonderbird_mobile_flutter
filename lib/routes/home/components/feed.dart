import 'package:flutter/material.dart';
import 'package:mywonderbird/components/feed-item.dart';
import 'package:mywonderbird/components/infinite-list.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/feed-location.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:mywonderbird/routes/details/pages/user-location-details.dart';
import 'package:mywonderbird/routes/image-view/main.dart';
import 'package:mywonderbird/routes/profile/current-user/main.dart';
import 'package:mywonderbird/routes/profile/other-user/main.dart';
import 'package:mywonderbird/routes/select-bookmark-group/main.dart';
import 'package:mywonderbird/routes/trip-overview/shared-trip.dart';
import 'package:mywonderbird/services/bookmark.dart';
import 'package:mywonderbird/services/feed.dart';
import 'package:mywonderbird/services/like.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/util/sentry.dart';
import 'package:provider/provider.dart';

Future<List<FeedLocation>> fetchFeedItems({DateTime lastDatetime}) async {
  final feedService = locator<FeedService>();

  return feedService.fetchFeedItems(lastDatetime);
}

class Feed extends StatefulWidget {
  final FeedController controller;

  const Feed({
    Key key,
    this.controller,
  }) : super(key: key);

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  final GlobalKey<InfiniteListState> _infiniteListKey = GlobalKey();

  List<FeedLocation> _items = [];
  bool _isPerformingRequest = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_controllerChange);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchInitial();
    });
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_controllerChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: _body(),
    );
  }

  Widget _body() {
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
    final user = Provider.of<User>(context);

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
      onView: () => _onView(item),
      onViewUser: () => _onViewUser(item, context, user),
      userAvatarUrl: item.userAvatarUrl,
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
    } catch (error, stackTrace) {
      await reportError(error, stackTrace);
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
    } catch (error, stackTrace) {
      await reportError(error, stackTrace);
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
    } catch (error, stackTrace) {
      await reportError(error, stackTrace);
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
    } catch (error, stackTrace) {
      await reportError(error, stackTrace);
      setState(() {
        item.isBookmarked = true;
      });
    }
  }

  _onView(FeedLocation item) async {
    final navigationService = locator<NavigationService>();
    if (item.journeyId == null) {
      navigationService.push(
        MaterialPageRoute(
          builder: (context) => UserLocationDetails(
            locationId: item.locationId,
            userAvatar: item.userAvatarUrl,
            userName: item.userName,
            userBio: item.userBio,
            userId: item.userId,
          ),
        ),
      );
    } else {
      navigationService.push(
        MaterialPageRoute(
          builder: (context) => SharedTripOverviewGeneric(
            id: item.journeyId,
          ),
        ),
      );
    }
  }

  _controllerChange() {
    _refresh();
  }
}

_onViewUser(FeedLocation item, BuildContext context, User user) async {
  final navigationService = locator<NavigationService>();

  if (item.userId == user.id) {
    navigationService.push(MaterialPageRoute(
      builder: (_) => Profile(),
    ));
  } else {
    navigationService.push(MaterialPageRoute(
      builder: (_) => OtherUser(id: item.userId),
    ));
  }
}

class FeedController with ChangeNotifier {
  bool shouldRefresh = false;

  refresh() {
    shouldRefresh = true;
    notifyListeners();
  }
}
