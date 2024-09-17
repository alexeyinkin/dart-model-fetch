import 'package:flutter/widgets.dart';

class MySpacing extends StatelessWidget {
  const MySpacing();

  static const value = 10.0;

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: value, height: value);
  }
}
