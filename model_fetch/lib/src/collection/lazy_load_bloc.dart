import 'collection_bloc.dart';

abstract class LazyLoadBloc<T> extends CollectionBloc<T> {
  LazyLoadBloc({
    super.clientFilters = const [],
    super.onError,
    super.totalLimit,
  });

  Future<void> loadMoreIfCan();
}
