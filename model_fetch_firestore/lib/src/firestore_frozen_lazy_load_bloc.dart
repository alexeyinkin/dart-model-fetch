import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:model_fetch/model_fetch.dart';
import 'firestore_lazy_load_bloc.dart';

class FirestoreFrozenLazyLoadBloc<T> extends FirestoreLazyLoadBloc<T> {
  final int fetchSize;
  final _objects = <T>[];
  var _hasMore = true;
  var _status = LazyLoadStatus.notTried;

  bool get hasMore => _hasMore;
  LazyLoadStatus get status => _status;

  FirestoreFrozenLazyLoadBloc({
    required Query<T> query,
    required this.fetchSize,
    int? totalLimit,
    List<AbstractClientFilter<T>> clientFilters = const [],
  }) :
      super(
        query: query,
        totalLimit: totalLimit,
        clientFilters: clientFilters,
      )
  ;

  Future<void> loadMoreIfCan() async {
    if (_status == LazyLoadStatus.loading) return;
    if (_hasMore) return _pushLoadingAndLoadMore();
  }

  Future<void> _pushLoadingAndLoadMore() async {
    _status = LazyLoadStatus.loading;
    pushOutput();
    await _loadMore();
  }

  Future<void> _loadMore() async {
    _status = LazyLoadStatus.loading;
    try {
      final snapshot = await getStartAtQuery()
          .limit(fetchSize)
          .get();
      _addQuerySnapshotToList(snapshot);

      if (snapshot.docs.length < fetchSize) _hasMore = false;
      _status = LazyLoadStatus.ok;
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
    _status = LazyLoadStatus.error;
    pushOutput();
  }

  @override
  LazyLoadState<T> createState() {
    return LazyLoadState<T>(
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
    if (_status == LazyLoadStatus.loading) return;

    _objects.clear();
    _hasMore = true;
    _status = LazyLoadStatus.notTried;
    setLastDocument(null);
    _loadMore();
  }
}
