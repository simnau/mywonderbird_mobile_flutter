import 'package:flutter/material.dart';
import 'package:mywonderbird/components/square-icon-button.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';

class SwipeActions extends StatelessWidget {
  final void Function() onDismiss;
  final void Function() onSelect;
  final void Function() onSave;

  const SwipeActions({
    Key key,
    @required this.onDismiss,
    @required this.onSelect,
    @required this.onSave,
  }) : super(key: key);

  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SquareIconButton(
                  onPressed: onDismiss,
                  icon: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 36,
                  ),
                  label: BodyText1(
                    'Skip',
                    color: Colors.red,
                  ),
                  size: 72,
                  backgroundColor: Colors.transparent,
                  side: BorderSide(color: Colors.red),
                  splashColor: Colors.red.withOpacity(0.4),
                  focusColor: Colors.red.withOpacity(0.1),
                ),
                SizedBox(width: 16.0),
                SquareIconButton(
                  onPressed: onSelect,
                  icon: Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 36,
                  ),
                  label: BodyText1(
                    'Add',
                    color: Colors.green,
                  ),
                  size: 72,
                  backgroundColor: Colors.transparent,
                  side: BorderSide(color: Colors.green),
                  splashColor: Colors.green.withOpacity(0.4),
                  focusColor: Colors.green.withOpacity(0.1),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SquareIconButton(
              onPressed: onSave,
              icon: Icon(
                Icons.save,
                size: 32,
                color: Colors.white,
              ),
              size: 60,
              backgroundColor: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
