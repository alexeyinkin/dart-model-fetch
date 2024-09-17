import 'list_loader.dart';

@Deprecated('Renamed to ListLazyLoader')
typedef LazyLoadBloc<T> = ListLazyLoader<T>;

abstract class ListLazyLoader<T> extends ListLoader<T> {
  ListLazyLoader({
    super.clientFilters = const [],
    super.onError,
    super.totalLimit,
  });

  Future<void> loadAllIfCan();

  Future<void> loadMoreIfCan();
}
