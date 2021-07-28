import 'package:flutter/material.dart';
import 'package:mywonderbird/models/location.dart';

class LocationSelector extends FormField<LocationModel> {
  final Future<LocationModel> Function() onSelectLocation;
  final Function(LocationModel) onChange;

  LocationSelector({
    Key key,
    LocationModel initialValue,
    String Function(LocationModel) validator,
    this.onChange,
    this.onSelectLocation,
  }) : super(
          key: key,
          initialValue: initialValue,
          validator: validator,
          builder: (FormFieldState<LocationModel> state) => Builder(
            builder: (context) {
              final theme = Theme.of(context);

              var iconColor;
              var subtitle;

              if (state.value != null) {
                iconColor = theme.primaryColor;
                subtitle = Text('Change the photo location');
              } else if (state.hasError) {
                iconColor = theme.errorColor;
                subtitle = Text(
                  state.errorText,
                  style: TextStyle(color: theme.errorColor),
                );
              } else {
                iconColor = Colors.black87;
                subtitle = null;
              }

              return ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: iconColor,
                  size: 40.0,
                ),
                title: Text(
                  state.value != null
                      ? state.value.name ?? 'Unnamed location'
                      : 'Choose the photo location',
                ),
                subtitle: subtitle,
                onTap: () async {
                  final location = await onSelectLocation();

                  if (location != null) {
                    state.didChange(location);
                    onChange(location);
                  }
                },
              );
            },
          ),
        );
}
