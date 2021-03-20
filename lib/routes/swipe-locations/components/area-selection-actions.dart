import 'package:flutter/material.dart';
import 'package:mywonderbird/components/square-icon-button.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';

class AreaSelectionActions extends StatelessWidget {
  final void Function() onSelectArea;
  final void Function() onGoToMyLocation;

  const AreaSelectionActions({
    Key key,
    @required this.onSelectArea,
    @required this.onGoToMyLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: ElevatedButton(
            child: BodyText1.light('SELECT AREA'),
            onPressed: onSelectArea,
            style: ElevatedButton.styleFrom(
              primary: theme.primaryColor.withOpacity(0.85),
            ),
          ),
        ),
        SizedBox(width: 16.0),
        SquareIconButton(
          size: 36,
          icon: Icon(
            Icons.my_location,
            color: Colors.black,
          ),
          onPressed: onGoToMyLocation,
          backgroundColor: Colors.grey[50].withOpacity(0.85),
        ),
      ],
    );
  }
}
