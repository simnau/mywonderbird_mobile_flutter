import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/h5.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/services/navigation.dart';

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

class Filters extends StatefulWidget {
  final List<String> types;

  const Filters({
    Key key,
    this.types,
  }) : super(key: key);

  @override
  _FiltersState createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  List<String> _selectedTypes;

  @override
  void initState() {
    super.initState();
    _selectedTypes = List.from(widget.types ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child: _filters()),
              _actions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        H5('Type of place'),
        Padding(padding: const EdgeInsets.only(bottom: 16.0)),
        _types(),
      ],
    );
  }

  Widget _actions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RaisedButton(
          colorBrightness: Brightness.dark,
          child: Text('Apply filters'),
          onPressed: _apply,
        ),
        FlatButton(
          child: Text('Close'),
          onPressed: _close,
        ),
      ],
    );
  }

  Widget _types() {
    return Wrap(
      children: _typeFilters(),
      runSpacing: 16.0,
      alignment: WrapAlignment.spaceAround,
    );
  }

  List<Widget> _typeFilters() {
    return TYPE_FILTERS.map(_typeFilter).toList();
  }

  Widget _typeFilter(Map<String, String> typeFilter) {
    final theme = Theme.of(context);
    final selected = _selectedTypes.contains(typeFilter['value']);

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

  _toggleFilter(value) {
    setState(() {
      if (_selectedTypes.contains(value)) {
        _selectedTypes.remove(value);
      } else {
        _selectedTypes.add(value);
      }
    });
  }

  _apply() {
    final navigationService = locator<NavigationService>();
    navigationService.pop(_selectedTypes);
  }

  _close() {
    final navigationService = locator<NavigationService>();
    navigationService.pop();
  }
}
