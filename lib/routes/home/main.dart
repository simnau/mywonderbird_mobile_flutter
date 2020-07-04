import 'package:flutter/material.dart';
import 'package:layout/components/bottom-nav-bar.dart';
import 'package:layout/routes/select-picture/home.dart';

class HomePage extends StatelessWidget {
  static const PATH = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Text('Home'),
      ),
      floatingActionButton: Container(
        width: 72,
        height: 72,
        margin: const EdgeInsets.all(2.0),
        child: FloatingActionButton(
          child: Icon(
            Icons.add,
            size: 36,
          ),
          onPressed: () {
            Navigator.pushNamed(context, SelectPictureHome.PATH);
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
