import 'package:model_interfaces/model_interfaces.dart';

import 'abstract_filter.dart';
import 'collection/lazy_load_bloc.dart';
import 'interfaces/async_disposable.dart';
import 'model_by_filter/model_by_filter_bloc.dart';
import 'model_by_id/model_by_id_bloc.dart';

/// A factory that produces loaders from different filters.
///
/// [I] is the type of ID.
/// [T] is the type of the entities.
/// [F] is the type of the filter used on the collection.
abstract class LoaderFactory<
    I,
    T extends WithId<I>,
    F extends AbstractFilter
//
    > {
  final _liveByIdBlocs = <I, ModelByIdBloc<I, T>>{};
  final _frozenByIdBlocs = <I, ModelByIdBloc<I, T>>{};
  final _liveModelByFilterBlocs = <F, ModelByFilterBloc<I, T>>{};
  final _frozenModelByFilterBlocs = <F, ModelByFilterBloc<I, T>>{};
  final _liveLazyLoadBlocs = <F, LazyLoadBloc<T>>{};
  final _frozenLazyLoadBlocs = <F, LazyLoadBloc<T>>{};

  /// Returns a loader for a single object by [id] that is self-updated
  /// when the data changes at the origin.
  ///
  /// The loader is cached for future calls with the same ID.
  ModelByIdBloc<I, T> liveByIdBloc(I id) {
    final existing = _liveByIdBlocs[id];
    if (existing != null) {
      return existing;
    }

    final result = createLiveByIdBloc(id);
    _liveByIdBlocs[id] = result;
    return result;
  }

  /// Creates a loader for a single object by [id] that is self-updated
  /// when the data changes at the origin.
  ModelByIdBloc<I, T> createLiveByIdBloc(I id);

  /// Returns a loader for a single object by [id] that is not self-updated
  /// when the data changes at the origin.
  ///
  /// The loader is cached for future calls with the same ID.
  ModelByIdBloc<I, T> frozenByIdBloc(I id) {
    final existing = _frozenByIdBlocs[id];
    if (existing != null) {
      return existing;
    }

    final result = createFrozenByIdBloc(id);
    _frozenByIdBlocs[id] = result;
    return result;
  }

  /// Creates a loader for a single object by [id] that is not self-updated
  /// when the data changes at the origin.
  ModelByIdBloc<I, T> createFrozenByIdBloc(I id);

  /// Returns a loader for a single object by [id].
  /// Returns a self-updated bloc if possible, or a frozen one otherwise.
  ModelByIdBloc<I, T> byIdBloc(I id) {
    try {
      return liveByIdBloc(id);
      // ignore: avoid_catching_errors
    } on UnimplementedError {
      return frozenByIdBloc(id);
    }
  }

  /// Returns a loader for a single object by [filter] that is self-updated
  /// when the data changes at the origin.
  ///
  /// The loader is cached for future calls with the same ID.
  ModelByFilterBloc<I, T> liveModelByFilterBloc(F filter) {
    final existing = _liveModelByFilterBlocs[filter];
    if (existing != null) {
      return existing;
    }

    final result = createLiveModelByFilterBloc(filter);
    _liveModelByFilterBlocs[filter] = result;
    return result;
  }

  /// Creates a loader for a single object by [filter] that is self-updated
  /// when the data changes at the origin.
  ModelByFilterBloc<I, T> createLiveModelByFilterBloc(F filter);

  /// Returns a loader for a single object by [filter] that is not self-updated
  /// when the data changes at the origin.
  ///
  /// The loader is cached for future calls with the same ID.
  ModelByFilterBloc<I, T> frozenModelByFilterBloc(F filter) {
    final existing = _frozenModelByFilterBlocs[filter];
    if (existing != null) {
      return existing;
    }

    final result = createFrozenModelByFilterBloc(filter);
    _frozenModelByFilterBlocs[filter] = result;
    return result;
  }

  /// Creates a loader for a single object by [filter] that is not self-updated
  /// when the data changes at the origin.
  ModelByFilterBloc<I, T> createFrozenModelByFilterBloc(F filter);

  /// Returns a loader for a single object by [filter].
  /// Returns a self-updated bloc if possible, or a frozen one otherwise.
  ModelByFilterBloc<I, T> modelByFilterBloc(F filter) {
    try {
      return liveModelByFilterBloc(filter);
      // ignore: avoid_catching_errors
    } on UnimplementedError {
      return frozenModelByFilterBloc(filter);
    }
  }

  /// Creates a lazy loader for the objects matching the [filter]
  /// that is self-updated when the data changes at the origin.
  ///
  /// The loader is cached for future calls with the same [filter].
  LazyLoadBloc<T> liveListBloc(F filter) {
    final existing = _liveLazyLoadBlocs[filter];
    if (existing != null) {
      return existing;
    }

    final result = createLiveListBloc(filter);
    _liveLazyLoadBlocs[filter] = result;
    return result;
  }

  /// Creates a lazy loader for the objects matching the [filter]
  /// that is self-updated when the data changes at the origin.
  LazyLoadBloc<T> createLiveListBloc(F filter);

  /// Creates a lazy loader for the objects matching the [filter]
  /// that is not self-updated when the data changes at the origin.
  ///
  /// The loader is cached for future calls with the same [filter].
  LazyLoadBloc<T> frozenListBloc(F filter) {
    final existing = _frozenLazyLoadBlocs[filter];
    if (existing != null) {
      return existing;
    }

    final result = createFrozenListBloc(filter);
    _frozenLazyLoadBlocs[filter] = result;
    return result;
  }

  /// Creates a lazy loader for the objects matching the [filter]
  /// that is not self-updated when the data changes at the origin.
  LazyLoadBloc<T> createFrozenListBloc(F filter);

  /// Returns a lazy loader for the objects matching the [filter].
  /// Returns a self-updated bloc if possible, or a frozen one otherwise.
  LazyLoadBloc<T> listBloc(F filter) {
    try {
      return liveListBloc(filter);
      // ignore: avoid_catching_errors
    } on UnimplementedError {
      return frozenListBloc(filter);
    }
  }

  /// Deletes all loaders.
  Future<void> clear() async {
    await Future.wait([
      _clearLiveByIdBlocs(),
      _clearFrozenByIdBlocs(),
      _clearLiveModelByFilterBlocs(),
      _clearFrozenModelByFilterBlocs(),
      _clearLiveLazyLoadBlocs(),
      _clearFrozenLazyLoadBlocs(),
    ]);
  }

  Future<void> _clearLiveByIdBlocs() async {
    await _clearBlocs(_liveByIdBlocs);
  }

  Future<void> _clearFrozenByIdBlocs() async {
    await _clearBlocs(_frozenByIdBlocs);
  }

  Future<void> _clearLiveModelByFilterBlocs() async {
    await _clearBlocs(_liveModelByFilterBlocs);
  }

  Future<void> _clearFrozenModelByFilterBlocs() async {
    await _clearBlocs(_frozenModelByFilterBlocs);
  }

  Future<void> _clearLiveLazyLoadBlocs() async {
    await _clearBlocs(_liveLazyLoadBlocs);
  }

  Future<void> _clearFrozenLazyLoadBlocs() async {
    await _clearBlocs(_frozenLazyLoadBlocs);
  }

  Future<void> _clearBlocs(Map<Object?, AsyncDisposable> map) async {
    await Future.wait(
      map.values.map((bloc) => bloc.dispose()),
    );
    map.clear();
  }
}
