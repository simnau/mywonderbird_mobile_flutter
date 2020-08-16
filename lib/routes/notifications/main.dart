import 'package:flutter/material.dart';

class Notifications extends StatelessWidget {
  static const RELATIVE_PATH = 'notifications';
  static const PATH = "/$RELATIVE_PATH";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        child: Center(
          child: Text('Notifications'),
        ),
      ),
    );
  }
}
