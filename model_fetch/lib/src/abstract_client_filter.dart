import 'collection/collection_bloc.dart';

abstract class AbstractClientFilter<T> {
  CollectionState<T> filter(CollectionState<T> state);
}
