import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_almox/services/item_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/lot_input_row.dart';
import 'package:sistema_almox/widgets/modal/detalhe_card_modal.dart';
import 'package:sistema_almox/widgets/snackbar.dart';

class ModifyPerishableStockModal extends StatefulWidget {
  final Map<String, dynamic> itemData;
  const ModifyPerishableStockModal({super.key, required this.itemData});

  @override
  State<ModifyPerishableStockModal> createState() =>
      _ModifyPerishableStockModalState();
}

class _ModifyPerishableStockModalState
    extends State<ModifyPerishableStockModal> {
  Map<String, dynamic>? _itemData;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();
  bool _hasSubmitted = false;

  final List<LotController> _lotControllers = [];

  @override
  void initState() {
    super.initState();
    _itemData = widget.itemData;

    final lotes = _itemData?['lotes'] as List?;
    if (lotes != null) {
      for (var loteData in lotes) {
        _lotControllers.add(
          LotController(
            id: loteData['id'],
            codigoLote: loteData['codigo_lote'],
            initialQuantity: (loteData['qtd_atual'] ?? 0).toString(),
            initialDate: loteData['data_validade'] != null
                ? DateFormat(
                    'dd/MM/yyyy',
                  ).format(DateTime.parse(loteData['data_validade']))
                : '',
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    for (var lot in _lotControllers) {
      lot.dispose();
    }
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;

    setState(() {
      _hasSubmitted = true;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final navigator = Navigator.of(context);
    final currentContext = context;
    FocusScope.of(context).unfocus();
    setState(() {
      _isSaving = true;
    });

    try {
      final itemId = _itemData?['id'];
      if (itemId == null) throw 'ID do item não encontrado.';

      final List<Map<String, dynamic>> lotsPayload = [];
      for (var lotCtrl in _lotControllers) {
        final dateParts = lotCtrl.dateController.text.split('/');
        final formattedDate = dateParts.length == 3
            ? '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}'
            : null;

        lotsPayload.add({
          'id': lotCtrl.id,
          'qtd_atual': int.tryParse(lotCtrl.quantityController.text),
          'data_validade': formattedDate,
          'data_entrada': DateTime.now().toIso8601String().substring(0, 10),
        });
      }

      await ItemService.instance.updateItem(itemId, {'lotes': lotsPayload});

      if (!mounted) return;
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      showCustomSnackbar(
        currentContext,
        'Erro ao salvar: ${e.toString()}',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _addLot() {
    setState(() {
      _lotControllers.add(LotController(initialQuantity: '', initialDate: ''));
    });
  }

  void _removeLot(int index) {
    setState(() {
      _lotControllers[index].dispose();
      _lotControllers.removeAt(index);
    });
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: _buildSuccessState(),
    );
  }

  Widget _buildSuccessState() {
    final nome = _itemData?['it_nome'] ?? '';
    final numFicha = _itemData?['it_num_ficha'] ?? '';
    final displayValue = '$numFicha - $nome';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DetailItemCard(label: "Nº DA FICHA E NOME", value: displayValue),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: Scrollbar(
            child: SingleChildScrollView(child: _buildPerishableSection()),
          ),
        ),
        if (_lotControllers.length > 2) const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                isLoading: _isSaving,
                icon: Icons.add,
                text: 'Salvar',
                onPressed: _isSaving ? null : _saveChanges,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: CustomButton(
                icon: Icons.add,
                text: "Novo lote",
                secondary: true,
                onPressed: _isSaving ? null : _addLot,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerishableSection() {
    return Form(
      key: _formKey,
      autovalidateMode: _hasSubmitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LISTA DE LOTES',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
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
        ],
      ),
    );
  }
}
