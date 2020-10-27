import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/services/navigation.dart';

class TitleEntry extends StatelessWidget {
  final String title;
  final String hint;
  final String saveLabel;
  final TextEditingController _titleController = TextEditingController();

  TitleEntry({
    Key key,
    this.title = 'Enter a title',
    this.hint = '',
    this.saveLabel = 'SAVE',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          FlatButton(
            onPressed: _onSave,
            child: Text(
              saveLabel,
              style: TextStyle(
                color: theme.primaryColor,
              ),
            ),
            shape: ContinuousRectangleBorder(),
          ),
        ],
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Subtitle1(
            title,
            textAlign: TextAlign.start,
          ),
          TextField(
            decoration: new InputDecoration(hintText: hint),
            controller: _titleController,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
          ),
        ],
      ),
    );
  }

  _onSave() {
    if (_titleController.text.isNotEmpty) {
      final navigationService = locator<NavigationService>();

      navigationService.pop(_titleController.text);
    }
  }
}
