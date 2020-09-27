import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/h5.dart';

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
        child: H5.light('No'),
        onPressed: _onNo,
        color: Colors.red,
      );
    }

    return OutlineButton(
      child: H5(
        'No',
        color: Colors.red,
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
        child: H5.light('Yes'),
        onPressed: _onYes,
        color: Colors.green,
      );
    }

    return OutlineButton(
      child: H5(
        'Yes',
        color: Colors.green,
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
