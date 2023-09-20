import 'package:meta/meta.dart';
import 'package:model_interfaces/model_interfaces.dart';
import 'package:rxdart/rxdart.dart';

import '../interfaces/async_disposable.dart';
import '../load_status.dart';

abstract class ModelByIdBloc<
    I,
    T extends WithId<I>
//
    > implements AsyncDisposable {
  final I id;

  final _statesController = BehaviorSubject<ModelByIdState<I, T>>();

  Stream<ModelByIdState<I, T>> get states => _statesController.stream;

  ModelByIdState<I, T> _state;

  ModelByIdBloc({
    required this.id,
  }) : _state = ModelByIdState(
          model: null,
          status: LoadStatus.notTried,
        );

  @protected
  void emitStateIfChanged(ModelByIdState<I, T> state) {
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
  void emitState(ModelByIdState<I, T> state) {
    _statesController.add(state);
    _state = state;
  }

  @override
  @mustCallSuper
  Future<void> dispose() async {
    await _statesController.close();
  }

  void reload();
}

class ModelByIdState<I, T extends WithId<I>> {
  final T? model;
  final LoadStatus status;

  ModelByIdState({
    required this.model,
    required this.status,
  });
}
