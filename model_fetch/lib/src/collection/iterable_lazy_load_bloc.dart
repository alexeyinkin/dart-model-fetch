import '../load_status.dart';
import 'collection_bloc.dart';
import 'lazy_load_bloc.dart';

/// A [LazyLoadBloc] that feeds from [iterable] synchronously in chunks
/// of [pageSize].
///
/// Good for mocks, local synchronous file system reads, etc.
class IterableLazyLoadBloc<T> extends LazyLoadBloc<T> {
  final Iterable<T> iterable;
  final int pageSize;

  bool _hasMore = true;
  final _items = <T>[];
  LoadStatus _loadStatus = LoadStatus.notTried;
  late Iterator<T> _iterator = iterable.iterator;

  IterableLazyLoadBloc({
    required this.iterable,
    this.pageSize = 1,
  });

  @override
  CollectionState<T> createState() {
    return CollectionState(
      items: _items,
      hasMore: _hasMore,
      status: _loadStatus,
    );
  }

  @override
  Future<void> loadAllIfCan() async {
    while (_iterator.moveNext()) {
      _items.add(_iterator.current);
    }
    _hasMore = false;
    _loadStatus = LoadStatus.ok;
    pushOutput();
  }

  @override
  Future<void> loadMoreIfCan() async {
    for (int i = pageSize; --i >= 0;) {
      if (!_iterator.moveNext()) {
        _hasMore = false;
        break;
      }

      _items.add(_iterator.current);
    }
    _loadStatus = LoadStatus.ok;
    pushOutput();
  }

  @override
  Future<void> clear() async {
    _items.clear();
    _hasMore = true;
    _loadStatus = LoadStatus.notTried;
    _iterator = iterable.iterator;
  }
}
