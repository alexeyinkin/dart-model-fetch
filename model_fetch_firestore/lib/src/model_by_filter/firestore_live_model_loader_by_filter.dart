import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:model_interfaces/model_interfaces.dart';

import '../util.dart';

@Deprecated('Renamed to FirestoreLiveModelLoaderByFilter')
typedef FirestoreLiveByFilterBloc<T extends WithId<String>>
    = FirestoreLiveModelLoaderByFilter<T>;

class FirestoreLiveModelLoaderByFilter<T extends WithId<String>>
    extends ModelLoaderByFilter<String, T> {
  final ErrorCallback onError;
  final Query<Future<T>> query;

  StreamSubscription? _subscription;

  @override
  T? get model => _model;

  T? _model;

  @override
  LoadStatus get status => _status;

  LoadStatus _status = LoadStatus.notTried;

  FirestoreLiveModelLoaderByFilter({
    required this.onError,
    required this.query,
  }) {
    _subscription =
        query.snapshots().handleError(onError).listen(_onModelChanged);
  }

  Future<void> _onModelChanged(QuerySnapshot<Future<T?>> querySnapshot) async {
    _model = await querySnapshot.docs.firstOrNull?.data();
    _status = _model == null ? LoadStatus.error : LoadStatus.ok;

    emitStateIfChanged(
      // ignore: deprecated_member_use
      ModelByFilterState(
        model: _model,
        status: _status,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    await super.dispose();
  }

  @override
  void reload() {
    // No-op, the model is live.
  }
}
