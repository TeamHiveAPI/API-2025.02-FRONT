import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sistema_almox/core/theme/colors.dart';

class ManagementCard extends StatelessWidget {
  final String iconPath;
  final String name;
  final String description;
  final VoidCallback onPressed;

  const ManagementCard({
    super.key,
    required this.iconPath,
    required this.name,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: brandBlueLight,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onPressed,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        iconPath,
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(
                          brandBlue,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: brandBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: brandBlue.withAlpha(170),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              top: 44.0,
              right: 20.0,
              child: Icon(Icons.arrow_forward_ios, color: brandBlue, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}