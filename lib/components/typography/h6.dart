import 'dart:ui' as ui show TextHeightBehavior;

import 'package:flutter/material.dart';

class H6 extends StatelessWidget {
  final String data;
  final StrutStyle strutStyle;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final Locale locale;
  final bool softWrap;
  final TextOverflow overflow;
  final double textScaleFactor;
  final int maxLines;
  final String semanticsLabel;
  final TextWidthBasis textWidthBasis;
  final ui.TextHeightBehavior textHeightBehavior;
  final bool isLight;
  final bool noColor;
  final Color color;
  final FontWeight fontWeight;

  const H6(
    this.data, {
    Key key,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.noColor = false,
    this.color,
    this.fontWeight,
  })  : isLight = false,
        super(key: key);

  const H6.light(
    this.data, {
    Key key,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.color,
    this.fontWeight,
  })  : isLight = true,
        noColor = false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = _style(context);

    return Text(
      data,
      key: key,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }

  TextStyle _style(BuildContext context) {
    final style = Theme.of(context).textTheme.headline6;

    if (isLight) {
      return style.copyWith(color: Colors.white, fontWeight: fontWeight);
    } else if (color != null) {
      return style.copyWith(color: color, fontWeight: fontWeight);
    } else if (noColor) {
      return style.copyWith(color: null, fontWeight: fontWeight);
    }

    return style;
  }
}
