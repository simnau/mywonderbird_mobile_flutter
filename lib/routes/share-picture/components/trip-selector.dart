import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/body-text2.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/models/journey.dart';

class TripSelector extends FormField<Journey> {
  final Future<Journey> Function() onCreateTrip;
  final Future<Journey> Function() onSelectTrip;
  final Function(Journey) onChange;
  final ImageProvider image;

  TripSelector({
    Key key,
    Journey initialValue,
    String Function(Journey) validator,
    AutovalidateMode autovalidateMode,
    this.onCreateTrip,
    this.onSelectTrip,
    this.onChange,
    this.image,
  }) : super(
          key: key,
          initialValue: initialValue,
          validator: validator,
          autovalidateMode: autovalidateMode,
          builder: (FormFieldState<Journey> state) {
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _CreateTripItem(
                        onCreateTrip: () async {
                          final trip = await onCreateTrip();

                          if (trip != null) {
                            state.didChange(trip);
                            onChange(trip);
                          }
                        },
                      ),
                    ),
                    Padding(padding: const EdgeInsets.only(right: 16.0)),
                    Expanded(
                      child: _TripItem(
                        trip: state.value,
                        onSelectTrip: () async {
                          final trip = await onSelectTrip();

                          if (trip != null) {
                            state.didChange(trip);
                            onChange(trip);
                          }
                        },
                        image: image,
                        hasError: state.hasError,
                        errorText: state.errorText,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
}

class _CreateTripItem extends StatelessWidget {
  final Function() onCreateTrip;

  const _CreateTripItem({
    Key key,
    this.onCreateTrip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Subtitle2('New trip'),
        Padding(padding: const EdgeInsets.only(bottom: 8.0)),
        AspectRatio(
          aspectRatio: 4 / 3,
          child: InkWell(
            onTap: onCreateTrip,
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black12,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                Icons.add,
                size: 96.0,
                color: Colors.black12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TripItem extends StatelessWidget {
  final Function() onSelectTrip;
  final Journey trip;
  final ImageProvider image;
  final bool hasError;
  final String errorText;

  const _TripItem({
    Key key,
    this.onSelectTrip,
    this.trip,
    this.image,
    this.hasError = false,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Subtitle2('Selected trip'),
        Padding(padding: const EdgeInsets.only(bottom: 8.0)),
        InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTap: onSelectTrip,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: _Content(
              trip: trip,
              image: image,
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(bottom: 4.0)),
        Subtitle1(
          trip != null ? trip.name : 'No trip selected',
          textAlign: TextAlign.center,
        ),
        Padding(padding: const EdgeInsets.only(bottom: 4.0)),
        if (!hasError) BodyText2(trip != null ? 'Change trip' : 'Choose trip'),
        if (hasError) BodyText1(errorText, color: theme.errorColor),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final Journey trip;
  final ImageProvider image;

  const _Content({
    Key key,
    this.trip,
    this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (trip == null) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black12,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Icon(
          Icons.block,
          size: 96.0,
          color: Colors.black12,
        ),
      );
    }

    if (trip.imageUrl == null) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black12,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        alignment: Alignment.center,
        child: Icon(
          FontAwesome.image,
          size: 96.0,
          color: Colors.black12,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(trip.imageUrl),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
