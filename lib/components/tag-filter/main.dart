import 'package:flutter/material.dart';
import 'package:mywonderbird/components/tag-filter/item.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/models/tag.dart';

class TagFilter extends StatelessWidget {
  final List<Tag> tags;
  final List<String> value;
  final Function(List<String>) onValueChanged;
  final String title;

  const TagFilter({
    Key key,
    @required this.tags,
    @required this.value,
    @required this.onValueChanged,
    this.title,
  }) : super(key: key);

  List<Widget> get _tagWidgets => tags
      .map(
        (tag) => TagFilterItem(
          tag: tag,
          selected: value.contains(tag.code),
          onPress: _toggleFilter,
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Subtitle1(title ?? 'Category'),
        SizedBox(height: 16.0),
        Wrap(
          clipBehavior: Clip.antiAlias,
          children: _tagWidgets,
          runSpacing: 8.0,
          spacing: 8.0,
          alignment: WrapAlignment.spaceBetween,
        ),
      ],
    );
  }

  _toggleFilter(String tagCode) {
    final List<String> list = List.from(value);

    if (list.contains(tagCode)) {
      list.remove(tagCode);
    } else {
      list.add(tagCode);
    }

    onValueChanged(list);
  }
}
