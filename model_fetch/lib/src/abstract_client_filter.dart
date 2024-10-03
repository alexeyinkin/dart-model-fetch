import 'list/loader.dart';

// TODO(alexeyinkin): Make FilteredLoader, https://github.com/alexeyinkin/dart-model-fetch/issues/7
@Deprecated(
  'As we are migrating from blocs and operations on states, '
  'this is deprecated. A new API has not yet been designed.',
)
abstract class AbstractClientFilter<T> {
  CollectionState<T> filter(CollectionState<T> state);
}
