import '../load_status.dart';
import 'list_lazy_loader.dart';

@Deprecated('Renamed to IterableLazyLoader')
typedef IterableLazyLoadBloc<T> = IterableLazyLoader<T>;

/// A [ListLazyLoader] that feeds from [iterable] synchronously in chunks
/// of [pageSize].
///
/// Good for mocks, local synchronous file system reads, etc.
class IterableLazyLoader<T> extends ListLazyLoader<T> {
  final Iterable<T> iterable;
  final int pageSize;

  @override
  bool get hasMore => _hasMore;

  bool _hasMore = true;

  @override
  final items = <T>[];

  @override
  LoadStatus get status => _loadStatus;
  LoadStatus _loadStatus = LoadStatus.notTried;

  late Iterator<T> _iterator = iterable.iterator;

  IterableLazyLoader({
    required this.iterable,
    this.pageSize = 1,
  });

  @override
  Future<void> loadAllIfCan() async {
    while (_iterator.moveNext()) {
      items.add(_iterator.current);
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

      items.add(_iterator.current);
    }
    _loadStatus = LoadStatus.ok;
    pushOutput();
  }

  @override
  Future<void> clear() async {
    items.clear();
    _hasMore = true;
    _loadStatus = LoadStatus.notTried;
    _iterator = iterable.iterator;
  }
}
