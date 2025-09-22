import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_list_lazy_loader.dart';

@Deprecated('Renamed to FirestoreFrozenListLazyLoader')
typedef FirestoreFrozenLazyLoadBloc<T> = FirestoreFrozenListLazyLoader<T>;

class FirestoreFrozenListLazyLoader<T> extends FirestoreListLazyLoader<T> {
  final GetOptions? options;
  final int pageSize;

  @override
  final items = <T>[];

  FirestoreFrozenListLazyLoader({
    required this.pageSize,
    required super.query,
    super.clientFilters,
    super.onError,
    super.totalLimit,
    this.options,
  });

  @override
  Future<void> loadAll() async {
    final snapshot = await getStartAtQuery().get(options);
    await _addQuerySnapshotToList(snapshot);
  }

  @override
  Future<bool> loadMore() async {
    final snapshot = await getStartAtQuery().limit(pageSize).get(options);
    await _addQuerySnapshotToList(snapshot);
    setLastDocument(snapshot.docs.lastOrNull);

    final hasMore = _hasMoreAfterSnapshot(snapshot);
    return hasMore;
  }

  bool _hasMoreAfterSnapshot(QuerySnapshot snapshot) {
    if (snapshot.docs.length < pageSize) {
      return false;
    }

    if (totalLimit != null && items.length >= totalLimit!) {
      // TODO(alexeyinkin): Remove excess over the limit, https://github.com/alexeyinkin/dart-model-fetch/issues/1
      return false;
    }

    return true;
  }

  Future<void> _addQuerySnapshotToList(
    QuerySnapshot<Future<T>> snapshot,
  ) async {
    if (snapshot.docs.isEmpty) {
      return;
    }

    items.addAll(await Future.wait(snapshot.docs.map((doc) => doc.data())));
  }

  @override
  Future<void> clearItems() async {
    items.clear();
    setLastDocument(null);
  }
}
