import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';

class CustomRadioButton<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?> onChanged;
  final String label;
  final double size;
  final double borderRadius;
  final bool smaller;

  const CustomRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
    this.size = 29.0,
    this.borderRadius = 4.0,
    this.smaller = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == groupValue;

    final double currentCheckboxSize = smaller ? 22.0 : size;
    final double currentFontSize = smaller ? 14.0 : 16.0;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(borderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: currentCheckboxSize,
              width: currentCheckboxSize,
              decoration: BoxDecoration(
                color: isSelected ? brandBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: isSelected ? brandBlue : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: currentCheckboxSize * 0.7,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: currentFontSize,
                color: isSelected ? text80 : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}