import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/label-value-pair.dart';
import 'package:mywonderbird/services/country.dart';
import 'package:mywonderbird/util/debouncer.dart';

const COUNTRIES = [
  'Lithuania',
  'USA',
  'Canada',
  'Latvia',
  'Liechtenschtein',
  'Luxembourg',
  'Laos'
];

class TripCountry extends StatefulWidget {
  final FocusNode focusNode;
  final Function(LabelValuePair) onValueChanged;
  final LabelValuePair value;

  const TripCountry({
    Key key,
    this.focusNode,
    @required this.onValueChanged,
    @required this.value,
  }) : super(key: key);

  @override
  _TripCountryState createState() => _TripCountryState(value: value);
}

class _TripCountryState extends State<TripCountry> {
  final _searchController;
  final _searchDebouncer = Debouncer(milliseconds: 300);

  _TripCountryState({
    LabelValuePair value,
  }) : _searchController = TextEditingController(
          text: value?.label,
        );

  List<LabelValuePair> _countries = [];
  bool _loading = false;
  String _previousSearchValue = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: TextField(
            autofocus: widget.value == null,
            controller: _searchController,
            focusNode: widget.focusNode,
            onChanged: _onSearchChange,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: theme.primaryColor,
              ),
              suffixIcon: widget.value != null
                  ? IconButton(
                      icon: Icon(Icons.close),
                      onPressed: _onClearCountry,
                    )
                  : null,
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  style: BorderStyle.solid,
                  color: theme.primaryColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              hintText: 'Search for countries',
              hintStyle: TextStyle(
                color: Colors.black26,
              ),
            ),
            style: theme.textTheme.subtitle1,
          ),
        ),
        Expanded(
          child: _list(),
        ),
      ],
    );
  }

  Widget _list() {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.separated(
      itemBuilder: _country,
      itemCount: _countries.length,
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
      ),
    );
  }

  Widget _country(BuildContext context, int index) {
    final country = _countries[index];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          title: Subtitle1(country.label),
          onTap: () => _onSelectCountry(country),
        ),
      ),
    );
  }

  _onSelectCountry(LabelValuePair country) {
    setState(() {
      _searchController.text = country.label;
      widget.onValueChanged(country);
      widget.focusNode.unfocus();
      _countries = [];
    });
  }

  _onClearCountry() {
    setState(() {
      _searchController.text = '';
      widget.onValueChanged(null);
    });
  }

  _onSearchChange(value) {
    if (value == _previousSearchValue) {
      return;
    }

    _previousSearchValue = value;

    if (value.isEmpty) {
      setState(() {
        _countries = [];
        _loading = false;
      });
      _searchDebouncer.cancel();
      return;
    }

    _searchDebouncer.run(() async {
      setState(() {
        _loading = true;
      });

      final countryService = locator<CountryService>();
      final countries = await countryService.searchCountries(value);

      setState(() {
        _countries = countries;
        _loading = false;
      });
    });
  }
}
