// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:common_macros/common_macros.dart';
import 'package:macro_util/macro_util.dart';
import 'package:macros/macros.dart';

import '../../enums/query_source_type.dart';

final _loaderFactoryLibrary = Uri.parse(
  'package:model_fetch_firestore/src/loader_factories/abstract.dart',
);

macro class FirestoreModel implements ClassTypesMacro, ClassDeclarationsMacro {
  final QuerySourceType querySourceType;

  const FirestoreModel({
    this.querySourceType = QuerySourceType.collection,
  });

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

    await _buildFilter(intr, builder);
    _buildLoaderFactory(intr, builder);
    _buildQueryBuilder(intr, builder);
  }

  Future<void> _buildFilter(
    _IntrospectionData intr,
    MemberDeclarationBuilder builder,
  ) async {
    final filterName = _getFilterName(intr.clazz);
    final i = intr.ids;

    final filterIdentifier =
        await builder.resolveIdentifier(intr.clazz.library.uri, filterName);
    final clazz = await builder.typeDeclarationOf(filterIdentifier);

    if (clazz is! ClassDeclaration) {
      throw Exception('Cannot resolve the declaration of $filterName');
    }

    builder.declareInLibrary(
      DeclarationCode.fromParts([
        //
        'augment class $filterName extends ', i.AbstractFilter, ' {\n',
        '  final ', i.String, '? id;',
        ...await const Constructor(
          isConst: true,
          extraNamedParameters: [
            ['this.id'],
          ],
        ).getParts(clazz, builder),
        '}\n',
      ]),
    );
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
        ..._getDefaultCollectionName(intr),
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
      '  return $builderName(\n',
      '    filter: filter,\n',
      '    loaderFactory: this,\n',
      '    sourceType: ', i.QuerySourceType, '.', querySourceType.name, ',\n',
      '  );\n',
      '}\n',
    ];
  }

  List<Object> _getFromFirestore(_IntrospectionData intr) {
    final name = intr.clazz.identifier.name;
    final i = intr.ids;

    return [
      //
      '@', i.override, '\n',
      i.Future, '<', name, '> fromFirestore(',
      i.DocumentSnapshot,
      '<', i.Map, '<', i.String, ', ', i.dynamic, '>> snapshot,',
      i.SnapshotOptions, '? options,',
      ') async => ',
      name, '.fromJson({"id": snapshot.id, ...?snapshot.data()});',
    ];
  }

  List<Object> _getDefaultCollectionName(_IntrospectionData intr) {
    final name = intr.clazz.identifier.name;
    final i = intr.ids;

    return [
      //
      '@', i.override, '\n',
      i.String, ' get defaultCollectionName => "$name";\n',
    ];
  }

  void _buildQueryBuilder(
    _IntrospectionData intr,
    DeclarationBuilder builder,
  ) {
    final name = intr.clazz.identifier.name;
    final filterName = _getFilterName(intr.clazz);
    final builderName = _getQueryBuilderName(intr.clazz);
    final i = intr.ids;

    builder.declareInLibrary(
      DeclarationCode.fromParts([
        //
        'augment class $builderName ',
        'extends ', i.QueryBuilder, '<$name, $filterName> {\n',
        '  ', i.Query, '<', i.Future, '<$name>>? _query;\n',

        '  $builderName({\n',
        '    required super.filter,\n',
        '    required super.loaderFactory,\n',
        '    required super.sourceType,\n',
        '  }) {\n',
        '    _build();',
        '  }\n',

        '  @', i.override, '\n',
        '  ', i.Query, '<', i.Future, '<$name>> get query => ',
        '_query ?? emptyQuery;\n',

        '  @', i.override, '\n',
        '  ', i.String, ' get collectionName => "$name";\n',

        ..._getBuild(intr),
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

  List<Object> _getBuild(_IntrospectionData intr) {
    final i = intr.ids;

    return [
      //
      'void _build() {\n',
      '  if (filter.id != null) {\n',
      '    _query = query.where(\n',
      '      ', i.FieldPath, '.documentId,\n',
      '      isEqualTo: filter.id!\n',
      '    );\n',
      '  }\n',
      // TODO: Filter with other fields in the filter.
      '}\n',
    ];
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
  final Identifier AbstractFilter;
  final Identifier AbstractFirestoreLoaderFactory;
  final Identifier DocumentSnapshot;
  final Identifier FieldPath;
  final Identifier Future;
  final Identifier Map;
  final Identifier Query;
  final Identifier QueryBuilder;
  final Identifier QuerySourceType;
  final Identifier SnapshotOptions;
  final Identifier String;
  final Identifier dynamic;
  final Identifier override;
}

macro class FirestoreCollectionGroupModel extends FirestoreModel {
  const FirestoreCollectionGroupModel()
      : super(querySourceType: QuerySourceType.collectionGroup);
}
