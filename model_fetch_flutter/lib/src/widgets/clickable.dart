import 'package:flutter/widgets.dart';

class ClickableWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const ClickableWidget({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return child;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SelectionContainer.disabled(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.translucent,
          child: child,
        ),
      ),
    );
  }
}
