import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/models/location.dart';

class SpotsList extends StatelessWidget {
  final List<LocationModel> spots;
  final void Function(LocationModel spot) onView;
  final void Function(LocationModel spot, BuildContext buildContext) onDelete;

  const SpotsList({
    Key key,
    @required this.spots,
    @required this.onView,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      itemBuilder: (context, index) => _buildSpotListItem(index, context),
      itemCount: spots.length,
    );
  }

  Widget _buildSpotListItem(int index, BuildContext context) {
    final spot = spots[index];

    return Container(
      child: ListTile(
        onTap: () => onView(spot),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 32.0,
        ),
        leading: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: spot.imageUrl != null
              ? Image(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    spot.imageUrl,
                  ),
                )
              : Container(
                  color: Colors.black26,
                ),
        ),
        title: Subtitle1(spot.name ?? '-'),
        subtitle: Subtitle2(spot.country),
        trailing: onDelete == null
            ? null
            : IconButton(
                icon: Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                ),
                onPressed: () => onDelete(spot, context),
              ),
      ),
    );
  }
}
