import 'loader.dart';

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
  final items = <T>[];

  late Iterator<T> _iterator = iterable.iterator;

  IterableLazyLoader({
    required this.iterable,
    this.pageSize = 1,
  });

  @override
  Future<void> loadAll() async {
    while (_iterator.moveNext()) {
      items.add(_iterator.current);
    }
  }

  @override
  Future<bool> loadMore() async {
    for (int i = pageSize; --i >= 0;) {
      if (!_iterator.moveNext()) {
        return false;
      }

      items.add(_iterator.current);
    }

    return true;
  }

  @override
  Future<void> clearItems() async {
    items.clear();
    _iterator = iterable.iterator;
  }
}
