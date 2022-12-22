import 'collection_bloc.dart';

abstract class LazyLoadBloc<T> extends CollectionBloc<T> {
  LazyLoadBloc({
    required super.onError,
    super.totalLimit,
    super.clientFilters = const [],
  });

  Future<void> loadMoreIfCan();
}
