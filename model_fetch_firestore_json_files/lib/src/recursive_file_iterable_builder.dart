import 'dart:io';

import 'package:path/path.dart';

import 'file_iterable_builder.dart';

class RecursiveFileIterableBuilder extends FileIterableBuilder {
  final Directory directory;
  final RegExp? re;

  RecursiveFileIterableBuilder({
    required this.directory,
    required this.re,
  });

  @override
  late Iterable<File> files = _createFilesIterable();

  Iterable<File> _createFilesIterable() {
    // TODO: Do not list all bot go one by one.
    Iterable<File> result =
        directory.listSync(recursive: true).whereType<File>();

    if (re != null) {
      result = result.where((f) => re!.hasMatch(basename(f.path)));
    }

    return result;
  }
}
