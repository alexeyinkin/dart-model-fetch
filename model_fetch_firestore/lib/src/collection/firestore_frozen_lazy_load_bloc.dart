import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:model_fetch/model_fetch.dart';

import 'firestore_lazy_load_bloc.dart';

class FirestoreFrozenLazyLoadBloc<T> extends FirestoreLazyLoadBloc<T> {
  final int fetchSize;
  final _objects = <T>[];
  bool _hasMore = true;
  LoadStatus _status = LoadStatus.notTried;

  bool get hasMore => _hasMore;

  LoadStatus get status => _status;

  FirestoreFrozenLazyLoadBloc({
    required Query<T> query,
    required this.fetchSize,
    int? totalLimit,
    List<AbstractClientFilter<T>> clientFilters = const [],
  }) : super(
          query: query,
          totalLimit: totalLimit,
          clientFilters: clientFilters,
        );

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
      final snapshot = await getStartAtQuery().limit(fetchSize).get();
      _addQuerySnapshotToList(snapshot);

      if (snapshot.docs.length < fetchSize) _hasMore = false;
      _status = LoadStatus.ok;
      pushOutput();
    } catch (error) {
      print(error.toString());
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
      // TODO: Remove excess over the limit.
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

  void clearAndLoadFirstPage() {
    backgroundReloadFirstPage();
    pushOutput();
  }

  void backgroundReloadFirstPage() {
    if (_status == LoadStatus.loading) return;

    _objects.clear();
    _hasMore = true;
    _status = LoadStatus.notTried;
    setLastDocument(null);
    _loadMore();
  }
}
