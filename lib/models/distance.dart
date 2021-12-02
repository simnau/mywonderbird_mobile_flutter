class Distance {
  final double value;
  final String units;

  Distance({
    this.value,
    this.units,
  });

  factory Distance.fromJson(Map<String, dynamic> json) {
    final value = json['value'];

    return Distance(
      value: value is int ? value.toDouble() : value,
      units: json['units'],
    );
  }

  String toDistanceString() {
    final valueAsString = value.round().toString();

    if (units == null) {
      return valueAsString;
    }

    final lowerCaseUnits = units.toLowerCase();

    if (lowerCaseUnits != "km" && lowerCaseUnits != "mi") {
      return valueAsString;
    }

    return "$valueAsString $lowerCaseUnits";
  }
}
