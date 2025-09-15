import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HeaderComponent extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;

  const HeaderComponent({
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
            child: SvgPicture.asset(
              'assets/icons/backonclick.svg',
              width: 24,
              height: 24,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2847AE),
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