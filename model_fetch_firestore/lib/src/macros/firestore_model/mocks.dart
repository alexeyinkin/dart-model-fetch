import 'package:macros/macros.dart';

class MockTypeDeclaration implements TypeDeclaration {
  @override
  final Identifier identifier;

  @override
  final Library library;

  const MockTypeDeclaration({required this.identifier, required this.library});

  @override
  Iterable<MetadataAnnotation> get metadata => throw UnimplementedError();
}

class MockIdentifier implements Identifier {
  @override
  final String name;

  const MockIdentifier({required this.name});
}

class MockLibrary implements Library {
  @override
  final Uri uri;

  const MockLibrary({required this.uri});

  static final dartCore = MockLibrary(uri: Uri.parse('dart:core'));

  @override
  LanguageVersion get languageVersion => throw UnimplementedError();

  @override
  Iterable<MetadataAnnotation> get metadata => throw UnimplementedError();
}
