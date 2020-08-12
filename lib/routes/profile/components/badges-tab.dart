import 'package:flutter/material.dart';

class BadgesTab extends StatefulWidget {
  @override
  _BadgesTabState createState() => _BadgesTabState();
}

class _BadgesTabState extends State<BadgesTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        'Badges',
        style: TextStyle(color: Colors.black45),
      ),
    );
  }
}
