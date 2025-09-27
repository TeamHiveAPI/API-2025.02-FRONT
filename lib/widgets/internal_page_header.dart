import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';

class InternalPageHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final bool isTransparent;

  const InternalPageHeader({
    super.key,
    required this.title,
    this.onBackPressed,
    this.isTransparent = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isTransparent ? Colors.white : brandBlue;
    
    final double topPadding = MediaQuery.of(context).padding.top;

    return Container(
      decoration: isTransparent
          ? BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withAlpha(170),
                  Colors.black.withAlpha(0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            )
          : null,
      padding: EdgeInsets.only(
        top: topPadding + 12.0,
        bottom: isTransparent ? 32.0 : 12.00,
        left: 16.0,
        right: 16.0,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackPressed ?? () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              size: 24,
              color: color,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}