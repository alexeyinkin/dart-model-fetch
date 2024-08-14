import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:model_interfaces/model_interfaces.dart';

import 'enums/query_source_type.dart';
import 'loader_factories/abstract.dart';

abstract class QueryBuilder<
//
    T extends WithId<String>,
    F extends AbstractFilter
//
    > {
  final F filter;
  final AbstractFirestoreLoaderFactory<T, F> loaderFactory;
  final QuerySourceType sourceType;

  const QueryBuilder({
    required this.filter,
    required this.loaderFactory,
    required this.sourceType,
  });

  Query<T> get query;

  String get collectionName;

  Query<Map<String, dynamic>> get collectionGroupQuery =>
      FirebaseFirestore.instance.collectionGroup(collectionName);

  CollectionReference<Map<String, dynamic>> get collectionReference =>
      FirebaseFirestore.instance.collection(collectionName);

  Query<Map<String, dynamic>> get _emptyMapQuery => switch (sourceType) {
        QuerySourceType.collection => collectionReference,
        QuerySourceType.collectionGroup => collectionGroupQuery,
      };

  Query<T> get emptyQuery => _emptyMapQuery.withConverter(
        fromFirestore: loaderFactory.fromFirestoreBase,
        toFirestore: (_, __) => throw UnimplementedError(),
      );
}
