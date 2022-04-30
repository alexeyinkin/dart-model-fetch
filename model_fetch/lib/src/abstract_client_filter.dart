import 'lazy_load_bloc.dart';

abstract class AbstractClientFilter<T> {
  LazyLoadState<T> filter(LazyLoadState<T> state);
}
