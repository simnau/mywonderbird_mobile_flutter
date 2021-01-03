import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/models/tag.dart';
import 'package:mywonderbird/providers/tags.dart';
import 'package:provider/provider.dart';

class TypesOfPlacePicker extends StatelessWidget {
  final List<String> types;
  final Function(List<String>) onValueChanged;
  final List<String> value;

  const TypesOfPlacePicker({
    Key key,
    this.types,
    @required this.onValueChanged,
    @required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: _places(context)),
        ],
      ),
    );
  }

  Widget _places(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _types(context)),
      ],
    );
  }

  Widget _types(BuildContext context) {
    return SingleChildScrollView(
      clipBehavior: Clip.antiAlias,
      child: Wrap(
        clipBehavior: Clip.antiAlias,
        children: _typeFilters(context),
        runSpacing: 16.0,
        alignment: WrapAlignment.spaceAround,
      ),
    );
  }

  List<Widget> _typeFilters(BuildContext context) {
    final tagsProvider = Provider.of<TagsProvider>(
      context,
    );

    return tagsProvider.tags
        .map((filter) => _typeFilter(filter, context))
        .toList();
  }

  Widget _typeFilter(Tag tags, BuildContext context) {
    final theme = Theme.of(context);
    final selected = value.contains(tags.code);

    return SizedBox(
      width: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 96,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(tags.imageUrl),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                    border: selected
                        ? Border.all(
                            color: theme.primaryColor,
                            width: 4.0,
                          )
                        : null,
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _toggleFilter(tags.code),
                    ),
                  ),
                ),
              ],
            ),
          ),
          BodyText1(
            tags.title,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  _toggleFilter(selection) {
    final List<String> list = List.from(value);
    if (list.contains(selection)) {
      list.remove(selection);
    } else {
      list.add(selection);
    }
    onValueChanged(list);
  }
}
