import '../filter_param.dart';

abstract class FilterParamVisitor<R> {
  const FilterParamVisitor();

  R visit(FilterParam param) => param.accept(this);

  R visitEquals(EqualsFilterParam param);
}
