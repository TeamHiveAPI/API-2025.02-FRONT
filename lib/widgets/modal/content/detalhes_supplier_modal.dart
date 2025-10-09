import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/supplier_service.dart';
import 'package:sistema_almox/widgets/snackbar.dart';

class DetalhesSupplierModal extends StatefulWidget {
  final int supplierId;
  const DetalhesSupplierModal({super.key, required this.supplierId});

  @override
  _DetalhesSupplierModalState createState() => _DetalhesSupplierModalState();
}

class _DetalhesSupplierModalState extends State<DetalhesSupplierModal> {
  Map<String, dynamic>? supplierData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSupplierDetails();
  }

  Future<void> _fetchSupplierDetails() async {
    final data = await SupplierService.instance.fetchSupplierById(widget.supplierId);
    if (data != null && mounted) {
      setState(() {
        supplierData = data;
        isLoading = false;
      });
    } else if (mounted) {
      showCustomSnackbar(context, 'Erro ao carregar detalhes do fornecedor.', isError: true);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (supplierData == null) {
      return const Center(child: Text('Nenhum dado encontrado.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nome: ${supplierData!['nome']}', style: const TextStyle(fontSize: 18, color: text80)),
          const SizedBox(height: 8),
          Text('CNPJ: ${supplierData!['cnpj']}', style: const TextStyle(fontSize: 16, color: text60)),
          const SizedBox(height: 8),
          Text('Contato: ${supplierData!['contato']}', style: const TextStyle(fontSize: 16, color: text60)),
        ],
      ),
    );
  }
}