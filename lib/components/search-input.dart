import 'package:flutter/material.dart';

class SearchInput extends StatelessWidget {
  final TextEditingController searchController;
  final String hintText;

  const SearchInput({
    Key key,
    this.searchController,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      autofocus: true,
      controller: searchController,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.search,
          color: theme.primaryColor,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            style: BorderStyle.solid,
            color: theme.primaryColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.black26,
        ),
      ),
      style: theme.textTheme.subtitle1,
    );
  }
}
