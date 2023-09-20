import 'package:model_interfaces/model_interfaces.dart';

import '../load_status.dart';
import 'model_by_id_bloc.dart';

/// A [ModelByIdBloc] that contains a fixed model.
///
/// Good for mocks, local synchronous file system reads, etc.
class FixedModelByIdBloc<
    I,
    T extends WithId<I>
//
    > extends ModelByIdBloc<I, T> {
  final T Function() _getter;
  T model;

  factory FixedModelByIdBloc({
    required T Function() getter,
  }) {
    final model = getter();
    return FixedModelByIdBloc._(
      getter: getter,
      model: model,
    );
  }

  FixedModelByIdBloc._({
    required T Function() getter,
    required this.model,
  })  : _getter = getter,
        super(id: model.id) {
    emitState(
      ModelByIdState(
        model: model,
        status: LoadStatus.ok,
      ),
    );
  }

  @override
  void reload() {
    model = _getter();
    emitState(
      ModelByIdState(
        model: model,
        status: LoadStatus.ok,
      ),
    );
  }
}
