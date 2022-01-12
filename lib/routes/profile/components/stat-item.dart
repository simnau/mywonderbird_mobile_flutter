import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text2.dart';
import 'package:mywonderbird/components/typography/h6.dart';

class StatItem extends StatelessWidget {
  final int count;
  final String title;
  final Function() onTap;
  final EdgeInsets padding;

  const StatItem({
    Key key,
    @required this.count,
    @required this.title,
    @required this.onTap,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Column(
          children: [
            H6(
              count.toString(),
              color: Colors.black87,
            ),
            BodyText2(title),
          ],
        ),
      ),
    );
  }
}
