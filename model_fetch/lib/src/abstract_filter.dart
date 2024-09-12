import 'dart:convert';

abstract class AbstractFilter {
  const AbstractFilter();

  int get pageSize => 20;

  @Deprecated('Make it a data object with @Data or use `fields` + @FirestoreModel')
  Map<String, dynamic> toJson() => const {};

  @Deprecated('Make it a data object with @Data or use `fields` + @FirestoreModel')
  String get hash => jsonEncode(toJson());

  List<Object> get fields => const [];
}
