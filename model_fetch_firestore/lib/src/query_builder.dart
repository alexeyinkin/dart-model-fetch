import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:model_interfaces/model_interfaces.dart';

import 'enums/query_source_type.dart';
import 'loader_factories/abstract.dart';
import 'util.dart';

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

  Query<Future<T>> get query => emptyQuery;

  String get collectionName => loaderFactory.defaultCollectionName;

  Query<Map<String, dynamic>> get _mapCollectionGroupQuery =>
      FirebaseFirestore.instance.collectionGroup(collectionName);

  Query<Future<T>> get collectionGroupQuery =>
      _mapCollectionGroupQuery.withConverter(
        fromFirestore: _fromFirestore,
        toFirestore: _toFirestore,
      );

  CollectionReference<Map<String, dynamic>> get mapCollectionReference =>
      loaderFactory.defaultCollectionReference;

  CollectionReference<Future<T>> get collectionReference =>
      mapCollectionReference.withConverter(
        fromFirestore: _fromFirestore,
        toFirestore: _toFirestore,
      );

  Query<Future<T>> get emptyQuery => switch (sourceType) {
        QuerySourceType.collection => collectionReference,
        QuerySourceType.collectionGroup => collectionGroupQuery,
      };

  Future<T> _fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) =>
      loaderFactory.fromFirestoreBase(snapshot, options);

  Map<String, Object?> _toFirestore(Future<T> future, SetOptions? options) {
    if (future is! SynchronousFuture) {
      throw ArgumentError('Expected SynchronousFuture, $future given.');
    }

    final value = (future as SynchronousFuture<T>).value;

    return (value as dynamic).toJson();
  }
}
