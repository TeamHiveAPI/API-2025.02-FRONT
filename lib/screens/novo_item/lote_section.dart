import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/lot_input_row.dart';
import 'package:sistema_almox/widgets/radio_button.dart';
import 'package:intl/intl.dart';

class LotManagementSection extends StatefulWidget {
  final void Function(bool isPerishable, List<LotController> lots) onChanged;
  final bool initialIsPerishable;
  final List<LotController>? initialLotes;

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
  late bool _isPerishable;
  final List<LotController> _lotControllers = [];

  @override
  void initState() {
    super.initState();
    _isPerishable = widget.initialIsPerishable;
    if (widget.initialLotes != null) {
      _lotControllers.addAll(widget.initialLotes!);
    }
  }

  @override
  void didUpdateWidget(covariant LotManagementSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialIsPerishable != oldWidget.initialIsPerishable) {
      setState(() {
        _isPerishable = widget.initialIsPerishable;
      });
    }

    if (widget.initialLotes != oldWidget.initialLotes) {
      setState(() {
        _lotControllers.clear();

        if (widget.initialLotes != null) {
          _lotControllers.addAll(widget.initialLotes!);
        }
      });
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
        _lotControllers.clear();
      }
    });
    widget.onChanged(_isPerishable, _lotControllers);
  }

  void _addLot() {
    setState(() {
      _lotControllers.add(LotController(initialQuantity: '', initialDate: ''));
    });
    widget.onChanged(_isPerishable, _lotControllers);
  }

  void _removeLot(int index) {
    setState(() {
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
      controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
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
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: text60,
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
                  return LotInputRow(
                    index: index,
                    lot: _lotControllers[index],
                    onRemove: () => _removeLot(index),
                    onSelectDate: _selectDate,
                  );
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
}
