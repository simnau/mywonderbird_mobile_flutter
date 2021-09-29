import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/theme.dart';

enum BigActionButtonVariant {
  primary,
  secondary,
}

class BigActionButton extends StatelessWidget {
  final Function() onTap;
  final BigActionButtonVariant variant;
  final IconData icon;
  final String title;
  final String subtitle;

  const BigActionButton({
    Key key,
    @required this.onTap,
    BigActionButtonVariant variant,
    @required this.icon,
    @required this.title,
    @required this.subtitle,
  })  : variant = variant ?? BigActionButtonVariant.secondary,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _backgroundDecoration(context),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(spacingFactor(2)),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: _iconColor(context),
                ),
                SizedBox(height: spacingFactor(2)),
                Subtitle1(
                  title,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacingFactor(2)),
                Subtitle2(
                  subtitle,
                  color: Colors.black45,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _backgroundDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(borderRadiusFactor(4));

    switch (variant) {
      case BigActionButtonVariant.primary:
        return BoxDecoration(
          color: theme.primaryColorLight.withOpacity(0.25),
          border: Border.all(
            color: theme.primaryColor,
            width: 2,
          ),
          borderRadius: borderRadius,
        );
      default:
        return BoxDecoration(
          border: Border.all(
            color: Colors.black87,
            width: 2,
          ),
          borderRadius: borderRadius,
        );
    }
  }

  Color _iconColor(BuildContext context) {
    final theme = Theme.of(context);

    switch (variant) {
      case BigActionButtonVariant.primary:
        return theme.primaryColor;
      default:
        return Colors.black45;
    }
  }
}
