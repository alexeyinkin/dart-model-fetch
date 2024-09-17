import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:model_fetch/model_fetch.dart';

@Deprecated('Renamed to FirestoreLazyLoader')
typedef FirestoreLazyLoadBloc<T> = FirestoreListLazyLoader<T>;

abstract class FirestoreListLazyLoader<T> extends ListLazyLoader<T> {
  final Query<Future<T>> query;

  DocumentSnapshot<Future<T>>? _lastDocument;

  FirestoreListLazyLoader({
    required this.query,
    super.clientFilters,
    super.onError,
    super.totalLimit,
  });

  Query<Future<T>> getStartAtQuery() {
    return _lastDocument == null
        ? query
        : query.startAfterDocument(_lastDocument!);
  }

  @protected
  // ignore: use_setters_to_change_properties
  void setLastDocument(DocumentSnapshot<Future<T>>? doc) {
    _lastDocument = doc;
  }
}
