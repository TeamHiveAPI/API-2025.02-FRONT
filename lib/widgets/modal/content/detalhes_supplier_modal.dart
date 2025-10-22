import 'package:flutter/material.dart';
import 'package:sistema_almox/services/supplier_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/modal/detalhe_card_modal.dart';
import 'package:sistema_almox/widgets/snackbar.dart';

class DetalhesSupplierModal extends StatefulWidget {
  final int supplierId;
  const DetalhesSupplierModal({super.key, required this.supplierId});

  @override
  _DetalhesSupplierModalState createState() => _DetalhesSupplierModalState();
}

class _DetalhesSupplierModalState extends State<DetalhesSupplierModal> {
  Map<String, dynamic>? _supplierData;
  bool _isLoadingInitialContent = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await SupplierService.instance.fetchSupplierById(
        widget.supplierId,
      );
      if (mounted) {
        setState(() {
          _supplierData = data;
          _isLoadingInitialContent = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(
          context,
          'Erro ao carregar detalhes do fornecedor: $e',
          isError: true,
        );
        setState(() => _isLoadingInitialContent = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoadingInitialContent && _supplierData == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('Fornecedor não encontrado ou erro ao carregar.'),
        ),
      );
    }

    final supplierDataForButtons = _supplierData ?? {};
    final nome = _supplierData?['frn_nome'] ?? '';
    final cnpj = _supplierData?['frn_cnpj'] ?? '';
    final telefone = _supplierData?['frn_telefone'] ?? '';
    final email = _supplierData?['frn_email'] ?? '';

    final itemList = _supplierData?['frn_item'] as List<dynamic>?;
    final itemCount = itemList?.length ?? 0;
    final itemsValue = itemCount.toString();
    dynamic setoresValue = _supplierData?['frn_setor_id'];
    String setores = '';
    if (setoresValue is List<dynamic>) {
      setores = setoresValue.join(', ');
    } else if (setoresValue is String) {
      setores = setoresValue;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        DetailItemCard(
          isLoading: _isLoadingInitialContent,
          label: "NOME",
          value: nome,
        ),
        const SizedBox(height: 12),
        DetailItemCard(
          isLoading: _isLoadingInitialContent,
          label: "CNPJ",
          value: cnpj,
        ),
        const SizedBox(height: 12),
        DetailItemCard(
          isLoading: _isLoadingInitialContent,
          label: "TELEFONE",
          value: telefone,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DetailItemCard(
                isLoading: _isLoadingInitialContent,
                label: "ITENS",
                value: itemsValue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DetailItemCard(
                isLoading: _isLoadingInitialContent,
                label: "SETOR",
                value: setores,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DetailItemCard(
          isLoading: _isLoadingInitialContent,
          label: "E-MAIL",
          value: email,
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: "Editar",
          onPressed: _isLoadingInitialContent
              ? null
              : () {
                  Navigator.of(
                    context,
                  ).pop({'action': 'edit', 'data': supplierDataForButtons});
                },
          secondary: true,
          isFullWidth: true,
          customIcon: 'assets/icons/edit.svg',
          iconPosition: IconPosition.right,
        ),
      ],
    );
  }
}
