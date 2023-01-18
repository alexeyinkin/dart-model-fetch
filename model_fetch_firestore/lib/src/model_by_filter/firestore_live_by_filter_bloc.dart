import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:model_interfaces/model_interfaces.dart';

class FirestoreLiveByFilterBloc<T extends WithId<String>>
    extends ModelByFilterBloc<String, T> {
  final Query<T> query;

  FirestoreLiveByFilterBloc({
    required this.query,
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
