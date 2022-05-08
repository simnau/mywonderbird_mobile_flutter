import 'package:flutter/material.dart';
import 'package:mywonderbird/components/avatar.dart';
import 'package:mywonderbird/constants/theme.dart';

class UserAvatar extends StatelessWidget {
  final String avatarUrl;
  final Function onTap;

  const UserAvatar({
    Key key,
    @required this.avatarUrl,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      margin: EdgeInsets.only(
        left: spacingFactor(1),
        right: spacingFactor(2),
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(
          borderRadiusFactor(16),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Avatar(
              url: avatarUrl,
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  borderRadiusFactor(16),
                ),
                onTap: onTap,
              ),
            ),
          )
        ],
      ),
    );
  }
}
