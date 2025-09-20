// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../abstract_client_filter.dart';
import '../interfaces/async_disposable.dart';
import '../load_status.dart';
import '../util.dart';

@Deprecated('Renamed to ListLoader')
typedef CollectionBloc<T> = ListLoader<T>;

@Deprecated('Renamed to ListLazyLoader')
typedef LazyLoadBloc<T> = ListLazyLoader<T>;

/// The base class for collection loaders.
// TODO: Make the base class for single-item loaders too?
abstract class Loader {
  Completer<void>? _currentCallCompleter;
  bool _hasMore = true;
  LoadStatus _status = LoadStatus.notTried;
  final ErrorCallback? _onError;

  Loader({
    ErrorCallback? onError,
  }) : _onError = onError;

  bool get hasMore => _hasMore;

  LoadStatus get status => _status;

  @Deprecated('Use the state fields directly.')
  Stream get states;

  Future<void> loadAllIfCan() async {
    await _acquireLoadingLockIfHasMore(shouldNotifyListeners: true);

    if (_hasMore) {
      try {
        await loadAll();

        _hasMore = false;
        _releaseLoadingLock();
        _notifyListeners();

        // ignore: avoid_catches_without_on_clauses
      } catch (error, trace) {
        _setErrorStateAndReleaseLoadingLock(error, trace);
      }
    }
  }

  /// Returns when this thread is ready to call a loading method
  /// or nothing is left to load.
  Future<void> _acquireLoadingLockIfHasMore({
    required bool shouldNotifyListeners,
  }) async {
    while (_hasMore) {
      if (_currentCallCompleter == null) {
        _currentCallCompleter = Completer<void>();
        _status = LoadStatus.loading;

        if (shouldNotifyListeners) {
          _notifyListeners();
        }

        return;
      }

      await _currentCallCompleter!.future;
    }
  }

  void _releaseLoadingLock() {
    _status = LoadStatus.ok;
    _currentCallCompleter!.complete();
    _currentCallCompleter = null;
  }

  @protected
  Future<void> loadAll();

  void _setErrorStateAndReleaseLoadingLock(Object error, StackTrace trace) {
    onError(error, trace);
    _hasMore = true;
    _status = LoadStatus.error;
    _currentCallCompleter!.completeError(error, trace);
    _currentCallCompleter = null;
    _notifyListeners();
  }

  void onError(Object error, StackTrace trace) {
    (_onError ?? _defaultOnError)(error, trace);
  }

  void _defaultOnError(Object error, StackTrace trace) {
    print(error); // ignore: avoid_print
    print(trace); // ignore: avoid_print
  }

  void _notifyListeners() => pushOutput();

  @internal

  /// Called when the state changes. For most custom loaders,
  /// use [LoaderStreamMixin] instead of implementing this.
  void pushOutput();

  /// Clears the local state and makes this loader reload the data when
  /// asked for.
  Future<void> clear({bool shouldNotifyListeners = true}) async {
    if (_status == LoadStatus.loading) {
      // TODO(alexeyinkin): Kill the operation in progress, https://github.com/alexeyinkin/dart-model-fetch/issues/6.
      return;
    }

    await clearItems();
    _hasMore = true;
    _status = LoadStatus.notTried;

    if (shouldNotifyListeners) {
      _notifyListeners();
    }
  }

  Future<void> clearItems();

  Future<void> retryAll() async {
    if (_status != LoadStatus.error) {
      return;
    }

    _hasMore = true;
    return loadAllIfCan();
  }
}

/// A local representation of a possibly larger list.
abstract class ListLoader<T> extends Loader implements AsyncDisposable {
  final _statesController = BehaviorSubject<CollectionState<T>>();

  @override
  @Deprecated('Use items, hasMore, and status directly.')
  Stream<CollectionState<T>> get states => _statesController.stream;

  @Deprecated('Use items, hasMore, and status directly.')
  CollectionState<T> get currentState =>
      _statesController.valueOrNull ?? initialState;

  final int? totalLimit;
  final List<AbstractClientFilter<T>> clientFilters;

  final initialState = CollectionState<T>(
    items: [],
    hasMore: true,
    status: LoadStatus.notTried,
  );

  ListLoader({
    super.onError,
    this.clientFilters = const [],
    this.totalLimit,
  });

  List<T> get items;

  @override
  void pushOutput() {
    if (_statesController.isClosed) return;
    _statesController.add(_createStateBase());
  }

  CollectionState<T> _createStateBase() {
    CollectionState<T> state = createState();

    if (totalLimit != null && state.items.length >= totalLimit!) {
      state = CollectionState<T>(
        items: state.items.sublist(0, totalLimit),
        hasMore: false,
        status: state.status,
      );
    }

    for (final clientFilter in clientFilters) {
      state = clientFilter.filter(state);
    }

    return state;
  }

  @nonVirtual
  @Deprecated('Use items, hasMore, and status directly.')
  CollectionState<T> createState() => CollectionState(
        hasMore: hasMore,
        items: items,
        status: status,
      );

  @override
  @mustCallSuper
  Future<void> dispose() async {
    await _statesController.close();
  }
}

abstract class ListLazyLoader<T> extends ListLoader<T> {
  ListLazyLoader({
    super.clientFilters = const [],
    super.onError,
    super.totalLimit,
  });

  Future<void> loadMoreIfCan({bool shouldNotifyListenersOnStart = true}) async {
    await _acquireLoadingLockIfHasMore(
      shouldNotifyListeners: shouldNotifyListenersOnStart,
    );

    if (_hasMore) {
      try {
        _hasMore = await loadMore();
        _releaseLoadingLock();
        _notifyListeners();

        // ignore: avoid_catches_without_on_clauses
      } catch (error, trace) {
        _setErrorStateAndReleaseLoadingLock(error, trace);
      }
    }
  }

  /// Loads the next batch. Must return whether there is more to load.
  @protected
  Future<bool> loadMore();

  Future<void> clearAndLoadFirstPage() async {
    await clear();
    await loadMoreIfCan();
  }

  Future<void> backgroundReloadFirstPage() async {
    await clear(shouldNotifyListeners: false);
    await loadMoreIfCan(shouldNotifyListenersOnStart: false);
  }

  Future<void> retryMore() async {
    if (_status != LoadStatus.error) {
      return;
    }

    _hasMore = true;
    return loadMoreIfCan();
  }
}

class CompoundLoader extends Loader with LoaderStreamMixin {
  final List<Loader> loaders;

  bool _ignoreEvents = false;

  CompoundLoader(this.loaders) {
    for (final loader in loaders) {
      loader.states.listen((_) {
        _onLoaderChanged(loader);
      });
    }
  }

  void _onLoaderChanged(Loader loader) {
    if (_ignoreEvents) {
      return;
    }

    final newHasMore = _mergeHasMore();
    final newStatus = _mergeStatuses();

    if (newHasMore == _hasMore && newStatus == _status) {
      return;
    }

    _hasMore = newHasMore;
    _status = newStatus;
    _notifyListeners();
  }

  bool _mergeHasMore() {
    for (final loader in loaders) {
      if (loader.hasMore) {
        return true;
      }
    }

    return false;
  }

  LoadStatus _mergeStatuses() {
    const priorities = [
      LoadStatus.error,
      LoadStatus.loading,
      LoadStatus.notTried,
    ];
    return getHighestPriorityValue(
          loaders.map((l) => l.status),
          priorities: priorities,
        ) ??
        LoadStatus.ok;
  }

  @override
  Future<void> clearItems() async {
    _ignoreEvents = true;

    try {
      await Future.wait(loaders.map((l) => l.clear()));
    } finally {
      _ignoreEvents = false;
    }
  }

  @override
  Future<void> loadAll() async {
    _ignoreEvents = true;

    try {
      await Future.wait(loaders.map((l) => l.loadAllIfCan()));
    } finally {
      _ignoreEvents = false;
    }
  }
}

mixin LoaderStreamMixin on Loader {
  final _statesController = BehaviorSubject();

  @override
  Stream get states => _statesController.stream;

  @override
  void pushOutput() {
    if (_statesController.isClosed) return;
    _statesController.add(null);
  }
}

@Deprecated('Use items, hasMore, and status directly from the loader.')
class CollectionState<T> {
  final List<T> items;
  final bool hasMore;
  final LoadStatus status;

  bool get isTried => status != LoadStatus.notTried;

  @Deprecated('Use items, hasMore, and status directly from the loader.')
  CollectionState({
    required this.items,
    required this.hasMore,
    required this.status,
  });
}
