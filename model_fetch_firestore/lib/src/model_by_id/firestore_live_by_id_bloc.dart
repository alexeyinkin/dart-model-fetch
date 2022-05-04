import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:model_fetch/model_fetch.dart';
import 'package:model_interfaces/model_interfaces.dart';

class FirestoreLiveByIdBloc<T extends WithId<String>>
    extends ModelByIdBloc<String, T> {
  final CollectionReference<T> collectionReference;

  final DocumentReference<T> _doc;

  FirestoreLiveByIdBloc({
    required this.collectionReference,
    required String id,
  })  : _doc = collectionReference.doc(id),
        super(id: id) {
    _doc.snapshots().listen(_onModelChanged);
  }

  void _onModelChanged(DocumentSnapshot<T> documentSnapshot) {
    final model = documentSnapshot.data();

    emitStateIfChanged(
      ModelByIdState(
        model: model,
        status: model == null ? LoadStatus.error : LoadStatus.ok,
      ),
    );
  }
}
