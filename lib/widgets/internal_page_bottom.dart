import 'package:flutter/material.dart';
import 'package:sistema_almox/widgets/button.dart';

class InternalPageBottom extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const InternalPageBottom({
    super.key,
    required this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(24),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: CustomButton(
        text: buttonText,
        onPressed: onButtonPressed,
        icon: Icons.add,
        iconPosition: IconPosition.right,
        isFullWidth: true,
        borderRadius: 8.0,
      ),
    );
  }
}
