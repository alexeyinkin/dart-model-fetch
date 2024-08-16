import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:model_interfaces/model_interfaces.dart';

import '../util.dart';

class FirestoreLiveByFilterBloc<T extends WithId<String>>
    extends ModelByFilterBloc<String, T> {
  final ErrorCallback onError;
  final Query<Future<T>> query;

  StreamSubscription? _subscription;

  FirestoreLiveByFilterBloc({
    required this.onError,
    required this.query,
  }) {
    _subscription =
        query.snapshots().handleError(onError).listen(_onModelChanged);
  }

  Future<void> _onModelChanged(QuerySnapshot<Future<T?>> querySnapshot) async {
    final model = await querySnapshot.docs.firstOrNull?.data();

    emitStateIfChanged(
      ModelByFilterState(
        model: model,
        status: model == null ? LoadStatus.error : LoadStatus.ok,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    await super.dispose();
  }
}
