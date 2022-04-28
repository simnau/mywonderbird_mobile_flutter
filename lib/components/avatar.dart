import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String url;
  final double size;

  const Avatar({
    Key key,
    @required this.url,
    double size,
  })  : size = size ?? 40,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: url != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(url),
              minRadius: size / 2,
              maxRadius: size / 2,
            )
          : Icon(
              Icons.person,
              size: size,
              color: Colors.black38,
            ),
    );
  }
}
