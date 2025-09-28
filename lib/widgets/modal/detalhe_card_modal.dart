import 'package:flutter/material.dart';
import 'package:sistema_almox/core/constants/system_constants.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/shimmer_placeholder.dart';

class DetailItemCard extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onPressed;
  final bool isLoading;

  const DetailItemCard({
    super.key,
    required this.label,
    required this.value,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ShimmerPlaceholder(
        height: SystemConstants.alturaCardModal.toDouble(),
      );
    }

    final bool isClickable = onPressed != null;

    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildRealContent(isClickable),
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

  Widget _buildRealContent(bool isClickable) {
    return Row(
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
    );
  }
}