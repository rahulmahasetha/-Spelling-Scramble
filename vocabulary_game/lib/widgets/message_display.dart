import 'package:flutter/material.dart';

class MessageDisplay extends StatelessWidget {
  final String message;
  final bool isCorrect; // True for success, false for error/info

  const MessageDisplay({
    super.key,
    required this.message,
    this.isCorrect = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: message.isEmpty
          ? const SizedBox.shrink()
          : Container(
        key: ValueKey(message), // Important for AnimatedSwitcher
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isCorrect ? Colors.green.shade800 : Colors.red.shade800,
          ),
        ),
      ),
    );
  }
}