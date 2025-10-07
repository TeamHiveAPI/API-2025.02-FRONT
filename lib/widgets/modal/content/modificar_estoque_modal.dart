import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/item_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/modal/detalhe_card_modal.dart';

class ModifyStockModal extends StatefulWidget {
  final String ficha;

  const ModifyStockModal({super.key, required this.ficha});

  @override
  State<ModifyStockModal> createState() => _ModifyStockModalState();
}

class _ModifyStockModalState extends State<ModifyStockModal> {
  Map<String, dynamic>? _itemData;
  bool _isLoading = true;
  int _newQuantity = 0;

  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    final data = await ItemService.instance.fetchItemByFicha(widget.ficha);

    if (mounted) {
      final currentStock = data?['qtd_total'] ?? 0;
      setState(() {
        _itemData = data;
        _newQuantity = currentStock;
        _quantityController.text = _newQuantity.toString();
        _isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (!_isLoading && _itemData == null) {
      content = _buildErrorState();
    } else {
      content = _buildSuccessState();
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: content,
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
        DetailItemCard(
          isLoading: _isLoading,
          label: "Nº DA FICHA E NOME",
          value: displayValue,
        ),
        const SizedBox(height: 24),
        const Text(
          "NOVA QUANTIDADE",
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStepperButton(
              icon: Icons.remove,
              onTap: _isLoading ? null : _decrementQuantity,
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
                  enabled: !_isLoading,
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
              onTap: _isLoading ? null : _incrementQuantity,
            ),
          ],
        ),
        const SizedBox(height: 24),
        CustomButton(
          isLoadingInitialContent: _isLoading,
          text: 'Salvar Alteração',
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.pop(context, {
                    'item': _itemData,
                    'newQuantity': _newQuantity,
                  });
                },
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

  Widget _buildErrorState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
        const SizedBox(height: 16),
        const Text(
          'Item não encontrado',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: 'Escanear Novamente',
          onPressed: _fetchData,
          widthPercent: 1.0,
        ),
      ],
    );
  }
}
