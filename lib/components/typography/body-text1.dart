import 'dart:ui' as ui show TextHeightBehavior;

import 'package:flutter/material.dart';

class BodyText1 extends StatelessWidget {
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
  final TextStyle style;

  const BodyText1(
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
    this.style,
  })  : isLight = false,
        super(key: key);

  const BodyText1.light(
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
    this.style,
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
    final textStyle = Theme.of(context).textTheme.bodyText1.merge(style);

    if (isLight) {
      return textStyle.copyWith(color: Colors.white);
    } else if (color != null) {
      return textStyle.copyWith(color: color);
    } else if (noColor) {
      return textStyle.copyWith(color: null);
    }

    return textStyle;
  }
}
