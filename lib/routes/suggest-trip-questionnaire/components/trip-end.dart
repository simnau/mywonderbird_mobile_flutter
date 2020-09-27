import 'package:flutter/material.dart';

class TripEnd extends StatefulWidget {
  final FocusNode focusNode;
  final String value;
  final Function(String) onValueChanged;

  TripEnd({
    Key key,
    this.value,
    this.onValueChanged,
    this.focusNode,
  }) : super(key: key);

  @override
  _TripEndState createState() => _TripEndState();
}

class _TripEndState extends State<TripEnd> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: TextField(
        focusNode: widget.focusNode,
        controller: _controller,
        onChanged: widget.onValueChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color: theme.primaryColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          hintText: 'Enter a starting point',
          hintStyle: TextStyle(
            color: Colors.black26,
          ),
        ),
        style: theme.textTheme.subtitle1,
      ),
    );
  }
}
