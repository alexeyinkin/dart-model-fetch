import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:model_interfaces/model_interfaces.dart';

import '../collection/firestore_frozen_lazy_load_bloc.dart';
import '../model_by_id/firestore_live_by_id_bloc.dart';
import '../query_builder.dart';

abstract class AbstractFirestoreLoaderFactory<T extends WithId<String>,
    F extends AbstractFilter> {

  final _liveByIdBlocs = <String, FirestoreLiveByIdBloc<T>>{};
  final _frozenListBlocs = <String, FirestoreFrozenLazyLoadBloc<T>>{};

  QueryBuilder<T> createQueryBuilder(F filter);

  T fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  );

  Map<String, Object?> toFirestore(
    T value,
    SetOptions? options,
  ) {
    throw UnimplementedError();
  }

  FirestoreLiveByIdBloc<T> liveByIdBloc(String id) {
    return _liveByIdBlocs[id] ?? _createAndCacheLiveByIdBloc(id);
  }

  FirestoreLiveByIdBloc<T> _createAndCacheLiveByIdBloc(String id) {
    final result = FirestoreLiveByIdBloc(
      collectionReference: getCollection().withConverter(
        fromFirestore: fromFirestore,
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
      query: createQueryBuilder(filter).query,
      pageSize: filter.pageSize,
    );

    _frozenListBlocs[filter.hash] = result;
    return result;
  }

  @protected
  CollectionReference<Map<String, dynamic>> getCollection();
}
