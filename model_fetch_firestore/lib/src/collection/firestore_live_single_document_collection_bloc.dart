import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:model_interfaces/model_interfaces.dart';

class FirestoreLiveSingleDocumentCollectionBloc<T extends WithId<String>>
    extends CollectionBloc<T> {
  final DocumentReference<Map<String, dynamic>> documentReference;
  final T Function(String id, Map<String, dynamic> map) fromIdAndMap;

  StreamSubscription? _snapshotSubscription;
  List<T> _items = const [];
  LoadStatus _loadStatus = LoadStatus.loading;

  FirestoreLiveSingleDocumentCollectionBloc({
    required this.documentReference,
    required this.fromIdAndMap,
    super.onError,
  }) {
    _snapshotSubscription = documentReference.snapshots().listen(_onSnapshot);
  }

  void _onSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();

    if (data == null) {
      _pushError();
      return;
    }

    final entries = data['entries'];
    if (entries is! Map) {
      _pushError();
      return;
    }

    _items = _entriesToItems(entries.cast<String, dynamic>());
    _loadStatus = LoadStatus.ok;
    pushOutput();
  }

  List<T> _entriesToItems(Map<String, dynamic> entries) {
    return entries.entries
        .map((entry) => fromIdAndMap(entry.key, entry.value))
        .toList(growable: false);
  }

  void _pushError() {
    _items = const [];
    _loadStatus = LoadStatus.error;
    pushOutput();
  }

  @override
  CollectionState<T> createState() {
    return CollectionState<T>(
      items: _items,
      hasMore: false,
      status: _loadStatus,
    );
  }

  @override
  Future<void> dispose() async {
    await _snapshotSubscription?.cancel();
    await super.dispose();
  }

  @override
  Future<void> clear() async {
    // No-op, the document is live.
  }
}
