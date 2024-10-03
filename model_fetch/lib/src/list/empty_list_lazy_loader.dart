import '../loader_factory.dart';
import 'loader.dart';

@Deprecated('Renamed to EmptyListLazyLoader')
typedef EmptyLazyLoadBloc<T> = EmptyListLazyLoader<T>;

/// A dummy [ListLazyLoader] that is always empty.
///
/// Use it in custom [LoaderFactory] classes if you don't want to throw
/// UnimplementedError.
class EmptyListLazyLoader<T> extends ListLazyLoader<T> {
  @override
  List<T> get items => const [];

  @override
  Future<void> loadAll() async {}

  @override
  Future<bool> loadMore() async => false;

  @override
  Future<void> clearItems() async {
    // No-op.
  }
}
