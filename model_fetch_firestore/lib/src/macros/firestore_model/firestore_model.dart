import 'dart:async';
import 'dart:convert';

import 'package:common_macros/common_macros.dart';
import 'package:macros/macros.dart';

import '../../enums/query_source_type.dart';
import 'filter_param_visitors/query_builder_build.dart';
import 'introspection_data.dart';

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
    final intr = await introspect(
      clazz,
      builder,
      prefix: prefix,
      suffix: suffix,
    );

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
    IntrospectionData intr,
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

        for (final param in intr.filterParams) ...[
          '  final ',
          param.typeDeclaration.identifier,
          '? ',
          param.name,
          ';\n',
        ],

        ...await Constructor(
          isConst: true,
          extraNamedParameters: [
            for (final param in intr.filterParams) ['this.${param.name}'],
          ],
          // extraNamedParameters: [
          //   ['this.id', for (final param in intr.filterParams) 'this.${param.name}'],
          // ],
        ).getParts(clazz, builder),

        '  @', i.override, '\n',
        i.bool, ' operator ==(', i.Object, ' other) {\n',
        '  if (other is! $filterName) return false;\n',
        // for (final field in intr.filterManualFields.values)
        //   '  if (other.${field.name} != ${field.name}) return false;\n',
        '  for (var i = fields.length; --i >= 0; ) {\n',
        '    if (fields[i] != other.fields[i]) return false;\n',
        '  }\n',
        for (final param in intr.filterParams)
          '  if (other.${param.name} != ${param.name}) return false;\n',
        '  return true;\n',
        '  }\n',

        '  @', i.override, '\n',
        i.int, ' get hashCode => ', i.Object, '.hashAll([',
        // for (final field in intr.filterManualFields.values) '${field.name},\n',
        '  ...fields,',
        for (final param in intr.filterParams) '${param.name},\n',
        '  ]);',
        '}\n',
      ]),
    );
  }

  Future<void> _buildSubcollectionFilter(
    IntrospectionData intr,
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
    IntrospectionData intr,
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
    IntrospectionData intr,
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
    IntrospectionData intr, {
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
    IntrospectionData intr, {
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

  List<Object> _getFromFirestore(IntrospectionData intr) {
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
    IntrospectionData intr, {
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

  List<Object> _getDefaultCollectionName(IntrospectionData intr) {
    final name = intr.clazz.identifier.name;
    final i = intr.ids;

    return [
      //
      '@', i.override, '\n',
      i.String, ' get defaultCollectionName => "$name";\n',
    ];
  }

  List<Object> _getDefaultCollectionNameUnimplemented(IntrospectionData intr) {
    final i = intr.ids;

    return [
      //
      '@', i.override, '\n',
      i.String, ' get defaultCollectionName => ',
      'throw ', i.UnimplementedError, ';\n',
    ];
  }

  void _buildQueryBuilder(IntrospectionData intr, DeclarationBuilder builder) {
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

        ...QueryBuilderBuildGenerator(intr).generate(),
        '}\n',
      ]),
    );
  }

  void _buildSubcollectionQueryBuilder(
    IntrospectionData intr,
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
    return getFilterName(
      clazz,
      subcollection: subcollection,
      prefix: prefix,
      suffix: suffix,
    );
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
}

macro class FirestoreCollectionGroupModel extends FirestoreModel {
  const FirestoreCollectionGroupModel({
    super.prefix,
    super.suffix,
  }) : super(querySourceType: QuerySourceType.collectionGroup);
}
