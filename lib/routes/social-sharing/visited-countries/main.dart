import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/social-sharing/visited-countries/components/share-provider-button.dart';
import 'package:mywonderbird/routes/social-sharing/visited-countries/components/visited-country-map.dart';
import 'package:mywonderbird/services/stats.dart';
import 'package:mywonderbird/util/snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_share/social_share.dart';

enum ShareTimeframe {
  ALL_TIME,
  THIS_YEAR,
  THIS_MONTH,
}

const TIMEFRAME_LABELS = {
  ShareTimeframe.ALL_TIME: 'All time',
  ShareTimeframe.THIS_YEAR: 'This year',
  ShareTimeframe.THIS_MONTH: 'This month',
};

const INSTAGRAM_GRADIENT_COLORS = [
  Colors.purple,
  Colors.pink,
  Colors.orange,
];

class VisitedCountriesSharing extends StatefulWidget {
  const VisitedCountriesSharing({
    Key key,
  }) : super(key: key);

  @override
  _VisitedCountriesSharingState createState() =>
      _VisitedCountriesSharingState();
}

class _VisitedCountriesSharingState extends State<VisitedCountriesSharing> {
  final GlobalKey _visitedCountryMapKey =
      GlobalKey(debugLabel: "visitedCountryMapKey");

  bool _isLoading = true;
  List<String> _visitedCountries = [];
  Map<dynamic, dynamic> _installedApps = {};

  ShareTimeframe timeframe = ShareTimeframe.ALL_TIME;

  String get timeframeLabel => TIMEFRAME_LABELS[timeframe];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _fetchVisitedCountries(timeframe);
      final installedApps = await SocialShare.checkInstalledAppsForShare();

      setState(() {
        _installedApps = installedApps;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: H6(
          'Share map',
          color: Colors.black87,
        ),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _choosePeriodWidget(),
          SizedBox(height: spacingFactor(2)),
          _visitedCountryMap(),
          SizedBox(height: spacingFactor(1)),
          _sharingOptions(),
        ],
      ),
    );
  }

  Widget _choosePeriodWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacingFactor(3),
      ),
      child: DropdownButtonFormField(
        isDense: true,
        isExpanded: true,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: spacingFactor(2),
          ),
          prefixText: "Choose period: ",
          border: OutlineInputBorder(),
        ),
        value: timeframe,
        onChanged: _onChooseTimeframe,
        items: ShareTimeframe.values.map((value) {
          return DropdownMenuItem(
            child: Subtitle2(
              TIMEFRAME_LABELS[value],
              color: Colors.black87,
            ),
            value: value,
          );
        }).toList(),
      ),
    );
  }

  Widget _visitedCountryMap() {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.accentColor,
          width: 5,
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: spacingFactor(3)),
      child: RepaintBoundary(
        key: _visitedCountryMapKey,
        child: Container(
          color: Colors.white,
          child: VisitedCountryMap(
            visitedCountries: _visitedCountries,
            size: size.width - spacingFactor(3) * 2,
            timeframeLabel: timeframeLabel.toLowerCase(),
          ),
        ),
      ),
    );
  }

  Widget _sharingOptions() {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: CustomPaint(
            painter: DrawTriangleShape(
              color: theme.primaryColorLight,
            ),
            size: Size(20, 20),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.primaryColorLight,
                theme.primaryColorLight.withOpacity(0),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacingFactor(3),
              vertical: spacingFactor(2),
            ),
            child: Column(
              children: [
                H6(
                  'Share with the world',
                  color: Colors.black87,
                ),
                SizedBox(height: spacingFactor(2)),
                Wrap(
                  runSpacing: spacingFactor(2),
                  spacing: spacingFactor(2),
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    if (_installedApps['facebook'])
                      ShareProviderButton(
                        icon: MaterialCommunityIcons.facebook,
                        onPressed: _shareToFacebook,
                        label: 'FACEBOOK',
                        backgroundColor: Color(0xFF4267B2),
                      ),
                    if (_installedApps['instagram'])
                      ShareProviderButton(
                        icon: MaterialCommunityIcons.instagram,
                        onPressed: _shareToInstagram,
                        label: 'INSTAGRAM',
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: INSTAGRAM_GRADIENT_COLORS,
                        ),
                      ),
                    ShareProviderButton(
                      icon: MaterialCommunityIcons.download,
                      onPressed: _download,
                      label: 'DOWNLOAD',
                      backgroundColor: theme.accentColor,
                    ),
                    ShareProviderButton(
                      icon: Icons.more_horiz,
                      onPressed: _shareMore,
                      label: 'MORE',
                      backgroundColor: Colors.grey.shade400,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _onChooseTimeframe(ShareTimeframe newTimeframe) {
    setState(() {
      timeframe = newTimeframe;
      _fetchVisitedCountries(newTimeframe);
    });
  }

  _fetchVisitedCountries(ShareTimeframe newTimeframe) async {
    final statsService = locator<StatsService>();

    setState(() {
      _isLoading = true;
    });

    try {
      final visitedCountryCodes = await statsService.fetchVisitedCountryCodes(
        startDate: _getStartDate(newTimeframe),
        endDate: _getEndDate(newTimeframe),
      );

      setState(() {
        _isLoading = false;
        _visitedCountries = visitedCountryCodes;
      });
    } catch (e) {
      final snackBar = createErrorSnackbar(
        text: 'An unexpected error has occurred. Please try again later.',
      );
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  DateTime _getStartDate(ShareTimeframe newTimeframe) {
    switch (newTimeframe) {
      case ShareTimeframe.ALL_TIME:
        return null;
      case ShareTimeframe.THIS_YEAR:
        {
          final now = DateTime.now();

          return DateTime.utc(now.year);
        }
      case ShareTimeframe.THIS_MONTH:
        {
          final now = DateTime.now();

          return DateTime.utc(now.year, now.month);
        }
      default:
        return null;
    }
  }

  DateTime _getEndDate(ShareTimeframe newTimeframe) {
    switch (newTimeframe) {
      case ShareTimeframe.ALL_TIME:
        return null;
      default:
        return DateTime.now();
    }
  }

  _shareToInstagram() async {
    final file = await _createSharedImageFromWidget();
    await SocialShare.shareInstagramStory(file.path);
    await file.delete();
  }

  _shareToFacebook() async {
    final file = await _createSharedImageFromWidget();
    await SocialShare.shareFacebookStory(
      file.path,
      Colors.white.toString(),
      Colors.white.toString(),
      "https://mywonderbird.com",
    );
    await file.delete();
  }

  _download() async {
    final currentDate = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]);
    final imageBytes = await _createSharedImageBytesFromWidget();

    await ImageGallerySaver.saveImage(
      imageBytes,
      quality: 80,
      name: "MyWonderbirdVisitedCountries-$currentDate.png",
    );

    final snackBar = createSuccessSnackbar(
      text: 'The image has been saved to your device.',
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _shareMore() async {
    final file = await _createSharedImageFromWidget();
    await SocialShare.shareOptions(
      "My visited countries",
      imagePath: file.path,
    );
    await file.delete();
  }

  Future<File> _createSharedImageFromWidget() async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    final imageBytes = await _createSharedImageBytesFromWidget();

    File imageFile = File("$directory/photo.png");
    await imageFile.writeAsBytes(imageBytes);

    return imageFile;
  }

  Future<Uint8List> _createSharedImageBytesFromWidget() async {
    RenderRepaintBoundary boundary =
        _visitedCountryMapKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);

    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();

    return pngBytes;
  }
}

class DrawTriangleShape extends CustomPainter {
  Paint painter;

  DrawTriangleShape({
    Color color = Colors.black,
    PaintingStyle style = PaintingStyle.fill,
  }) {
    painter = Paint()
      ..color = color
      ..style = style;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();

    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.height, size.width);
    path.close();

    canvas.drawPath(path, painter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
