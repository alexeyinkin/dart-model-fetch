import 'package:rxdart/rxdart.dart';

import 'abstract_client_filter.dart';
import 'load_status.dart';

abstract class LazyLoadBloc<T> {
  final _statesController = BehaviorSubject<LazyLoadState<T>>();

  Stream<LazyLoadState<T>> get states => _statesController.stream;

  final initialState = LazyLoadState<T>(
    items: [],
    hasMore: true,
    status: LoadStatus.notTried,
  );

  final int? totalLimit;
  final List<AbstractClientFilter<T>> clientFilters;

  LazyLoadBloc({
    this.totalLimit,
    this.clientFilters = const [],
  });

  Future<void> loadMoreIfCan();

  void pushOutput() {
    if (_statesController.isClosed) return;
    _statesController.add(_createStateBase());
  }

  LazyLoadState<T> _createStateBase() {
    LazyLoadState<T> state = createState();

    if (totalLimit != null && state.items.length >= totalLimit!) {
      state = LazyLoadState<T>(
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

  LazyLoadState<T> createState();

  void dispose() {
    _statesController.close();
  }
}

class LazyLoadState<T> {
  final List<T> items;
  final bool hasMore;
  final LoadStatus status;

  bool get isTried => status != LoadStatus.notTried;

  LazyLoadState({
    required this.items,
    required this.hasMore,
    required this.status,
  });
}
