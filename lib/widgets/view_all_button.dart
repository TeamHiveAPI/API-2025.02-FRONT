import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';

class VerTudoButton extends StatelessWidget {
  final VoidCallback onPressed;

  const VerTudoButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return Color.alphaBlend(Colors.black.withAlpha(128), brandBlue);
            }
            return brandBlue;
          },
        ),
      ),
      child: const Text(
        'Ver Tudo',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}