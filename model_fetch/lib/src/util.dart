typedef ErrorCallback = void Function(Object error, StackTrace trace);

/// Returns the value from [values] that appears first in [priorities].
T? getHighestPriorityValue<T>(
  Iterable<T> values, {
  required Iterable<T> priorities,
}) {
  final set = values.toSet();
  for (final value in priorities) {
    if (set.contains(value)) {
      return value;
    }
  }

  return null;
}
