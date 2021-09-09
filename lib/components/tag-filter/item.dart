import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/tag.dart';

class TagFilterItem extends StatelessWidget {
  final bool selected;
  final Tag tag;
  final void Function(String code) onPress;

  const TagFilterItem({
    Key key,
    @required this.selected,
    @required this.tag,
    @required this.onPress,
  }) : super(key: key);

  _onPress() {
    onPress(tag.code);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                      image: NetworkImage(tag.imageUrl),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                    border: selected
                        ? Border.all(
                            color: theme.accentColor,
                            width: 4.0,
                          )
                        : null,
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _onPress,
                    ),
                  ),
                ),
                if (selected)
                  Positioned(
                    bottom: spacingFactor(1),
                    left: spacingFactor(1),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.accentColor,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.black87,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          BodyText1(
            tag.title,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
