import 'package:flutter/material.dart';

class LetterBox extends StatefulWidget {
  final String letter;
  final VoidCallback onTap;
  final bool isUsed;
  final double letterSize; // This will now be the font size, not box size
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final bool isFixedLetter;
  // New property to distinguish fixed letter tile

  const LetterBox({
    super.key,
    required this.letter,
    required this.onTap,
    this.isUsed = false,
    required this.letterSize,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    this.isFixedLetter = false,
  });

  @override
  State<LetterBox> createState() => _LetterBoxState();
}

class _LetterBoxState extends State<LetterBox> {
  bool _isHovering = false; // For hover effect
  bool _isTapped = false; // For active/pressed effect

  @override
  Widget build(BuildContext context) {
    // Determine responsive sizing based on screen width
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen =
        screenWidth < 640.0; // Corresponds to @media (max-width: 640px)

    // Apply the min-width/min-height properties
    final double baseBoxDimension = isSmallScreen
        ? 48.0
        : 60.0; // .letter-tile min-width/height

    // Font size mapping (1.25rem = 20px, 3rem = 48px)
    final double actualFontSize = isSmallScreen ? 20.0 : 48.0;

    return GestureDetector(
      // Using GestureDetector for more control over tap states
      onTapDown: (_) {
        setState(() {
          _isTapped = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isTapped = false;
        });
        widget.onTap(); // Execute the original tap callback
      },
      onTapCancel: () {
        setState(() {
          _isTapped = false;
        });
      },
      child: MouseRegion(
        // For hover effect on web
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedScale(
          // AnimatedScale for smooth hover/active transitions
          scale: _isTapped
              ? 0.95
              : (_isHovering && !widget.isUsed
                    ? 1.05
                    : 1.0), // active:scale-95, hover:scale effect
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            constraints: BoxConstraints(
              minWidth: baseBoxDimension,
              minHeight: baseBoxDimension,
            ),
            width: baseBoxDimension, // Enforce square by setting width/height
            height: baseBoxDimension,
            decoration: BoxDecoration(
              color: widget.isUsed
                  ? Colors.grey.shade300
                  : widget.backgroundColor, // Gray out if used
              borderRadius: BorderRadius.circular(8), // rounded-lg
              border: Border.all(
                color: widget.isUsed
                    ? Colors.grey.shade400
                    : widget.borderColor, // border-2
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // box-shadow
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                  spreadRadius: -1,
                ),
              ],
            ),
            alignment: Alignment.center, // flex items-center justify-center
            child: Text(
              widget.letter.toUpperCase(),
              style: TextStyle(
                fontSize: actualFontSize, // Apply the actual font size
                fontWeight: FontWeight.bold, // font-bold
                color: widget.isUsed ? Colors.grey.shade600 : widget.textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
