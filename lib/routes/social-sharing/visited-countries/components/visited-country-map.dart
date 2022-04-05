import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class VisitedCountryMap extends StatefulWidget {
  final String timeframeLabel;
  final List<String> visitedCountries;
  final double size;
  final Color backgroundColor;

  const VisitedCountryMap({
    Key key,
    @required this.visitedCountries,
    @required this.timeframeLabel,
    this.backgroundColor,
    double size,
    double titleSize,
    double countSize,
  })  : size = size ?? 1024,
        super(key: key);

  @override
  State<VisitedCountryMap> createState() => _VisitedCountryMapState();
}

class _VisitedCountryMapState extends State<VisitedCountryMap> {
  MapShapeSource _mapShapeSource;

  @override
  void initState() {
    super.initState();

    setState(() {
      _mapShapeSource = MapShapeSource.asset(
        'images/vector-maps/world-map.json',
        shapeDataField: 'ISO_A3',
        dataCount: widget.visitedCountries.length,
        primaryValueMapper: widget.visitedCountries.isNotEmpty
            ? (index) => widget.visitedCountries[index]
            : null,
        shapeColorValueMapper: (index) {
          final theme = Theme.of(context);

          return theme.accentColor;
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: Container(
        height: widget.size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.5, 1],
            colors: [
              Color(0xFF3098FE),
              Color(0xAA3098FE),
              Color(0x003098FE),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                padding: EdgeInsets.all(spacingFactor(1)),
                child: SfMaps(
                  layers: <MapShapeLayer>[
                    MapShapeLayer(
                      source: _mapShapeSource,
                      color: Colors.white,
                      loadingBuilder: (_) => Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: _logo(),
            ),
            Positioned(
              bottom: spacingFactor(1),
              left: spacingFactor(1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "My visited countries ${widget.timeframeLabel}",
                    style: TextStyle(
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: spacingFactor(1)),
                  Text(
                    widget.visitedCountries.length.toString(),
                    style: TextStyle(
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.all(spacingFactor(0.5)),
      child: Subtitle2.light(
        "MyWonderbird",
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
