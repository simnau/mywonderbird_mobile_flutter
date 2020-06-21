String formatDateTime(DateTime dateTime) {
  return dateTime.toUtc().toIso8601String();
}
