import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';

class DetailItemCard extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onPressed;

  const DetailItemCard({
    super.key,
    required this.label,
    required this.value,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isClickable = onPressed != null;

    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: text80,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: text40,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isClickable)
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: text40,
              ),
            ),
        ],
      ),
    );

    if (isClickable) {
      return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: content,
      );
    }

    return content;
  }
}