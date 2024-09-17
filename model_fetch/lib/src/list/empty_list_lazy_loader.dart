import '../load_status.dart';
import '../loader_factory.dart';
import 'list_lazy_loader.dart';

@Deprecated('Renamed to EmptyListLazyLoader')
typedef EmptyLazyLoadBloc<T> = EmptyListLazyLoader<T>;

/// A dummy [ListLazyLoader] that is always empty.
///
/// Use it in custom [LoaderFactory] classes if you don't want to throw
/// UnimplementedError.
class EmptyListLazyLoader<T> extends ListLazyLoader<T> {
  bool _tried = false;

  @override
  List<T> get items => const [];

  @override
  bool get hasMore => !_tried;

  @override
  LoadStatus get status => _tried ? LoadStatus.ok : LoadStatus.notTried;

  @override
  Future<void> loadAllIfCan() async {
    _tried = true;
    pushOutput();
  }

  @override
  Future<void> loadMoreIfCan() async {
    _tried = true;
    pushOutput();
  }

  @override
  Future<void> clear() async {
    // No-op.
  }
}
