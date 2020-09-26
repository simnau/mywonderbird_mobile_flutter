import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mywonderbird/components/custom-grid-tile.dart';
import 'package:mywonderbird/components/small-icon-button.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/bookmark-group.dart';
import 'package:mywonderbird/routes/select-bookmark-group/components/create-bookmark-group-dialog.dart';
import 'package:mywonderbird/services/bookmark-group.dart';
import 'package:mywonderbird/services/navigation.dart';
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
        backgroundColor: Colors.transparent,
        title: Text(
          'Select a bookmark group',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 18.0,
          ),
        ),
      ),
      body: _bookmarkGroups(),
    );
  }

  Widget _bookmarkGroups() {
    if (_isLoading) {
      return new Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: CircularProgressIndicator(),
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
    return CustomGridTile(
      child: Container(
        color: Colors.grey[100],
        child: Icon(
          Icons.add_circle,
          size: 48,
          color: Colors.black26,
        ),
      ),
      onTap: _onOpenCreateBookmarkGroup,
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
        _items.insert(1, bookmarkGroup);
      });
    } catch (e) {}
  }

  _onSelect(BookmarkGroupModel bookmarkGroup) {
    final navigationService = locator<NavigationService>();
    navigationService.pop(bookmarkGroup);
  }

  _onDelete(BookmarkGroupModel bookmarkGroup) async {
    final bookmarkGroupService = locator<BookmarkGroupService>();
    await bookmarkGroupService.delete(bookmarkGroup.id);
    setState(() {
      _items.remove(bookmarkGroup);
    });
  }
}
