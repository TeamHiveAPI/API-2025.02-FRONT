import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';

class InternalPageHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;

  const InternalPageHeader({
    super.key,
    required this.title,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackPressed ?? () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              size: 24,
              color: brandBlue,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: brandBlue,
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
