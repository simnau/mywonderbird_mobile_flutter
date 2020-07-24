import 'package:flutter/material.dart';
import 'package:layout/components/small-icon-button.dart';

class FeedItem extends StatelessWidget {
  final String title;
  final String country;
  final int likeCount;
  final bool isLiked;
  final bool isBookmarked;
  final void Function() onLike;
  final void Function() onBookmark;
  final NetworkImage image;

  const FeedItem({
    Key key,
    this.title = '',
    this.country = '',
    this.likeCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    @required this.onLike,
    @required this.onBookmark,
    @required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 45),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: image,
                ),
              ),
              height: 280,
            ),
          ),
          Positioned(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(16.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFBECDE2),
                    offset: Offset(6, 6),
                    blurRadius: 16,
                  ),
                ],
              ),
              width: 200,
              height: 90,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: _details(context),
            ),
            bottom: 0,
            right: 0,
          ),
        ],
      ),
    );
  }

  Widget _details(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title ?? '',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black45,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              country ?? '',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Row(
              children: <Widget>[
                SmallIconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? theme.primaryColor : Colors.black87,
                    size: 24.0,
                  ),
                  onTap: onLike,
                  padding: const EdgeInsets.all(6.0),
                  borderRadius: BorderRadius.circular(24.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                ),
                Text(
                  likeCount.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
            ),
            SmallIconButton(
              icon: Icon(
                isBookmarked ? Icons.turned_in : Icons.turned_in_not,
                color: isBookmarked ? theme.primaryColor : Colors.black87,
                size: 24.0,
              ),
              onTap: onBookmark,
              padding: const EdgeInsets.all(6.0),
              borderRadius: BorderRadius.circular(24.0),
            ),
          ],
        ),
      ],
    );
  }
}
