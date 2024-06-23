// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:macro_util/macro_util.dart';
import 'package:macros/macros.dart';

final _loaderFactoryLibrary = Uri.parse(
    'package:model_fetch_firestore/src/loader_factories/abstract.dart',);

macro class FirestoreModel implements ClassTypesMacro, ClassDeclarationsMacro {
  const FirestoreModel();

  @override
  Future<void> buildTypesForClass(
    ClassDeclaration clazz,
    ClassTypeBuilder builder,
  ) async {
    // TODO(alexeyinkin): Create a filter class when it's visible outside, https://github.com/dart-lang/sdk/issues/56040

    final loaderFactoryName = _getLoaderFactoryClassName(clazz);
    // ignore: deprecated_member_use
    final baseId = await builder.resolveIdentifier(
      _loaderFactoryLibrary,
      'AbstractFirestoreLoaderFactory',
    );

    builder.declareType(
      loaderFactoryName,
      DeclarationCode.fromParts(
        [..._getLoaderFactoryDeclarationSignature(clazz, baseId), ' {}'],
      ),
    );
  }

  @override
  Future<void> buildDeclarationsForClass(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
  ) async {
    final intr = await _introspect(clazz, builder);

    _buildLoaderFactory(intr, builder);
    _buildQueryBuilder(intr, builder);
  }

  void _buildLoaderFactory(
    _IntrospectionData intr,
    MemberDeclarationBuilder builder,
  ) {
    builder.declareInLibrary(
      DeclarationCode.fromParts([
        //
        'augment ',
        ..._getLoaderFactoryDeclarationSignature(
          intr.clazz,
          intr.ids.AbstractFirestoreLoaderFactory,
        ),
        ' {\n',
        ..._getCreateQueryBuilder(intr),
        ..._getFromFirestore(intr),
        ..._getGetCollectionReference(intr),
        '}\n',
      ]),
    );
  }

  List<Object> _getLoaderFactoryDeclarationSignature(
    ClassDeclaration clazz,
    Identifier baseId,
  ) {
    final name = clazz.identifier.name;
    final filterName = _getFilterName(clazz);
    final loaderFactoryName = _getLoaderFactoryClassName(clazz);

    return [
      //
      'class $loaderFactoryName extends ', baseId, '<$name, $filterName>',
    ];
  }

  List<Object> _getCreateQueryBuilder(_IntrospectionData intr) {
    final filterName = _getFilterName(intr.clazz);
    final builderName = _getQueryBuilderName(intr.clazz);
    final i = intr.ids;

    return [
      //
      '@', i.override, '\n',
      '$builderName createQueryBuilder($filterName filter) {\n',
      '  return $builderName(filter, this);\n',
      '}\n',
    ];
  }

  List<Object> _getFromFirestore(_IntrospectionData intr) {
    final name = intr.clazz.identifier.name;
    final i = intr.ids;

    return [
      //
      '@', i.override, '\n',
      name, ' fromFirestore(',
      i.DocumentSnapshot,
      '<', i.Map, '<', i.String, ', ', i.dynamic, '>> snapshot,',
      i.SnapshotOptions, '? options,',
      ') => ',
      name, '.fromJson({"id": snapshot.id, ...?snapshot.data()});',
    ];
  }

  List<Object> _getGetCollectionReference(_IntrospectionData intr) {
    final name = intr.clazz.identifier.name;
    final i = intr.ids;

    return [
      //
      '@', i.override, '\n',
      i.CollectionReference,
      '<', i.Map, '<', i.String, ', ', i.dynamic, '>> getCollection() {\n',
      '  return ', i.FirebaseFirestore, '.instance.collection("$name");\n',
      '}\n',
    ];
  }

  void _buildQueryBuilder(
    _IntrospectionData intr,
    DeclarationBuilder builder,
  ) {
    final name = intr.clazz.identifier.name;
    final filterName = _getFilterName(intr.clazz);
    final factoryName = _getLoaderFactoryClassName(intr.clazz);
    final builderName = _getQueryBuilderName(intr.clazz);
    final i = intr.ids;

    builder.declareInLibrary(
      DeclarationCode.fromParts([
        //
        'augment class $builderName ',
        'extends ', i.QueryBuilder, '<', name, '> {\n',
        '  final $filterName filter;\n',
        '  final $factoryName loaderFactory;\n',
        '  ', i.Query, '<$name>? _query;\n',

        '  @', i.override, '\n',
        '  ', i.Query, '<$name> get query => _query ?? _createEmptyQuery();\n',

        '  $builderName(this.filter, this.loaderFactory) {\n',
        // TODO(alexeyinkin): Build the query.
        '  }\n',

        '  ', i.Query, '<$name> _createEmptyQuery() {\n',
        '    return ', i.FirebaseFirestore,
        '.instance.collection("$name").withConverter(\n',
        '      fromFirestore: loaderFactory.fromFirestoreBase,\n',
        '      toFirestore: (_, __) => throw ', i.UnimplementedError, '(),\n',
        '    );\n',
        '  }\n',
        '}\n',
      ]),
    );
  }

  String _getFilterName(ClassDeclaration clazz) {
    return '${clazz.identifier.name}Filter';
  }

  String _getLoaderFactoryClassName(ClassDeclaration clazz) {
    return '${clazz.identifier.name}FirestoreLoaderFactory';
  }

  String _getQueryBuilderName(ClassDeclaration clazz) {
    return '${clazz.identifier.name}QueryBuilder';
  }
}

Future<_IntrospectionData> _introspect(
  ClassDeclaration clazz,
  MemberDeclarationBuilder builder,
) async {
  final (ids, fields) = await (
    _ResolvedIdentifiers.resolve(builder),
    builder.introspectFields(clazz),
  ).wait;

  return _IntrospectionData(
    clazz: clazz,
    fields: fields,
    ids: ids,
  );
}

class _IntrospectionData {
  final ClassDeclaration clazz;

  final Map<String, FieldIntrospectionData> fields;

  final _ResolvedIdentifiers ids;

  _IntrospectionData({
    required this.clazz,
    required this.fields,
    required this.ids,
  });
}

@ResolveIdentifiers()
class _ResolvedIdentifiers {
  final Identifier AbstractFirestoreLoaderFactory;
  final Identifier CollectionReference;
  final Identifier DocumentSnapshot;
  final Identifier FirebaseFirestore;
  final Identifier Map;
  final Identifier Query;
  final Identifier QueryBuilder;
  final Identifier SnapshotOptions;
  final Identifier String;
  final Identifier UnimplementedError;
  final Identifier dynamic;
  final Identifier override;
}
