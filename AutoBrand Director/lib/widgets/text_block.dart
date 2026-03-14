import 'package:flutter/material.dart';

class TextBlock extends StatelessWidget {
  final String text;

  const TextBlock({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SelectableText(
        text,
        style: TextStyle(
          fontSize: 15.5,
          color: Colors.white.withValues(alpha: 0.95),
          height: 1.6,
          letterSpacing: 0.2,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
