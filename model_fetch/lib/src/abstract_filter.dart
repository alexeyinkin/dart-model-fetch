import 'dart:convert';

abstract class AbstractFilter {
  const AbstractFilter();

  int get pageSize => 20;

  Map<String, dynamic> toJson() => const {};

  String get hash => jsonEncode(toJson());
}
