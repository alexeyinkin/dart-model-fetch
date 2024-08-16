import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:model_fetch/model_fetch.dart';
import 'package:model_interfaces/model_interfaces.dart';

import '../util.dart';

class FirestoreLiveByIdBloc<T extends WithId<String>>
    extends ModelByIdBloc<String, T> {
  final CollectionReference<Future<T>> collectionReference;
  final ErrorCallback onError;

  final DocumentReference<Future<T>> _doc;
  StreamSubscription? _subscription;

  T? _model;
  final _firstLoadCompleter = Completer<void>();

  FirestoreLiveByIdBloc({
    required super.id,
    required this.collectionReference,
    required this.onError,
  }) : _doc = collectionReference.doc(id) {
    _subscription =
        _doc.snapshots().handleError(onError).listen(_onModelChanged);
  }

  Future<void> _onModelChanged(
    DocumentSnapshot<Future<T>> documentSnapshot,
  ) async {
    _model = await documentSnapshot.data();
    _firstLoadCompleter.complete();

    emitStateIfChanged(
      ModelByIdState(
        model: _model,
        status: _model == null ? LoadStatus.error : LoadStatus.ok,
      ),
    );
  }

  @override
  Future<T?> get() async {
    await _firstLoadCompleter.future;
    return _model;
  }

  @override
  void reload() {
    // No-op, the model is live.
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    await super.dispose();
  }
}
