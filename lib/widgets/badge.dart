import 'package:flutter/material.dart';

class CustomBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final bool small;

  const CustomBadge({
    super.key,
    required this.text,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = small
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 1)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          2.0,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12.0,
        ),
      ),
    );
  }
}
