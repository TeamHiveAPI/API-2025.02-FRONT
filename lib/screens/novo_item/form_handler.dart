import 'package:flutter/material.dart';
import 'package:sistema_almox/config/permissions.dart';

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

  final expirationDateController = TextEditingController();
  bool isControlled = false;

  List<ItemGroup> groupOptions = [];
  int? selectedGroupId;

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  String? validateGroup(int? value) {
    if (value == null) {
      return 'Campo obrigatório';
    }
    return null;
  }

  String? validateExpirationDate(String? value, UserRole role) {
    final bool isPharmacyUser =
        role == UserRole.tenenteFarmacia || role == UserRole.soldadoFarmacia;

    if (isPharmacyUser && (value == null || value.isEmpty)) {
      return 'Campo obrigatório';
    }
    return null;
  }

  void dispose() {
    nameController.dispose();
    recordNumberController.dispose();
    unitOfMeasureController.dispose();
    initialQuantityController.dispose();
    minStockController.dispose();
    expirationDateController.dispose();
  }
}
