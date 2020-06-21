Map<String, dynamic> removeNulls(Map<String, dynamic> json) {
  Map<String, dynamic> jsonWithoutNulls = Map();

  for (final entry in json.entries) {
    if (entry.value != null) {
      jsonWithoutNulls[entry.key] = entry.value;
    }
  }

  return jsonWithoutNulls;
}
