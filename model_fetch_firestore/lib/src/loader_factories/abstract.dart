import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:model_interfaces/model_interfaces.dart';

import '../collection/firestore_frozen_lazy_load_bloc.dart';
import '../model_by_filter/firestore_live_by_filter_bloc.dart';
import '../model_by_id/firestore_live_by_id_bloc.dart';
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
  QueryBuilder<T> createQueryBuilder(F filter);

  T fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  );

  void onError(Object error, StackTrace trace);

  T fromFirestoreBase(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    try {
      return fromFirestore(snapshot, options);

      // ignore: avoid_catches_without_on_clauses
    } catch (error, trace) {
      onError(error, trace);
      rethrow;
    }
  }

  Map<String, Object?> toFirestore(
    T value,
    SetOptions? options,
  ) {
    throw UnimplementedError();
  }

  @override
  FirestoreLiveByIdBloc<T> createLiveByIdBloc(String id) {
    return FirestoreLiveByIdBloc(
      collectionReference: getCollection().withConverter(
        fromFirestore: fromFirestoreBase,
        toFirestore: toFirestore,
      ),
      id: id,
    );
  }

  @override
  ModelByIdBloc<String, T> createFrozenByIdBloc(String id) {
    throw UnimplementedError();
  }

  @override
  FirestoreLiveByFilterBloc<T> createLiveModelByFilterBloc(F filter) {
    final query = createQueryBuilder(filter).query.limit(1);

    return FirestoreLiveByFilterBloc(
      query: query,
    );
  }

  @override
  ModelByFilterBloc<String, T> createFrozenModelByFilterBloc(F filter) {
    // TODO(alexeyinkin): Clone FirestoreLiveByFilterBloc but make it frozen.
    throw UnimplementedError('TODO');
  }

  @override
  LazyLoadBloc<T> createLiveListBloc(F filter) {
    throw UnimplementedError();
  }

  @override
  FirestoreFrozenLazyLoadBloc<T> createFrozenListBloc(F filter) {
    return FirestoreFrozenLazyLoadBloc(
      onError: onError,
      query: createQueryBuilder(filter).query,
      pageSize: filter.pageSize,
    );
  }

  @protected
  CollectionReference<Map<String, dynamic>> getCollection();
}
