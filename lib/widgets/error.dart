import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sistema_almox/core/theme/colors.dart';

class ErrorMessage extends StatelessWidget {
  final String message;

  const ErrorMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/warning.svg',
              colorFilter: const ColorFilter.mode(deleteRed, BlendMode.srcIn),
              width: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Erro',
              style: TextStyle(
                color: deleteRed,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: const TextStyle(fontSize: 16, color: text40),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}