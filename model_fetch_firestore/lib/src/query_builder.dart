import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:model_interfaces/model_interfaces.dart';

import 'loader_factories/abstract.dart';

abstract class QueryBuilder<
//
    T extends WithId<String>,
    F extends AbstractFilter
//
    > {
  final F filter;
  final AbstractFirestoreLoaderFactory<T, F> loaderFactory;

  const QueryBuilder({
    required this.filter,
    required this.loaderFactory,
  });

  Query<T> get query;

  String get collectionName;

  CollectionReference get collectionReference =>
      FirebaseFirestore.instance.collection(collectionName);

  Query<T> get emptyQuery => collectionReference.withConverter(
        fromFirestore: loaderFactory.fromFirestoreBase,
        toFirestore: (_, __) => throw UnimplementedError(),
      );
}
