import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';

class InputTitleDialog extends StatefulWidget {
  final String title;
  final String hint;
  final String cancelLabel;
  final String saveLabel;

  const InputTitleDialog({
    Key key,
    this.title = 'Enter a title',
    this.hint = '',
    this.cancelLabel = 'Cancel',
    this.saveLabel = 'Save',
  }) : super(key: key);

  @override
  _InputTitleDialogState createState() => _InputTitleDialogState();
}

class _InputTitleDialogState extends State<InputTitleDialog> {
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
            widget.title,
            textAlign: TextAlign.start,
          ),
          TextField(
            decoration: new InputDecoration(hintText: widget.hint),
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
                  widget.cancelLabel,
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              RaisedButton(
                onPressed: _onCreate,
                child: BodyText1.light(widget.saveLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _onCreate() {
    Navigator.of(context).pop(_titleController.text);
  }

  _onCancel() {
    Navigator.of(context).pop();
  }
}
