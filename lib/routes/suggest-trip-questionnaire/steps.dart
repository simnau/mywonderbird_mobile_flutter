import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';

import 'components/bool-picker.dart';
import 'components/count-picker.dart';
import 'components/trip-country.dart';
import 'components/trip-end.dart';
import 'components/trip-start.dart';
import 'wizard-step.dart';

final questionnaireSteps = [
  WizardStep(
    key: 'country',
    title: 'Where do you want to travel?',
    builder: (arguments) => TripCountry(
      focusNode: arguments.focusNode,
      onValueChanged: arguments.onValueChanged,
      value: arguments.value,
    ),
    validator: (value) => value != null,
    stringValue: (country) => country?.value,
  ),
  WizardStep(
    key: 'start',
    title: 'Where does your trip start?',
    builder: (arguments) => TripStart(
      focusNode: arguments.focusNode,
      onValueChanged: arguments.onValueChanged,
      value: arguments.value,
    ),
    validator: (value) => true,
  ),
  WizardStep(
    key: 'end',
    title: 'Where does it end?',
    builder: (arguments) => TripEnd(
      focusNode: arguments.focusNode,
      onValueChanged: arguments.onValueChanged,
      value: arguments.value,
    ),
    validator: (value) => true,
  ),
  WizardStep(
    key: 'duration',
    title: 'How long is your trip?',
    builder: (arguments) => CountPicker(
      onValueChanged: arguments.onValueChanged,
      value: arguments.value,
      minValue: 1,
      maxValue: 365,
      prefix: Subtitle1('Duration'),
      postfix: Subtitle1('day(s)'),
    ),
    validator: (value) => value != null && value > 0,
  ),
  WizardStep(
    key: 'locationCount',
    title: 'How many locations do you want to visit per day?',
    builder: (arguments) => CountPicker(
      onValueChanged: arguments.onValueChanged,
      value: arguments.value,
      minValue: 1,
      maxValue: 20,
      postfix: Subtitle1('location(s)'),
    ),
    validator: (value) => value != null && value > 0,
  ),
  WizardStep(
    key: 'travelerCount',
    title: 'How many more people are traveling with you?',
    builder: (arguments) => CountPicker(
      onValueChanged: arguments.onValueChanged,
      value: arguments.value,
      minValue: 0,
      maxValue: 10,
      postfix: Subtitle1('traveler(s)'),
    ),
    validator: (value) => value != null && value >= 0,
  ),
  WizardStep(
    key: 'travelingWithChildren',
    title: 'Are you traveling with children?',
    builder: (arguments) => BoolPicker(
      onValueChanged: (bool value) {
        arguments.onValueChanged(value);
        if (value != null) {
          arguments.onComplete();
        }
      },
      value: arguments.value,
    ),
    validator: (value) => value != null,
  )
];

Map<String, String> stepValues(Map<String, dynamic> originalStepValues) {
  return questionnaireSteps.fold<Map<String, String>>(
    {},
    (previousValue, element) {
      final value = originalStepValues[element.key];
      final stringValue = element.stringValue != null
          ? element.stringValue(value)
          : value?.toString();

      return {
        ...previousValue,
        element.key: stringValue,
      };
    },
  );
}
