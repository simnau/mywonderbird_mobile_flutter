import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String avatarUrl;

  const UserAvatar({
    Key key,
    @required this.avatarUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            offset: Offset(0, 4),
            color: Colors.black26,
          ),
        ],
        color: avatarUrl != null ? Colors.transparent : Colors.grey[400],
        image: avatarUrl != null
            ? DecorationImage(image: NetworkImage(avatarUrl))
            : null,
      ),
      child: avatarUrl == null
          ? Icon(
              Icons.person,
              size: 48,
              color: Colors.black38,
            )
          : null,
    );
  }
}
