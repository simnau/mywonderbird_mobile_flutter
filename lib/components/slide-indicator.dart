import 'package:flutter/material.dart';

class SlideIndicator extends StatelessWidget {
  final int itemCount;
  final int currentItem;
  final Color color;

  const SlideIndicator({
    Key key,
    this.itemCount,
    this.currentItem,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _items(),
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  List<Widget> _items() {
    List<Widget> items = [];

    for (int i = 0; i < itemCount; i++) {
      items.add(_item(currentItem == i));
      items.add(Padding(padding: const EdgeInsets.only(right: 12.0)));
    }

    return items;
  }

  Widget _item(bool isSelected) {
    return Container(
      width: isSelected ? 60 : 12,
      height: 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: isSelected ? color : color.withOpacity(0.6),
      ),
    );
  }
}
