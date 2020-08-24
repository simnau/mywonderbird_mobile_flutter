import 'package:flutter/material.dart';
import 'package:mywonderbird/components/custom-list-item.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/providers/share-picture.dart';
import 'package:mywonderbird/routes/select-journey/main.dart';
import 'package:mywonderbird/routes/share-picture/main.dart';
import 'package:mywonderbird/services/journeys.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/types/share-screen-arguments.dart';

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
        title: Text(
          'Share to',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 18.0,
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
