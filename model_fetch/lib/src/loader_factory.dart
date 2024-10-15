import 'package:meta/meta.dart';
import 'package:model_interfaces/model_interfaces.dart';

import 'abstract_filter.dart';
import 'interfaces/async_disposable.dart';
import 'list/loader.dart';
import 'model_by_filter/model_loader_by_filter.dart';
import 'model_by_id/model_loader_by_id.dart';

/// A factory that produces loaders from different filters.
///
/// [I] is the type of ID.
/// [T] is the type of the entities.
/// [F] is the type of the filter used on the loaders.
abstract class LoaderFactory<
    I,
    T extends WithId<I>,
    F extends AbstractFilter
//
    > {
  final _liveModelById = <I, ModelLoaderById<I, T>>{};
  final _frozenModelById = <I, ModelLoaderById<I, T>>{};
  final _liveModelByFilter = <F, ModelLoaderByFilter<I, T>>{};
  final _frozenModelByFilter = <F, ModelLoaderByFilter<I, T>>{};
  final _liveListLazyLoaders = <F, ListLazyLoader<T>>{};
  final _frozenListLazyLoaders = <F, ListLazyLoader<T>>{};

  @Deprecated('Renamed to liveModelLoaderById')
  ModelLoaderById<I, T> liveByIdBloc(I id) => liveModelLoaderById(id);

  /// Returns a loader for a single object by [id] that is self-updated
  /// when the data changes at the origin.
  ///
  /// The loader is cached for future calls with the same ID.
  ModelLoaderById<I, T> liveModelLoaderById(I id) {
    final existing = _liveModelById[id];
    if (existing != null) {
      return existing;
    }

    final result = createLiveModelLoaderById(id);
    _liveModelById[id] = result;
    return result;
  }

  @Deprecated('Renamed to createLiveModelLoaderById')
  @nonVirtual
  ModelLoaderById<I, T> createLiveByIdBloc(I id) =>
      createLiveModelLoaderById(id);

  /// Creates a loader for a single object by [id] that is self-updated
  /// when the data changes at the origin.
  ModelLoaderById<I, T> createLiveModelLoaderById(I id);

  @Deprecated('Renamed to frozenModelLoaderById')
  ModelLoaderById<I, T> frozenByIdBloc(I id) => frozenModelLoaderById(id);

  /// Returns a loader for a single object by [id] that is not self-updated
  /// when the data changes at the origin.
  ///
  /// The loader is cached for future calls with the same ID.
  ModelLoaderById<I, T> frozenModelLoaderById(I id) {
    final existing = _frozenModelById[id];
    if (existing != null) {
      return existing;
    }

    final result = createFrozenModelLoaderById(id);
    _frozenModelById[id] = result;
    return result;
  }

  @Deprecated('Renamed to createFrozenModelLoaderById')
  @nonVirtual
  ModelLoaderById<I, T> createFrozenByIdBloc(I id) =>
      createFrozenModelLoaderById(id);

  /// Creates a loader for a single object by [id] that is not self-updated
  /// when the data changes at the origin.
  ModelLoaderById<I, T> createFrozenModelLoaderById(I id);

  @Deprecated('Renamed to modelLoaderById')
  ModelLoaderById<I, T> byIdBloc(I id) => modelLoaderById(id);

  /// Returns a loader for a single object by [id].
  /// Returns a self-updated loader if possible, or a frozen one otherwise.
  ModelLoaderById<I, T> modelLoaderById(I id) {
    try {
      return liveModelLoaderById(id);
      // ignore: avoid_catching_errors
    } on UnimplementedError {
      return frozenModelLoaderById(id);
    }
  }

  @Deprecated('Renamed to liveModelLoaderByFilter')
  ModelLoaderByFilter<I, T> liveModelByFilterBloc(F filter) =>
      liveModelLoaderByFilter(filter);

  /// Returns a loader for a single object by [filter] that is self-updated
  /// when the data changes at the origin.
  ///
  /// The loader is cached for future calls with the same ID.
  ModelLoaderByFilter<I, T> liveModelLoaderByFilter(F filter) {
    final existing = _liveModelByFilter[filter];
    if (existing != null) {
      return existing;
    }

    final result = createLiveModelLoaderByFilter(filter);
    _liveModelByFilter[filter] = result;
    return result;
  }

  @Deprecated('Renamed to createLiveModelLoaderByFilter')
  @nonVirtual
  ModelLoaderByFilter<I, T> createLiveModelByFilterBloc(F filter) =>
      createLiveModelLoaderByFilter(filter);

  /// Creates a loader for a single object by [filter] that is self-updated
  /// when the data changes at the origin.
  ModelLoaderByFilter<I, T> createLiveModelLoaderByFilter(F filter);

  @Deprecated('Renamed to frozenModelLoaderByFilter')
  ModelLoaderByFilter<I, T> frozenModelByFilterBloc(F filter) =>
      frozenModelLoaderByFilter(filter);

  /// Returns a loader for a single object by [filter] that is not self-updated
  /// when the data changes at the origin.
  ///
  /// The loader is cached for future calls with the same ID.
  ModelLoaderByFilter<I, T> frozenModelLoaderByFilter(F filter) {
    final existing = _frozenModelByFilter[filter];
    if (existing != null) {
      return existing;
    }

    final result = createFrozenModelLoaderByFilter(filter);
    _frozenModelByFilter[filter] = result;
    return result;
  }

  @Deprecated('Renamed to createFrozenModelLoaderByFilter')
  @nonVirtual
  ModelLoaderByFilter<I, T> createFrozenModelByFilterBloc(F filter) =>
      createFrozenModelLoaderByFilter(filter);

  /// Creates a loader for a single object by [filter] that is not self-updated
  /// when the data changes at the origin.
  ModelLoaderByFilter<I, T> createFrozenModelLoaderByFilter(F filter);

  @Deprecated('Renamed to modelLoaderByFilter')
  ModelLoaderByFilter<I, T> modelByFilterBloc(F filter) =>
      modelLoaderByFilter(filter);

  /// Returns a loader for a single object by [filter].
  /// Returns a self-updated loader if possible, or a frozen one otherwise.
  ModelLoaderByFilter<I, T> modelLoaderByFilter(F filter) {
    try {
      return liveModelLoaderByFilter(filter);
      // ignore: avoid_catching_errors
    } on UnimplementedError {
      return frozenModelLoaderByFilter(filter);
    }
  }

  @Deprecated('Renamed to liveListLazyLoader')
  ListLazyLoader<T> liveListBloc(F filter) => liveListLazyLoader(filter);

  /// Creates a lazy loader for the objects matching the [filter]
  /// that is self-updated when the data changes at the origin.
  ///
  /// The loader is cached for future calls with the same [filter].
  ListLazyLoader<T> liveListLazyLoader(F filter) {
    final existing = _liveListLazyLoaders[filter];
    if (existing != null) {
      return existing;
    }

    final result = createLiveListLazyLoader(filter);
    _liveListLazyLoaders[filter] = result;
    return result;
  }

  @Deprecated('Renamed to createLiveListLazyLoader')
  @nonVirtual
  ListLazyLoader<T> createLiveListBloc(F filter) =>
      createLiveListLazyLoader(filter);

  /// Creates a lazy loader for the objects matching the [filter]
  /// that is self-updated when the data changes at the origin.
  ListLazyLoader<T> createLiveListLazyLoader(F filter);

  @Deprecated('Renamed to frozenListLazyLoader')
  ListLazyLoader<T> frozenListBloc(F filter) => frozenListLazyLoader(filter);

  /// Creates a lazy loader for the objects matching the [filter]
  /// that is not self-updated when the data changes at the origin.
  ///
  /// The loader is cached for future calls with the same [filter].
  ListLazyLoader<T> frozenListLazyLoader(F filter) {
    final existing = _frozenListLazyLoaders[filter];
    if (existing != null) {
      return existing;
    }

    final result = createFrozenListLazyLoader(filter);
    _frozenListLazyLoaders[filter] = result;
    return result;
  }

  @Deprecated('Renamed to createFrozenListLazyLoader')
  @nonVirtual
  ListLazyLoader<T> createFrozenListBloc(F filter) =>
      createFrozenListLazyLoader(filter);

  /// Creates a lazy loader for the objects matching the [filter]
  /// that is not self-updated when the data changes at the origin.
  ListLazyLoader<T> createFrozenListLazyLoader(F filter);

  @Deprecated('Renamed to listLazyLoader')
  ListLazyLoader<T> listBloc(F filter) => listLazyLoader(filter);

  /// Returns a lazy loader for the objects matching the [filter].
  /// Returns a self-updated loader if possible, or a frozen one otherwise.
  ListLazyLoader<T> listLazyLoader(F filter) {
    try {
      return liveListLazyLoader(filter);
      // ignore: avoid_catching_errors
    } on UnimplementedError {
      return frozenListLazyLoader(filter);
    }
  }

  /// Empties all frozen loaders but not disposes them.
  ///
  /// This causes the list loaders to reload the data when asked for.
  /// Single-object loaders are reloaded immediately
  /// because they are not designed to await a signal to load.
  Future<void> clearFrozenLoaders() async {
    for (final loader in _frozenModelById.values) {
      loader.reload();
    }

    for (final loader in _frozenModelByFilter.values) {
      loader.reload();
    }

    await Future.wait(_frozenListLazyLoaders.values.map((l) => l.clear()));
  }

  /// Deletes all loaders.
  Future<void> clear() async {
    await Future.wait([
      _clearLiveModelByIdLoaders(),
      _clearFrozenModelByIdLoaders(),
      _clearLiveModelByFilterLoaders(),
      _clearFrozenModelByFilterLoaders(),
      _clearLiveListLazyLoaders(),
      _clearFrozenListLazyLoaders(),
    ]);
  }

  Future<void> _clearLiveModelByIdLoaders() async {
    await _clearLoaders(_liveModelById);
  }

  Future<void> _clearFrozenModelByIdLoaders() async {
    await _clearLoaders(_frozenModelById);
  }

  Future<void> _clearLiveModelByFilterLoaders() async {
    await _clearLoaders(_liveModelByFilter);
  }

  Future<void> _clearFrozenModelByFilterLoaders() async {
    await _clearLoaders(_frozenModelByFilter);
  }

  Future<void> _clearLiveListLazyLoaders() async {
    await _clearLoaders(_liveListLazyLoaders);
  }

  Future<void> _clearFrozenListLazyLoaders() async {
    await _clearLoaders(_frozenListLazyLoaders);
  }

  Future<void> _clearLoaders(Map<Object?, AsyncDisposable> map) async {
    await Future.wait(
      map.values.map((loader) => loader.dispose()),
    );
    map.clear();
  }

  /// Prints [error] and [trace].
  void onError(Object error, StackTrace trace) {
    print('Error in $runtimeType: $error'); // ignore: avoid_print
    print(trace); // ignore: avoid_print
  }
}
