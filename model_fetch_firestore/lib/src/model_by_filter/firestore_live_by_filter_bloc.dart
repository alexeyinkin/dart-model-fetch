import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:model_interfaces/model_interfaces.dart';

class FirestoreLiveByFilterBloc<T extends WithId<String>>
    extends ModelByFilterBloc<Query<T>, T> {
  final CollectionReference<T> collectionReference;

  FirestoreLiveByFilterBloc({
    required this.collectionReference,
    required super.query,
  }) {
    query.snapshots().listen(_onModelChanged);
  }

  void _onModelChanged(QuerySnapshot<T?> querySnapshot) {
    final model = querySnapshot.docs.first.data();

    emitStateIfChanged(
      ModelByFilterState(
        model: model,
        status: model == null ? LoadStatus.error : LoadStatus.ok,
      ),
    );
  }
}
