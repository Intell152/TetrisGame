import 'package:flutter/material.dart';

class PixelCard extends StatelessWidget {
  final Color color;

  const PixelCard({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      margin: const EdgeInsets.all(1),
    );
  }
}
