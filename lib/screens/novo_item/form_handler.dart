import 'package:flutter/material.dart';

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
  final initialQuantityController = TextEditingController();
  final minStockController = TextEditingController();

  List<ItemGroup> groupOptions = [];
  int? selectedGroupId;

  String? selectedGroup;

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório.';
    }
    return null;
  }

  String? validateGroup(int? value) {
    if (value == null) {
      return 'Selecione um grupo.';
    }
    return null;
  }


  void dispose() {
    nameController.dispose();
    recordNumberController.dispose();
    unitOfMeasureController.dispose();
    initialQuantityController.dispose();
    minStockController.dispose();
  }
}
