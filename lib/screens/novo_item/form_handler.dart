import 'package:flutter/material.dart';
import 'package:sistema_almox/widgets/lot_input_row.dart';

class ItemGroup {
  final int id;
  final String nome;
  ItemGroup({required this.id, required this.nome});
}

class RegisterItemFormHandler {
  final formKey = GlobalKey<FormState>();
  bool hasSubmitted = false;

  final nameController = TextEditingController();
  final recordNumberController = TextEditingController();
  final unitOfMeasureController = TextEditingController();
  final minStockController = TextEditingController();

  final initialQuantityController = TextEditingController();

  List<ItemGroup> groupOptions = [];
  int? selectedGroupId;
  bool isControlled = false;
  bool isPerishable = false;
  List<LotController> lotControllers = [];

  void dispose() {
    nameController.dispose();
    recordNumberController.dispose();
    unitOfMeasureController.dispose();
    minStockController.dispose();
    initialQuantityController.dispose();

    for (final controller in lotControllers) {
      controller.dispose();
    }
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }
}
