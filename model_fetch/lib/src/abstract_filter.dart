import 'dart:convert';

abstract class AbstractFilter {
  const AbstractFilter();

  Map<String, dynamic> toJson() => const {};

  String get hash => jsonEncode(toJson());
}
