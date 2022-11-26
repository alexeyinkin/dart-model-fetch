import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../abstract_client_filter.dart';
import '../load_status.dart';

abstract class CollectionBloc<T> {
  final _statesController = BehaviorSubject<CollectionState<T>>();

  Stream<CollectionState<T>> get states => _statesController.stream;

  final int? totalLimit;
  final List<AbstractClientFilter<T>> clientFilters;

  final initialState = CollectionState<T>(
    items: [],
    hasMore: true,
    status: LoadStatus.notTried,
  );

  CollectionBloc({
    this.totalLimit,
    this.clientFilters = const [],
  });

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

  CollectionState<T> createState();

  @mustCallSuper
  Future<void> dispose() async {
    await _statesController.close();
  }
}

class CollectionState<T> {
  final List<T> items;
  final bool hasMore;
  final LoadStatus status;

  bool get isTried => status != LoadStatus.notTried;

  CollectionState({
    required this.items,
    required this.hasMore,
    required this.status,
  });
}
