import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/badge.dart';

class BadgeConfig {
  final String backgroundAsset;
  final Color color;
  final Color textColor;

  const BadgeConfig({
    @required this.backgroundAsset,
    @required this.color,
    @required this.textColor,
  });
}

const BADGE_CONFIG_BY_LEVEL = {
  1: BadgeConfig(
    backgroundAsset: "images/badges/levels/paper-texture.jpg",
    color: Color(0xFFF5E1C5),
    textColor: Colors.white,
  ),
  2: BadgeConfig(
    backgroundAsset: "images/badges/levels/wood-texture.jpg",
    color: Color(0xFFECD4BC),
    textColor: Colors.white,
  ),
  3: BadgeConfig(
    backgroundAsset: "images/badges/levels/cast-iron-texture.jpg",
    color: Color(0xFFEEEEED),
    textColor: Colors.white,
  ),
  4: BadgeConfig(
    backgroundAsset: "images/badges/levels/metal-texture.jpg",
    color: Color(0xFFCD7F32),
    textColor: Colors.white,
  ),
  5: BadgeConfig(
    backgroundAsset: "images/badges/levels/metal-texture.jpg",
    color: Color(0xFFF0F0F0),
    textColor: Colors.white,
  ),
  6: BadgeConfig(
    backgroundAsset: "images/badges/levels/metal-texture.jpg",
    color: Color(0xFFFFD700),
    textColor: Colors.white,
  ),
};

class BadgeIconConfig {
  final String image;
  final String bg;

  const BadgeIconConfig({
    @required this.image,
    @required this.bg,
  });
}

BadgeIconConfig createConfigFromType(String type) {
  return BadgeIconConfig(
    image: "images/badges/$type/image.png",
    bg: "images/badges/$type/bg.png",
  );
}

final badgeIconConfigsByTypes = {
  'content-creator': createConfigFromType("content-creator"),
};

BadgeConfig getBadgeConfig(Badge badge) {
  if (badge.level == 0) {
    return null;
  }

  // if the badge only has level, show the highest level color
  final adjustedLevel = math.min(
    badge.level + BADGE_CONFIG_BY_LEVEL.length - badge.badgeLevels,
    BADGE_CONFIG_BY_LEVEL.length,
  );

  return BADGE_CONFIG_BY_LEVEL[adjustedLevel];
}

class AchievementBadge extends StatelessWidget {
  final Badge badge;
  final double size;
  final bool noBackground;
  final bool showLevel;

  const AchievementBadge({
    Key key,
    @required this.badge,
    double size,
    bool noBackground,
    bool showLevel,
  })  : size = size ?? 64,
        noBackground = noBackground ?? false,
        showLevel = showLevel ?? false,
        super(key: key);

  factory AchievementBadge.withLevel({
    @required Badge badge,
    double size,
    bool noBackground,
  }) {
    return AchievementBadge(
      badge: badge,
      size: size,
      noBackground: noBackground,
      showLevel: true,
    );
  }

  BadgeConfig get badgeConfig {
    return getBadgeConfig(badge);
  }

  BadgeIconConfig get iconConfig {
    return badgeIconConfigsByTypes[badge.type];
  }

  String get icon {
    return iconConfig?.image;
  }

  String get iconBackground {
    return iconConfig?.bg;
  }

  String get levelBackgroundAsset {
    return badgeConfig?.backgroundAsset;
  }

  Color get color {
    return badgeConfig?.color;
  }

  Color get textColor {
    return badgeConfig?.textColor;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadImage(levelBackgroundAsset),
      builder: ((context, snapshot) {
        if (showLevel) {
          return _withLevel(snapshot);
        }

        return _withoutLevel(snapshot);
      }),
    );
  }

  Widget _withoutLevel(AsyncSnapshot<ui.Image> snapshot) {
    final background = iconBackground;

    return Container(
      width: size,
      height: size,
      child: Stack(
        children: [
          if (!noBackground && background != null)
            _noLevelBackground(
              background,
              snapshot,
            ),
          Positioned.fill(
            child: _icon(),
          ),
        ],
      ),
    );
  }

  Widget _withLevel(AsyncSnapshot<ui.Image> snapshot) {
    final badgeContent = Container(
      padding: EdgeInsets.all(spacingFactor(1)),
      child: Column(
        children: [
          _icon(),
          SizedBox(height: spacingFactor(1)),
          Subtitle2(
            "Level ${badge.level > 0 ? badge.level : 1}",
            color: textColor,
          ),
        ],
      ),
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadiusFactor(2)),
        border: Border.all(color: color),
        boxShadow: [
          BoxShadow(
            color: color,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          _background(
            snapshot,
            Container(
              color: Colors.white,
              child: badgeContent,
            ),
          ),
          Positioned.fill(child: badgeContent),
        ],
      ),
    );
  }

  Widget _icon() {
    final badgeIcon = icon;

    return Center(
      child: badgeIcon == null
          ? Container(
              width: size,
              height: size,
            )
          : Image.asset(
              badgeIcon,
              fit: BoxFit.contain,
              width: size,
              height: size,
            ),
    );
  }

  Widget _noLevelBackground(
    String backgroundAsset,
    AsyncSnapshot<ui.Image> snapshot,
  ) {
    final image = Image.asset(
      backgroundAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    return _background(snapshot, image);
  }

  Widget _background(
    AsyncSnapshot<ui.Image> snapshot,
    Widget child,
  ) {
    final backgroundColor = color;

    if (snapshot.connectionState != ConnectionState.done || snapshot.hasError) {
      return Container();
    }

    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [backgroundColor, backgroundColor],
      ).createShader(bounds),
      child: ShaderMask(
        shaderCallback: (bounds) => ImageShader(
          snapshot.data,
          ui.TileMode.mirror,
          ui.TileMode.mirror,
          Float64List.fromList(Matrix4.identity().storage),
        ),
        child: child,
      ),
    );
  }

  Future<ui.Image> _loadImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final list = Uint8List.view(data.buffer);
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(list, completer.complete);
    return completer.future;
  }
}
