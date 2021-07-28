import 'package:flutter/material.dart';

class ScreenLayout extends StatelessWidget {
  final Widget child;

  const ScreenLayout({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          bottom: 0,
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/mywonderbird-travel.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white54,
              ),
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 64, 32, 96),
                    child: child,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
