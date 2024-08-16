import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:model_fetch/model_fetch.dart';

import 'firestore_lazy_load_bloc.dart';

class FirestoreFrozenLazyLoadBloc<T> extends FirestoreLazyLoadBloc<T> {
  final int pageSize;
  final _objects = <T>[];
  bool _hasMore = true;
  LoadStatus _status = LoadStatus.notTried;

  bool get hasMore => _hasMore;

  LoadStatus get status => _status;

  FirestoreFrozenLazyLoadBloc({
    required this.pageSize,
    required super.query,
    super.clientFilters,
    super.onError,
    super.totalLimit,
  });

  @override
  Future<void> loadAllIfCan() async {
    if (_status == LoadStatus.loading) return;
    if (_hasMore) return _pushLoadingAndLoadAll();
  }

  Future<void> _pushLoadingAndLoadAll() async {
    _status = LoadStatus.loading;
    pushOutput();
    await _loadAll();
  }

  Future<void> _loadAll() async {
    _status = LoadStatus.loading;
    try {
      final snapshot = await getStartAtQuery().get();
      await _addQuerySnapshotToList(snapshot);

      _hasMore = false;
      _status = LoadStatus.ok;
      pushOutput();

      // ignore: avoid_catches_without_on_clauses
    } catch (error, trace) {
      onError(error, trace);
      _setErrorState();
    }
  }

  @override
  Future<void> loadMoreIfCan() async {
    if (_status == LoadStatus.loading) return;
    if (_hasMore) return _pushLoadingAndLoadMore();
  }

  Future<void> _pushLoadingAndLoadMore() async {
    _status = LoadStatus.loading;
    pushOutput();
    await _loadMore();
  }

  Future<void> _loadMore() async {
    _status = LoadStatus.loading;
    try {
      final snapshot = await getStartAtQuery().limit(pageSize).get();
      await _addQuerySnapshotToList(snapshot);

      if (snapshot.docs.length < pageSize) _hasMore = false;
      _status = LoadStatus.ok;
      pushOutput();

      // ignore: avoid_catches_without_on_clauses
    } catch (error, trace) {
      onError(error, trace);
      _setErrorState();
    }
  }

  Future<void> _addQuerySnapshotToList(
    QuerySnapshot<Future<T>> snapshot,
  ) async {
    if (snapshot.docs.isEmpty) {
      _hasMore = false;
      return;
    }

    _objects.addAll(await Future.wait(snapshot.docs.map((doc) => doc.data())));

    if (totalLimit != null && _objects.length >= totalLimit!) {
      // TODO(alexeyinkin): Remove excess over the limit, https://github.com/alexeyinkin/dart-model-fetch/issues/1
      _hasMore = false;
      return;
    }

    setLastDocument(snapshot.docs.last);
  }

  void _setErrorState() {
    _hasMore = false;
    _status = LoadStatus.error;
    pushOutput();
  }

  @override
  CollectionState<T> createState() {
    return CollectionState<T>(
      items: _objects,
      hasMore: _hasMore,
      status: _status,
    );
  }

  Future<void> clearAndLoadFirstPage() async {
    if (_status == LoadStatus.loading) return;

    _objects.clear();
    _hasMore = true;
    _status = LoadStatus.notTried;
    setLastDocument(null);
    pushOutput();
    await _loadMore();
  }

  Future<void> backgroundReloadFirstPage() async {
    if (_status == LoadStatus.loading) return;

    _objects.clear();
    _hasMore = true;
    _status = LoadStatus.notTried;
    setLastDocument(null);
    await _loadMore();
  }
}
