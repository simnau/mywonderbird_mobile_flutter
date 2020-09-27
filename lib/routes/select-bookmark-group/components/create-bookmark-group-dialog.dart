import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';

class CreateBookmarkGroupDialog extends StatefulWidget {
  final void Function(String) onCreate;

  const CreateBookmarkGroupDialog({
    Key key,
    this.onCreate,
  }) : super(key: key);

  @override
  _CreateBookmarkGroupDialogState createState() =>
      _CreateBookmarkGroupDialogState();
}

class _CreateBookmarkGroupDialogState extends State<CreateBookmarkGroupDialog> {
  final _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Subtitle1(
            'Create a bookmark group',
            textAlign: TextAlign.start,
          ),
          TextField(
            decoration: new InputDecoration(hintText: 'Bookmark group title'),
            controller: _titleController,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                onPressed: _onCancel,
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              RaisedButton(
                onPressed: _onCreate,
                child: Text(
                  'Create',
                ),
                colorBrightness: Brightness.dark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  _onCreate() {
    widget?.onCreate(_titleController.text);
    Navigator.of(context).pop();
  }

  _onCancel() {
    Navigator.of(context).pop();
  }
}
