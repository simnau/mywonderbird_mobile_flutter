import 'package:flutter/material.dart';
import 'package:layout/components/custom-grid-tile.dart';
import 'package:layout/components/small-icon-button.dart';
import 'package:layout/locator.dart';
import 'package:layout/models/bookmark-group.dart';
import 'package:layout/routes/bookmarked-locations/main.dart';
import 'package:layout/services/bookmark-group.dart';
import 'package:layout/services/navigation.dart';
import 'package:transparent_image/transparent_image.dart';

class Bookmarks extends StatefulWidget {
  static const RELATIVE_PATH = 'bookmarks';
  static const PATH = "/$RELATIVE_PATH";

  @override
  _BookmarksState createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  bool _isLoading = false;
  List<BookmarkGroupModel> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBookmarkGroups());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Your bookmark groups',
          style: TextStyle(color: Colors.black54),
        ),
      ),
      body: _bookmarkGroups(),
    );
  }

  Widget _bookmarkGroups() {
    if (_isLoading) {
      return new Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Center(
          child: new CircularProgressIndicator(),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _items.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (context, index) {
        final item = _items[index];
        return _bookmarkGroup(item);
      },
    );
  }

  Widget _bookmarkGroup(BookmarkGroupModel bookmarkGroup) {
    return CustomGridTile(
      onTap: () => _onSelect(bookmarkGroup),
      header: Row(
        children: [
          if (bookmarkGroup.id != null)
            SmallIconButton(
              borderRadius: BorderRadius.circular(24.0),
              padding: const EdgeInsets.all(8.0),
              icon: Icon(
                Icons.delete_forever,
                color: Colors.redAccent,
              ),
              onTap: () => _onDelete(bookmarkGroup),
            ),
        ],
      ),
      child: Container(
        color: Colors.black54,
        child: bookmarkGroup.imageUrl != null
            ? FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: bookmarkGroup.imageUrl,
                fit: BoxFit.cover,
              )
            : null,
      ),
      trailing: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                bookmarkGroup.title ?? '-',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              "${bookmarkGroup.bookmarkCount ?? 0}",
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _loadBookmarkGroups() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final bookmarkGroupService = locator<BookmarkGroupService>();
      final bookmarkGroups = await bookmarkGroupService.fetchBookmarkGroups();

      setState(() {
        _isLoading = false;
        _items = bookmarkGroups;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _onSelect(BookmarkGroupModel bookmarkGroup) {
    final navigationService = locator<NavigationService>();
    navigationService.push(
      MaterialPageRoute(
        builder: (context) => BookmarkedLocations(
          bookmarkGroup: bookmarkGroup,
        ),
      ),
    );
  }

  _onDelete(BookmarkGroupModel bookmarkGroup) async {
    final bookmarkGroupService = locator<BookmarkGroupService>();
    await bookmarkGroupService.delete(bookmarkGroup.id);
    setState(() {
      _items.remove(bookmarkGroup);
    });
  }
}
