import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  static const PATH = '/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Text('Test'),
      ),
    );
  }
}
