import 'package:flutter/material.dart';

class TextActionButton extends StatelessWidget {
  final bool disabled;
  final Function() onPress;
  final String title;
  final Color color;

  const TextActionButton({
    Key key,
    bool disabled,
    @required this.onPress,
    @required this.title,
    this.color,
  })  : this.disabled = disabled ?? false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: disabled ? null : onPress,
      child: Text(
        title,
        style: TextStyle(
          color:
              disabled ? theme.disabledColor : this.color ?? theme.primaryColor,
        ),
      ),
    );
  }
}
