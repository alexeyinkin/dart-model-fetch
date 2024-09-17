import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:model_fetch/model_fetch.dart';

import 'firestore_list_lazy_loader.dart';

@Deprecated('Renamed to FirestoreFrozenListLazyLoader')
typedef FirestoreFrozenLazyLoadBloc<T> = FirestoreFrozenListLazyLoader<T>;

class FirestoreFrozenListLazyLoader<T> extends FirestoreListLazyLoader<T> {
  final int pageSize;
  bool _hasMore = true;
  LoadStatus _status = LoadStatus.notTried;
  Completer<void>? _currentCallCompleter;

  @override
  bool get hasMore => _hasMore;

  @override
  final items = <T>[];

  @override
  LoadStatus get status => _status;

  FirestoreFrozenListLazyLoader({
    required this.pageSize,
    required super.query,
    super.clientFilters,
    super.onError,
    super.totalLimit,
  });

  @override
  Future<void> loadAllIfCan() async {
    await _acquireLoadingLock();

    if (_hasMore) {
      return _loadAll();
    }
  }

  Future<void> _loadAll() async {
    try {
      final snapshot = await getStartAtQuery().get();
      await _addQuerySnapshotToList(snapshot);

      _hasMore = false;
      _status = LoadStatus.ok;
      _currentCallCompleter!.complete();
      _currentCallCompleter = null;
      pushOutput();

      // ignore: avoid_catches_without_on_clauses
    } catch (error, trace) {
      _setErrorState(error, trace);
    }
  }

  @override
  Future<void> loadMoreIfCan() async {
    await _acquireLoadingLock();

    if (_hasMore) {
      return _loadMore();
    }
  }

  Future<void> _loadMore() async {
    _status = LoadStatus.loading;
    try {
      final snapshot = await getStartAtQuery().limit(pageSize).get();
      await _addQuerySnapshotToList(snapshot);

      if (snapshot.docs.length < pageSize) _hasMore = false;
      _status = LoadStatus.ok;
      _currentCallCompleter!.complete();
      _currentCallCompleter = null;
      pushOutput();

      // ignore: avoid_catches_without_on_clauses
    } catch (error, trace) {
      _setErrorState(error, trace);
    }
  }

  Future<void> _addQuerySnapshotToList(
    QuerySnapshot<Future<T>> snapshot,
  ) async {
    if (snapshot.docs.isEmpty) {
      _hasMore = false;
      return;
    }

    items.addAll(await Future.wait(snapshot.docs.map((doc) => doc.data())));

    if (totalLimit != null && items.length >= totalLimit!) {
      // TODO(alexeyinkin): Remove excess over the limit, https://github.com/alexeyinkin/dart-model-fetch/issues/1
      _hasMore = false;
      return;
    }

    setLastDocument(snapshot.docs.last);
  }

  void _setErrorState(Object error, StackTrace trace) {
    onError(error, trace);
    _hasMore = false;
    _status = LoadStatus.error;
    _currentCallCompleter!.completeError(error, trace);
    _currentCallCompleter = null;
    pushOutput();
  }

  Future<void> clearAndLoadFirstPage() async {
    await clear();
    await _loadMore();
  }

  Future<void> backgroundReloadFirstPage() async {
    if (_status == LoadStatus.loading) {
      // TODO(alexeyinkin): Kill the operation in progress, https://github.com/alexeyinkin/dart-model-fetch/issues/6.
      return;
    }

    items.clear();
    _hasMore = true;
    _status = LoadStatus.notTried;
    setLastDocument(null);
    await _loadMore();
  }

  @override
  Future<void> clear() async {
    if (_status == LoadStatus.loading) {
      // TODO(alexeyinkin): Kill the operation in progress, https://github.com/alexeyinkin/dart-model-fetch/issues/6.
      return;
    }

    items.clear();
    _hasMore = true;
    _status = LoadStatus.notTried;
    setLastDocument(null);
    pushOutput();
  }

  /// Returns when this thread is ready to call a loading method
  /// or nothing is left to load.
  Future<void> _acquireLoadingLock() async {
    while (_hasMore) {
      if (_currentCallCompleter != null) {
        await _currentCallCompleter!.future;
      } else {
        _currentCallCompleter = Completer<void>();
        _status = LoadStatus.loading;
        pushOutput();
        return;
      }
    }
  }
}
