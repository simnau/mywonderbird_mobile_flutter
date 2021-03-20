import 'package:flutter/material.dart';

class SwipeActions extends StatelessWidget {
  final void Function() onBack;
  final void Function() onDismiss;
  final void Function() onSelect;
  final void Function() onReset;

  const SwipeActions({
    Key key,
    @required this.onBack,
    @required this.onDismiss,
    @required this.onSelect,
    @required this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      child: SizedBox(
        height: 68,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FloatingActionButton(
              onPressed: onBack,
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              child: BackButtonIcon(),
              heroTag: null,
              mini: true,
            ),
            Align(
              alignment: Alignment.center,
              child: FloatingActionButton(
                onPressed: onDismiss,
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                heroTag: null,
                child: Icon(
                  Icons.close,
                  size: 32,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: FloatingActionButton(
                onPressed: onSelect,
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                heroTag: null,
                child: Icon(
                  Icons.check,
                  size: 32,
                ),
              ),
            ),
            FloatingActionButton(
              onPressed: onReset,
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              heroTag: null,
              mini: true,
              child: Icon(
                Icons.refresh,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
