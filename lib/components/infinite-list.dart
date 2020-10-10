import 'package:flutter/material.dart';

class InfiniteList extends StatefulWidget {
  final void Function() fetchMore;
  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;
  final EdgeInsets padding;
  final EdgeInsets rowPadding;
  final bool isPerformingRequest;

  InfiniteList({
    Key key,
    @required this.fetchMore,
    @required this.itemBuilder,
    @required this.itemCount,
    this.padding,
    this.rowPadding,
    this.isPerformingRequest,
  }) : super(key: key);

  @override
  InfiniteListState createState() => InfiniteListState();
}

class InfiniteListState extends State<InfiniteList> {
  final ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchMore();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  onNoNewResults() {
    double edge = 50.0;
    double offsetFromBottom = _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    if (offsetFromBottom < edge) {
      _scrollController.animateTo(
          _scrollController.offset - (edge - offsetFromBottom),
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: widget.padding,
      itemCount: widget.itemCount + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == widget.itemCount) {
          return _progressIndicator();
        } else {
          return widget.itemBuilder(context, index);
        }
      },
      separatorBuilder: (context, index) => Padding(
        padding: widget.rowPadding,
      ),
      controller: _scrollController,
    );
  }

  Widget _progressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: widget.isPerformingRequest ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  _fetchMore() async {
    widget.fetchMore();
  }
}
