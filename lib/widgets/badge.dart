import 'package:flutter/material.dart';

class CustomBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final bool small;
  final bool big;

  const CustomBadge({
    super.key,
    required this.text,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.small = false,
    this.big = false,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = small
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 1)
        : big
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    final double borderRadiusValue = big ? 4.0 : 2.0;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadiusValue),
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
