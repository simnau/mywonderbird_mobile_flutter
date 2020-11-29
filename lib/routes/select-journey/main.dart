import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:mywonderbird/providers/journeys.dart';
import 'package:provider/provider.dart';

class SelectJourney extends StatefulWidget {
  final Journey journey;

  SelectJourney({
    this.journey,
  });

  @override
  _SelectJourneyState createState() => _SelectJourneyState();
}

class _SelectJourneyState extends State<SelectJourney> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserJourneys());
  }

  @override
  void dispose() {
    super.dispose();
    locator<JourneysProvider>().clearState();
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final journeysProvider = Provider.of<JourneysProvider>(
      context,
    );

    if (journeysProvider.loading) {
      return Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (journeysProvider.journeys.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Subtitle1(
                'You have no trips',
                textAlign: TextAlign.center,
                softWrap: true,
              ),
              Padding(padding: const EdgeInsets.only(bottom: 8.0)),
              Subtitle2(
                'Create a new trip instead',
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemBuilder: (_, index) => _buildJourneyListItem(
        journeysProvider.journeys[index],
      ),
      itemCount: journeysProvider.journeys.length,
    );
  }

  Widget _buildJourneyListItem(Journey journey) {
    final isSelected = widget.journey?.id == journey.id;
    final theme = Theme.of(context);

    return Container(
      color: isSelected ? theme.primaryColorLight : null,
      child: ListTile(
        selected: isSelected,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 32.0,
          vertical: 8.0,
        ),
        onTap: () => _onSelectJourney(journey),
        leading: Container(
          width: 64,
          height: 64,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: journey.imageUrl != null
                ? Image(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      journey.imageUrl,
                    ),
                  )
                : Container(
                    child: Icon(
                      FontAwesome.image,
                      color: Colors.black12,
                      size: 54,
                    ),
                  ),
          ),
        ),
        title: Subtitle1(journey.name ?? 'Trip with no name'),
        subtitle: Subtitle2(timeago.format(journey.startDate)),
      ),
    );
  }

  _loadUserJourneys() async {
    final journeysProvider = locator<JourneysProvider>();
    await journeysProvider.loadUserJourneys();
  }

  _onSelectJourney(Journey journey) {
    final navigationService = locator<NavigationService>();
    navigationService.pop(journey);
  }
}
