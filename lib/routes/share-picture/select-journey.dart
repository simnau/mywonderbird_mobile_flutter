import 'package:layout/models/journey.dart';
import 'package:layout/providers/share-picture.dart';
import 'package:layout/routes/share-picture/share-screen.dart';
import 'package:layout/types/share-screen-arguments.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:layout/providers/journeys.dart';
import 'package:layout/routes/home.dart';
import 'package:provider/provider.dart';

import 'mock.dart';

class SelectJourney extends StatefulWidget {
  static const RELATIVE_PATH = 'share-picture/journey';
  static const PATH = "/$RELATIVE_PATH";

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
  JourneysProvider _journeysProvider;

  @override
  void initState() {
    super.initState();
    _creating = widget.createNew ?? false;
    WidgetsBinding.instance.addPostFrameCallback((_) => loadUserJourneys());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _journeysProvider = Provider.of<JourneysProvider>(
      context,
      listen: false,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _journeysProvider.clearState();
  }

  void loadUserJourneys() async {
    final journeysProvider = Provider.of<JourneysProvider>(
      context,
      listen: false,
    );
    await journeysProvider.loadUserJourneys();
  }

  void _cancel() {
    Navigator.of(context, rootNavigator: true).popUntil(
      (route) => route.settings.name == Home.PATH,
    );
  }

  void _onSelectJourney(Journey journey) {
    if (widget.createNew ?? false) {
      Navigator.of(context).pushReplacementNamed(
        ShareScreen.RELATIVE_PATH,
        arguments: ShareScreenArguments(
          selectedJourney: journey,
        ),
      );
    } else {
      Navigator.of(context).pop(journey);
    }
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
        title: Text(
          journey.name ?? 'Journey with no name',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          timeago.format(journey.startDate),
          style: TextStyle(
            fontSize: 18,
            color: Colors.black26,
          ),
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

  void _createTrip() async {
    final journeysProvider = Provider.of<JourneysProvider>(
      context,
      listen: false,
    );

    final journey = Journey(
      imageUrl: MOCK_IMAGE,
      name: _titleController.text,
      startDate: DateTime.now(),
    );

    await journeysProvider.addJourney(journey);

    _closeCreateTrip();
  }

  void _openCreateTrip() {
    setState(() {
      _creating = true;
    });
  }

  void _closeCreateTrip() {
    _titleController.clear();
    setState(() {
      _creating = false;
    });
  }

  Widget _buildCreateTripHeader() {
    final sharePictureProvider = Provider.of<SharePictureProvider>(
      context,
      listen: false,
    );

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
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
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
      title: Text(
        'Create a new trip',
        style: TextStyle(
          color: Colors.black38,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildListHeader() {
    if (_creating) {
      return _buildCreateTripHeader();
    }

    return _buildCreateTripButton();
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.close,
            ),
            onPressed: _cancel,
          ),
        ],
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
}
