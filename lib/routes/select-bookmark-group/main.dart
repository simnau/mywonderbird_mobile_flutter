import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:layout/locator.dart';
import 'package:layout/models/bookmark-group.dart';
import 'package:layout/routes/select-bookmark-group/components/create-bookmark-group-dialog.dart';
import 'package:layout/services/bookmark-group.dart';
import 'package:layout/services/navigation.dart';
import 'package:transparent_image/transparent_image.dart';

class SelectBookmarkGroup extends StatefulWidget {
  @override
  _SelectBookmarkGroupState createState() => _SelectBookmarkGroupState();
}

class _SelectBookmarkGroupState extends State<SelectBookmarkGroup> {
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
        backgroundColor: Colors.white,
        title: Text(
          'Select a bookmark group',
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
      itemCount: _items.length + 1,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _createBookmarkGroupButton();
        }

        final item = _items[index - 1];
        return _bookmarkGroup(item);
      },
    );
  }

  Widget _createBookmarkGroupButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(16.0),
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Colors.grey[100],
              child: Icon(
                Icons.add_circle,
                size: 48,
                color: Colors.black26,
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _onOpenCreateBookmarkGroup,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookmarkGroup(BookmarkGroupModel bookmarkGroup) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(16.0),
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
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
                ),
                Padding(
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
              ],
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onSelect(bookmarkGroup),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _loadBookmarkGroups() async {
    try {
      final bookmarkGroupService = locator<BookmarkGroupService>();
      final bookmarkGroups = await bookmarkGroupService.fetchBookmarkGroups();

      setState(() {
        _isLoading = false;
        _items = bookmarkGroups;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  _onOpenCreateBookmarkGroup() {
    showDialog(
      context: context,
      child: Dialog(
        child: CreateBookmarkGroupDialog(
          onCreate: _onCreateBookmarkGroup,
        ),
      ),
      barrierDismissible: true,
    );
  }

  _onCreateBookmarkGroup(String title) async {
    if (title.isEmpty) {
      return;
    }

    try {
      final bookmarkGroupService = locator<BookmarkGroupService>();
      final bookmarkGroup =
          await bookmarkGroupService.createBookmarkGroup(title);

      setState(() {
        _items.insert(0, bookmarkGroup);
      });
    } catch (e) {}
  }

  _onSelect(BookmarkGroupModel bookmarkGroup) {
    final navigationService = locator<NavigationService>();
    navigationService.pop(bookmarkGroup);
  }
}
