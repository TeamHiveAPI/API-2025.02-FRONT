import 'package:flutter/material.dart';
import 'package:sistema_almox/widgets/button.dart';

class InternalPageBottom extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onButtonPressed;

  final VoidCallback? onDeletePressed;
  final bool isEditMode;
  final bool isLoading;

  const InternalPageBottom({
    super.key,
    required this.buttonText,
    this.onButtonPressed,
    this.onDeletePressed,
    this.isEditMode = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final mainButton = CustomButton(
      text: buttonText,
      isLoading: isLoading,
      onPressed: isLoading ? null : onButtonPressed,
      icon: Icons.add,
      iconPosition: IconPosition.right,
      isFullWidth: true,
      borderRadius: 8.0,
    );

    final deleteButton = CustomButton(
      squareMode: true,
      danger: true,
      onPressed: isLoading ? null : onDeletePressed,
      borderRadius: 8.0,
      customIcon: "assets/icons/trash.svg",
    );

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

      child: isEditMode
          ? Row(
              children: [
                Expanded(child: mainButton),
                const SizedBox(width: 20),
                deleteButton,
              ],
            )
          : mainButton,
    );
  }
}
