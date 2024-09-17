// ignore_for_file: deprecated_member_use_from_same_package

import 'package:meta/meta.dart';
import 'package:model_interfaces/model_interfaces.dart';
import 'package:rxdart/rxdart.dart';

import '../interfaces/async_disposable.dart';
import '../load_status.dart';

@Deprecated('Renamed to ModelLoaderByFilter')
typedef ModelByFilterBloc<I, T extends WithId<I>> = ModelLoaderByFilter<I, T>;

abstract class ModelLoaderByFilter<
    I,
    T extends WithId<I>
//
    > implements AsyncDisposable {
  final _statesController = BehaviorSubject<ModelByFilterState<I, T>>();

  @Deprecated('Use model and status directly.')
  Stream<ModelByFilterState<I, T>> get states => _statesController.stream;

  ModelByFilterState<I, T> _state;

  ModelLoaderByFilter()
      : _state = ModelByFilterState(
          model: null,
          status: LoadStatus.notTried,
        );

  T? get model;

  LoadStatus get status;

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

  @override
  @mustCallSuper
  Future<void> dispose() async {
    await _statesController.close();
  }

  void reload();
}

@Deprecated('Use model and status directly from the loader.')
class ModelByFilterState<I, T extends WithId<I>> {
  final T? model;
  final LoadStatus status;

  @Deprecated('Use model and status directly from the loader.')
  ModelByFilterState({
    required this.model,
    required this.status,
  });
}
