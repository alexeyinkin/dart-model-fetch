import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:model_interfaces/model_interfaces.dart';

@Deprecated('Renamed to FirestoreLiveSingleDocumentListLoader')
typedef FirestoreLiveSingleDocumentCollectionBloc<T extends WithId<String>> = FirestoreLiveSingleDocumentListLoader<T>;

// TODO(alexeyinkin): Make a general-purpose wrapper, https://github.com/alexeyinkin/dart-model-fetch/issues/8
class FirestoreLiveSingleDocumentListLoader<T extends WithId<String>>
    extends ListLoader<T> {
  final DocumentReference<Map<String, dynamic>> documentReference;
  final T Function(String id, Map<String, dynamic> map) fromIdAndMap;

  StreamSubscription? _snapshotSubscription;

  @override
  bool get hasMore => _loadStatus == LoadStatus.notTried;

  @override
  List<T> get items => _items;

  List<T> _items = const [];

  @override
  LoadStatus get status => _loadStatus;

  LoadStatus _loadStatus = LoadStatus.loading;

  FirestoreLiveSingleDocumentListLoader({
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
  @mustCallSuper
  Future<void> dispose() async {
    await _snapshotSubscription?.cancel();
    await super.dispose();
  }

  @override
  Future<void> clear() async {
    // No-op, the document is live.
  }
}
