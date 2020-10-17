import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';

const TYPE_FILTERS = [
  {
    'title': 'Museums',
    'value': 'museums',
    'imageAsset': 'images/filters/museums.jpg',
  },
  {
    'title': 'Architecture',
    'value': 'architecture',
    'imageAsset': 'images/filters/architecture.jpg',
  },
  {
    'title': 'Hidden gems',
    'value': 'hidden-gems',
    'imageAsset': 'images/filters/hidden-gems.jpg',
  },
  {
    'title': 'Viewpoints',
    'value': 'viewpoints',
    'imageAsset': 'images/filters/viewpoints.jpg',
  },
  {
    'title': 'Hikes',
    'value': 'hikes',
    'imageAsset': 'images/filters/hikes.jpg',
  },
];

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

  // @override
  // _FiltersState createState() => _FiltersState(value: value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child: _places(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _places(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _types(context),
      ],
    );
  }

  Widget _types(BuildContext context) {
    return Wrap(
      children: _typeFilters(context),
      runSpacing: 16.0,
      alignment: WrapAlignment.spaceAround,
    );
  }

  List<Widget> _typeFilters(BuildContext context) {
    return TYPE_FILTERS.map((filter) => _typeFilter(filter, context)).toList();
  }

  Widget _typeFilter(Map<String, String> typeFilter, BuildContext context) {
    final theme = Theme.of(context);
    final selected = value.contains(typeFilter['value']);
    print(value);
    return SizedBox(
      width: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 96,
            child: Ink(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(typeFilter['imageAsset']),
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
              child: InkWell(
                onTap: () => _toggleFilter(typeFilter['value']),
              ),
            ),
          ),
          BodyText1(
            typeFilter['title'],
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
