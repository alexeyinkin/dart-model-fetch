import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:model_interfaces/model_interfaces.dart';

import '../collection/firestore_frozen_lazy_load_bloc.dart';
import '../model_by_filter/firestore_live_by_filter_bloc.dart';
import '../model_by_id/firestore_live_by_id_bloc.dart';
import '../query_builder.dart';

abstract class AbstractFirestoreLoaderFactory<T extends WithId<String>,
    F extends AbstractFilter> {
  final _liveByFilterBlocs = <String, FirestoreLiveByFilterBloc<T>>{};
  final _liveByIdBlocs = <String, FirestoreLiveByIdBloc<T>>{};
  final _frozenListBlocs = <String, FirestoreFrozenLazyLoadBloc<T>>{};

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

  FirestoreLiveByFilterBloc<T> liveByFilterBloc(F filter) {
    return _liveByFilterBlocs[filter] ??
        _createAndCacheLiveByFilterBloc(filter);
  }

  FirestoreLiveByFilterBloc<T> _createAndCacheLiveByFilterBloc(F filter) {
    final query = createQueryBuilder(filter).query.limit(1);

    final result = FirestoreLiveByFilterBloc(
      collectionReference: getCollection().withConverter(
        fromFirestore: fromFirestoreBase,
        toFirestore: toFirestore,
      ),
      query: query,
    );

    _liveByFilterBlocs[filter.hash] = result;
    return result;
  }

  FirestoreLiveByIdBloc<T> liveByIdBloc(String id) {
    return _liveByIdBlocs[id] ?? _createAndCacheLiveByIdBloc(id);
  }

  FirestoreLiveByIdBloc<T> _createAndCacheLiveByIdBloc(String id) {
    final result = FirestoreLiveByIdBloc(
      collectionReference: getCollection().withConverter(
        fromFirestore: fromFirestoreBase,
        toFirestore: toFirestore,
      ),
      id: id,
    );

    _liveByIdBlocs[id] = result;
    return result;
  }

  LazyLoadBloc<T> frozenListBloc(F filter) {
    return _frozenListBlocs[filter.hash] ??
        _createAndCacheFrozenListBloc(filter);
  }

  LazyLoadBloc<T> _createAndCacheFrozenListBloc(F filter) {
    final result = FirestoreFrozenLazyLoadBloc(
      onError: onError,
      query: createQueryBuilder(filter).query,
      pageSize: filter.pageSize,
    );

    _frozenListBlocs[filter.hash] = result;
    return result;
  }

  @protected
  CollectionReference<Map<String, dynamic>> getCollection();
}
