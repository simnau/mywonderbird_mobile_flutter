import 'package:flutter/material.dart';
import 'package:mywonderbird/models/suggested-location.dart';

class SelectedLocations extends StatelessWidget {
  final List<SuggestedLocation> selectedLocations;

  const SelectedLocations({
    Key key,
    this.selectedLocations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      height: 32,
      child: _content(),
    );
  }

  Widget _content() {
    if (selectedLocations.isEmpty) {
      return Text(
        'No locations selected',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: selectedLocations.length,
            itemBuilder: _item,
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 4),
            ),
          ),
        ),
        Text(
          "${selectedLocations.length} selected",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _item(context, index) {
    final item = selectedLocations[index];
    final imageUrl = item.coverImage?.url;

    return Material(
      borderRadius: BorderRadius.circular(8.0),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          image: imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                )
              : null,
          color: Colors.grey,
        ),
      ),
      elevation: 8,
    );
  }
}
