// ignore_for_file: deprecated_member_use_from_same_package

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../abstract_client_filter.dart';
import '../interfaces/async_disposable.dart';
import '../load_status.dart';
import '../util.dart';

@Deprecated('Renamed to ListLoader')
typedef CollectionBloc<T> = ListLoader<T>;

/// A local representation of a possibly larger list.
abstract class ListLoader<T> implements AsyncDisposable {
  final _statesController = BehaviorSubject<CollectionState<T>>();

  @Deprecated('Use items, hasMore, and status directly.')
  Stream<CollectionState<T>> get states => _statesController.stream;

  @Deprecated('Use items, hasMore, and status directly.')
  CollectionState<T> get currentState =>
      _statesController.valueOrNull ?? initialState;

  final ErrorCallback? _onError;

  final int? totalLimit;
  final List<AbstractClientFilter<T>> clientFilters;

  final initialState = CollectionState<T>(
    items: [],
    hasMore: true,
    status: LoadStatus.notTried,
  );

  ListLoader({
    this.clientFilters = const [],
    ErrorCallback? onError,
    this.totalLimit,
  }) : _onError = onError;

  bool get hasMore;

  List<T> get items;

  LoadStatus get status;

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

  void onError(Object error, StackTrace trace) {
    (_onError ?? _defaultOnError)(error, trace);
  }

  void _defaultOnError(Object error, StackTrace trace) {
    print(error); // ignore: avoid_print
    print(trace); // ignore: avoid_print
  }

  @override
  @mustCallSuper
  Future<void> dispose() async {
    await _statesController.close();
  }

  /// Clears the local state and makes the loader reload the data when
  /// asked for.
  Future<void> clear();
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
