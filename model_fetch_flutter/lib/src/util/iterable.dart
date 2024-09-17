extension IterableExtension<T> on Iterable<T> {
  Iterable<T> intersperse(T separator) {
    return expand((item) sync* {
      yield separator;
      yield item;
    }).skip(1);
  }
}
