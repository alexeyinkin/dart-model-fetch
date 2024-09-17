// ignore_for_file: deprecated_member_use_from_same_package

import 'package:model_interfaces/model_interfaces.dart';

import '../load_status.dart';
import 'model_loader_by_id.dart';

typedef FixedModelByIdBloc<I, T extends WithId<I>> = FixedModelLoaderById<I, T>;

/// A [ModelLoaderById] that contains a fixed model.
///
/// Good for mocks, local synchronous file system reads, etc.
class FixedModelLoaderById<
    I,
    T extends WithId<I>
//
    > extends ModelLoaderById<I, T> {
  final T Function() _getter;

  @override
  T model;

  @override
  LoadStatus get status => LoadStatus.ok;

  factory FixedModelLoaderById({
    required T Function() getter,
  }) {
    final model = getter();
    return FixedModelLoaderById._(
      getter: getter,
      model: model,
    );
  }

  FixedModelLoaderById._({
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
  Future<T> get() async => model;

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
