import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:model_interfaces/model_interfaces.dart';

import '../list/firestore_frozen_list_lazy_loader.dart';
import '../model_by_filter/firestore_live_model_loader_by_filter.dart';
import '../model_by_id/firestore_live_model_loader_by_id.dart';
import '../query_builder.dart';

abstract class AbstractFirestoreLoaderFactory<
    T extends WithId<String>,
    F extends AbstractFilter
//
    > extends LoaderFactory<
    String,
    T,
    F
//
    > {
  QueryBuilder<T, F> createQueryBuilder(F filter);

  Future<T> fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  );

  void onError(Object error, StackTrace trace) {
    print('Error in $runtimeType: $error'); // ignore: avoid_print
    print(trace); // ignore: avoid_print
  }

  Future<T> fromFirestoreBase(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) async {
    try {
      return await fromFirestore(snapshot, options);

      // ignore: avoid_catches_without_on_clauses
    } catch (error, trace) {
      // TODO(alexeyinkin): Allow to silence this, https://github.com/alexeyinkin/dart-model-fetch/issues/9
      print('Error denormalizing object ${snapshot.id}.'); //ignore: avoid_print
      onError(error, trace);
      rethrow;
    }
  }

  Map<String, Object?> toFirestore(
    Future<T> value,
    SetOptions? options,
  ) {
    throw UnimplementedError();
  }

  @override
  FirestoreLiveModelLoaderById<T> createLiveModelLoaderById(String id) {
    return FirestoreLiveModelLoaderById(
      collectionReference: defaultCollectionReference.withConverter(
        fromFirestore: fromFirestoreBase,
        toFirestore: toFirestore,
      ),
      id: id,
      onError: onError,
    );
  }

  @override
  ModelLoaderById<String, T> createFrozenModelLoaderById(String id) {
    throw UnimplementedError();
  }

  @override
  FirestoreLiveModelLoaderByFilter<T> createLiveModelLoaderByFilter(F filter) {
    final query = createQueryBuilder(filter).query.limit(1);

    return FirestoreLiveModelLoaderByFilter(
      onError: onError,
      query: query,
    );
  }

  @override
  ModelLoaderByFilter<String, T> createFrozenModelLoaderByFilter(F filter) {
    // TODO(alexeyinkin): Clone FirestoreLiveModelLoaderByFilter, make frozen.
    throw UnimplementedError('TODO');
  }

  @override
  ListLazyLoader<T> createLiveListLazyLoader(F filter) {
    throw UnimplementedError();
  }

  @override
  FirestoreFrozenListLazyLoader<T> createFrozenListLazyLoader(F filter) {
    return FirestoreFrozenListLazyLoader(
      onError: onError,
      pageSize: filter.pageSize,
      query: createQueryBuilder(filter).query,
    );
  }

  String get defaultCollectionName;

  CollectionReference<Map<String, dynamic>> get defaultCollectionReference =>
      FirebaseFirestore.instance.collection(defaultCollectionName);
}
