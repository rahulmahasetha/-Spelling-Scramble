import 'package:flutter/material.dart';

class FixedLetterDisplay extends StatelessWidget {
  final String letter;

  const FixedLetterDisplay({super.key, required this.letter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68, // As per your HTML's letter-tile min-width
      height: 48, // As per your HTML's letter-tile min-height
      decoration: BoxDecoration(
        color: Colors.yellow.shade400, // bg-yellow-400
        borderRadius: BorderRadius.circular(
          15,
        ), // rounded-lg is usually 8-12px, let's keep 15 for a softer look
        border: Border.all(
          color: Colors.yellow.shade500,
          width: 2,
        ), // border-2 border-yellow-500
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.shade400.withOpacity(
              0.5,
            ), // shadow based on yellow
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter.toUpperCase(),
        style: TextStyle(
          fontSize: 30, // Approximating 3xl (text-3xl)
          fontWeight: FontWeight.bold, // font-bold
          color: Colors.yellow.shade800, // text-yellow-800
        ),
      ),
    );
  }
}
