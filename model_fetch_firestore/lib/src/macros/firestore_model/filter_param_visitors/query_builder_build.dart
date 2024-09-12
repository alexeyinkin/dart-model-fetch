import '../filter_param.dart';
import '../introspection_data.dart';
import 'abstract.dart';

class QueryBuilderBuildGenerator extends FilterParamVisitor<List<Object>> {
  final IntrospectionData intr;

  const QueryBuilderBuildGenerator(this.intr);

  List<Object> generate() {
    return [
      'void _build() {\n',
      for (final param in intr.filterParams) ...visit(param),
      '}\n',
    ];
  }

  @override
  List<Object> visitEquals(EqualsFilterParam param) {
    final name = param.name;

    return [
      //
      'if (filter.$name != null) {\n',
      '  _query = query.where(\n',
      '    ', ..._getFirebaseFieldName(param), ',\n',
      '    isEqualTo: filter.$name!\n',
      '  );\n',
      '}\n',
    ];
  }

  List<Object> _getFirebaseFieldName(FilterParam param) => switch (param.name) {
        'id' => [intr.ids.FieldPath, '.documentId'],
        _ => ['"${param.name}"'],
      };
}
