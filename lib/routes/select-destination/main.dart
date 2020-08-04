import 'package:flutter/material.dart';
import 'package:layout/components/custom-list-item.dart';
import 'package:layout/locator.dart';
import 'package:layout/providers/share-picture.dart';
import 'package:layout/routes/select-journey.dart/main.dart';
import 'package:layout/routes/share-picture/main.dart';
import 'package:layout/services/journeys.dart';
import 'package:layout/services/navigation.dart';
import 'package:layout/types/share-screen-arguments.dart';

class SelectDestination extends StatefulWidget {
  static const RELATIVE_PATH = "select-destination";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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

  void _shareToLastJourney(BuildContext context) async {
    final journeyService = locator<JourneyService>();
    final lastJourney = await journeyService.getLastJourney();
    final navigationService = locator<NavigationService>();
    navigationService.pushNamed(
      ShareScreen.PATH,
      arguments: ShareScreenArguments(
        selectedJourney: lastJourney,
      ),
    );
  }

  void _shareToNewJourney(BuildContext context) {
    final navigationService = locator<NavigationService>();
    navigationService.push(
      MaterialPageRoute(
        builder: (context) => SelectJourney(
          createNew: true,
        ),
      ),
    );
  }
}
