import 'package:flutter/material.dart';
import 'package:mywonderbird/components/empty-list-placeholder.dart';
import 'package:mywonderbird/components/infinite-list.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/user-notification.dart';
import 'package:mywonderbird/providers/user-notification.dart';
import 'package:mywonderbird/routes/notifications/components/notification-item.dart';
import 'package:mywonderbird/services/user-notification.dart';
import 'package:mywonderbird/util/sentry.dart';
import 'package:mywonderbird/util/snackbar.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget {
  static const RELATIVE_PATH = 'notifications';
  static const PATH = "/$RELATIVE_PATH";

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final GlobalKey<InfiniteListState> _infiniteListKey = GlobalKey();
  final userNotificationService = locator<UserNotificationService>();

  List<UserNotification> _items = [];
  bool _isPerformingRequest = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchInitial();
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _items = [];
      _isLoading = true;
    });

    try {
      List<UserNotification> newEntries =
          await userNotificationService.fetchNotifications(null);
      setState(() {
        _items = newEntries;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      await reportError(error, stackTrace);
      final snackBar = createErrorSnackbar(
        text: 'An unexpected error has occurred. Please try again later.',
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  _fetchInitial() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<UserNotification> newEntries =
          await userNotificationService.fetchNotifications(null);
      setState(() {
        _items = newEntries;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      await reportError(error, stackTrace);
      final snackBar = createErrorSnackbar(
        text: 'An unexpected error has occurred. Please try again later.',
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  _fetchMore() async {
    if (!_isPerformingRequest) {
      setState(() => _isPerformingRequest = true);

      try {
        List<UserNotification> newEntries =
            await userNotificationService.fetchNotifications(
          _items.last != null ? _items.last.updatedAt : null,
        );

        if (newEntries.isEmpty) {
          _infiniteListKey.currentState.onNoNewResults();
        }

        setState(() {
          _isPerformingRequest = false;

          if (newEntries.isNotEmpty) {
            _items = List.from(_items)..addAll(newEntries);
          }
        });
      } catch (error, stackTrace) {
        await reportError(error, stackTrace);
        final snackBar = createErrorSnackbar(
          text: 'An unexpected error has occurred. Please try again later.',
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userNotificationProvider =
        Provider.of<UserNotificationProvider>(context);
    final notificationCount = userNotificationProvider.notificationCount;
    final title = notificationCount > 0
        ? "Notifications ($notificationCount)"
        : 'Notifications';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: H6(
          title,
          color: Colors.black87,
        ),
      ),
      body: RefreshIndicator(
        child: _body(),
        onRefresh: _refresh,
      ),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_items.isEmpty) {
      return EmptyListPlaceholder(
        title: 'You have no notifications',
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: spacingFactor(2),
        right: spacingFactor(2),
        bottom: spacingFactor(1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            onPressed: _onMarkAllAsRead,
            child: BodyText1(
              'Mark all as read',
              color: Colors.black45,
            ),
          ),
          Expanded(
            child: InfiniteList(
              key: _infiniteListKey,
              fetchMore: _fetchMore,
              itemBuilder: (BuildContext context, int index) {
                return _notificationItem(_items[index]);
              },
              itemCount: _items.length,
              padding: EdgeInsets.only(
                top: spacingFactor(1),
                bottom: spacingFactor(8),
              ),
              rowPadding: EdgeInsets.only(bottom: spacingFactor(2)),
              isPerformingRequest: _isPerformingRequest,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationItem(UserNotification userNotification) {
    return NotificationItem(
      userNotification: userNotification,
      onMarkAsRead: _onMarkAsRead,
    );
  }

  _onMarkAllAsRead() async {
    final userNotificationProvider = Provider.of<UserNotificationProvider>(
      context,
      listen: false,
    );

    await userNotificationProvider.markAllNotificationsAsRead();

    setState(() {
      _items.forEach((userNotification) {
        userNotification.read = true;
      });
    });
  }

  _onMarkAsRead(UserNotification userNotification) async {
    final userNotificationProvider = Provider.of<UserNotificationProvider>(
      context,
      listen: false,
    );

    await userNotificationProvider.markNotificationAsRead(userNotification);

    setState(() {
      userNotification.read = true;
    });
  }
}
