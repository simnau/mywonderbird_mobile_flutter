import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mywonderbird/components/empty-list-placeholder.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/picture-sharing/components/picture-selection.dart';
import 'package:mywonderbird/routes/picture-sharing/pages/share-pictures-standalone/main.dart';
import 'package:mywonderbird/routes/picture-sharing/pages/share-pictures-trip/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/picture-data.dart';
import 'package:photo_manager/photo_manager.dart';

class SelectPicture extends StatefulWidget {
  final bool isStandalone;

  const SelectPicture({
    Key key,
    @required this.isStandalone,
  }) : super(key: key);

  @override
  _SelectPictureState createState() => _SelectPictureState();
}

class _SelectPictureState extends State<SelectPicture>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = new ScrollController();
  List<AssetEntity> _photoList = [];
  List<Widget> _photoWidgetList = [];
  int _currentPage = 0;
  int _lastPage;
  List<AssetEntity> _selectedPhotos = [];
  bool _hasPermission = true;
  bool _isLoading = true;
  bool _isPaused = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        // Whether the app was put into background and then reopened
        if (_isPaused) {
          await _fetchPhotos();
        }
        _isPaused = false;
        break;
      case AppLifecycleState.paused:
        _isPaused = true;
        break;
      default:
        _isPaused = false;
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPhotos();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_currentPage != _lastPage) {
          _fetchPhotos();
        }
      }
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  _fetchPhotos() async {
    _lastPage = _currentPage;
    final hasPermission = await PhotoManager.requestPermission();

    if (hasPermission) {
      setState(() {
        _isLoading = true;
        _hasPermission = true;
      });

      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: RequestType.image,
      );

      if (albums.isEmpty) {
        setState(() {
          _isLoading = false;
        });
      } else {
        List<AssetEntity> photos =
            await albums[0].getAssetListPaged(_currentPage, 20);

        List<Widget> photoWidgets = photos.map<Widget>(_picture).toList();

        _photoList = _photoList..addAll(photos);

        setState(() {
          _photoWidgetList = _photoWidgetList..addAll(photoWidgets);
          _currentPage += 1;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _hasPermission = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _selectedPhotos.isNotEmpty ? _onNext : null,
            child: Text(
              'NEXT',
              style: TextStyle(
                color: _selectedPhotos.isNotEmpty
                    ? theme.primaryColor
                    : theme.disabledColor,
              ),
            ),
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    final theme = Theme.of(context);
    final subtitle = Platform.isAndroid
        ? 'Please give the permission to access the device\'s storage to share photos'
        : 'Please give the permission to access the device\'s photos to share them';

    if (!_hasPermission) {
      return EmptyListPlaceholder(
        title: 'No permission',
        subtitle: subtitle,
        action: OutlinedButton.icon(
          onPressed: _requestPermission,
          icon: Icon(
            Icons.lock_open,
            color: theme.accentColor,
          ),
          label: BodyText1('Allow access'),
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(
              theme.accentColor.withOpacity(0.2),
            ),
            side: MaterialStateProperty.all(
              BorderSide(color: theme.accentColor),
            ),
          ),
        ),
      );
    }

    if (_isLoading && _currentPage == 0) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_isLoading && _currentPage == 0 && _photoWidgetList.isEmpty) {
      return EmptyListPlaceholder(
        title: 'No photos on the device',
        subtitle:
            'No photos found on your device. Take some pictures to share them.',
      );
    }

    return _pictures();
  }

  Widget _pictures() {
    return Container(
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 96),
        controller: _scrollController,
        itemCount: _photoList.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (BuildContext context, int index) {
          final photo = _photoList[index];
          final isSelected = _selectedPhotos.contains(photo);

          return PictureSelection(
            selectPhoto: _selectPhoto,
            photo: photo,
            child: _photoWidgetList[index],
            isSelected: isSelected,
          );
        },
      ),
    );
  }

  Widget _picture(AssetEntity photo) {
    return FutureBuilder(
      future: photo.thumbDataWithSize(200, 200),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Image.memory(
            snapshot.data,
            fit: BoxFit.cover,
          );
        }
        return Container();
      },
    );
  }

  _requestPermission() async {
    final result = await PhotoManager.requestPermission();

    if (!result) {
      PhotoManager.openSetting();
    } else {
      _fetchPhotos();
    }
  }

  _selectPhoto(AssetEntity photo) {
    if (_selectedPhotos.contains(photo)) {
      setState(() {
        _selectedPhotos.remove(photo);
      });
    } else {
      setState(() {
        _selectedPhotos.add(photo);
      });
    }
  }

  _onNext() async {
    if (_selectedPhotos.isNotEmpty) {
      final navigationService = locator<NavigationService>();
      final pictureDataService = locator<PictureDataService>();

      final filePaths = await Future.wait(
        _selectedPhotos
            .map((selectedPhoto) async => (await selectedPhoto.file).path),
      );
      final pictureDatas = await pictureDataService.extractPicturesData(
          filePaths, widget.isStandalone);

      navigationService.push(
        MaterialPageRoute(
          builder: (_) => widget.isStandalone
              ? SharePicturesStandalone(pictureDatas: pictureDatas)
              : SharePicturesTrip(pictureDatas: pictureDatas),
        ),
      );
    }
  }
}
