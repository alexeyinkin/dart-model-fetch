import '../load_status.dart';
import '../loader_factory.dart';
import 'collection_bloc.dart';
import 'lazy_load_bloc.dart';

/// A dummy [LazyLoadBloc] that is always empty.
///
/// Use it in custom [LoaderFactory] classes if you don't want to throw
/// UnimplementedError.
class EmptyLazyLoadBloc<T> extends LazyLoadBloc<T> {
  bool _tried = false;

  @override
  CollectionState<T> createState() => CollectionState(
        items: [],
        hasMore: !_tried,
        status: _tried ? LoadStatus.ok : LoadStatus.notTried,
      );

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
