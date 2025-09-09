import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPlaceholder extends StatelessWidget {
  final double height;
  final int? itemCount;
  final double itemSpacing;

  const ShimmerPlaceholder({
    super.key,
    required this.height,
    this.itemCount,
    this.itemSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (itemCount == null || itemCount! <= 1) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    final totalSpacing = (itemCount! - 1) * itemSpacing;
    final singleItemHeight = (height - totalSpacing) / itemCount!;

    if (singleItemHeight <= 0) {
      return SizedBox(height: height);
    }

    return SizedBox(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(itemCount!, (index) {
          return Container(
            height: singleItemHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}