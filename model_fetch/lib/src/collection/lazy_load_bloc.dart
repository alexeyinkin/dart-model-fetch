import 'collection_bloc.dart';

abstract class LazyLoadBloc<T> extends CollectionBloc<T> {
  LazyLoadBloc({
    super.totalLimit,
    super.clientFilters = const [],
  });

  Future<void> loadMoreIfCan();
}
