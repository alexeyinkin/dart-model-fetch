import 'package:flutter/material.dart';

class RetryButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RetryButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: onPressed,
    );
  }
}
