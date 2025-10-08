import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';

class LotController {
  final int? id;
  final String? codigoLote;
  final TextEditingController quantityController;
  final TextEditingController dateController;

  LotController({
    this.id,
    this.codigoLote,
    required String initialQuantity,
    required String initialDate,
  }) : quantityController = TextEditingController(text: initialQuantity),
       dateController = TextEditingController(text: initialDate);

  void dispose() {
    quantityController.dispose();
    dateController.dispose();
  }
}

class LotInputRow extends StatelessWidget {
  final int index;
  final LotController lot;
  final VoidCallback onRemove;
  final Function(TextEditingController) onSelectDate;

  const LotInputRow({
    super.key,
    required this.index,
    required this.lot,
    required this.onRemove,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextFormField(
                    upperLabel: 'LOTE ${index + 1}',
                    hintText: 'QTD',
                    controller: lot.quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: CustomTextFormField(
                    upperLabel: '',
                    hintText: 'Validade',
                    controller: lot.dateController,
                    onTap: () => onSelectDate(lot.dateController),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset('assets/icons/calendar.svg'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: CustomButton(
                    icon: Icons.remove_circle_outline,
                    squareMode: true,
                    danger: true,
                    secondary: true,
                    onPressed: onRemove,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 22,
            right: 0,
            child: Text(
              lot.codigoLote ?? 'NOVO LOTE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: lot.codigoLote != null ? text80 : successGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
