// ignore_for_file: deprecated_member_use_from_same_package

import 'package:meta/meta.dart';
import 'package:model_interfaces/model_interfaces.dart';
import 'package:rxdart/rxdart.dart';

import '../interfaces/async_disposable.dart';
import '../load_status.dart';

@Deprecated('Renamed to ModelLoaderById')
typedef ModelByIdBloc<I, T extends WithId<I>> = ModelLoaderById<I, T>;

abstract class ModelLoaderById<
    I,
    T extends WithId<I>
//
    > implements AsyncDisposable {
  final I id;

  final _statesController = BehaviorSubject<ModelByIdState<I, T>>();

  @Deprecated('Use model and status directly.')
  Stream<ModelByIdState<I, T>> get states => _statesController.stream;

  ModelByIdState<I, T> _state;

  ModelLoaderById({
    required this.id,
  }) : _state = ModelByIdState(
          model: null,
          status: LoadStatus.notTried,
        );

  T? get model;

  LoadStatus get status;

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

  /// Loads the model if it is not loaded yet, and returns it or null on error.
  Future<T?> get();

  void reload();
}

@Deprecated('Use model and status directly from the loader.')
class ModelByIdState<I, T extends WithId<I>> {
  final T? model;
  final LoadStatus status;

  @Deprecated('Use model and status directly from the loader.')
  ModelByIdState({
    required this.model,
    required this.status,
  });
}
