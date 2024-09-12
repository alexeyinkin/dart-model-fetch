import 'package:macros/macros.dart';

import 'filter_param_visitors/abstract.dart';

sealed class FilterParam {
  final String name;
  final TypeDeclaration typeDeclaration;

  const FilterParam({
    required this.name,
    required this.typeDeclaration,
  });

  R accept<R>(FilterParamVisitor<R> visitor);
}

class EqualsFilterParam extends FilterParam {
  const EqualsFilterParam({
    required super.name,
    required super.typeDeclaration,
  });

  @override
  R accept<R>(FilterParamVisitor<R> visitor) => visitor.visitEquals(this);
}
