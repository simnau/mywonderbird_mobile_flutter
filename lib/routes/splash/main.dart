import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';

class SplashScreen extends StatefulWidget {
  static const PATH = '/';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Color> _loaderColor;

  _SplashScreenState() {
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
  }

  @override
  void initState() {
    super.initState();

    final Animation curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _loaderColor = ColorTween(
      begin: Colors.blue[500],
      end: Colors.white,
    ).animate(curve);
    _controller.forward();

    _loaderColor.addStatusListener(_colorStatusListener);
  }

  @override
  void dispose() {
    _loaderColor.removeStatusListener(_colorStatusListener);
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor,
              theme.accentColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Expanded(
                child: Image.asset('images/logo.png'),
                flex: 4,
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Subtitle1.light('MyWonderbird is loading...'),
                      CircularProgressIndicator(
                        strokeWidth: 5,
                        valueColor: _loaderColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _colorStatusListener(status) {
    if (status == AnimationStatus.completed) {
      _controller.reverse();
    }
    if (status == AnimationStatus.dismissed) {
      _controller.forward();
    }
  }
}
