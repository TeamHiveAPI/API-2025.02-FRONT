import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';

class SectorToggleButtons extends StatelessWidget {
  final int currentSectorId;
  final Function(int) onSectorSelected;

  const SectorToggleButtons({
    super.key,
    required this.currentSectorId,
    required this.onSectorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: brandBlueLight,
      borderRadius: BorderRadius.circular(8.0),
      child: Row(
        children: [
          _buildButton(context, text: 'Almoxarifado', sectorId: 1),
          _buildButton(context, text: 'Farmácia', sectorId: 2),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String text,
    required int sectorId,
  }) {
    final bool isSelected = currentSectorId == sectorId;

    final BorderRadius borderRadius;
    if (sectorId == 1) {
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(8.0),
        bottomLeft: Radius.circular(8.0),
      );
    } else {
      borderRadius = const BorderRadius.only(
        topRight: Radius.circular(8.0),
        bottomRight: Radius.circular(8.0),
      );
    }

    return Expanded(
      child: InkWell(
        onTap: () => onSectorSelected(sectorId),
        borderRadius: borderRadius,
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? brandBlue : Colors.transparent,
            borderRadius: borderRadius,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? brandBlueLight : brandBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
