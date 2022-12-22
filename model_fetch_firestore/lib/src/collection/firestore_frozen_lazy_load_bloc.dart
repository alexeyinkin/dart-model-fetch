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
    required super.onError,
    required this.pageSize,
    required super.query,
    super.clientFilters,
    super.totalLimit,
  });

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
      _addQuerySnapshotToList(snapshot);

      if (snapshot.docs.length < pageSize) _hasMore = false;
      _status = LoadStatus.ok;
      pushOutput();
    } catch (error) {
      onError(error);
      _setErrorState();
    }
  }

  void _addQuerySnapshotToList(QuerySnapshot<T> snapshot) {
    if (snapshot.docs.isEmpty) {
      _hasMore = false;
      return;
    }

    _objects.addAll(snapshot.docs.map((doc) => doc.data()));

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
