import 'package:flutter/material.dart';
import 'package:mywonderbird/components/square-icon-button.dart';
import 'package:mywonderbird/components/typography/body-text2.dart';
import 'package:mywonderbird/constants/theme.dart';

class ShareProviderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final void Function() onPressed;
  final Color backgroundColor;
  final Gradient gradient;

  const ShareProviderButton({
    Key key,
    @required this.icon,
    @required this.label,
    @required this.onPressed,
    this.backgroundColor,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SquareIconButton(
          backgroundColor: backgroundColor,
          gradient: gradient,
          size: 80,
          icon: Icon(
            icon,
            size: 56,
            color: Colors.white,
          ),
          onPressed: onPressed,
        ),
        SizedBox(height: spacingFactor(1)),
        BodyText2(
          label,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }
}
