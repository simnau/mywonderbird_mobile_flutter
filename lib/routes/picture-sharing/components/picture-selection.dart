import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:photo_manager/photo_manager.dart';

class PictureSelection extends StatelessWidget {
  final Function(AssetEntity photo) selectPhoto;
  final AssetEntity photo;
  final Widget child;
  final bool isSelected;

  const PictureSelection({
    Key key,
    @required this.selectPhoto,
    @required this.photo,
    @required this.child,
    @required bool isSelected,
  })  : this.isSelected = isSelected ?? false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _selectPhoto,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          child,
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? theme.accentColor : Colors.black,
                width: isSelected ? 3 : 1,
              ),
            ),
          ),
          Positioned(
            left: spacingFactor(1.5),
            bottom: spacingFactor(1.5),
            child: isSelected
                ? Icon(
                    MaterialCommunityIcons.checkbox_marked_circle,
                    color: theme.accentColor,
                  )
                : Icon(
                    MaterialCommunityIcons.checkbox_blank_circle_outline,
                    color: Colors.white.withOpacity(0.75),
                  ),
          )
        ],
      ),
    );
  }

  _selectPhoto() {
    selectPhoto(photo);
  }
}
