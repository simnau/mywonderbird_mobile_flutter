import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/trip-stats.dart';
import 'package:mywonderbird/providers/profile.dart';
import 'package:mywonderbird/routes/profile/components/trip-list/trip-list.dart';
import 'package:mywonderbird/routes/saved-trip-overview/main.dart';
import 'package:mywonderbird/routes/trip-overview/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/util/snackbar.dart';

class TripScreen extends StatefulWidget {
  final String title;
  final Future<List<TripStats>> Function() fetchTripsFunction;
  final Widget actionButton;
  final Widget emptyListPlaceholder;
  final bool renderTripProgress;
  final bool refetchOnPop;

  const TripScreen({
    Key key,
    @required this.title,
    @required this.fetchTripsFunction,
    this.actionButton,
    this.emptyListPlaceholder,
    bool renderTripProgress,
    bool refetchOnPop,
  })  : renderTripProgress = renderTripProgress ?? false,
        refetchOnPop = refetchOnPop ?? true,
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
      child: Expanded(
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
        ),
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
    } catch (error) {
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
        builder: (context) => tripStats.tripType == TripType.SAVED_TRIP
            ? SavedTripOverview(
                id: tripStats.id,
              )
            : TripOverview(id: tripStats.id),
      ),
    );

    final profileProvider = locator<ProfileProvider>();

    if (widget.refetchOnPop && profileProvider.reloadProfile) {
      await _fetchTrips();
    }
  }
}
