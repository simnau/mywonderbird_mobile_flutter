import 'package:flutter/material.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/providers/share-picture.dart';
import 'package:mywonderbird/routes/select-destination/main.dart';
import 'package:mywonderbird/routes/share-picture/mock.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/picture-data.dart';
import 'package:mywonderbird/types/picture-data.dart';
import 'package:photo_manager/photo_manager.dart';

class SelectPicture extends StatefulWidget {
  static const RELATIVE_PATH = 'select-picture';
  static const PATH = "/$RELATIVE_PATH";

  @override
  _SelectPictureState createState() => _SelectPictureState();
}

class _SelectPictureState extends State<SelectPicture> {
  final ScrollController _scrollController = new ScrollController();
  List<AssetEntity> _photoList = [];
  List<Widget> _photoWidgetList = [];
  int _currentPage = 0;
  int _lastPage;
  AssetEntity _selectedPhoto;

  @override
  void initState() {
    super.initState();
    _fetchPhotos();

    final sharePictureProvider = locator<SharePictureProvider>();

    sharePictureProvider.pictureData = PictureData(
      image: NetworkImage(MOCK_IMAGE),
      imagePath: '',
      location: MOCK_LOCATION,
      creationDate: DateTime.now(),
    );

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_currentPage != _lastPage) {
          _fetchPhotos();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  _fetchPhotos() async {
    _lastPage = _currentPage;
    final result = await PhotoManager.requestPermission();

    if (result) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: RequestType.image,
      );
      List<AssetEntity> photos =
          await albums[0].getAssetListPaged(_currentPage, 20);

      List<Widget> photoWidgets = photos.map<Widget>(_picture).toList();

      _photoList = _photoList..addAll(photos);
      setState(() {
        _photoWidgetList = _photoWidgetList..addAll(photoWidgets);
        _currentPage += 1;
      });
    } else {
      // failure
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            _pictures(),
            Positioned(
              bottom: 32,
              left: 32,
              right: 32,
              child: RaisedButton(
                color: theme.primaryColor,
                disabledColor: Colors.grey,
                textColor: Colors.white,
                child: Text('Next'),
                onPressed: _selectedPhoto != null ? _onNext : null,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _pictures() {
    final theme = Theme.of(context);

    return Container(
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 96),
        controller: _scrollController,
        itemCount: _photoList.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (BuildContext context, int index) {
          final photo = _photoList[index];
          final isSelected = photo == _selectedPhoto;

          return GestureDetector(
            onTap: () => _selectPhoto(photo),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                _photoWidgetList[index],
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? theme.accentColor : Colors.black,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                ),
              ],
            ),
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

  _selectPhoto(AssetEntity photo) {
    if (photo == _selectedPhoto) {
      setState(() {
        _selectedPhoto = null;
      });
    } else {
      setState(() {
        _selectedPhoto = photo;
      });
    }
  }

  _onNext() async {
    if (_selectedPhoto != null) {
      final navigationService = locator<NavigationService>();
      final pictureDataService = locator<PictureDataService>();
      final sharePictureProvider = locator<SharePictureProvider>();

      final selectedFile = await _selectedPhoto.file;
      final pictureData =
          await pictureDataService.extractPictureData(selectedFile.path);

      sharePictureProvider.pictureData = pictureData;
      navigationService.pushNamed(SelectDestination.PATH);
    }
  }
}
