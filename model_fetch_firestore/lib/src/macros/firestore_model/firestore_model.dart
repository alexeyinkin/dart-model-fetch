// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:common_macros/common_macros.dart';
import 'package:macro_util/macro_util.dart';
import 'package:macros/macros.dart';

import '../../enums/query_source_type.dart';

final _loaderFactoryLibrary = Uri.parse(
  'package:model_fetch_firestore/src/loader_factories/abstract.dart',
);

macro class FirestoreModel implements ClassTypesMacro, ClassDeclarationsMacro {
  final String prefix;
  final QuerySourceType querySourceType;
  final String subcollectionsJson;
  final String suffix;

  const FirestoreModel({
    this.prefix = '',
    this.querySourceType = QuerySourceType.collection,
    this.subcollectionsJson = '',
    this.suffix = '',
  });

  Map<String, String> get subcollections {
    return subcollectionsJson == ''
        ? const {}
        : jsonDecode(subcollectionsJson).cast<String, String>();
  }

  @override
  Future<void> buildTypesForClass(
    ClassDeclaration clazz,
    ClassTypeBuilder builder,
  ) async {
    // TODO(alexeyinkin): Create a filter class when it's visible outside, https://github.com/dart-lang/sdk/issues/56040

    // ignore: deprecated_member_use
    final baseId = await builder.resolveIdentifier(
      _loaderFactoryLibrary,
      'AbstractFirestoreLoaderFactory',
    );

    final loaderFactoryName = _getLoaderFactoryName(clazz);
    builder.declareType(
      loaderFactoryName,
      DeclarationCode.fromParts([
        ..._getLoaderFactoryDeclarationSignature(clazz, baseId),
        ' {}',
      ]),
    );

    for (final s in subcollections.values) {
      final loaderFactoryName = _getLoaderFactoryName(clazz, subcollection: s);
      builder.declareType(
        loaderFactoryName,
        DeclarationCode.fromParts([
          ..._getLoaderFactoryDeclarationSignature(
            clazz,
            baseId,
            subcollection: s,
          ),
          ' {}',
        ]),
      );
    }
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

    for (final s in subcollections.values) {
      await _buildSubcollectionFilter(intr, builder, subcollection: s);
      _buildSubcollectionLoaderFactory(intr, builder, subcollection: s);
      _buildSubcollectionQueryBuilder(intr, builder, subcollection: s);
    }
  }

  Future<void> _buildFilter(
    _IntrospectionData intr,
    MemberDeclarationBuilder builder,
  ) async {
    final filterName = _getFilterName(intr.clazz);
    final i = intr.ids;

    final filterIdentifier = await builder.resolveIdentifier(
      intr.clazz.library.uri,
      filterName,
    );
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

  Future<void> _buildSubcollectionFilter(
    _IntrospectionData intr,
    MemberDeclarationBuilder builder, {
    required String subcollection,
  }) async {
    final filterName = _getFilterName(intr.clazz, subcollection: subcollection);
    final i = intr.ids;

    final filterIdentifier = await builder.resolveIdentifier(
      intr.clazz.library.uri,
      filterName,
    );
    final clazz = await builder.typeDeclarationOf(filterIdentifier);

    if (clazz is! ClassDeclaration) {
      throw Exception('Cannot resolve the declaration of $filterName');
    }

    builder.declareInLibrary(
      DeclarationCode.fromParts([
        //
        'augment class $filterName extends ', i.AbstractFilter, ' {\n',
        '  final ', i.String, ' ${intr.clazz.identifier.name}Id;',
        ...await Constructor(
          isConst: true,
          extraNamedParameters: [
            ['required this.${intr.clazz.identifier.name}Id'],
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
        ..._getLoaderFactoryInstance(intr),
        ..._getCreateQueryBuilder(intr),
        ..._getFromFirestore(intr),
        ..._getDefaultCollectionName(intr),
        '}\n',
      ]),
    );
  }

  void _buildSubcollectionLoaderFactory(
    _IntrospectionData intr,
    MemberDeclarationBuilder builder, {
    required String subcollection,
  }) {
    builder.declareInLibrary(
      DeclarationCode.fromParts([
        //
        'augment ',
        ..._getLoaderFactoryDeclarationSignature(
          intr.clazz,
          intr.ids.AbstractFirestoreLoaderFactory,
          subcollection: subcollection,
        ),
        ' {\n',
        ..._getLoaderFactoryInstance(intr, subcollection: subcollection),
        ..._getCreateQueryBuilder(intr, subcollection: subcollection),
        ..._getSubcollectionFromFirestore(intr, subcollection: subcollection),
        ..._getDefaultCollectionNameUnimplemented(intr),
        '}\n',
      ]),
    );
  }

  List<Object> _getLoaderFactoryDeclarationSignature(
    ClassDeclaration clazz,
    Identifier baseId, {
    String? subcollection,
  }) {
    final name = clazz.identifier.name;
    final entity = subcollection ?? name;
    final filterName = _getFilterName(clazz, subcollection: subcollection);
    final loaderFactoryName = _getLoaderFactoryName(
      clazz,
      subcollection: subcollection,
    );

    return [
      //
      'class $loaderFactoryName extends ', baseId, '<$entity, $filterName>',
    ];
  }

  List<Object> _getLoaderFactoryInstance(
    _IntrospectionData intr, {
    String? subcollection,
  }) {
    final factoryName = _getLoaderFactoryName(
      intr.clazz,
      subcollection: subcollection,
    );

    return [
      //
      'static final instance = $factoryName();\n',
    ];
  }

  List<Object> _getCreateQueryBuilder(
    _IntrospectionData intr, {
    String? subcollection,
  }) {
    final filterName = _getFilterName(intr.clazz, subcollection: subcollection);
    final builderName = _getQueryBuilderName(
      intr.clazz,
      subcollection: subcollection,
    );
    final i = intr.ids;

    return [
      //
      '@', i.override, '\n',
      '$builderName createQueryBuilder($filterName filter) {\n',
      '  return $builderName(\n',
      '    filter: filter,\n',
      '    loaderFactory: this,\n',
      if (subcollection == null) ...[
        '    sourceType: ',
        i.QuerySourceType,
        '.',
        querySourceType.name,
        ',\n',
      ],
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
      i.Future, '<$name> fromFirestore(',
      i.DocumentSnapshot,
      '<', i.Map, '<', i.String, ', ', i.dynamic, '>> snapshot,',
      i.SnapshotOptions, '? options,',
      ') async {',
      '  final id = snapshot.id;\n',

      for (final entry in subcollections.entries) ...[
        'final ${entry.key}Loader = ',
        _getLoaderFactoryName(intr.clazz, subcollection: entry.value),
        '.instance.frozenListBloc(',
        _getFilterName(intr.clazz, subcollection: entry.value),
        '(',
        '${name}Id: id',
        ')',
        ');\n',
      ],

      '  await ', i.Future, '.wait([\n',
      for (final fieldName in subcollections.keys) ...[
        '    ${fieldName}Loader.loadAllIfCan(),\n',
      ],
      '  ]);\n',

      '  final r = $name.fromJson({\n',
      '    "id": snapshot.id,\n',
      for (final fieldName in subcollections.keys) ...[
        '    "$fieldName": [],\n',
      ],
      '    ...?snapshot.data(),\n',
      '  });',

      for (final fieldName in subcollections.keys) ...[
        '  r.$fieldName.addAll(${fieldName}Loader.createState().items);\n',
      ],

      '  return r;\n',
      '}',
    ];
  }

  List<Object> _getSubcollectionFromFirestore(
    _IntrospectionData intr, {
    required String subcollection,
  }) {
    final i = intr.ids;

    return [
      //
      '@', i.override, '\n',
      i.Future, '<$subcollection> fromFirestore(',
      i.DocumentSnapshot,
      '<', i.Map, '<', i.String, ', ', i.dynamic, '>> snapshot,',
      i.SnapshotOptions, '? options,',
      ') async => ',
      '$subcollection.fromJson({"id": snapshot.id, ...?snapshot.data()});',
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

  List<Object> _getDefaultCollectionNameUnimplemented(_IntrospectionData intr) {
    final i = intr.ids;

    return [
      //
      '@', i.override, '\n',
      i.String, ' get defaultCollectionName => ',
      'throw ', i.UnimplementedError, ';\n',
    ];
  }

  void _buildQueryBuilder(_IntrospectionData intr, DeclarationBuilder builder) {
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

  void _buildSubcollectionQueryBuilder(
    _IntrospectionData intr,
    DeclarationBuilder builder, {
    required String subcollection,
  }) {
    final name = intr.clazz.identifier.name;
    final filterName = _getFilterName(intr.clazz, subcollection: subcollection);
    final builderName = _getQueryBuilderName(
      intr.clazz,
      subcollection: subcollection,
    );
    final i = intr.ids;

    builder.declareInLibrary(
      DeclarationCode.fromParts([
        //
        'augment class $builderName ',
        'extends ', i.QueryBuilder, '<$subcollection, $filterName> {\n',
        '  $builderName({\n',
        '    required super.filter,\n',
        '    required super.loaderFactory,\n',
        '  }) : super(sourceType: ', i.QuerySourceType, '.collection);\n',

        '  @', i.override, '\n',
        '  ', i.CollectionReference,
        '<', i.Map, '<', i.String, ', ', i.dynamic, '>> ',
        'get mapCollectionReference => ',
        i.FirebaseFirestore, '.instance',
        '.collection("$name")',
        '.doc(filter.${name}Id)',
        '.collection("$subcollection");\n',

        '}\n',
      ]),
    );
  }

  String _getFilterName(ClassDeclaration clazz, {String? subcollection}) {
    return '$prefix${clazz.identifier.name}$suffix${subcollection ?? ''}Filter';
  }

  String _getLoaderFactoryName(
    ClassDeclaration clazz, {
    String? subcollection,
  }) {
    return '$prefix${clazz.identifier.name}$suffix${subcollection ?? ''}FirestoreLoaderFactory';
  }

  String _getQueryBuilderName(ClassDeclaration clazz, {String? subcollection}) {
    return '$prefix${clazz.identifier.name}$suffix${subcollection ?? ''}QueryBuilder';
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
  final Identifier CollectionReference;
  final Identifier DocumentSnapshot;
  final Identifier FieldPath;
  final Identifier FirebaseFirestore;
  final Identifier Future;
  final Identifier Map;
  final Identifier Query;
  final Identifier QueryBuilder;
  final Identifier QuerySourceType;
  final Identifier SnapshotOptions;
  final Identifier String;
  final Identifier UnimplementedError;
  final Identifier dynamic;
  final Identifier override;
}

macro class FirestoreCollectionGroupModel extends FirestoreModel {
  const FirestoreCollectionGroupModel({
    super.prefix,
    super.suffix,
  }) : super(querySourceType: QuerySourceType.collectionGroup);
}
