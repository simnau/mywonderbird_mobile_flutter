import 'package:flutter/material.dart';

class BoolPicker extends StatelessWidget {
  final bool value;
  final Function(bool) onValueChanged;

  const BoolPicker({
    Key key,
    @required this.value,
    @required this.onValueChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      shape: ContinuousRectangleBorder(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _yesButton(),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
              ),
              _noButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noButton() {
    if (value == false) {
      return RaisedButton(
        colorBrightness: Brightness.dark,
        child: Text(
          'No',
          style: TextStyle(
            fontSize: 24,
          ),
        ),
        onPressed: _onNo,
        color: Colors.red,
      );
    }

    return OutlineButton(
      child: Text(
        'No',
        style: TextStyle(
          color: Colors.red,
          fontSize: 24,
        ),
      ),
      onPressed: _onNo,
      color: Colors.red,
      borderSide: BorderSide(color: Colors.red),
      highlightedBorderColor: Colors.red,
    );
  }

  Widget _yesButton() {
    if (value == true) {
      return RaisedButton(
        colorBrightness: Brightness.dark,
        child: Text(
          'Yes',
          style: TextStyle(
            fontSize: 24,
          ),
        ),
        onPressed: _onYes,
        color: Colors.green,
      );
    }

    return OutlineButton(
      child: Text(
        'Yes',
        style: TextStyle(
          color: Colors.green,
          fontSize: 24,
        ),
      ),
      onPressed: _onYes,
      color: Colors.green,
      borderSide: BorderSide(color: Colors.green),
      highlightedBorderColor: Colors.green,
    );
  }

  _onYes() {
    onValueChanged(true);
  }

  _onNo() {
    onValueChanged(false);
  }
}
