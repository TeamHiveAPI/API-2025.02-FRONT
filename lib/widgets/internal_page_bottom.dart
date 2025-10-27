import 'package:flutter/material.dart';
import 'package:sistema_almox/widgets/button.dart';

class InternalPageBottom extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onButtonPressed;

  final VoidCallback? onDeletePressed;
  final bool isEditMode;
  final bool isLoading;

  final bool showSecondaryButton;
  final String? secondaryButtonIcon;
  final VoidCallback? onSecondaryButtonPressed;

  const InternalPageBottom({
    super.key,
    required this.buttonText,
    this.onButtonPressed,
    this.onDeletePressed,
    this.isEditMode = false,
    this.isLoading = false,
    this.showSecondaryButton = false,
    this.secondaryButtonIcon,
    this.onSecondaryButtonPressed,
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

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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
      child: Row(
        children: [
          Expanded(child: mainButton),

          if (!isEditMode && showSecondaryButton && secondaryButtonIcon != null) ...[
            const SizedBox(width: 20),
            CustomButton(
              squareMode: true,
              onPressed: isLoading ? null : onSecondaryButtonPressed,
              borderRadius: 8.0,
              customIcon: secondaryButtonIcon,
            ),
          ],

          if (isEditMode) ...[
            const SizedBox(width: 16),
            CustomButton(
              squareMode: true,
              danger: true,
              onPressed: isLoading ? null : onDeletePressed,
              borderRadius: 8.0,
              customIcon: "assets/icons/trash.svg",
            ),
          ],
        ],
      ),
    );
  }
}