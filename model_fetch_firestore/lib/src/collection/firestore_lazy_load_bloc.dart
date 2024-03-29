import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:model_fetch/model_fetch.dart';

abstract class FirestoreLazyLoadBloc<T> extends LazyLoadBloc<T> {
  final Query<T> query;

  DocumentSnapshot<T>? _lastDocument;

  FirestoreLazyLoadBloc({
    required this.query,
    super.clientFilters,
    super.onError,
    super.totalLimit,
  });

  Query<T> getStartAtQuery() {
    return _lastDocument == null
        ? query
        : query.startAfterDocument(_lastDocument!);
  }

  @protected
  // ignore: use_setters_to_change_properties
  void setLastDocument(DocumentSnapshot<T>? doc) {
    _lastDocument = doc;
  }
}
