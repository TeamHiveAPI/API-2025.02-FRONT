import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/radio_button.dart';

class LotFieldControllers {
  final int? id;
  final String? codigoLote;
  final TextEditingController quantityController;
  final TextEditingController dateController;

  LotFieldControllers({
    this.id,
    this.codigoLote,
    String? initialQuantity,
    String? initialDate,
  }) : quantityController = TextEditingController(text: initialQuantity),
       dateController = TextEditingController(text: initialDate);

  void dispose() {
    quantityController.dispose();
    dateController.dispose();
  }
}

class LotManagementSection extends StatefulWidget {
  final void Function(bool isPerishable, List<LotFieldControllers> lots)
  onChanged;

  final bool initialIsPerishable;
  final List<LotFieldControllers>? initialLotes;

  const LotManagementSection({
    super.key,
    required this.onChanged,
    this.initialIsPerishable = false,
    this.initialLotes,
  });

  @override
  State<LotManagementSection> createState() => _LotManagementSectionState();
}

class _LotManagementSectionState extends State<LotManagementSection> {
  bool _isPerishable = false;
  final List<LotFieldControllers> _lotControllers = [];

  @override
  void initState() {
    super.initState();
    _isPerishable = widget.initialIsPerishable;
    if (widget.initialLotes != null) {
      _lotControllers.addAll(widget.initialLotes!);
    }
  }

  @override
  void dispose() {
    for (var controller in _lotControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handlePerishableChange(bool? value) {
    if (value == null || value == _isPerishable) return;

    setState(() {
      _isPerishable = value;
      if (_isPerishable && _lotControllers.isEmpty) {
        _addLot();
      } else if (!_isPerishable) {
        for (var c in _lotControllers) {
          c.dispose();
        }
        _lotControllers.clear();
      }
    });
    widget.onChanged(_isPerishable, _lotControllers);
  }

  void _addLot() {
    setState(() {
      _lotControllers.add(LotFieldControllers());
    });
    widget.onChanged(_isPerishable, _lotControllers);
  }

  void _removeLot(int index) {
    setState(() {
      _lotControllers[index].dispose();
      _lotControllers.removeAt(index);
    });
    widget.onChanged(_isPerishable, _lotControllers);
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      String formattedDate =
          "${pickedDate.year.toString().padLeft(4, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      controller.text = formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'O ITEM É PERECÍVEL?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: text80,
          ),
        ),
        const SizedBox(height: 12.0),
        Row(
          children: [
            CustomRadioButton<bool>(
              value: true,
              groupValue: _isPerishable,
              label: 'Sim',
              onChanged: _handlePerishableChange,
            ),
            const SizedBox(width: 24),
            CustomRadioButton<bool>(
              value: false,
              groupValue: _isPerishable,
              label: 'Não',
              onChanged: _handlePerishableChange,
            ),
          ],
        ),

        if (_isPerishable)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(color: coolGray, thickness: 1, height: 48),
              const Text(
                'LISTA DE LOTES',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: text80,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _lotControllers.length,
                itemBuilder: (context, index) {
                  return _buildLotInputRow(index);
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: CustomButton(
                  icon: Icons.add,
                  text: "Adicionar lote",
                  secondary: true,
                  widthPercent: 1.0,
                  onPressed: _addLot,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildLotInputRow(int index) {
    final lot = _lotControllers[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Stack(
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
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Obrigatório' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: CustomTextFormField(
                    upperLabel: '',
                    hintText: 'Validade',
                    controller: lot.dateController,
                    onTap: () => _selectDate(lot.dateController),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Obrigatório' : null,
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
                    onPressed: () => _removeLot(index),
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
