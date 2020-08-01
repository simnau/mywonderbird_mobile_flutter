import 'package:flutter/material.dart';
import 'package:layout/components/custom-list-item.dart';
import 'package:layout/locator.dart';
import 'package:layout/providers/share-picture.dart';
import 'package:layout/routes/share-picture/select-journey.dart';
import 'package:layout/routes/share-picture/share-screen.dart';
import 'package:layout/services/journeys.dart';
import 'package:layout/services/navigation.dart';
import 'package:layout/types/select-journey-arguments.dart';
import 'package:layout/types/share-screen-arguments.dart';

class SelectDestination extends StatefulWidget {
  static const RELATIVE_PATH = "share-picture";
  static const PATH = "/$RELATIVE_PATH";

  @override
  _SelectDestinationState createState() => _SelectDestinationState();
}

class _SelectDestinationState extends State<SelectDestination> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.dependOnInheritedWidgetOfExactType();
  }

  @override
  void dispose() {
    super.dispose();
    SharePictureProvider().dispose();
  }

  void _shareToLastJourney(BuildContext context) async {
    final journeyService = locator<JourneyService>();
    final lastJourney = await journeyService.getLastJourney();
    Navigator.pushNamed(
      context,
      ShareScreen.RELATIVE_PATH,
      arguments: ShareScreenArguments(
        selectedJourney: lastJourney,
      ),
    );
  }

  void _shareToNewJourney(BuildContext context) {
    Navigator.pushNamed(
      context,
      SelectJourney.RELATIVE_PATH,
      arguments: SelectJourneyArguments(
        createNew: true,
      ),
    );
  }

  void _onBack(BuildContext context) {
    final navigationService = locator<NavigationService>();
    navigationService.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () => _onBack(context),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Share to',
          style: TextStyle(
            color: Colors.black87,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(32.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CustomListItem(
                title: 'Your last journey',
                subtitle:
                    'Your photo will be shared to the last journey you created',
                leadingIcon: Icons.history,
                trailingIcon: Icons.chevron_right,
                onTap: () => _shareToLastJourney(context),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
              ),
              CustomListItem(
                title: 'A new journey',
                subtitle:
                    'Create a new journey with this photo as a starting point',
                leadingIcon: Icons.add,
                trailingIcon: Icons.chevron_right,
                onTap: () => _shareToNewJourney(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
