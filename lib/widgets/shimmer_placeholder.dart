import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPlaceholder extends StatelessWidget {
  final double? height;
  final double? radius;
  final bool circle;

  const ShimmerPlaceholder({
    super.key,
    this.height,
  })  : circle = false,
        radius = null,
        assert(height != null, 'Height must be provided for a rectangle.');

  const ShimmerPlaceholder.circle({
    super.key,
    required this.radius,
  })  : circle = true,
        height = null,
        assert(radius != null, 'Radius must be provided for a circle.');

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: circle ? _buildCircle() : _buildRectangle(),
    );
  }

  Widget _buildRectangle() {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildCircle() {
    return Container(
      height: radius! * 2,
      width: radius! * 2,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}