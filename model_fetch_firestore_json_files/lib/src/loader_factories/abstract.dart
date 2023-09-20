import 'dart:convert';
import 'dart:io';

import 'package:firestore_api_converter/firestore_api_converter.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:model_interfaces/model_interfaces.dart';
import 'package:path/path.dart';

import '../file_iterable_builder.dart';

abstract class AbstractFirestoreJsonFilesLoaderFactory<
    T extends WithId<String>,
    F extends AbstractFilter
//
    > extends LoaderFactory<String, T, F> {
  File idToFile(String id);

  FileIterableBuilder createFileIterableBuilder(F filter);

  T fromMap(Map<String, dynamic> map);

  void onError(Object error, StackTrace trace);

  @override
  ModelByIdBloc<String, T> createLiveByIdBloc(String id) {
    // TODO: Live
    return FixedModelByIdBloc(getter: () => _modelById(id));
    //throw UnimplementedError();
  }

  @override
  ModelByIdBloc<String, T> createFrozenByIdBloc(String id) {
    return FixedModelByIdBloc(getter: () => _modelById(id));
  }

  T _modelById(String id) {
    return fromMap(fileToMap(idToFile(id)));
  }

  @override
  ModelByFilterBloc<String, T> createLiveModelByFilterBloc(F filter) {
    throw UnimplementedError();
  }

  @override
  ModelByFilterBloc<String, T> createFrozenModelByFilterBloc(F filter) {
    // TODO(alexeyinkin): Clone FirestoreLiveByFilterBloc but make it frozen.
    throw UnimplementedError('TODO');
  }

  @override
  LazyLoadBloc<T> createLiveListBloc(F filter) {
    throw UnimplementedError();
  }

  @override
  LazyLoadBloc<T> createFrozenListBloc(F filter) {
    final builder = createFileIterableBuilder(filter);
    final objectsIterable = builder.files.map(fileToMap).map(fromMap);

    return IterableLazyLoadBloc(
      iterable: objectsIterable,
      pageSize: 10,
    );
  }

  String fileToId(File file) {
    return basenameWithoutExtension(file.path);
  }

  Map<String, dynamic> fileToMap(File file) {
    final firestoreMap = jsonDecode(file.readAsStringSync());

    if (firestoreMap is! Map<String, dynamic>) {
      throw Exception('Cannot parse JSON to Map<String, dynamic>: $file');
    }

    final fieldsMap = FirestoreApiConverter.fromFirestore({
      'fields': firestoreMap,
    });

    fieldsMap['id'] = fileToId(file);
    return fieldsMap;
  }
}
