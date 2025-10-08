import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/item_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/modal/detalhe_card_modal.dart';
import 'package:sistema_almox/widgets/snackbar.dart';

class ModifyNonPerishableStockModal extends StatefulWidget {
  final Map<String, dynamic> itemData;
  const ModifyNonPerishableStockModal({super.key, required this.itemData});

  @override
  State<ModifyNonPerishableStockModal> createState() =>
      _ModifyNonPerishableStockModalState();
}

class _ModifyNonPerishableStockModalState
    extends State<ModifyNonPerishableStockModal> {
  Map<String, dynamic>? _itemData;
  bool _isSaving = false;
  int _newQuantity = 0;
  int? _lotId;

  final TextEditingController _quantityController = TextEditingController();

  @override
  @override
  void initState() {
    super.initState();
    _itemData = widget.itemData;
    final currentStock = _itemData?['qtd_total'] ?? 0;
    _newQuantity = currentStock;
    _quantityController.text = _newQuantity.toString();

    final lotes = _itemData!['lotes'] as List?;
    if (lotes != null && lotes.isNotEmpty) {
      _lotId = lotes[0]['id'];
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      _newQuantity++;
      _quantityController.text = _newQuantity.toString();
    });
  }

  void _decrementQuantity() {
    if (_newQuantity > 0) {
      setState(() {
        _newQuantity--;
        _quantityController.text = _newQuantity.toString();
      });
    }
  }

  Future<void> _saveChanges() async {
  if (_isSaving) return;

  final navigator = Navigator.of(context);
  final currentContext = context;

  FocusScope.of(context).unfocus();
  setState(() {
    _isSaving = true;
  });

  try {
    final itemId = _itemData?['id'];
    if (itemId == null) throw 'ID do item não encontrado.';

    final Map<String, dynamic> payload = {
      'lotes': [
        {
          'id': _lotId,
          'qtd_atual': _newQuantity,
          'data_validade': null,
          'data_entrada': DateTime.now().toIso8601String().substring(0, 10),
        }
      ]
    };

    await ItemService.instance.updateItem(itemId, payload);

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
        const SizedBox(height: 24),
        const Text(
          "NOVA QUANTIDADE",
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStepperButton(
              icon: Icons.remove,
              onTap: _isSaving ? null : _decrementQuantity,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 56.0,
                decoration: BoxDecoration(
                  color: brightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _quantityController,
                  enabled: !_isSaving,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 0.0,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _newQuantity = int.tryParse(value) ?? 0;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildStepperButton(
              icon: Icons.add,
              onTap: _isSaving ? null : _incrementQuantity,
            ),
          ],
        ),
        const SizedBox(height: 24),
        CustomButton(
          isLoading: _isSaving,
          text: 'Salvar Alteração',
          onPressed: _isSaving ? null : _saveChanges,
        ),
      ],
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: brightGray,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, color: brandBlue),
      ),
    );
  }
}
