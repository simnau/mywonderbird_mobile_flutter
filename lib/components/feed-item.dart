import 'package:flutter/material.dart';
import 'package:mywonderbird/components/small-icon-button.dart';
import 'package:transparent_image/transparent_image.dart';

class FeedItem extends StatefulWidget {
  final String title;
  final String country;
  final int likeCount;
  final bool isLiked;
  final bool isBookmarked;
  final void Function() onLike;
  final void Function() onBookmark;
  final void Function() onTap;
  final String imageUrl;

  const FeedItem({
    Key key,
    this.title = '',
    this.country = '',
    this.likeCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    @required this.onLike,
    @required this.onBookmark,
    @required this.onTap,
    @required this.imageUrl,
  }) : super(key: key);

  @override
  _FeedItemState createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> with TickerProviderStateMixin {
  AnimationController _controller;

  _FeedItemState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 45),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: GestureDetector(
                    onTap: widget.onTap,
                    onDoubleTap: widget.isLiked ? null : _onLike,
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: widget.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                _LikeAnimation(
                  controller: _controller,
                ),
              ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.title ?? '',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black45,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.country ?? '',
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
                    widget.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.black87,
                    size: 24.0,
                  ),
                  onTap: _onLike,
                  padding: const EdgeInsets.all(6.0),
                  borderRadius: BorderRadius.circular(24.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                ),
                Text(
                  widget.likeCount.toString(),
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
                widget.isBookmarked ? Icons.turned_in : Icons.turned_in_not,
                color: Colors.black87,
                size: 24.0,
              ),
              onTap: widget.onBookmark,
              padding: const EdgeInsets.all(6.0),
              borderRadius: BorderRadius.circular(24.0),
            ),
          ],
        ),
      ],
    );
  }

  _onLike() {
    widget.onLike();

    if (!widget.isLiked) {
      _playLikeAnimation();
    }
  }

  _playLikeAnimation() async {
    try {
      await _controller.forward().orCancel;
      await _controller.reverse().orCancel;
    } on TickerCanceled {
      print('Cancelled');
      // the animation got canceled, probably because it was disposed of
    }
  }
}

class _LikeAnimation extends StatelessWidget {
  final Animation<double> controller;
  final Animation<double> opacity;
  final Animation<double> size;

  _LikeAnimation({Key key, this.controller})
      : opacity = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.0,
              0.300,
              curve: Curves.ease,
            ),
          ),
        ),
        size = Tween<double>(
          begin: 64,
          end: 96,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.0,
              0.3,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: controller,
    );
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 25),
      opacity: opacity.value,
      child: Icon(
        Icons.favorite,
        color: Colors.black87,
        size: size.value,
      ),
    );
  }
}
