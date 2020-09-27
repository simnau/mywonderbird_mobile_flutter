import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/providers/share-picture.dart';
import 'package:mywonderbird/routes/share-picture/main.dart';
import 'package:mywonderbird/routes/share-picture/mock.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/types/share-screen-arguments.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:mywonderbird/providers/journeys.dart';
import 'package:provider/provider.dart';

class SelectJourney extends StatefulWidget {
  final Journey journey;
  final bool createNew;

  SelectJourney({
    this.journey,
    this.createNew,
  });

  @override
  _SelectJourneyState createState() => _SelectJourneyState();
}

class _SelectJourneyState extends State<SelectJourney> {
  final _titleController = TextEditingController();

  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _creating = widget.createNew ?? false;
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
              flex: 0,
              child: _buildListHeader(),
            ),
            Expanded(
              flex: 1,
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
                    color: Colors.black26,
                  ),
          ),
        ),
        title: Subtitle1(journey.name ?? 'Journey with no name'),
        subtitle: Subtitle2(timeago.format(journey.startDate)),
      ),
    );
  }

  Widget _buildListHeader() {
    if (_creating) {
      return _buildCreateTripHeader();
    }

    return _buildCreateTripButton();
  }

  Widget _buildCreateTripHeader() {
    final sharePictureProvider = locator<SharePictureProvider>();
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 32.0,
        vertical: 8.0,
      ),
      leading: Container(
        width: 64,
        height: 64,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image(
            fit: BoxFit.cover,
            image: sharePictureProvider.pictureData?.image,
          ),
        ),
      ),
      title: TextField(
        autofocus: true,
        controller: _titleController,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Enter a trip title',
          hintStyle: TextStyle(
            color: Colors.black26,
          ),
        ),
        style: theme.textTheme.subtitle1,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.check,
                color: Colors.green,
                size: 24,
              ),
            ),
            onTap: _createTrip,
          ),
          InkWell(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.close,
                color: Colors.red,
                size: 24,
              ),
            ),
            onTap: _closeCreateTrip,
          ),
        ],
      ),
    );
  }

  Widget _buildCreateTripButton() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 32.0,
        vertical: 8.0,
      ),
      onTap: _openCreateTrip,
      leading: Container(
        width: 64,
        height: 64,
        child: Icon(
          Icons.add_circle,
          color: Colors.black38,
          size: 32.0,
        ),
      ),
      title: Subtitle1(
        'Create a new trip',
        color: Colors.black38,
      ),
    );
  }

  void _closeCreateTrip() {
    _titleController.clear();
    setState(() {
      _creating = false;
    });
  }

  void _openCreateTrip() {
    setState(() {
      _creating = true;
    });
  }

  void _createTrip() async {
    final journeysProvider = locator<JourneysProvider>();

    final journey = Journey(
      imageUrl: MOCK_IMAGE, // TODO: use appropriate image
      name: _titleController.text,
      startDate: DateTime.now(),
    );

    await journeysProvider.addJourney(journey);

    _closeCreateTrip();
  }

  _loadUserJourneys() async {
    final journeysProvider = locator<JourneysProvider>();
    await journeysProvider.loadUserJourneys();
  }

  _onSelectJourney(Journey journey) {
    final navigationService = locator<NavigationService>();
    if (widget.createNew ?? false) {
      navigationService.pushReplacementNamed(
        ShareScreen.PATH,
        arguments: ShareScreenArguments(
          selectedJourney: journey,
        ),
      );
    } else {
      navigationService.pop(journey);
    }
  }
}
