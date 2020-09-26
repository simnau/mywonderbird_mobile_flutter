import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' show radians;

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final Function dismissLeft;
  final Function dismissRight;
  final double width;
  final AnimatedCardController controller;

  const AnimatedCard({
    Key key,
    @required this.child,
    @required this.dismissLeft,
    @required this.dismissRight,
    @required this.width,
    this.controller,
  }) : super(key: key);

  @override
  AnimatedCardState createState() => AnimatedCardState();
}

class AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  double lastOffset = 0;
  double currentOffset = 0;
  Tween<double> offsetTween;
  Tween<double> flickLeftTween;
  Tween<double> flickRightTween;
  Animation<double> offsetX;
  Animation<double> flickLeft;
  Animation<double> flickRight;

  double get fullOffset =>
      currentOffset + offsetX.value + flickLeft.value + flickRight.value;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_controllerChange);

    controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    offsetTween = Tween<double>(begin: 0, end: 0);
    flickLeftTween = Tween<double>(begin: 0, end: 0);
    flickRightTween = Tween<double>(begin: 0, end: 0);
    offsetX = offsetTween.animate(controller);
    flickLeft = flickLeftTween.animate(controller);
    flickRight = flickRightTween.animate(controller);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_controllerChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget child) {
        return GestureDetector(
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: Transform.translate(
            offset: Offset(fullOffset, 0),
            child: Transform.rotate(
              angle: radians(fullOffset * -0.05),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }

  _controllerChange() {
    switch (widget.controller.direction) {
      case SwipeDirection.LEFT:
        _onSwipeLeft();
        break;
      case SwipeDirection.RIGHT:
        _onSwipeRight();
        break;
    }
  }

  _onDragStart(DragStartDetails details) {
    lastOffset = details.globalPosition.dx;
    setState(() {
      currentOffset = 0;
    });
  }

  _onDragUpdate(DragUpdateDetails details) {
    final offsetChange = details.globalPosition.dx - lastOffset;
    lastOffset = details.globalPosition.dx;

    setState(() {
      currentOffset += offsetChange;
    });
  }

  _onDragEnd(DragEndDetails details) {
    lastOffset = 0;
    setState(() {
      _animateOffset(currentOffset);
      currentOffset = 0;
    });
  }

  _animateOffset(double offset) {
    if (offset > (widget.width / 3)) {
      _onFlingRight(offset: offset);
    } else if (offset < -(widget.width / 3)) {
      _onFlingLeft(offset: offset);
    } else {
      _onReturnToCenter(offset: offset);
    }
  }

  _onSwipeLeft({double offset = 0}) {
    controller.reset();
    flickLeftTween.begin = offset;
    flickLeftTween.end = -widget.width * 2;
    controller.forward().whenCompleteOrCancel(() {
      widget.dismissLeft();
      flickLeftTween.begin = 0;
      flickLeftTween.end = 0;
      controller.reset();
    });
  }

  _onFlingLeft({double offset = 0}) {
    controller.reset();
    flickLeftTween.begin = offset;
    flickLeftTween.end = -widget.width * 2;
    controller.fling().whenCompleteOrCancel(() {
      widget.dismissLeft();
      flickLeftTween.begin = 0;
      flickLeftTween.end = 0;
      controller.reset();
    });
  }

  _onSwipeRight({double offset = 0}) {
    controller.reset();
    flickRightTween.begin = offset;
    flickRightTween.end = widget.width * 2;
    controller.forward().whenCompleteOrCancel(() {
      widget.dismissRight();
      flickRightTween.begin = 0;
      flickRightTween.end = 0;
      controller.reset();
    });
  }

  _onFlingRight({double offset = 0}) {
    controller.reset();
    flickRightTween.begin = offset;
    flickRightTween.end = widget.width * 2;
    controller.fling().whenCompleteOrCancel(() {
      widget.dismissRight();
      flickRightTween.begin = 0;
      flickRightTween.end = 0;
      controller.reset();
    });
  }

  _onReturnToCenter({double offset = 0}) {
    controller.reset();
    offsetTween.begin = offset;
    offsetTween.end = 0;
    controller.forward().whenCompleteOrCancel(() {
      offsetTween.begin = 0;
      offsetTween.end = 0;
      controller.reset();
    });
  }
}

enum SwipeDirection {
  LEFT,
  RIGHT,
}

class AnimatedCardController with ChangeNotifier {
  SwipeDirection direction;

  swipeLeft() {
    direction = SwipeDirection.LEFT;
    notifyListeners();
  }

  swipeRight() {
    direction = SwipeDirection.RIGHT;
    notifyListeners();
  }
}
