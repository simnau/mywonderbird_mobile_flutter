import 'package:flutter/material.dart';
import 'package:mywonderbird/components/avatar.dart';
import 'package:mywonderbird/components/small-icon-button.dart';
import 'package:mywonderbird/components/typography/body-text2.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:transparent_image/transparent_image.dart';

import 'typography/body-text1.dart';

class FeedItem extends StatefulWidget {
  final String title;
  final String country;
  final int likeCount;
  final bool isLiked;
  final bool isBookmarked;
  final void Function() onLike;
  final void Function() onBookmark;
  final void Function() onTap;
  final void Function() onView;
  final void Function() onViewUser;
  final String imageUrl;
  final String userAvatarUrl;

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
    @required this.onView,
    @required this.onViewUser,
    @required this.imageUrl,
    @required this.userAvatarUrl,
  }) : super(key: key);

  @override
  _FeedItemState createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
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
            child: Material(
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(16.0),
              ),
              child: InkWell(
                onTap: widget.onView,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(16.0),
                ),
                child: Container(
                  width: 300,
                  height: 90,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: _details(context),
                ),
              ),
            ),
            bottom: 0,
            right: 0,
          ),
        ],
      ),
    );
  }

  Widget _details(BuildContext context) {
    return Row(
      children: [
        Align(
          alignment: Alignment.center,
          child: Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.only(left: 8.0, right: 16.0),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(width: 2, color: Colors.white),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 4),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Avatar(
                    url: widget.userAvatarUrl,
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(60),
                      onTap: widget.onViewUser,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Subtitle2(
                    widget.title ?? '',
                    overflow: TextOverflow.ellipsis,
                  ),
                  BodyText2(
                    widget.country ?? '',
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SmallIconButton(
                        icon: Icon(
                          widget.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
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
                      BodyText1(widget.likeCount.toString()),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                  ),
                  SmallIconButton(
                    icon: Icon(
                      widget.isBookmarked
                          ? Icons.turned_in
                          : Icons.turned_in_not,
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
          ),
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
