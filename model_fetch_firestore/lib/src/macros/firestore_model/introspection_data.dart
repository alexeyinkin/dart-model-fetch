import 'package:collection/collection.dart';
import 'package:macro_util/macro_util.dart';
import 'package:macros/macros.dart';

import 'filter_param.dart';
import 'mocks.dart';
import 'resolved_identifiers.dart';

class IntrospectionData {
  final ClassDeclaration clazz;

  final Map<String, FieldIntrospectionData> fields;

  // /// The fields in the filter class added manually before the macro.
  // final Map<String, FieldIntrospectionData> filterManualFields;

  final List<FilterParam> filterParams;

  final ResolvedIdentifiers ids;

  IntrospectionData({
    required this.clazz,
    required this.fields,
    // required this.filterManualFields,
    required this.filterParams,
    required this.ids,
  });
}

Future<IntrospectionData> introspect(
  ClassDeclaration clazz,
  MemberDeclarationBuilder builder, {
  required String prefix,
  required String suffix,
}) async {
  // final filterClazz = await _getFilterClassDeclaration(clazz, builder, prefix: prefix, suffix: suffix,);

  final (
    ids,
    fields,
    // filterManualFields,
  ) = await (
    ResolvedIdentifiers.resolve(builder),
    builder.introspectFields(clazz),
    // builder.introspectFields(filterClazz),
  ).wait;

  return IntrospectionData(
    clazz: clazz,
    fields: fields,
    // filterManualFields: filterManualFields,
    filterParams: _fieldsToFilterParams(fields.values, ids: ids),
    ids: ids,
  );
}

Future<ClassDeclaration> _getFilterClassDeclaration(
  ClassDeclaration clazz,
  MemberDeclarationBuilder builder, {
  required String prefix,
  required String suffix,
}) async {
  final filterName = getFilterName(clazz, prefix: prefix, suffix: suffix);
  return (await builder.typesOf(clazz.library))
          .firstWhere((type) => type.identifier.name == filterName)
      as ClassDeclaration;
}

String getFilterName(
  ClassDeclaration clazz, {
  String? subcollection,
  required String prefix,
  required String suffix,
}) {
  return '$prefix${clazz.identifier.name}$suffix${subcollection ?? ''}Filter';
}

List<FilterParam> _fieldsToFilterParams(
  Iterable<FieldIntrospectionData> fields, {
  required ResolvedIdentifiers ids,
}) {
  return {
    for (final field in fields) field.name: _fieldToFilterParams(field),
    'id': [
      EqualsFilterParam(
        name: 'id',
        typeDeclaration: MockTypeDeclaration(
          identifier: ids.String,
          library: MockLibrary.dartCore,
        ),
      )
    ],
  }.values.flattened.toList(growable: false);
}

List<FilterParam> _fieldToFilterParams(FieldIntrospectionData field) {
  if (field is! ResolvedFieldIntrospectionData ||
      field.fieldDeclaration.hasStatic) {
    return const []; // Not a regular field.
  }

  final typeDecl = field.deAliasedTypeDeclaration;

  if (typeDecl.library.uri.toString() != 'dart:core') {
    // TODO: Handle enums.
    return const [];
  }

  switch (field.deAliasedTypeDeclaration.identifier.name) {
    case 'String':
      return [EqualsFilterParam(name: field.name, typeDeclaration: typeDecl)];
  }

  return const [];
}
