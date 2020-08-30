Map<String, T> removeNulls<T>(Map<String, T> json) {
  Map<String, T> jsonWithoutNulls = Map();

  for (final entry in json.entries) {
    if (entry.value != null) {
      jsonWithoutNulls[entry.key] = entry.value;
    }
  }

  return jsonWithoutNulls;
}
