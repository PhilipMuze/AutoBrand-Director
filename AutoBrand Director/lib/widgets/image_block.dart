import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageBlock extends StatelessWidget {
  final Uint8List bytes;

  const ImageBlock({super.key, required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.memory(bytes),
      ),
    );
  }
}
