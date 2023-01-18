import 'package:meta/meta.dart';
import 'package:model_interfaces/model_interfaces.dart';
import 'package:rxdart/rxdart.dart';

import '../load_status.dart';

abstract class ModelByFilterBloc<I, T extends WithId<String>> {
  final I query;

  final _statesController = BehaviorSubject<ModelByFilterState<I, T>>();

  Stream<ModelByFilterState<I, T>> get states => _statesController.stream;

  ModelByFilterState<I, T> _state;

  ModelByFilterBloc({
    required this.query,
  }) : _state = ModelByFilterState(
          model: null,
          status: LoadStatus.notTried,
        );

  @protected
  void emitStateIfChanged(ModelByFilterState<I, T> state) {
    if (state.status == LoadStatus.ok) {
      if (state.model == _state.model) return;
      emitState(state);
      return;
    }

    if (state.status != _state.status) {
      emitState(state);
      return;
    }
  }

  @protected
  void emitState(ModelByFilterState<I, T> state) {
    _statesController.add(state);
    _state = state;
  }

  Future<void> dispose() async {
    await _statesController.close();
  }
}

class ModelByFilterState<I, T extends WithId<String>> {
  final T? model;
  final LoadStatus status;

  ModelByFilterState({
    required this.model,
    required this.status,
  });
}
