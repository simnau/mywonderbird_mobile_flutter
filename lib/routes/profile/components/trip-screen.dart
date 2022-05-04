import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/trip-stats.dart';
import 'package:mywonderbird/providers/profile.dart';
import 'package:mywonderbird/routes/profile/components/trip-list.dart';
import 'package:mywonderbird/routes/saved-trip-overview/main.dart';
import 'package:mywonderbird/routes/trip-overview/saved-trip.dart';
import 'package:mywonderbird/routes/trip-overview/shared-trip.dart';
import 'package:mywonderbird/services/journeys.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/saved-trip.dart';
import 'package:mywonderbird/util/sentry.dart';
import 'package:mywonderbird/util/snackbar.dart';

class TripScreen extends StatefulWidget {
  final String title;
  final Future<List<TripStats>> Function() fetchTripsFunction;
  final Widget actionButton;
  final Widget emptyListPlaceholder;
  final bool renderTripProgress;
  final bool refetchOnPop;
  final bool isCurrentUser;

  const TripScreen({
    Key key,
    @required this.title,
    @required this.fetchTripsFunction,
    this.actionButton,
    this.emptyListPlaceholder,
    bool renderTripProgress,
    bool refetchOnPop,
    bool isCurrentUser,
  })  : renderTripProgress = renderTripProgress ?? false,
        refetchOnPop = refetchOnPop ?? true,
        isCurrentUser = isCurrentUser ?? false,
        super(key: key);

  @override
  _TripScreenState createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  List<TripStats> _trips;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Subtitle1(widget.title),
        backgroundColor: Colors.transparent,
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchTrips,
      child: TripList(
        trips: _trips,
        renderProgress: widget.renderTripProgress,
        onViewTrip: _onViewTrip,
        padding: EdgeInsets.symmetric(
          horizontal: spacingFactor(2),
          vertical: spacingFactor(1),
        ),
        actionButton: widget.actionButton,
        emptyListPlaceholder: widget.emptyListPlaceholder,
        showItemActions: widget.isCurrentUser,
        onDeleteTrip: _onDeleteTrip,
      ),
    );
  }

  Future<void> _fetchTrips() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final trips = await widget.fetchTripsFunction();

      setState(() {
        _isLoading = false;
        _trips = trips;
      });
    } catch (error, stackTrace) {
      await reportError(error, stackTrace);

      final errorSnackbar = createErrorSnackbar(
        text: "There was an error loading the trips. Please try again",
      );

      ScaffoldMessenger.of(context).showSnackBar(errorSnackbar);
    }
  }

  _onViewTrip(TripStats tripStats) async {
    final navigationService = locator<NavigationService>();
    await navigationService.push(
      MaterialPageRoute(
        builder: (context) => tripStats.tripType == TripType.SHARED_TRIP
            ? SharedTripOverviewGeneric(id: tripStats.id)
            : widget.isCurrentUser &&
                    tripStats.tripStatus != TripStatus.FINISHED
                ? SavedTripOverview(id: tripStats.id)
                : SavedTripOverviewGeneric(id: tripStats.id),
      ),
    );

    final profileProvider = locator<ProfileProvider>();

    if (widget.refetchOnPop && profileProvider.reloadProfile) {
      await _fetchTrips();
    }
  }

  _onDeleteTrip(TripStats tripStats) async {
    final navigationService = locator<NavigationService>();
    final theme = Theme.of(context);

    final result = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Subtitle1("Are you sure?"),
        content: Subtitle2("You cannot undo this action"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              navigationService.pop(false);
            },
            child: BodyText1(
              'Cancel',
              color: theme.primaryColor,
            ),
          ),
          TextButton(
            onPressed: () {
              navigationService.pop(true);
            },
            child: BodyText1(
              'Delete',
              color: theme.errorColor,
            ),
          ),
        ],
      ),
    );

    if (result != null && result) {
      await _deleteTrip(tripStats);
    }
  }

  _deleteTrip(TripStats tripStats) async {
    if (tripStats.tripType != TripType.SAVED_TRIP &&
        tripStats.tripType != TripType.SHARED_TRIP) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      if (tripStats.tripType == TripType.SAVED_TRIP) {
        final savedTripService = locator<SavedTripService>();

        await savedTripService.deleteTrip(tripStats.id);
      } else {
        final sharedTripService = locator<JourneyService>();

        await sharedTripService.deleteJourney(tripStats.id);
      }

      setState(() {
        _trips.remove(tripStats);
        _isLoading = false;
      });

      final profileProvider = locator<ProfileProvider>();
      profileProvider.reloadProfile = true;

      final snackBar = createSuccessSnackbar(
        text: 'The trip has been deleted',
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (error, stackTrace) {
      await reportError(error, stackTrace);

      final snackBar = createErrorSnackbar(
        text: 'An unexpected error has occurred. Please try again later.',
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
