import 'package:flutter/material.dart';
import 'package:mywonderbird/components/square-icon-button.dart';
import 'package:mywonderbird/components/typography/body-text2.dart';

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
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: BackButton(),
          ),
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
                    size: 28,
                  ),
                  label: BodyText2(
                    'Skip',
                    color: Colors.red,
                  ),
                  size: 56,
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
                    size: 28,
                  ),
                  label: BodyText2(
                    'Add',
                    color: Colors.green,
                  ),
                  size: 56,
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
                size: 28,
                color: Colors.white,
              ),
              label: BodyText2(
                'Save',
                color: Colors.white,
              ),
              size: 56,
              backgroundColor: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
