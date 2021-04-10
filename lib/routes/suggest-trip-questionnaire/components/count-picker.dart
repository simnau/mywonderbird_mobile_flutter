import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class CountPicker extends StatelessWidget {
  final int value;
  final int minValue;
  final int maxValue;
  final Function(int) onValueChanged;
  final Widget prefix;
  final Widget postfix;

  const CountPicker({
    Key key,
    @required this.value,
    @required this.minValue,
    @required this.maxValue,
    @required this.onValueChanged,
    this.prefix,
    this.postfix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: prefix,
            ),
          ),
          NumberPicker(
            haptics: true,
            value: value,
            minValue: minValue,
            maxValue: maxValue,
            onChanged: onValueChanged,
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: postfix,
            ),
          ),
        ],
      ),
    );
  }
}
