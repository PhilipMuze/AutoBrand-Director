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
        style: const TextStyle(
          fontSize: 15,
          color: Colors.white,
          height: 1.6,
        ),
      ),
    );
  }
}
