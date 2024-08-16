import 'package:cloud_firestore/cloud_firestore.dart';
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
  QueryBuilder<T, F> createQueryBuilder(F filter);

  Future<T> fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  );

  void onError(Object error, StackTrace trace) {
    print('Error in ${runtimeType}: $error'); // ignore: avoid_print
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
      // TODO(alexeyinkin): Allow to silence this.
      print('Error denormalizing object ${snapshot.id}.');
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
  FirestoreLiveByIdBloc<T> createLiveByIdBloc(String id) {
    return FirestoreLiveByIdBloc(
      collectionReference: defaultCollectionReference.withConverter(
        fromFirestore: fromFirestoreBase,
        toFirestore: toFirestore,
      ),
      id: id,
      onError: onError,
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
      onError: onError,
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
    // return FirestoreLiveLoader(
    //   onError: onError,
    //   query: createQueryBuilder(filter).query,
    // );
    throw UnimplementedError();
  }

  @override
  FirestoreFrozenLazyLoadBloc<T> createFrozenListBloc(F filter) {
    return FirestoreFrozenLazyLoadBloc(
      onError: onError,
      pageSize: filter.pageSize,
      query: createQueryBuilder(filter).query,
    );
  }

  String get defaultCollectionName;

  CollectionReference<Map<String, dynamic>> get defaultCollectionReference =>
      FirebaseFirestore.instance.collection(defaultCollectionName);
}
